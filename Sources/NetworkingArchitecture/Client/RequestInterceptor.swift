import Foundation

/// Changes requests before they are sent and decides whether a failed request is sent again.
///
/// Interceptors run in the order they are listed in ``NetworkClient/Configuration``:
/// each ``adapt(_:context:)`` receives the request returned by the previous interceptor.
/// When a request fails, ``retry(_:dueTo:context:)`` is asked in the same order and the first
/// interceptor that does not answer ``RetryDecision/doNotRetry`` decides; if none does, the
/// client's ``RetryPolicy`` decides.
///
/// ```swift
/// struct APIKeyInterceptor: RequestInterceptor {
///     let key: String
///     let host: String
///
///     func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
///         // An endpoint whose path is a full URL can point at another server.
///         guard request.url?.scheme == "https", request.url?.host == host else { return request }
///         var request = request
///         request.setValue(key, forHTTPHeaderField: "X-API-Key")
///         return request
///     }
/// }
/// ```
public protocol RequestInterceptor: Sendable {
    /// Returns the request to send, for example with an extra header. Throwing stops the
    /// request with that error. Called again before every retry.
    func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest

    /// Decides whether to send the request again after `error`. Throwing stops the request
    /// with the thrown error instead of `error`.
    func retry(_ request: URLRequest, dueTo error: NetworkError, context: RequestContext) async throws -> RetryDecision

    /// Called after every attempt with its outcome: the status code, the error when no
    /// response arrived, or ``AttemptOutcome/notSent`` when the attempt ended before the
    /// client sent it. Every interceptor whose ``adapt(_:context:)`` returned is called, so
    /// one that holds something for the request, such as a ``CircuitBreaker``'s test request,
    /// can release it.
    func didComplete(_ request: URLRequest, outcome: AttemptOutcome, context: RequestContext) async
}

extension RequestInterceptor {
    public func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        request
    }

    public func retry(_ request: URLRequest, dueTo error: NetworkError, context: RequestContext) async throws -> RetryDecision {
        .doNotRetry
    }

    public func didComplete(_ request: URLRequest, outcome: AttemptOutcome, context: RequestContext) async {}
}

/// What happened to one attempt of a request.
public enum AttemptOutcome: Sendable {
    /// The server answered with this status code, accepted or not.
    case response(statusCode: Int)
    /// No response arrived.
    case failure(NetworkError)
    /// The client did not send the request itself, so the attempt says nothing about the
    /// service: a cached response answered it, a later interceptor's
    /// ``RequestInterceptor/adapt(_:context:)`` threw, or it was handed to a
    /// ``WebSocketConnection``, whose handshake the interceptors do not see.
    case notSent

    /// Whether the attempt counts as a failure of the service: no response, or a 5xx status.
    public var isServiceFailure: Bool {
        switch self {
        case .response(let statusCode): statusCode >= 500
        case .failure(let error): error.isServiceFailure
        case .notSent: false
        }
    }
}

extension Array where Element == any RequestInterceptor {
    /// Runs every interceptor's `adapt` in order. When one throws, the interceptors before it
    /// are told that the request was not sent, then the error is rethrown.
    func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var request = request
        for (index, interceptor) in enumerated() {
            do {
                request = try await interceptor.adapt(request, context: context)
            } catch {
                await self[..<index].complete(request, outcome: .notSent, context: context)
                throw error
            }
        }
        return request
    }
}

extension Collection where Element == any RequestInterceptor {
    /// Reports the outcome of an attempt to every interceptor, in order.
    func complete(_ request: URLRequest, outcome: AttemptOutcome, context: RequestContext) async {
        for interceptor in self {
            await interceptor.didComplete(request, outcome: outcome, context: context)
        }
    }
}

extension NetworkError {
    var isServiceFailure: Bool {
        switch self {
        case .transport: true
        case .unacceptableStatusCode(let code, _): code >= 500
        default: false
        }
    }
}

/// Whether a failed request is sent again.
public enum RetryDecision: Sendable, Hashable {
    /// Fail with the error.
    case doNotRetry
    /// Send the request again after `delay`, which is clamped to 0 seconds...24 hours.
    /// `reason` is counted in ``RequestContext/retryCount(for:)``.
    case retry(after: Duration, reason: RetryReason)
}

/// Why a request was retried. Interceptors use it to limit their own retries.
public struct RetryReason: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral {
    /// The name of the reason.
    public let rawValue: String

    /// Creates a reason with a name of your own, such as `"rateLimited"`.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// A temporary failure, such as a timeout or a 503, retried by ``RetryPolicy``.
    public static let transientFailure: RetryReason = "transientFailure"
    /// The credentials were refreshed after a 401, by ``BearerTokenAuthenticator``.
    public static let authentication: RetryReason = "authentication"
}

/// What the interceptors know about the request they are handling.
public struct RequestContext: Sendable {
    /// Identifies the request across its attempts.
    public let id: UUID

    /// The number of the current attempt, starting at 1.
    public internal(set) var attempt: Int

    /// The endpoint's retry policy, or the client's when the endpoint has none.
    public let retryPolicy: RetryPolicy

    private var retries: [RetryReason: Int] = [:]

    init(retryPolicy: RetryPolicy) {
        self.id = UUID()
        self.attempt = 1
        self.retryPolicy = retryPolicy
    }

    /// How many times the request has been retried for `reason`.
    public func retryCount(for reason: RetryReason) -> Int {
        retries[reason, default: 0]
    }

    mutating func recordRetry(_ reason: RetryReason) {
        retries[reason, default: 0] += 1
        attempt += 1
    }
}
