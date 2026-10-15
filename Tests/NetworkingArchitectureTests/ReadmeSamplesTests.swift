import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// Runs the README samples (ReadmeExamples.swift) against canned responses, so the README
/// shows code that both compiles and does what the text says.
@Suite("README samples", .timeLimit(.minutes(1)))
struct ReadmeSamplesTests {
    private let base = URL(string: "https://api.example.com/v1")!

    private func client(_ transport: MockTransport, cache: (any ResponseCache)? = nil) -> NetworkClient {
        NetworkClient(baseURL: base, configuration: .init(retryPolicy: .immediate, cache: cache), transport: transport)
    }

    @Test func apiEndpointsBuildTheDocumentedRequests() async throws {
        let transport = MockTransport { request in
            request.httpMethod == "DELETE" ? .status(204) : try .json(User(id: 7, name: "Ada"))
        }
        let client = client(transport)
        _ = try await client.send(API.user(named: "ada?admin=1"))
        _ = try await client.send(API.createUser(NewUser(name: "Grace")))
        try await client.send(API.deleteUser(id: 7))
        #expect(transport.requests.map { "\($0.httpMethod!) \($0.url!.absoluteString)" } == [
            "GET https://api.example.com/v1/users/by-name/ada%3Fadmin%3D1",
            "POST https://api.example.com/v1/users",
            "DELETE https://api.example.com/v1/users/7"
        ])
        #expect(transport.requests[1].httpBody == Data(#"{"name":"Grace"}"#.utf8))
    }

    @Test func loadUsersTurnsErrorsIntoStates() async throws {
        let transport = MockTransport()
        transport.register(.get, "users", .failure(.notConnectedToInternet))
        #expect(await loadUsers(with: client(transport)) == .offline)

        transport.register(.get, "users", .status(404))
        #expect(await loadUsers(with: client(transport)) == .notFound)

        transport.register(.get, "users", try .json([User(id: 1, name: "Ada")]))
        #expect(await loadUsers(with: client(transport)) == .loaded([User(id: 1, name: "Ada")]))
    }

    @Test func cachedUsersComeFromTheCacheTheSecondTime() async throws {
        let transport = MockTransport()
        transport.register(.get, "users", try .json([User(id: 1, name: "Ada")]))
        let client = client(transport, cache: MemoryResponseCache())
        #expect(try await cachedUsers(with: client).source == .network)
        #expect(try await cachedUsers(with: client).source == .cache)
        #expect(transport.requests.count == 1)
    }

    @Test func uploadPhotoSendsAMultipartBody() async throws {
        let transport = MockTransport()
        transport.register(.post, "photos", .text(#"{"id":42}"#))
        let photo = try await uploadPhoto(Data([0xFF, 0xD8, 0xFF]), with: client(transport))
        #expect(photo.id == 42)
        let contentType = try #require(transport.requests.first?.value(forHTTPHeaderField: "Content-Type"))
        #expect(contentType.hasPrefix("multipart/form-data; boundary="))
    }

    @Test func watchPricesKeepsOnlyPriceEvents() async throws {
        let stream = """
        event: price
        data: {"symbol":"AAPL","price":231.5}

        event: heartbeat
        data: {}

        event: price
        data: {"symbol":"MSFT","price":512.25}


        """
        // The server sends the stream once, then answers the reconnection with 204 to end it.
        let transport = MockTransport()
        transport.register(.get, "prices/stream", .text(stream, headers: ["Content-Type": "text/event-stream"], chunks: 5), .status(204))
        let updates = try await watchPrices(with: client(transport))
        #expect(updates.map(\.symbol) == ["AAPL", "MSFT"])
        #expect(updates.map(\.price) == [231.5, 512.25])
    }

    @Test func viewerLoginReadsTheGraphQLData() async throws {
        let transport = MockTransport()
        transport.register(.post, "graphql", .text(#"{"data":{"viewer":{"login":"muhittincamdali"}}}"#))
        #expect(try await viewerLogin(with: client(transport)) == "muhittincamdali")
    }

    @Test func testClientRetriesTheScripted503() async throws {
        let (client, transport) = try makeTestClient()
        let users = try await client.send(API.users(page: 1))
        #expect(users == [User(id: 1, name: "Ada")])
        #expect(transport.requests.count == 2)
    }
}
