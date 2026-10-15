import Foundation

/// When and how long after a failure a request is sent again.
///
/// The default policy retries idempotent requests (`GET`, `PUT`, `DELETE`, …) up to two more
/// times after a timeout, a lost connection or a 408, 429, 500, 502, 503 or 504 response,
/// waiting 0.5 s and then 1 s, plus or minus 20 % jitter. A `Retry-After` header from the
/// server replaces the computed delay, up to ``maximumRetryAfter``.
///
/// ```swift
/// var policy = RetryPolicy.default
/// policy.maximumAttempts = 5
/// policy.retriesNonIdempotentRequests = true   // only if the server deduplicates POSTs
/// ```
public struct RetryPolicy: Sendable, Hashable {
    /// The most times a request is sent, including the first. Clamped to 1...10.
    public var maximumAttempts: Int {
        get { storedMaximumAttempts }
        set { storedMaximumAttempts = Self.clampAttempts(newValue) }
    }

    /// The delay before the first retry; later retries multiply it by ``multiplier``.
    public var baseDelay: Duration

    /// The longest computed delay between two attempts.
    public var maximumDelay: Duration

    /// How much each delay grows over the previous one. Values below 1 or not finite are
    /// treated as 1.
    public var multiplier: Double

    /// The share of the delay added or removed at random, from 0 to 1, so clients that
    /// failed together do not retry together. Values outside 0...1 are clamped.
    public var jitter: Double

    /// Status codes that are retried.
    public var retryableStatusCodes: Set<Int>

    /// Transport errors that are retried.
    public var retryableErrorCodes: Set<URLError.Code>

    /// Whether `POST`, `PATCH` and other non-idempotent requests are retried too.
    public var retriesNonIdempotentRequests: Bool

    /// The longest `Retry-After` delay that is honoured. A longer one ends the retries,
    /// so a request does not hang for minutes.
    public var maximumRetryAfter: Duration

    private var storedMaximumAttempts: Int

    /// Creates a policy. See the properties for what each value means.
    public init(
        maximumAttempts: Int = 3,
        baseDelay: Duration = .milliseconds(500),
        maximumDelay: Duration = .seconds(30),
        multiplier: Double = 2,
        jitter: Double = 0.2,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504],
        retryableErrorCodes: Set<URLError.Code> = [
            .timedOut, .networkConnectionLost, .notConnectedToInternet,
            .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed
        ],
        retriesNonIdempotentRequests: Bool = false,
        maximumRetryAfter: Duration = .seconds(60)
    ) {
        self.storedMaximumAttempts = Self.clampAttempts(maximumAttempts)
        self.baseDelay = baseDelay
        self.maximumDelay = maximumDelay
        self.multiplier = multiplier
        self.jitter = jitter
        self.retryableStatusCodes = retryableStatusCodes
        self.retryableErrorCodes = retryableErrorCodes
        self.retriesNonIdempotentRequests = retriesNonIdempotentRequests
        self.maximumRetryAfter = maximumRetryAfter
    }

    /// Three attempts with exponential backoff; see the type description.
    public static let `default` = RetryPolicy()

    /// Never retries.
    public static let none = RetryPolicy(maximumAttempts: 1)

    /// The upper bound for ``maximumAttempts``.
    public static let attemptLimit = 10

    /// Decides whether to retry after `error` on attempt number `attempt` (starting at 1).
    ///
    /// - Parameter random: Returns a number in 0...1 for the jitter; tests pass a fixed one.
    public func decision(
        for error: NetworkError,
        method: HTTPMethod,
        attempt: Int,
        random: () -> Double = { Double.random(in: 0...1) }
    ) -> RetryDecision {
        guard attempt < maximumAttempts, method.isIdempotent || retriesNonIdempotentRequests else {
            return .doNotRetry
        }
        switch error {
        case .transport(let urlError) where retryableErrorCodes.contains(urlError.code):
            return .retry(after: delay(forRetry: attempt, random: random), reason: .transientFailure)
        case .unacceptableStatusCode(let code, let response) where retryableStatusCodes.contains(code):
            if let header = response.headers["Retry-After"] {
                guard let serverDelay = RetryAfter.delay(header) else {
                    return .retry(after: delay(forRetry: attempt, random: random), reason: .transientFailure)
                }
                guard serverDelay <= maximumRetryAfter else { return .doNotRetry }
                return .retry(after: serverDelay, reason: .transientFailure)
            }
            return .retry(after: delay(forRetry: attempt, random: random), reason: .transientFailure)
        default:
            return .doNotRetry
        }
    }

    /// The backoff delay before retry number `retry` (1 for the first retry), without a
    /// `Retry-After` header. Never negative, never longer than ``maximumDelay``.
    public func delay(forRetry retry: Int, random: () -> Double = { Double.random(in: 0...1) }) -> Duration {
        let base = max(0, baseDelay.timeInterval)
        let ceiling = max(0, maximumDelay.timeInterval)
        let growth = multiplier.isFinite && multiplier >= 1 ? multiplier : 1
        let exponent = retry > 1 ? Double(retry - 1) : 0
        // pow can overflow to infinity for large exponents; min() below then picks the ceiling.
        let exponential = min(base * pow(growth, exponent), ceiling)
        let spread = jitter.isFinite ? min(max(jitter, 0), 1) : 0
        let unit = random()
        let factor = unit.isFinite ? min(max(unit, 0), 1) : 0.5
        let jittered = exponential * (1 + spread * (factor * 2 - 1))
        return Duration.clamped(seconds: min(jittered, ceiling), max: maximumDelay)
    }

    private static func clampAttempts(_ value: Int) -> Int {
        min(max(value, 1), attemptLimit)
    }
}

/// Reads the `Retry-After` header (RFC 9110, section 10.2.3).
enum RetryAfter {
    /// The delay the header asks for, or `nil` when it is neither a number of seconds nor an
    /// HTTP date. A date in the past means no delay.
    static func delay(_ value: String, now: Date = Date()) -> Duration? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty, trimmed.unicodeScalars.allSatisfy({ ("0"..."9").contains($0) }) {
            // A number too large for Int is still a valid header; treat it as "very long".
            guard let seconds = Int(trimmed), seconds < veryLongSeconds else { return .seconds(veryLongSeconds) }
            return .seconds(seconds)
        }
        guard let date = httpDate(trimmed) else { return nil }
        return Duration.clamped(seconds: date.timeIntervalSince(now), max: .seconds(veryLongSeconds))
    }

    /// About 31 years: longer than any delay a client would wait.
    private static let veryLongSeconds = 1_000_000_000

    private static func httpDate(_ text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        for format in ["EEE, dd MMM yyyy HH:mm:ss zzz", "EEEE, dd-MMM-yy HH:mm:ss zzz", "EEE MMM d HH:mm:ss yyyy"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }
}
