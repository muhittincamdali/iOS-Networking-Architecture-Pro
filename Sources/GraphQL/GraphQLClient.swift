// GraphQLClient.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import NetworkingArchitecture

/// GraphQL client for query and mutation operations
public actor GraphQLClient {
    
    // MARK: - Properties
    
    private let endpoint: URL
    private let client: NetworkClient
    private let headers: [String: String]
    
    // MARK: - Initialization
    
    public init(
        endpoint: URL,
        client: NetworkClient? = nil,
        headers: [String: String] = [:]
    ) {
        self.endpoint = endpoint
        self.client = client ?? NetworkClient()
        self.headers = headers
    }
    
    // MARK: - Query
    
    /// Execute a GraphQL query
    public func query<T: Decodable>(
        _ query: String,
        variables: [String: Any]? = nil,
        operationName: String? = nil
    ) async throws -> T {
        let request = GraphQLRequest(
            query: query,
            variables: variables,
            operationName: operationName
        )
        
        let response: GraphQLResponse<T> = try await execute(request)
        
        if let errors = response.errors, !errors.isEmpty {
            throw GraphQLError.queryFailed(errors)
        }
        
        guard let data = response.data else {
            throw GraphQLError.noData
        }
        
        return data
    }
    
    /// Execute a GraphQL query with typed query
    public func query<Q: GraphQLQuery>(_ query: Q) async throws -> Q.Response {
        try await self.query(
            query.queryString,
            variables: query.variables,
            operationName: query.operationName
        )
    }
    
    // MARK: - Mutation
    
    /// Execute a GraphQL mutation
    public func mutate<T: Decodable>(
        _ mutation: String,
        variables: [String: Any]? = nil,
        operationName: String? = nil
    ) async throws -> T {
        let request = GraphQLRequest(
            query: mutation,
            variables: variables,
            operationName: operationName
        )
        
        let response: GraphQLResponse<T> = try await execute(request)
        
        if let errors = response.errors, !errors.isEmpty {
            throw GraphQLError.mutationFailed(errors)
        }
        
        guard let data = response.data else {
            throw GraphQLError.noData
        }
        
        return data
    }
    
    /// Execute a GraphQL mutation with typed mutation
    public func mutate<M: GraphQLMutation>(_ mutation: M) async throws -> M.Response {
        try await self.mutate(
            mutation.mutationString,
            variables: mutation.variables,
            operationName: mutation.operationName
        )
    }
    
    // MARK: - Subscription
    
    /// Subscribe to a GraphQL subscription
    public func subscribe<T: Decodable>(
        _ subscription: String,
        variables: [String: Any]? = nil
    ) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            Task {
                // Would typically use WebSocket for subscriptions
                // This is a placeholder implementation
                continuation.finish(throwing: GraphQLError.subscriptionsNotSupported)
            }
        }
    }
    
    // MARK: - Private
    
    private func execute<T: Decodable>(_ request: GraphQLRequest) async throws -> GraphQLResponse<T> {
        let graphqlEndpoint = GraphQLEndpoint(
            url: endpoint,
            request: request,
            headers: headers
        )
        
        return try await client.execute(Request(endpoint: graphqlEndpoint)).data
    }
}

// MARK: - GraphQL Request

/// GraphQL request body
public struct GraphQLRequest: Encodable, Sendable {
    public let query: String
    public let variables: [String: AnyCodable]?
    public let operationName: String?
    
    public init(
        query: String,
        variables: [String: Any]? = nil,
        operationName: String? = nil
    ) {
        self.query = query
        self.variables = variables?.mapValues { AnyCodable($0) }
        self.operationName = operationName
    }
}

// MARK: - GraphQL Response

/// GraphQL response wrapper
public struct GraphQLResponse<T: Decodable>: Decodable {
    public let data: T?
    public let errors: [GraphQLResponseError]?
    public let extensions: [String: AnyCodable]?
}

/// GraphQL error from response
public struct GraphQLResponseError: Decodable, Sendable {
    public let message: String
    public let locations: [GraphQLLocation]?
    public let path: [AnyCodable]?
    public let extensions: [String: AnyCodable]?
}

/// GraphQL error location
public struct GraphQLLocation: Decodable, Sendable {
    public let line: Int
    public let column: Int
}

// MARK: - GraphQL Error

/// GraphQL-specific errors
public enum GraphQLError: Error, LocalizedError, Sendable {
    case queryFailed([GraphQLResponseError])
    case mutationFailed([GraphQLResponseError])
    case subscriptionsNotSupported
    case noData
    case invalidQuery(String)
    
    public var errorDescription: String? {
        switch self {
        case .queryFailed(let errors):
            return "Query failed: \(errors.map { $0.message }.joined(separator: ", "))"
        case .mutationFailed(let errors):
            return "Mutation failed: \(errors.map { $0.message }.joined(separator: ", "))"
        case .subscriptionsNotSupported:
            return "GraphQL subscriptions are not supported"
        case .noData:
            return "No data returned from GraphQL server"
        case .invalidQuery(let reason):
            return "Invalid GraphQL query: \(reason)"
        }
    }
}

// MARK: - GraphQL Endpoint

/// GraphQL endpoint
private struct GraphQLEndpoint: Endpoint {
    let url: URL
    let request: GraphQLRequest
    let headers: [String: String]
    
    var baseURL: URL { url }
    var path: String { "" }
    var method: HTTPMethod { .post }
    var queryParameters: [String: Any]? { nil }
    var body: RequestBody? { .json(request) }
    var timeoutInterval: TimeInterval? { nil }
    var cachePolicy: CachePolicy { .noCache }
    var retryPolicy: RetryPolicy { .default }
    var requiresAuthentication: Bool { false }
    var contentType: ContentType { .json }
    var acceptType: ContentType { .json }
}

// MARK: - Type-Safe Query Protocol

/// Protocol for type-safe GraphQL queries
public protocol GraphQLQuery: Sendable {
    associatedtype Response: Decodable
    
    var queryString: String { get }
    var variables: [String: Any]? { get }
    var operationName: String? { get }
}

public extension GraphQLQuery {
    var variables: [String: Any]? { nil }
    var operationName: String? { nil }
}

// MARK: - Type-Safe Mutation Protocol

/// Protocol for type-safe GraphQL mutations
public protocol GraphQLMutation: Sendable {
    associatedtype Response: Decodable
    
    var mutationString: String { get }
    var variables: [String: Any]? { get }
    var operationName: String? { get }
}

public extension GraphQLMutation {
    var variables: [String: Any]? { nil }
    var operationName: String? { nil }
}

// MARK: - GraphQL Fragment

/// Reusable GraphQL fragment
public struct GraphQLFragment: Sendable {
    public let name: String
    public let onType: String
    public let fields: String
    
    public init(name: String, onType: String, fields: String) {
        self.name = name
        self.onType = onType
        self.fields = fields
    }
    
    public var definition: String {
        """
        fragment \(name) on \(onType) {
          \(fields)
        }
        """
    }
}

// MARK: - Query Builder

/// Builder for constructing GraphQL queries
@resultBuilder
public struct GraphQLBuilder {
    public static func buildBlock(_ components: String...) -> String {
        components.joined(separator: "\n")
    }
}

/// Build a GraphQL query
public func graphQL(@GraphQLBuilder _ builder: () -> String) -> String {
    builder()
}

// MARK: - AnyCodable

/// Type-erased Codable for dynamic values
public struct AnyCodable: Codable, Sendable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to decode value"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(codingPath: [], debugDescription: "Unable to encode value")
            )
        }
    }
}
