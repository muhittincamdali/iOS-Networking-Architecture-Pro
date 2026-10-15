import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// `Task.sleep(for: .seconds(Int64.max))` traps. These tests feed such delays through every
/// place the package waits; before the waits were clamped, each of them crashed the test run.
@Suite("Extreme delays", .timeLimit(.minutes(1)))
struct ExtremeDelayTests {
    private let huge = Duration.seconds(Int64.max)

    @Test func waitsAreClampedToADay() {
        #expect(Pause.clamped(huge) == .seconds(86_400))
        #expect(Pause.clamped(.seconds(-5)) == .zero)
        #expect(Pause.clamped(.milliseconds(250)) == .milliseconds(250))
    }

    @Test func interceptorAskingForAnEndlessDelayCanBeCancelled() async throws {
        struct Patient: RequestInterceptor {
            let delay: Duration
            func retry(_ request: URLRequest, dueTo error: NetworkError, context: RequestContext) async throws -> RetryDecision {
                .retry(after: delay, reason: "patient")
            }
        }
        let transport = MockTransport()
        transport.register(.get, "x", .status(500))
        let client = NetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            configuration: .init(interceptors: [Patient(delay: huge)]),
            transport: transport
        )
        let task = Task { try await client.send(Endpoint<Void>.get("x")) }
        try await Task.sleep(for: .milliseconds(100))
        task.cancel()
        guard case .failure(NetworkError.cancelled) = await task.result else {
            Issue.record("Expected cancelled")
            return
        }
    }

    @Test func eventStreamWithAnEndlessRetryCanBeCancelled() async throws {
        let transport = MockTransport { _ in
            .text("retry: 9223372036854775807\ndata: x\n\n", headers: ["Content-Type": "text/event-stream"])
        }
        let client = NetworkClient(baseURL: URL(string: "https://api.example.com")!, transport: transport)
        let options = EventStreamOptions(maximumRetry: huge)
        let task = Task {
            var count = 0
            for try await _ in client.events(.get("s"), options: options) { count += 1 }
            return count
        }
        try await Task.sleep(for: .milliseconds(200))
        task.cancel()
        _ = await task.result
        #expect(transport.requests.count == 1)
    }

    @Test func webSocketWithAnEndlessBackoffCanBeClosed() async throws {
        let options = WebSocketConnection.Options(
            backoff: RetryPolicy(baseDelay: huge, maximumDelay: huge),
            pingInterval: huge
        )
        let socket = WebSocketConnection(url: URL(string: "ws://127.0.0.1:9/socket")!, options: options)
        let stream = await socket.messages()
        let reader = Task { for try await _ in stream {} }
        // Polled rather than a fixed pause: on a busy machine the first attempt can take longer
        // to be refused.
        let deadline = ContinuousClock.now.advanced(by: .seconds(30))
        while ContinuousClock.now < deadline {
            if case .reconnecting = await socket.state { break }
            try await Task.sleep(for: .milliseconds(20))
        }
        guard case .reconnecting = await socket.state else {
            Issue.record("Expected to wait before reconnecting")
            return
        }
        await socket.close()
        _ = await reader.result
        #expect(await socket.state == .closed)
    }
}
