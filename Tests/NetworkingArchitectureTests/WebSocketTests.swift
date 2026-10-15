import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// Collects the messages of a connection in the background.
private final class Inbox: @unchecked Sendable {
    private let lock = NSLock()
    private var messages: [WebSocketConnection.Message] = []
    private var ending: String?

    var received: [WebSocketConnection.Message] {
        lock.lock()
        defer { lock.unlock() }
        return messages
    }

    var end: String? {
        lock.lock()
        defer { lock.unlock() }
        return ending
    }

    func start(_ stream: AsyncThrowingStream<WebSocketConnection.Message, any Error>) -> Task<Void, Never> {
        Task {
            do {
                for try await message in stream {
                    append(message)
                }
                finish("finished")
            } catch {
                finish("failed")
            }
        }
    }

    private func append(_ message: WebSocketConnection.Message) {
        lock.lock()
        messages.append(message)
        lock.unlock()
    }

    private func finish(_ value: String) {
        lock.lock()
        ending = value
        lock.unlock()
    }

    /// Waits until `condition` holds, for at most five seconds.
    func waitFor(_ condition: @escaping @Sendable (Inbox) -> Bool) async throws {
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while !condition(self) {
            guard ContinuousClock.now < deadline else { throw CancellationError() }
            try await Task.sleep(for: .milliseconds(20))
        }
    }
}

@Suite("WebSocket", .serialized, .timeLimit(.minutes(1)))
struct WebSocketTests {
    private let fastReconnect = WebSocketConnection.Options(
        maximumReconnectAttempts: 2,
        backoff: RetryPolicy(baseDelay: .milliseconds(50), jitter: 0),
        pingInterval: .seconds(5)
    )

    @Test func echoesTextAndBinaryMessages() async throws {
        let server = try await LocalWebSocketServer()
        let socket = WebSocketConnection(url: server.url, options: fastReconnect)
        let inbox = Inbox()
        let reader = inbox.start(await socket.messages())
        try await socket.send(.text("hello"))
        try await socket.send(.data(Data([1, 2, 3])))
        try await inbox.waitFor { $0.received.count == 2 }
        #expect(inbox.received == [.text("hello"), .data(Data([1, 2, 3]))])
        #expect(await socket.state == .connected)
        await socket.close()
        await reader.value
        #expect(inbox.end == "finished")
    }

    @Test func reconnectsAfterTheConnectionDrops() async throws {
        let server = try await LocalWebSocketServer()
        let socket = WebSocketConnection(url: server.url, options: fastReconnect)
        let inbox = Inbox()
        let reader = inbox.start(await socket.messages())
        try await socket.send(.text("first"))
        try await inbox.waitFor { $0.received.count == 1 }
        try await socket.send(.text("drop"))
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while true {
            let state = await socket.state
            if server.connectionCount >= 2, state == .connected { break }
            guard ContinuousClock.now < deadline else { Issue.record("Did not reconnect"); return }
            try await Task.sleep(for: .milliseconds(20))
        }
        try await socket.send(.text("second"))
        try await inbox.waitFor { $0.received.count == 2 }
        #expect(inbox.received == [.text("first"), .text("second")])
        await socket.close()
        await reader.value
    }

    @Test func normalCloseByTheServerEndsTheStream() async throws {
        let server = try await LocalWebSocketServer()
        let socket = WebSocketConnection(url: server.url, options: fastReconnect)
        let inbox = Inbox()
        let reader = inbox.start(await socket.messages())
        try await socket.send(.text("close"))
        await reader.value
        #expect(inbox.end == "finished")
        #expect(server.connectionCount == 1)
        #expect(await socket.state == .closed)
        await #expect(throws: WebSocketConnection.NotConnected.self) { try await socket.send(.text("late")) }
    }

    @Test func givesUpWhenTheServerStaysUnreachable() async throws {
        let socket = WebSocketConnection(url: URL(string: "ws://127.0.0.1:9/socket")!, options: fastReconnect)
        let inbox = Inbox()
        let reader = inbox.start(await socket.messages())
        await reader.value
        #expect(inbox.end == "failed")
        #expect(await socket.state == .closed)
    }

    @Test func oversizedMessagesEndTheConnection() async throws {
        let server = try await LocalWebSocketServer()
        var options = fastReconnect
        options.reconnects = false
        options.maximumMessageSize = 16
        let socket = WebSocketConnection(url: server.url, options: options)
        let inbox = Inbox()
        let reader = inbox.start(await socket.messages())
        try await socket.send(.text(String(repeating: "x", count: 100)))
        await reader.value
        #expect(inbox.received.isEmpty)
        #expect(inbox.end == "failed")
    }

    @Test func aConsumerThatFallsBehindClosesTheConnection() async throws {
        let server = try await LocalWebSocketServer()
        var options = fastReconnect
        options.maximumBufferedMessages = 3
        let socket = WebSocketConnection(url: server.url, options: options)
        let stream = await socket.messages()
        // The connection may close because of the overflow before all ten are sent.
        for index in 1...10 {
            guard (try? await socket.send(.text("\(index)"))) != nil else { break }
        }
        // Read nothing until the echoes have piled up.
        try await Task.sleep(for: .milliseconds(500))
        var received: [WebSocketConnection.Message] = []
        do {
            for try await message in stream { received.append(message) }
            Issue.record("Expected bufferOverflow")
        } catch NetworkError.bufferOverflow(let limit) {
            #expect(limit == 3)
        }
        #expect(received == [.text("1"), .text("2"), .text("3")])
        #expect(await socket.state == .closed)
        #expect(server.connectionCount == 1)
    }

    @Test func clientWebSocketsUseTheBaseURLAndInterceptors() async throws {
        struct Token: RequestInterceptor {
            func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
                var request = request
                request.setValue("Bearer ws-token", forHTTPHeaderField: "Authorization")
                return request
            }
        }
        let server = try await LocalWebSocketServer()
        let client = NetworkClient(
            baseURL: URL(string: "http://127.0.0.1:\(server.port)")!,
            configuration: .init(interceptors: [Token()])
        )
        let socket = try client.webSocket(.get("socket"), options: fastReconnect)
        let inbox = Inbox()
        let reader = inbox.start(await socket.messages())
        try await socket.send(.text("ping"))
        try await inbox.waitFor { $0.received.count == 1 }
        #expect(server.authorizations == ["Bearer ws-token"])
        await socket.close()
        await reader.value
    }

    @Test func connectingDoesNotKeepACircuitBreakerHalfOpen() async throws {
        let server = try await LocalWebSocketServer()
        let opened = ContinuousClock.now
        let later = Locked(false)
        let breaker = CircuitBreaker(failureThreshold: 1, resetTimeout: .seconds(30)) {
            later.withLock { $0 } ? opened.advanced(by: .seconds(31)) : opened
        }
        let transport = MockTransport()
        transport.register(.get, "x", .failure(.cannotConnectToHost), .status(200))
        let client = NetworkClient(
            baseURL: URL(string: "http://127.0.0.1:\(server.port)")!,
            configuration: .init(interceptors: [breaker], retryPolicy: .none),
            transport: transport
        )
        _ = try? await client.send(Endpoint<Void>.get("x"))
        guard case .open = await breaker.state else {
            Issue.record("Expected open")
            return
        }
        later.withLock { $0 = true }

        let socket = try client.webSocket(.get("socket"), options: fastReconnect)
        let inbox = Inbox()
        let reader = inbox.start(await socket.messages())
        try await socket.send(.text("ping"))
        try await inbox.waitFor { $0.received.count == 1 }
        #expect(await breaker.state == .halfOpen)

        try await client.send(Endpoint<Void>.get("x"))
        #expect(await breaker.state == .closed)
        await socket.close()
        await reader.value
    }
}
