import Foundation

/// Stops sending requests to a service that keeps failing, and tries again after a pause.
///
/// After `failureThreshold` consecutive failures (no response, or a `5xx` status) the
/// breaker *opens*: requests fail at once with ``NetworkError/circuitOpen(retryAfter:)``
/// instead of waiting for a server that is down, which also gives the server room to recover.
/// After `resetTimeout` it lets one request through (*half-open*). If that request succeeds
/// the breaker *closes* and traffic resumes; if it fails the breaker opens again.
///
/// ```swift
/// var configuration = NetworkClient.Configuration()
/// configuration.interceptors = [CircuitBreaker(failureThreshold: 5, resetTimeout: .seconds(30))]
/// ```
///
/// A `4xx` response counts as a success: the server is up and answered. A test request that
/// ends without an answer about the service (it was cancelled, a cached response answered it,
/// or a later interceptor stopped it) lets the next request test the service instead.
public actor CircuitBreaker: RequestInterceptor {
    /// The state of the breaker.
    public enum State: Sendable, Equatable {
        /// Requests pass.
        case closed
        /// Requests fail at once until the given time.
        case open(until: ContinuousClock.Instant)
        /// One request is let through to test the service.
        case halfOpen
    }

    /// The number of consecutive failures that opens the breaker.
    public nonisolated let failureThreshold: Int

    /// How long the breaker stays open before letting a test request through.
    public nonisolated let resetTimeout: Duration

    /// The current state.
    public private(set) var state: State = .closed

    private var consecutiveFailures = 0
    /// The ``RequestContext/id`` of the request let through while half-open, until it ends.
    private var probe: UUID?
    private let now: @Sendable () -> ContinuousClock.Instant

    /// Creates a breaker.
    ///
    /// - Parameters:
    ///   - failureThreshold: Consecutive failures that open the breaker, at least 1.
    ///   - resetTimeout: How long it stays open. Negative values are treated as zero.
    ///   - now: The current time; tests pass a clock they control.
    public init(
        failureThreshold: Int = 5,
        resetTimeout: Duration = .seconds(30),
        now: @escaping @Sendable () -> ContinuousClock.Instant = { ContinuousClock.now }
    ) {
        self.failureThreshold = max(1, failureThreshold)
        self.resetTimeout = max(.zero, resetTimeout)
        self.now = now
    }

    public func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        switch state {
        case .closed:
            return request
        case .open(let until):
            let current = now()
            guard current >= until else {
                throw NetworkError.circuitOpen(retryAfter: until - current)
            }
            state = .halfOpen
            probe = context.id
            return request
        case .halfOpen:
            guard probe == nil || probe == context.id else {
                throw NetworkError.circuitOpen(retryAfter: resetTimeout)
            }
            probe = context.id
            return request
        }
    }

    public func didComplete(_ request: URLRequest, outcome: AttemptOutcome, context: RequestContext) async {
        switch outcome {
        case .notSent, .failure(.cancelled):
            // Says nothing about the service; when it was the test request, let the next
            // request test the service instead.
            if probe == context.id { probe = nil }
            return
        default:
            break
        }
        guard outcome.isServiceFailure else {
            consecutiveFailures = 0
            probe = nil
            state = .closed
            return
        }
        switch state {
        case .closed:
            consecutiveFailures += 1
            if consecutiveFailures >= failureThreshold {
                open()
            }
        case .halfOpen:
            open()
        case .open:
            break
        }
    }

    /// Closes the breaker, for example when the device comes back online.
    public func reset() {
        consecutiveFailures = 0
        probe = nil
        state = .closed
    }

    private func open() {
        state = .open(until: now().advanced(by: resetTimeout))
        probe = nil
        consecutiveFailures = 0
    }
}
