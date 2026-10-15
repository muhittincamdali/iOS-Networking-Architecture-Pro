import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

@Suite("GraphQL")
struct GraphQLTests {
    struct HeroData: Decodable, Sendable, Equatable {
        struct Hero: Decodable, Sendable, Equatable { let name: String }
        let hero: Hero?
    }

    struct Variables: Encodable, Sendable { let episode: String }

    private func client(_ transport: MockTransport) -> NetworkClient {
        NetworkClient(baseURL: URL(string: "https://api.example.com")!, transport: transport)
    }

    @Test func postsTheQueryVariablesAndOperationName() async throws {
        let transport = MockTransport()
        transport.register(.post, "graphql", .text(#"{"data":{"hero":{"name":"R2-D2"}}}"#))
        let operation = GraphQLOperation<HeroData>(
            "query Hero($episode: Episode) { hero(episode: $episode) { name } }",
            variables: Variables(episode: "JEDI"),
            operationName: "Hero"
        )
        let data = try await client(transport).graphQL(operation)
        #expect(data == HeroData(hero: .init(name: "R2-D2")))

        let request = try #require(transport.requests.first)
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["query"] as? String == operation.query)
        #expect(json["operationName"] as? String == "Hero")
        #expect((json["variables"] as? [String: String]) == ["episode": "JEDI"])
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept")?.hasPrefix("application/graphql-response+json") == true)
    }

    @Test func operationsWithoutVariablesOmitTheKeys() async throws {
        let transport = MockTransport()
        transport.register(.post, "graphql", .text(#"{"data":{"hero":null}}"#))
        _ = try await client(transport).graphQL(GraphQLOperation<HeroData>("{ hero { name } }"))
        let body = try #require(transport.requests.first?.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json.keys.sorted() == ["query"])
    }

    @Test func errorsAreThrownWithPartialData() async throws {
        let transport = MockTransport()
        transport.register(.post, "graphql", .text("""
        {"data":{"hero":{"name":"Luke"}},
         "errors":[{"message":"friends unavailable","path":["hero","friends",1],
                    "locations":[{"line":2,"column":7}],"extensions":{"code":"UNAVAILABLE","retry":true}}]}
        """))
        do {
            _ = try await client(transport).graphQL(GraphQLOperation<HeroData>("{ hero { name friends { name } } }"))
            Issue.record("Expected a GraphQLFailure")
        } catch let failure as GraphQLFailure<HeroData> {
            #expect(failure.partialData == HeroData(hero: .init(name: "Luke")))
            let error = try #require(failure.errors.first)
            #expect(error.message == "friends unavailable")
            #expect(error.path == [.field("hero"), .field("friends"), .index(1)])
            #expect(error.locations == [.init(line: 2, column: 7)])
            #expect(error.code == "UNAVAILABLE")
        }
    }

    @Test func responseWithoutDataOrErrorsFails() async throws {
        let transport = MockTransport()
        transport.register(.post, "graphql", .text("{}"))
        await #expect(throws: GraphQLFailure<HeroData>.self) {
            try await client(transport).graphQL(GraphQLOperation<HeroData>("{ hero { name } }"))
        }
    }

    @Test func responseEndpointExposesDataAndErrorsTogether() async throws {
        let transport = MockTransport()
        transport.register(.post, "api/graphql", .text(#"{"data":null,"errors":[{"message":"nope"}]}"#))
        let response = try await client(transport).send(.graphQL(GraphQLOperation<HeroData>("{ hero { name } }"), path: "api/graphql"))
        #expect(response.data == nil)
        #expect(response.errors.map(\.message) == ["nope"])
        #expect(response.errors.first?.code == nil)
    }
}
