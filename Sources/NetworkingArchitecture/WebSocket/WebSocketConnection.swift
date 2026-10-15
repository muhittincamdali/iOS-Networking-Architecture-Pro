import Foundation

/// A WebSocket that reconnects with backoff, keeps itself alive with pings, and delivers
/// messages as an async sequence.
///
/// ```swift
/// let socket = try client.webSocket(.get("wss://api.example.com/live"))
/// Task {
///     for try await message in await socket.messages() {
///         if case .text(let text) = message { print(text) }
///     }
/// }
/// try await socket.send(.text("subscribe:prices"))
/// ```
///
/// The connection opens when you call ``messages()``. When it drops, it reconnects after a
/// backoff delay (with jitter) up to ``Options/maximumReconnectAttempts`` times in a row; a
/// close by the server with code 1000 (normal) or 1008 (policy violation) ends the stream
/// instead. Each reconnection builds the request again, so a refreshed token is used.
///
/// On watchOS, URLSession only allows WebSocket connections in apps with an active audio
/// session; see Apple's TN3135.
public actor WebSocketConnection {
    /// A message received or sent.
    public enum Message: Sendable, Hashable {
        case text(String)
        case data(Data)
    }

    /// The state of the connection.
    public enum State: Sendable, Hashable {
        case idle
        case connecting
        case connected
        /// Waiting before reconnection attempt number `attempt` (starting at 1).
        case reconnecting(attempt: Int)
        case closed
    }

    /// Settings for reconnection, keep-alive and message size.
    public struct Options: Sendable, Hashable {
        /// Whether to reconnect after the connection drops.
        public var reconnects: Bool
        /// Reconnection attempts in a row before the stream ends with the error.
        public var maximumReconnectAttempts: Int
        /// The backoff between reconnection attempts.
        public var backoff: RetryPolicy
        /// How often a ping checks that the connection is alive; `nil` sends none.
        public var pingInterval: Duration?
        /// The largest message accepted, in bytes; a larger one closes the connection.
        public var maximumMessageSize: Int

        public init(
            reconnects: Bool = true,
            maximumReconnectAttempts: Int = 5,
            backoff: RetryPolicy = RetryPolicy(baseDelay: .seconds(1), maximumDelay: .seconds(30)),
            pingInterval: Duration? = .seconds(25),
            maximumMessageSize: Int = 1_048_576
        ) {
            self.reconnects = reconnects
            self.maximumReconnectAttempts = max(0, maximumReconnectAttempts)
            self.backoff = backoff
            self.pingInterval = pingInterval.map { max(.milliseconds(100), $0) }
            self.maximumMessageSize = max(1, maximumMessageSize)
        }
    }

    /// The error thrown by ``send(_:)`` when the connection is closed.
    public struct NotConnected: Error, Sendable {}

    /// The current state.
    public private(set) var state: State = .idle {
        didSet { resumeWaiters() }
    }

    /// The settings.
    public nonisolated let options: Options

    private let session: URLSession
    private let makeRequest: @Sendable () async throws -> URLRequest
    private var task: URLSessionWebSocketTask?
    private var runner: Task<Void, Never>?
    private var continuation: AsyncThrowingStream<Message, any Error>.Continuation?
    private var closedByClient = false
    private var generation = 0
    private var connectedThisAttempt = false
    private var waiters: [CheckedContinuation<Void, any Error>] = []

    /// Creates a connection that builds its request with `makeRequest` before every
    /// connection attempt.
    public init(
        session: URLSession = .shared,
        options: Options = Options(),
        makeRequest: @escaping @Sendable () async throws -> URLRequest
    ) {
        self.session = session
        self.options = options
        self.makeRequest = makeRequest
    }

    /// Creates a connection to `url`.
    public init(url: URL, session: URLSession = .shared, options: Options = Options()) {
        self.init(session: session, options: options) { URLRequest(url: url) }
    }

    /// Opens the connection and returns the messages it receives. Call it once; a second
    /// call finishes the first stream and starts a new connection.
    public func messages() -> AsyncThrowingStream<Message, any Error> {
        let (stream, continuation) = AsyncThrowingStream<Message, any Error>.makeStream()
        stop()
        closedByClient = false
        generation += 1
        let current = generation
        self.continuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.streamEnded(generation: current) }
        }
        runner = Task { await run() }
        return stream
    }

    /// Sends a message. While the connection is being opened or reopened, waits for it.
    ///
    /// - Throws: ``NotConnected`` when the connection is closed or ``messages()`` was not
    ///   called, or the send error.
    public func send(_ message: Message) async throws {
        try await waitUntilConnected()
        guard let task else { throw NotConnected() }
        switch message {
        case .text(let text): try await task.send(.string(text))
        case .data(let data): try await task.send(.data(data))
        }
    }

    /// Closes the connection and finishes the message stream.
    public func close(code: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        closedByClient = true
        task?.cancel(with: code, reason: nil)
        stop()
        state = .closed
    }

    /// Returns once the connection is open; throws ``NotConnected`` when it closes first.
    public func waitUntilConnected() async throws {
        switch state {
        case .connected: return
        case .idle, .closed: throw NotConnected()
        case .connecting, .reconnecting:
            try await withCheckedThrowingContinuation { waiters.append($0) }
        }
    }

    private func resumeWaiters() {
        switch state {
        case .connected:
            let ready = waiters
            waiters.removeAll()
            ready.forEach { $0.resume() }
        case .closed, .idle:
            let failed = waiters
            waiters.removeAll()
            failed.forEach { $0.resume(throwing: NotConnected()) }
        case .connecting, .reconnecting:
            break
        }
    }

    private func streamEnded(generation ended: Int) {
        // Only the consumer of the current stream ending its iteration closes the socket.
        if ended == generation, state != .closed {
            close()
        }
    }

    private func stop() {
        runner?.cancel()
        runner = nil
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
        continuation?.finish()
        continuation = nil
    }

    private func run() async {
        var failures = 0
        while !Task.isCancelled, !closedByClient {
            state = failures == 0 ? .connecting : .reconnecting(attempt: failures)
            connectedThisAttempt = false
            let outcome: (any Error)?
            do {
                let request = try await makeRequest()
                let task = session.webSocketTask(with: request)
                task.maximumMessageSize = options.maximumMessageSize
                self.task = task
                task.resume()
                outcome = await receive(on: task)
            } catch {
                outcome = error
            }
            guard !Task.isCancelled, !closedByClient else { break }
            // A connection that opened resets the count; only failures in a row add up.
            if connectedThisAttempt { failures = 0 }
            let closeCode = task?.closeCode ?? .invalid
            task = nil
            if closeCode == .normalClosure || closeCode == .policyViolation {
                continuation?.finish()
                break
            }
            failures += 1
            guard options.reconnects, failures <= options.maximumReconnectAttempts else {
                continuation?.finish(throwing: NetworkError(outcome ?? URLError(.networkConnectionLost)))
                break
            }
            state = .reconnecting(attempt: failures)
            let delay = options.backoff.delay(forRetry: failures)
            try? await Pause.sleep(for: delay)
        }
        state = .closed
        continuation = nil
    }

    /// Receives until the connection ends and returns the error that ended it.
    private func receive(on task: URLSessionWebSocketTask) async -> (any Error)? {
        let pinger = startPinging(task)
        defer { pinger?.cancel() }
        do {
            // The first message or pong confirms the handshake.
            while true {
                let message = try await task.receive()
                markConnected(task)
                switch message {
                case .string(let text): continuation?.yield(.text(text))
                case .data(let data): continuation?.yield(.data(data))
                @unknown default: break
                }
            }
        } catch {
            return error
        }
    }

    private func startPinging(_ task: URLSessionWebSocketTask) -> Task<Void, Never>? {
        let interval = options.pingInterval
        // An immediate ping confirms the connection without waiting for a message.
        return Task { [weak self] in
            var first = true
            while !Task.isCancelled {
                if !first {
                    guard let interval else { return }
                    try? await Pause.sleep(for: interval)
                    guard !Task.isCancelled else { return }
                }
                first = false
                let alive = await Self.ping(task)
                guard !Task.isCancelled else { return }
                if alive {
                    await self?.markConnected(task)
                } else {
                    task.cancel(with: .goingAway, reason: nil)
                    return
                }
            }
        }
    }

    private func markConnected(_ pinged: URLSessionWebSocketTask) {
        if pinged === task, state != .closed {
            connectedThisAttempt = true
            if state != .connected { state = .connected }
        }
    }

    private static func ping(_ task: URLSessionWebSocketTask) async -> Bool {
        await withCheckedContinuation { continuation in
            task.sendPing { error in continuation.resume(returning: error == nil) }
        }
    }
}

extension NetworkClient {
    /// Creates a WebSocket connection for `endpoint`.
    ///
    /// The path is resolved against the base URL like any endpoint, with `http` and `https`
    /// turned into `ws` and `wss`, and the client's interceptors adapt the request before
    /// every connection attempt (so an authenticator adds its token). Retries of the
    /// interceptors do not apply; ``WebSocketConnection/Options`` controls reconnection.
    public func webSocket(
        _ endpoint: Endpoint<Void>,
        session: URLSession = .shared,
        options: WebSocketConnection.Options = .init()
    ) throws -> WebSocketConnection {
        var request = try makeRequest(for: endpoint)
        if let url = request.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            switch components.scheme?.lowercased() {
            case "http": components.scheme = "ws"
            case "https": components.scheme = "wss"
            default: break
            }
            request.url = components.url
        }
        let interceptors = configuration.interceptors
        let prepared = request
        return WebSocketConnection(session: session, options: options) {
            var request = prepared
            let context = RequestContext(retryPolicy: .none)
            for interceptor in interceptors {
                request = try await interceptor.adapt(request, context: context)
            }
            return request
        }
    }
}
