import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// Counts refreshes and can pause them, for the concurrency tests.
private actor RefreshServer {
    private(set) var refreshCount = 0
    private var nextToken: Int = 1
    var failure: (any Error)?
    var pause: Duration = .zero

    func refresh(_ token: BearerToken) async throws -> BearerToken {
        refreshCount += 1
        if pause > .zero {
            try await Task.sleep(for: pause)
        }
        if let failure { throw failure }
        defer { nextToken += 1 }
        return BearerToken(accessToken: "fresh-\(nextToken)", refreshToken: "r")
    }

    func setFailure(_ error: (any Error)?) { failure = error }
    func setPause(_ duration: Duration) { pause = duration }
}

@Suite("Bearer token authentication")
struct BearerTokenAuthenticatorTests {
    private let api = URL(string: "https://api.example.com")!

    /// A server that accepts only tokens starting with "fresh".
    private func strictServer() -> MockTransport {
        MockTransport { request in
            let header = request.value(forHTTPHeaderField: "Authorization") ?? ""
            return header.hasPrefix("Bearer fresh") ? .text("ok") : .status(401)
        }
    }

    private func client(_ transport: MockTransport, _ authenticator: BearerTokenAuthenticator) -> NetworkClient {
        NetworkClient(
            baseURL: api,
            configuration: .init(interceptors: [authenticator], retryPolicy: .immediate),
            transport: transport
        )
    }

    private func authenticator(
        _ server: RefreshServer,
        token: BearerToken? = BearerToken(accessToken: "stale", refreshToken: "r"),
        hosts: Set<String> = ["api.example.com"],
        onChange: (@Sendable (BearerToken?) -> Void)? = nil
    ) -> BearerTokenAuthenticator {
        BearerTokenAuthenticator(token: token, allowedHosts: hosts, onTokenChange: onChange) { stale in
            try await server.refresh(stale)
        }
    }

    @Test func refreshesAfterA401AndRetriesOnce() async throws {
        let server = RefreshServer()
        let transport = strictServer()
        let changes = EventLog()
        let auth = authenticator(server) { changes.append($0?.accessToken ?? "nil") }
        let text = try await client(transport, auth).send(Endpoint<Data>.get("me"))
        #expect(String(decoding: text, as: UTF8.self) == "ok")
        #expect(await server.refreshCount == 1)
        #expect(transport.requests.map { $0.value(forHTTPHeaderField: "Authorization") } == ["Bearer stale", "Bearer fresh-1"])
        #expect(changes.all == ["fresh-1"])
        #expect(await auth.currentToken?.accessToken == "fresh-1")
    }

    @Test func concurrent401sShareOneRefresh() async throws {
        let server = RefreshServer()
        await server.setPause(.milliseconds(100))
        let transport = strictServer()
        let client = client(transport, authenticator(server))
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<20 {
                group.addTask { _ = try await client.send(Endpoint<Data>.get("items/\(index)")) }
            }
            try await group.waitForAll()
        }
        #expect(await server.refreshCount == 1)
        // Every request was sent at most twice: once with the stale token, once with the new one.
        #expect(transport.requests.count <= 40)
        #expect(transport.requests.filter { $0.value(forHTTPHeaderField: "Authorization") == "Bearer fresh-1" }.count == 20)
    }

    @Test func aStill401AfterRefreshIsThrownWithoutLooping() async throws {
        let server = RefreshServer()
        let transport = MockTransport()
        transport.register(.get, "admin", .status(401))
        let error = await #expect(throws: NetworkError.self) {
            try await client(transport, authenticator(server)).send(Endpoint<Data>.get("admin"))
        }
        #expect(error?.statusCode == 401)
        #expect(await server.refreshCount == 1)
        #expect(transport.requests.count == 2)
    }

    @Test func failedRefreshThrowsAuthenticationFailed() async throws {
        struct RefreshRejected: Error {}
        let server = RefreshServer()
        await server.setFailure(RefreshRejected())
        let error = await #expect(throws: NetworkError.self) {
            try await client(strictServer(), authenticator(server)).send(Endpoint<Data>.get("me"))
        }
        guard case .authenticationFailed(let underlying)? = error else {
            Issue.record("Expected authenticationFailed, got \(String(describing: error))")
            return
        }
        #expect(underlying is RefreshRejected)
    }

    @Test func expiringTokenIsRefreshedBeforeSending() async throws {
        let server = RefreshServer()
        let transport = strictServer()
        let expiring = BearerToken(accessToken: "old", refreshToken: "r", expiresAt: Date().addingTimeInterval(5))
        _ = try await client(transport, authenticator(server, token: expiring)).send(Endpoint<Data>.get("me"))
        #expect(transport.requests.count == 1)
        #expect(transport.requests.first?.value(forHTTPHeaderField: "Authorization") == "Bearer fresh-1")
    }

    @Test func tokenIsOnlySentToAllowedHosts() async throws {
        let server = RefreshServer()
        let transport = MockTransport { _ in .text("ok") }
        let client = client(transport, authenticator(server, token: BearerToken(accessToken: "secret"), hosts: ["*.example.com"]))
        let urls = [
            "https://api.example.com/a", "https://EXAMPLE.com/b", "https://cdn.eu.example.com/c",
            "https://evil-example.com/d", "https://example.com.evil.net/e", "https://other.org/f",
            "http://api.example.com/g", "HTTP://example.com/h", "wss://api.example.com/i", "ws://api.example.com/j"
        ]
        for url in urls {
            _ = try await client.send(Endpoint<Data>.get(url))
        }
        let sent = transport.requests.map { $0.value(forHTTPHeaderField: "Authorization") != nil }
        #expect(sent == [true, true, true, false, false, false, false, false, true, false])
    }

    @Test func a401OverPlainHTTPDoesNotRefresh() async throws {
        let server = RefreshServer()
        let transport = MockTransport { _ in .status(401) }
        let client = client(transport, authenticator(server, token: BearerToken(accessToken: "secret")))
        _ = try? await client.send(Endpoint<Data>.get("http://api.example.com/me"))
        #expect(transport.requests.count == 1)
        #expect(transport.requests.first?.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(await server.refreshCount == 0)
    }

    @Test func requestWithoutTokenIsSentUnauthenticated() async throws {
        let server = RefreshServer()
        let transport = MockTransport { _ in .status(401) }
        _ = try? await client(transport, authenticator(server, token: nil)).send(Endpoint<Data>.get("me"))
        #expect(transport.requests.first?.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(await server.refreshCount == 0)
    }

    @Test func signingOutDuringARefreshKeepsTheTokenRemoved() async throws {
        let server = RefreshServer()
        await server.setPause(.milliseconds(200))
        let auth = authenticator(server)
        let client = client(strictServer(), auth)
        let request = Task { try await client.send(Endpoint<Data>.get("me")) }
        try await Task.sleep(for: .milliseconds(50))
        await auth.setToken(nil)
        let result = await request.result
        #expect(await auth.currentToken == nil)
        guard case .failure(NetworkError.authenticationFailed(let underlying)) = result else {
            Issue.record("Expected authenticationFailed, got \(result)")
            return
        }
        #expect(underlying is BearerTokenAuthenticator.SignedOut)
    }

    @Test func expiryUsesTheLeeway() {
        let now = Date(timeIntervalSince1970: 1_000)
        let token = BearerToken(accessToken: "a", expiresAt: now.addingTimeInterval(20))
        #expect(token.expires(within: .seconds(30), now: now))
        #expect(!token.expires(within: .seconds(10), now: now))
        #expect(!BearerToken(accessToken: "a").expires(within: .seconds(3_600), now: now))
    }
}
