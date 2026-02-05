// RESTClient.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import NetworkingArchitecture

/// REST API client with fluent interface
public final class RESTClient: Sendable {
    
    // MARK: - Properties
    
    private let baseURL: URL
    private let client: NetworkClient
    private let defaultHeaders: [String: String]
    
    // MARK: - Initialization
    
    public init(
        baseURL: URL,
        client: NetworkClient? = nil,
        defaultHeaders: [String: String] = [:]
    ) async {
        self.baseURL = baseURL
        self.client = client ?? NetworkClient()
        self.defaultHeaders = defaultHeaders
    }
    
    // MARK: - HTTP Methods
    
    /// Perform GET request
    public func get<T: Decodable & Sendable>(
        _ path: String,
        query: [String: Any]? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = RESTEndpoint<T>(
            baseURL: baseURL,
            path: path,
            method: .get,
            headers: mergeHeaders(headers),
            queryParameters: query
        )
        
        return try await client.execute(Request(endpoint: endpoint)).data
    }
    
    /// Perform POST request
    public func post<T: Decodable & Sendable, Body: Encodable & Sendable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = RESTEndpoint<T>(
            baseURL: baseURL,
            path: path,
            method: .post,
            headers: mergeHeaders(headers),
            body: .json(body)
        )
        
        return try await client.execute(Request(endpoint: endpoint)).data
    }
    
    /// Perform POST request without response body
    public func post<Body: Encodable & Sendable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:]
    ) async throws {
        let endpoint = RESTEndpoint<EmptyResponse>(
            baseURL: baseURL,
            path: path,
            method: .post,
            headers: mergeHeaders(headers),
            body: .json(body)
        )
        
        _ = try await client.execute(Request(endpoint: endpoint))
    }
    
    /// Perform PUT request
    public func put<T: Decodable & Sendable, Body: Encodable & Sendable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = RESTEndpoint<T>(
            baseURL: baseURL,
            path: path,
            method: .put,
            headers: mergeHeaders(headers),
            body: .json(body)
        )
        
        return try await client.execute(Request(endpoint: endpoint)).data
    }
    
    /// Perform PATCH request
    public func patch<T: Decodable & Sendable, Body: Encodable & Sendable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = RESTEndpoint<T>(
            baseURL: baseURL,
            path: path,
            method: .patch,
            headers: mergeHeaders(headers),
            body: .json(body)
        )
        
        return try await client.execute(Request(endpoint: endpoint)).data
    }
    
    /// Perform DELETE request
    public func delete(
        _ path: String,
        headers: [String: String] = [:]
    ) async throws {
        let endpoint = RESTEndpoint<EmptyResponse>(
            baseURL: baseURL,
            path: path,
            method: .delete,
            headers: mergeHeaders(headers)
        )
        
        _ = try await client.execute(Request(endpoint: endpoint))
    }
    
    /// Perform DELETE request with response
    public func delete<T: Decodable & Sendable>(
        _ path: String,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = RESTEndpoint<T>(
            baseURL: baseURL,
            path: path,
            method: .delete,
            headers: mergeHeaders(headers)
        )
        
        return try await client.execute(Request(endpoint: endpoint)).data
    }
    
    // MARK: - Upload/Download
    
    /// Upload file
    public func upload(
        _ path: String,
        data: Data,
        filename: String,
        mimeType: String,
        headers: [String: String] = [:]
    ) async throws -> RawResponse {
        let multipart = MultipartFormData(
            name: "file",
            data: data,
            filename: filename,
            mimeType: mimeType
        )
        
        let endpoint = RESTEndpoint<Data>(
            baseURL: baseURL,
            path: path,
            method: .post,
            headers: mergeHeaders(headers),
            body: .multipart([multipart])
        )
        
        return try await client.executeRaw(endpoint: endpoint)
    }
    
    /// Download file
    public func download(
        _ path: String,
        headers: [String: String] = [:]
    ) async throws -> Data {
        let endpoint = RESTEndpoint<Data>(
            baseURL: baseURL,
            path: path,
            method: .get,
            headers: mergeHeaders(headers)
        )
        
        return try await client.download(from: endpoint)
    }
    
    // MARK: - Private
    
    private func mergeHeaders(_ headers: [String: String]) -> [String: String] {
        var merged = defaultHeaders
        for (key, value) in headers {
            merged[key] = value
        }
        return merged
    }
}

// MARK: - REST Endpoint

/// REST-specific endpoint
public struct RESTEndpoint<Response>: Endpoint {
    public let baseURL: URL
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let queryParameters: [String: Any]?
    public let body: RequestBody?
    public let timeoutInterval: TimeInterval?
    public let cachePolicy: CachePolicy
    public let retryPolicy: RetryPolicy
    public let requiresAuthentication: Bool
    public let contentType: ContentType
    public let acceptType: ContentType
    
    public init(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryParameters: [String: Any]? = nil,
        body: RequestBody? = nil,
        timeoutInterval: TimeInterval? = nil,
        cachePolicy: CachePolicy = .default,
        retryPolicy: RetryPolicy = .default,
        requiresAuthentication: Bool = false,
        contentType: ContentType = .json,
        acceptType: ContentType = .json
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.retryPolicy = retryPolicy
        self.requiresAuthentication = requiresAuthentication
        self.contentType = contentType
        self.acceptType = acceptType
    }
}

// MARK: - REST Resource

/// RESTful resource for CRUD operations
public actor RESTResource<T: Codable & Sendable & Identifiable> where T.ID: LosslessStringConvertible {
    private let client: RESTClient
    private let basePath: String
    
    public init(client: RESTClient, basePath: String) {
        self.client = client
        self.basePath = basePath
    }
    
    /// Get all resources
    public func list(query: [String: Any]? = nil) async throws -> [T] {
        try await client.get(basePath, query: query)
    }
    
    /// Get single resource by ID
    public func get(id: T.ID) async throws -> T {
        try await client.get("\(basePath)/\(id)")
    }
    
    /// Create new resource
    public func create(_ resource: T) async throws -> T {
        try await client.post(basePath, body: resource)
    }
    
    /// Update existing resource
    public func update(_ resource: T) async throws -> T {
        try await client.put("\(basePath)/\(resource.id)", body: resource)
    }
    
    /// Partial update
    public func patch(_ id: T.ID, changes: [String: Any]) async throws -> T {
        try await client.patch("\(basePath)/\(id)", body: changes)
    }
    
    /// Delete resource
    public func delete(id: T.ID) async throws {
        try await client.delete("\(basePath)/\(id)")
    }
}

// MARK: - API Versioning

/// API version configuration
public struct APIVersion: Sendable {
    public let version: String
    public let strategy: VersioningStrategy
    
    public init(version: String, strategy: VersioningStrategy = .path) {
        self.version = version
        self.strategy = strategy
    }
    
    public enum VersioningStrategy: Sendable {
        case path           // /v1/users
        case header(String) // X-API-Version: 1
        case query(String)  // ?version=1
    }
}

// MARK: - Request Batching

/// Batch multiple requests
public actor RequestBatcher {
    private var pendingRequests: [BatchedRequest] = []
    private let maxBatchSize: Int
    private let batchDelay: TimeInterval
    private var batchTask: Task<Void, Never>?
    
    public init(maxBatchSize: Int = 10, batchDelay: TimeInterval = 0.1) {
        self.maxBatchSize = maxBatchSize
        self.batchDelay = batchDelay
    }
    
    /// Add request to batch
    public func add<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            let request = BatchedRequest(
                endpoint: endpoint,
                continuation: continuation as! CheckedContinuation<Any, Error>
            )
            pendingRequests.append(request)
            
            if pendingRequests.count >= maxBatchSize {
                Task { await flush() }
            } else {
                scheduleBatch()
            }
        }
    }
    
    /// Flush pending requests
    public func flush() async {
        batchTask?.cancel()
        let requests = pendingRequests
        pendingRequests = []
        
        // Execute all requests
        for request in requests {
            // Would execute and resolve continuations
        }
    }
    
    private func scheduleBatch() {
        batchTask?.cancel()
        batchTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(batchDelay * 1_000_000_000))
            await flush()
        }
    }
}

private struct BatchedRequest {
    let endpoint: any Endpoint
    let continuation: CheckedContinuation<Any, Error>
}
