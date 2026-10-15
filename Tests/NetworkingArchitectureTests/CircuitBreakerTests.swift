import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// A clock the test moves by hand.
private final class ManualClock: Sendable {
    private let current = Locked(ContinuousClock.now)

    var now: ContinuousClock.Instant { current.withLock { $0 } }

    func advance(by duration: Duration) {
        current.withLock { $0 = $0.advanced(by: duration) }
    }
}

/// Rejects requests whose path ends in `rejected`, as an interceptor listed after the breaker.
private struct RejectingInterceptor: RequestInterceptor {
    func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        guard request.url?.path.hasSuffix("rejected") != true else {
            throw NetworkError.authenticationFailed(URLError(.userAuthenticationRequired))
        }
        return request
    }
}

@Suite("Circuit breaker")
struct CircuitBreakerTests {
    private func setUp(
        threshold: Int = 3,
        after: [any RequestInterceptor] = [],
        cache: (any ResponseCache)? = nil
    ) -> (NetworkClient, MockTransport, CircuitBreaker, ManualClock) {
        let clock = ManualClock()
        let breaker = CircuitBreaker(failureThreshold: threshold, resetTimeout: .seconds(30)) { clock.now }
        let transport = MockTransport()
        let client = NetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            configuration: .init(interceptors: [breaker] + after, retryPolicy: .none, cache: cache),
            transport: transport
        )
        return (client, transport, breaker, clock)
    }

    /// Opens a breaker with a threshold of 1 by failing one request to `x`, then lets the
    /// reset timeout pass, so the next request is the test request.
    private func openAndWait(_ client: NetworkClient, _ breaker: CircuitBreaker, _ clock: ManualClock) async throws {
        _ = try? await client.send(Endpoint<Void>.get("x"))
        guard case .open = await breaker.state else {
            Issue.record("Expected open")
            throw CancellationError()
        }
        clock.advance(by: .seconds(31))
    }

    private func isCircuitOpen(_ error: (any Error)?) -> Bool {
        guard case NetworkError.circuitOpen? = error as? NetworkError else { return false }
        return true
    }

    @Test func opensAfterConsecutiveFailuresAndFailsFast() async throws {
        let (client, transport, breaker, _) = setUp()
        transport.register(.get, "x", .status(503))
        for _ in 0..<3 {
            _ = try? await client.send(Endpoint<Void>.get("x"))
        }
        guard case .open = await breaker.state else {
            Issue.record("Expected open")
            return
        }
        let error = await #expect(throws: NetworkError.self) { try await client.send(Endpoint<Void>.get("x")) }
        #expect(isCircuitOpen(error))
        if case .circuitOpen(let wait)? = error {
            #expect(wait == .seconds(30))
        }
        #expect(transport.requests.count == 3)
    }

    @Test func clientErrorsAndSuccessesResetTheCount() async throws {
        let (client, transport, breaker, _) = setUp()
        transport.register(.get, "x", .status(500), .status(500), .status(404), .status(500), .status(500))
        for _ in 0..<5 {
            _ = try? await client.send(Endpoint<Void>.get("x"))
        }
        #expect(await breaker.state == .closed)
    }

    @Test func halfOpenLetsOneProbeThroughAndClosesOnSuccess() async throws {
        let (client, transport, breaker, clock) = setUp(threshold: 1)
        transport.register(.get, "x", .failure(.cannotConnectToHost), MockResponse(statusCode: 200).delayed(by: .milliseconds(200)))
        _ = try? await client.send(Endpoint<Void>.get("x"))
        clock.advance(by: .seconds(31))

        let probe = Task { try await client.send(Endpoint<Void>.get("x")) }
        try await Task.sleep(for: .milliseconds(50))
        #expect(await breaker.state == .halfOpen)
        let second = await #expect(throws: NetworkError.self) { try await client.send(Endpoint<Void>.get("x")) }
        #expect(isCircuitOpen(second))

        try await probe.value
        #expect(await breaker.state == .closed)
        try await client.send(Endpoint<Void>.get("x"))
        #expect(transport.requests.count == 3)
    }

    @Test func failedProbeOpensTheBreakerAgain() async throws {
        let (client, transport, breaker, clock) = setUp(threshold: 1)
        transport.register(.get, "x", .status(502))
        _ = try? await client.send(Endpoint<Void>.get("x"))
        clock.advance(by: .seconds(30))
        _ = try? await client.send(Endpoint<Void>.get("x"))
        guard case .open(let until) = await breaker.state else {
            Issue.record("Expected open")
            return
        }
        #expect(until == clock.now.advanced(by: .seconds(30)))
        #expect(transport.requests.count == 2)
    }

    @Test func resetClosesTheBreaker() async throws {
        let (client, transport, breaker, _) = setUp(threshold: 1)
        transport.register(.get, "x", .status(500), .status(200))
        _ = try? await client.send(Endpoint<Void>.get("x"))
        await breaker.reset()
        try await client.send(Endpoint<Void>.get("x"))
    }

    @Test func cachedAnswerToTheTestRequestLetsTheNextRequestTest() async throws {
        let (client, transport, breaker, clock) = setUp(threshold: 1, cache: MemoryResponseCache())
        transport.register(.get, "cached", try .json(["value": 1]))
        transport.register(.get, "x", .failure(.cannotConnectToHost), .status(200))
        let cached = Endpoint<Data>.get("cached").with(\.cachePolicy, .cacheFirst(maxAge: .seconds(3600)))
        _ = try await client.send(cached)
        try await openAndWait(client, breaker, clock)

        let fromCache = try await client.response(for: cached)
        #expect(fromCache.source == .cache)
        try await client.send(Endpoint<Void>.get("x"))
        #expect(await breaker.state == .closed)
        #expect(transport.requests.count == 3)
    }

    @Test func laterInterceptorRejectingTheTestRequestLetsTheNextRequestTest() async throws {
        let (client, transport, breaker, clock) = setUp(threshold: 1, after: [RejectingInterceptor()])
        transport.register(.get, "x", .failure(.cannotConnectToHost), .status(200))
        try await openAndWait(client, breaker, clock)

        let rejected = await #expect(throws: NetworkError.self) { try await client.send(Endpoint<Void>.get("rejected")) }
        guard case .authenticationFailed? = rejected else {
            Issue.record("Expected authenticationFailed, got \(String(describing: rejected))")
            return
        }
        #expect(await breaker.state == .halfOpen)
        try await client.send(Endpoint<Void>.get("x"))
        #expect(await breaker.state == .closed)
        #expect(transport.requests.count == 2)
    }

    @Test func requestsThatStartedBeforeTheTestRequestDoNotReleaseIt() async throws {
        let (client, transport, breaker, clock) = setUp(threshold: 1)
        transport.register(.get, "slow", MockResponse(statusCode: 200).delayed(by: .seconds(5)))
        transport.register(.get, "probe", MockResponse(statusCode: 200).delayed(by: .milliseconds(300)))
        transport.register(.get, "x", .failure(.cannotConnectToHost))
        let slow = Task { try await client.send(Endpoint<Void>.get("slow")) }
        try await Task.sleep(for: .milliseconds(50))
        try await openAndWait(client, breaker, clock)

        let probe = Task { try await client.send(Endpoint<Void>.get("probe")) }
        try await Task.sleep(for: .milliseconds(50))
        slow.cancel()
        _ = await slow.result
        #expect(await breaker.state == .halfOpen)
        let second = await #expect(throws: NetworkError.self) { try await client.send(Endpoint<Void>.get("x")) }
        #expect(isCircuitOpen(second))
        try await probe.value
        #expect(await breaker.state == .closed)
    }

    @Test func outOfRangeSettingsAreClamped() async {
        let breaker = CircuitBreaker(failureThreshold: -3, resetTimeout: .seconds(-10))
        #expect(breaker.failureThreshold == 1)
        #expect(breaker.resetTimeout == .zero)
    }
}
