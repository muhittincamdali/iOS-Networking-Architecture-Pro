import Foundation

/// Something that happened while a ``NetworkClient`` handled a request.
public enum NetworkEvent: Sendable {
    /// An attempt is about to be sent, after every interceptor adapted it.
    case willSend(URLRequest)
    /// The server answered. The status code may still be one the endpoint rejects.
    case didReceive(URLRequest, HTTPResponse<Data>, duration: Duration)
    /// The attempt failed without a usable response.
    case didFail(URLRequest, NetworkError, duration: Duration)
    /// The request will be sent again after `delay`.
    case willRetry(URLRequest, delay: Duration, reason: RetryReason)
}

/// Observes the requests of a ``NetworkClient``, for logging or metrics.
///
/// Monitors are called synchronously on the task that sends the request, so keep
/// ``handle(_:context:)`` short. ``NetworkLogger`` is a monitor.
public protocol NetworkEventMonitor: Sendable {
    /// Called for every event of every request.
    func handle(_ event: NetworkEvent, context: RequestContext)
}

/// A monitor that forwards every event to a closure.
public struct ClosureEventMonitor: NetworkEventMonitor {
    private let handler: @Sendable (NetworkEvent, RequestContext) -> Void

    /// Creates a monitor that calls `handler` for every event.
    public init(_ handler: @escaping @Sendable (NetworkEvent, RequestContext) -> Void) {
        self.handler = handler
    }

    public func handle(_ event: NetworkEvent, context: RequestContext) {
        handler(event, context)
    }
}
