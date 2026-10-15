import Foundation

/// How ``NetworkClient/events(_:options:)`` reconnects.
public struct EventStreamOptions: Sendable, Hashable {
    /// Whether to reconnect when the connection ends or drops.
    public var reconnects: Bool

    /// The wait before reconnecting until the server sends a `retry:` field.
    public var defaultRetry: Duration

    /// The longest wait honoured, whatever the server asks for.
    public var maximumRetry: Duration

    /// How many times in a row a reconnection may fail before the stream ends with the error.
    /// A connection that delivers an event resets the count.
    public var maximumReconnectAttempts: Int

    /// The largest single event kept in memory. See ``ServerSentEventParser/maximumEventSize``.
    public var maximumEventSize: Int

    /// The most events kept while the code iterating the stream is busy. When more arrive,
    /// the stream ends with ``NetworkError/bufferOverflow(limit:)`` instead of growing memory
    /// without bound.
    public var maximumBufferedEvents: Int

    public init(
        reconnects: Bool = true,
        defaultRetry: Duration = .seconds(3),
        maximumRetry: Duration = .seconds(60),
        maximumReconnectAttempts: Int = 5,
        maximumEventSize: Int = 1_048_576,
        maximumBufferedEvents: Int = 1_000
    ) {
        self.reconnects = reconnects
        self.defaultRetry = max(.zero, defaultRetry)
        self.maximumRetry = max(.zero, maximumRetry)
        self.maximumReconnectAttempts = max(0, maximumReconnectAttempts)
        self.maximumEventSize = max(1, maximumEventSize)
        self.maximumBufferedEvents = max(1, maximumBufferedEvents)
    }
}

extension NetworkClient {
    /// Opens a server-sent events stream (`text/event-stream`) and returns its events as they
    /// arrive.
    ///
    /// ```swift
    /// for try await event in client.events(.get("notifications/stream")) {
    ///     let note = try event.decode(Notification.self)
    /// }
    /// ```
    ///
    /// The request goes through the client's interceptors, so authentication applies. When
    /// the connection ends or drops, the client waits for the server's `retry:` time (or
    /// ``EventStreamOptions/defaultRetry``) and reconnects with a `Last-Event-ID` header, as
    /// browsers do. A `204 No Content` answer ends the stream. Stop iterating, or cancel the
    /// task, to close the connection.
    public func events(
        _ endpoint: Endpoint<Void>,
        options: EventStreamOptions = EventStreamOptions()
    ) -> AsyncThrowingStream<ServerSentEvent, any Error> {
        let (stream, continuation) = AsyncThrowingStream<ServerSentEvent, any Error>.makeStream(
            bufferingPolicy: .bufferingOldest(options.maximumBufferedEvents)
        )
        let task = Task {
            do {
                try await runEventStream(endpoint, options: options) { event in
                    if case .dropped = continuation.yield(event) {
                        throw NetworkError.bufferOverflow(limit: options.maximumBufferedEvents)
                    }
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: NetworkError(error))
            }
        }
        continuation.onTermination = { _ in task.cancel() }
        return stream
    }

    private func runEventStream(
        _ endpoint: Endpoint<Void>,
        options: EventStreamOptions,
        emit: (ServerSentEvent) throws -> Void
    ) async throws {
        var base = try makeRequest(for: endpoint)
        base.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        base.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        var parser = ServerSentEventParser(maximumEventSize: options.maximumEventSize)
        // Connections in a row that delivered no event.
        var emptyConnections = 0

        while true {
            var request = base
            if !parser.lastEventID.isEmpty {
                request.setValue(parser.lastEventID, forHTTPHeaderField: "Last-Event-ID")
            }
            var delivered = false
            var failure: NetworkError?
            do {
                guard let chunks = try await openEventStream(request, endpoint: endpoint) else { return }
                for try await chunk in chunks {
                    for event in try parser.parse(chunk) {
                        delivered = true
                        try emit(event)
                    }
                }
            } catch let error as ServerSentEventParser.EventTooLarge {
                throw NetworkError.responseTooLarge(limit: error.limit)
            } catch NetworkError.bufferOverflow(let limit) {
                throw NetworkError.bufferOverflow(limit: limit)
            } catch {
                failure = NetworkError(error)
            }

            emptyConnections = delivered ? 0 : emptyConnections + 1
            if let failure, !failure.allowsEventStreamReconnect {
                throw failure
            }
            guard options.reconnects, emptyConnections <= options.maximumReconnectAttempts else {
                if let failure { throw failure }
                return
            }
            // A partial event from the dropped connection is discarded, as browsers do.
            parser = parser.restarted()
            let wait = min(parser.reconnectionTime ?? options.defaultRetry, options.maximumRetry)
            try await Pause.sleep(for: wait)
        }
    }

    /// Connects, letting the interceptors adapt the request and retry a rejected one (for
    /// example after refreshing a token). Returns `nil` for `204 No Content`.
    private func openEventStream(
        _ request: URLRequest,
        endpoint: Endpoint<Void>
    ) async throws -> AsyncThrowingStream<Data, any Error>? {
        var opened: AsyncThrowingStream<Data, any Error>?
        let streamEndpoint = endpoint.with(\.acceptableStatusCodes, [200, 204]).with(\.retryPolicy, RetryPolicy.none)
        let result = try await perform(request, endpoint: streamEndpoint) { adapted in
            let (response, stream) = try await self.transport.stream(adapted)
            opened = stream
            return (Data(), response)
        }
        guard result.response.statusCode != 204 else { return nil }
        let type = result.response.headers["Content-Type"]?.lowercased() ?? ""
        guard type.hasPrefix("text/event-stream") else {
            throw NetworkError.invalidResponse
        }
        return opened
    }
}

extension NetworkError {
    /// Whether an event stream that failed with this error reconnects. A 4xx answer, a
    /// response that is not an event stream, or an error a retry cannot fix end the stream.
    var allowsEventStreamReconnect: Bool {
        if case .invalidResponse = self { return false }
        if let statusCode, (400..<500).contains(statusCode) { return false }
        return isRetryable
    }
}
