import Foundation
import Testing
@testable import NetworkingArchitecture

@Suite("Redirects", .serialized, .timeLimit(.minutes(1)))
struct RedirectPolicyTests {
    /// Starts a target server that records the headers it receives and a server that
    /// redirects to it, on another port and therefore another origin.
    private func servers() async throws -> (start: LocalHTTPServer, target: LocalHTTPServer, received: Locked<[[String: String]]>) {
        let received = Locked<[[String: String]]>([])
        let target = try await LocalHTTPServer { request in
            received.withLock { $0.append(request.headers) }
            return .body(Data("arrived".utf8))
        }
        let location = target.url("/landing").absoluteString
        let start = try await LocalHTTPServer { _ in
            LocalHTTPServer.Response(status: 302, headers: ["Location": location])
        }
        return (start, target, received)
    }

    private func send(to server: LocalHTTPServer, policy: RedirectPolicy) async throws -> HTTPResponse<Data> {
        let client = NetworkClient(
            baseURL: server.url(""),
            configuration: .init(headers: ["X-API-Key": "k-123", "X-Trace": "t-1"], retryPolicy: .none),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral), redirectPolicy: policy)
        )
        return try await client.response(for: Endpoint<Data>.get("start").with(\.acceptableStatusCodes, Set(200..<400)))
    }

    private func header(_ name: String, in headers: [String: String]?) -> String? {
        headers?.first { $0.key.caseInsensitiveCompare(name) == .orderedSame }?.value
    }

    @Test func safeRedirectsDropCredentialHeadersAcrossOrigins() async throws {
        let (start, target, received) = try await servers()
        let response = try await send(to: start, policy: .followSafely)
        withExtendedLifetime(target) {}
        #expect(response.value == Data("arrived".utf8))
        let headers = received.withLock { $0.first }
        #expect(header("X-API-Key", in: headers) == nil)
        #expect(header("X-Trace", in: headers) == "t-1")
    }

    @Test func plainFollowingForwardsCustomHeaders() async throws {
        let (start, target, received) = try await servers()
        _ = try await send(to: start, policy: .follow)
        withExtendedLifetime(target) {}
        #expect(header("X-API-Key", in: received.withLock { $0.first }) == "k-123")
    }

    @Test func doNotFollowReturnsTheRedirect() async throws {
        let (start, target, received) = try await servers()
        let response = try await send(to: start, policy: .doNotFollow)
        withExtendedLifetime(target) {}
        #expect(response.statusCode == 302)
        #expect(received.withLock { $0.isEmpty })
    }

    @Test func downgradesFromHTTPSAreRefused() {
        let original = URLRequest(url: URL(string: "https://api.example.com/a")!)
        let redirect = URLRequest(url: URL(string: "http://api.example.com/b")!)
        #expect(RedirectPolicy.followSafely.request(redirecting: original, to: redirect) == nil)
        #expect(RedirectPolicy.follow.request(redirecting: original, to: redirect) != nil)
    }

    @Test func sameOriginRedirectsKeepEveryHeader() {
        let original = URLRequest(url: URL(string: "https://api.example.com/a")!)
        var redirect = URLRequest(url: URL(string: "https://API.example.com:443/b")!)
        redirect.setValue("k", forHTTPHeaderField: "X-API-Key")
        let followed = RedirectPolicy.followSafely.request(redirecting: original, to: redirect)
        #expect(followed?.value(forHTTPHeaderField: "X-API-Key") == "k")
    }
}
