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

    @Test func theDefaultReturnsACrossOriginRedirect() async throws {
        let (start, target, received) = try await servers()
        let client = NetworkClient(
            baseURL: start.url(""),
            configuration: .init(headers: ["X-API-Key": "k-123"], retryPolicy: .none),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral))
        )
        let response = try await client.response(for: Endpoint<Data>.get("start").with(\.acceptableStatusCodes, Set(200..<400)))
        withExtendedLifetime(target) {}
        #expect(URLSessionTransport(session: .shared).redirectPolicy == .followSameOrigin)
        #expect(response.statusCode == 302)
        #expect(received.withLock { $0.isEmpty })
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
        #expect(RedirectPolicy.followSameOrigin.request(redirecting: original, to: redirect) == nil)
        #expect(RedirectPolicy.follow.request(redirecting: original, to: redirect) != nil)
    }

    @Test func crossOriginRedirectsDropHeadersWhoseValueIsACredential() throws {
        let original = URLRequest(url: try #require(URL(string: "https://api.example.com/a")))
        var redirect = URLRequest(url: try #require(URL(string: "https://cdn.example.net/b")))
        redirect.setValue("Bearer x", forHTTPHeaderField: "X-Upstream")
        redirect.setValue("Token y", forHTTPHeaderField: "X-Forwarded-Auth-Header")
        redirect.setValue("https://api.example.com/cb?access_token=z", forHTTPHeaderField: "X-Return")
        redirect.setValue("t-1", forHTTPHeaderField: "X-Trace")
        let followed = try #require(RedirectPolicy.followSafely.request(redirecting: original, to: redirect))
        #expect(followed.value(forHTTPHeaderField: "X-Upstream") == nil)
        #expect(followed.value(forHTTPHeaderField: "X-Forwarded-Auth-Header") == nil)
        #expect(followed.value(forHTTPHeaderField: "X-Return") == nil)
        #expect(followed.value(forHTTPHeaderField: "X-Trace") == "t-1")
    }

    private func request(_ text: String, headers: [String: String] = [:], body: Data? = nil) throws -> URLRequest {
        var request = URLRequest(url: try #require(URL(string: text)))
        for (name, value) in headers { request.setValue(value, forHTTPHeaderField: name) }
        request.httpBody = body
        return request
    }

    private static let credentials = ["Authorization": "Bearer a", "Cookie": "s=1", "Proxy-Authorization": "Basic b", "X-Session-Id": "c"]

    @Test("A redirect to another host, another port or another scheme is not followed by default", arguments: [
        "https://cdn.example.net/b", "https://api.example.com:8443/b", "http://api.example.com/b", "wss://api.example.com/b",
    ])
    func crossOriginRedirectsStopByDefault(location: String) throws {
        let original = try request("https://api.example.com/a")
        let redirect = try request(location, headers: Self.credentials, body: Data("password=hunter2".utf8))
        #expect(RedirectPolicy.followSameOrigin.request(redirecting: original, to: redirect) == nil)
        #expect(RedirectPolicy.follow.request(redirecting: original, to: redirect) != nil)
    }

    @Test("Following safely drops credentials and the body on a redirect to another host or port", arguments: [
        "https://cdn.example.net/b", "https://api.example.com:8443/b", "https://API.example.com.evil.example/b",
    ])
    func crossOriginRedirectsLoseCredentialsAndBody(location: String) throws {
        let original = try request("https://api.example.com/a")
        let headers = Self.credentials.merging(["Content-Type": "application/x-www-form-urlencoded", "X-Trace": "t-1"]) { first, _ in first }
        let redirect = try request(location, headers: headers, body: Data("password=hunter2".utf8))
        let followed = try #require(RedirectPolicy.followSafely.request(redirecting: original, to: redirect))
        for name in Self.credentials.keys { #expect(followed.value(forHTTPHeaderField: name) == nil, "\(name)") }
        #expect(followed.httpBody == nil && followed.httpBodyStream == nil)
        #expect(followed.value(forHTTPHeaderField: "Content-Type") == nil)
        #expect(followed.value(forHTTPHeaderField: "X-Trace") == "t-1")
    }

    @Test("A redirect whose Location holds user info is refused by every policy but follow", arguments: [
        "https://user:pass@api.example.com/b", "https://user@api.example.com/b", "https://user:pass@cdn.example.net/b",
    ])
    func userInfoInLocationIsRefused(location: String) throws {
        let original = try request("https://api.example.com/a")
        let redirect = try request(location)
        #expect(RedirectPolicy.followSameOrigin.request(redirecting: original, to: redirect) == nil)
        #expect(RedirectPolicy.followSafely.request(redirecting: original, to: redirect) == nil)
        #expect(RedirectPolicy.doNotFollow.request(redirecting: original, to: redirect) == nil)
    }

    @Test func downgradesAreRefusedEvenToTheSameHost() throws {
        let original = try request("https://api.example.com/a")
        let redirect = try request("http://api.example.com:443/b")
        #expect(RedirectPolicy.followSameOrigin.request(redirecting: original, to: redirect) == nil)
        #expect(RedirectPolicy.followSafely.request(redirecting: original, to: redirect) == nil)
    }

    @Test func sameOriginRedirectsKeepEveryHeader() {
        let original = URLRequest(url: URL(string: "https://api.example.com/a")!)
        var redirect = URLRequest(url: URL(string: "https://API.example.com:443/b")!)
        redirect.setValue("k", forHTTPHeaderField: "X-API-Key")
        for policy in [RedirectPolicy.followSameOrigin, .followSafely] {
            let followed = policy.request(redirecting: original, to: redirect)
            #expect(followed?.value(forHTTPHeaderField: "X-API-Key") == "k")
        }
    }
}
