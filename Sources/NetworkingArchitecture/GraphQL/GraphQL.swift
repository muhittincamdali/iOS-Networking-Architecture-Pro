import Foundation

/// A GraphQL query or mutation and the type of its `data`.
///
/// ```swift
/// struct HeroData: Decodable, Sendable {
///     struct Hero: Decodable, Sendable { let name: String }
///     let hero: Hero
/// }
///
/// let operation = GraphQLOperation<HeroData>(
///     "query Hero($episode: Episode) { hero(episode: $episode) { name } }",
///     variables: ["episode": "JEDI"]
/// )
/// let data = try await client.graphQL(operation)
/// print(data.hero.name)
/// ```
public struct GraphQLOperation<Data: Decodable & Sendable>: Sendable {
    /// The query document.
    public var query: String

    /// The operation to run when the document defines several.
    public var operationName: String?

    private let encodeBody: @Sendable (JSONEncoder) throws -> Foundation.Data

    /// An operation without variables.
    public init(_ query: String, operationName: String? = nil) {
        self.query = query
        self.operationName = operationName
        self.encodeBody = { encoder in
            try encoder.encode(Body<Empty>(query: query, operationName: operationName, variables: nil))
        }
    }

    /// An operation with variables, encoded with the client's JSON encoder.
    public init<Variables: Encodable & Sendable>(_ query: String, variables: Variables, operationName: String? = nil) {
        self.query = query
        self.operationName = operationName
        self.encodeBody = { encoder in
            try encoder.encode(Body(query: query, operationName: operationName, variables: variables))
        }
    }

    /// The request body: `{"query": …, "operationName": …, "variables": …}`.
    func body() -> RequestBody {
        RequestBody(contentType: "application/json", encode: encodeBody)
    }

    private struct Body<Variables: Encodable>: Encodable {
        let query: String
        let operationName: String?
        let variables: Variables?

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(query, forKey: .query)
            try container.encodeIfPresent(operationName, forKey: .operationName)
            try container.encodeIfPresent(variables, forKey: .variables)
        }

        enum CodingKeys: String, CodingKey {
            case query, operationName, variables
        }
    }

    private struct Empty: Encodable {}
}

/// An error in a GraphQL response's `errors` list.
public struct GraphQLError: Error, Sendable, Hashable, Decodable {
    /// One step of the path to the field that failed.
    public enum PathComponent: Sendable, Hashable, Decodable {
        case field(String)
        case index(Int)

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let index = try? container.decode(Int.self) {
                self = .index(index)
            } else {
                self = .field(try container.decode(String.self))
            }
        }
    }

    /// A position in the query document.
    public struct Location: Sendable, Hashable, Decodable {
        /// The line, starting at 1.
        public let line: Int
        /// The column, starting at 1.
        public let column: Int
    }

    /// The description of the error.
    public let message: String

    /// The path to the field that failed, if the error belongs to one.
    public let path: [PathComponent]?

    /// Where in the query the error is.
    public let locations: [Location]?

    /// The `extensions.code` value many servers use to classify errors, such as
    /// `"UNAUTHENTICATED"`.
    public let code: String?

    private enum CodingKeys: String, CodingKey {
        case message, path, locations, extensions
    }

    private enum ExtensionKeys: String, CodingKey {
        case code
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        path = try container.decodeIfPresent([PathComponent].self, forKey: .path)
        locations = try container.decodeIfPresent([Location].self, forKey: .locations)
        let extensions = try? container.nestedContainer(keyedBy: ExtensionKeys.self, forKey: .extensions)
        code = try? extensions?.decodeIfPresent(String.self, forKey: .code)
    }
}

/// A GraphQL response: the data and any errors. Both can be present when part of a query
/// failed.
public struct GraphQLResponse<Data: Decodable & Sendable>: Sendable, Decodable {
    /// The result, or `nil` when the operation failed before running.
    public let data: Data?

    /// The errors, empty when there were none.
    public let errors: [GraphQLError]

    private enum CodingKeys: String, CodingKey {
        case data, errors
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(Data.self, forKey: .data)
        errors = try container.decodeIfPresent([GraphQLError].self, forKey: .errors) ?? []
    }
}

/// The error ``NetworkClient/graphQL(_:path:)`` throws when the response has errors.
public struct GraphQLFailure<Data: Decodable & Sendable>: Error, Sendable {
    /// The errors of the response.
    public let errors: [GraphQLError]

    /// The data that was returned anyway, if any.
    public let partialData: Data?
}

extension Endpoint {
    /// A `POST` of `operation` to the GraphQL endpoint at `path`.
    public static func graphQL<Data>(
        _ operation: GraphQLOperation<Data>,
        path: String = "graphql"
    ) -> Endpoint<GraphQLResponse<Data>> where Response == GraphQLResponse<Data> {
        Endpoint(
            method: .post,
            path: path,
            headers: ["Accept": "application/graphql-response+json, application/json"],
            body: operation.body()
        )
    }
}

extension NetworkClient {
    /// Runs `operation` and returns its data.
    ///
    /// - Throws: ``GraphQLFailure`` when the response contains errors (with any partial
    ///   data), or ``NetworkError`` when the request itself fails.
    public func graphQL<Data>(_ operation: GraphQLOperation<Data>, path: String = "graphql") async throws -> Data {
        let response = try await send(Endpoint<GraphQLResponse<Data>>.graphQL(operation, path: path))
        guard response.errors.isEmpty, let data = response.data else {
            throw GraphQLFailure(errors: response.errors, partialData: response.data)
        }
        return data
    }
}
