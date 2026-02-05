// Request.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Type-safe network request with generics
public struct Request<Response: Decodable>: Sendable {
    
    // MARK: - Properties
    
    public let id: UUID
    public let endpoint: any Endpoint
    public let responseType: Response.Type
    public let priority: TaskPriority
    public let tags: Set<String>
    
    /// Custom decoder for this request
    public var decoder: JSONDecoder?
    
    /// Callback for download progress
    public var onProgress: (@Sendable (Double) -> Void)?
    
    // MARK: - Initialization
    
    public init(
        endpoint: any Endpoint,
        responseType: Response.Type = Response.self,
        priority: TaskPriority = .medium,
        tags: Set<String> = [],
        decoder: JSONDecoder? = nil
    ) {
        self.id = UUID()
        self.endpoint = endpoint
        self.responseType = responseType
        self.priority = priority
        self.tags = tags
        self.decoder = decoder
    }
    
    // MARK: - Builder Methods
    
    /// Set custom decoder
    public func decoder(_ decoder: JSONDecoder) -> Request<Response> {
        var copy = self
        copy.decoder = decoder
        return copy
    }
    
    /// Set progress callback
    public func onProgress(_ callback: @escaping @Sendable (Double) -> Void) -> Request<Response> {
        var copy = self
        copy.onProgress = callback
        return copy
    }
}

// MARK: - Request Priority

/// Request execution priority
public enum TaskPriority: Int, Comparable, Sendable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3
    
    public static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Request Context

/// Context information for a request
public struct RequestContext: Sendable {
    public let requestId: UUID
    public let startTime: Date
    public var retryCount: Int
    public var tags: Set<String>
    public var metadata: [String: String]
    
    public init(
        requestId: UUID = UUID(),
        startTime: Date = Date(),
        retryCount: Int = 0,
        tags: Set<String> = [],
        metadata: [String: String] = [:]
    ) {
        self.requestId = requestId
        self.startTime = startTime
        self.retryCount = retryCount
        self.tags = tags
        self.metadata = metadata
    }
    
    /// Time elapsed since request started
    public var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
}

// MARK: - Request Builder

/// Fluent builder for creating requests
@resultBuilder
public struct RequestBuilder {
    public static func buildBlock(_ components: RequestComponent...) -> [RequestComponent] {
        components
    }
}

/// Component for request builder
public protocol RequestComponent {
    func apply(to request: inout URLRequest)
}

/// Header component
public struct HeaderComponent: RequestComponent {
    let key: String
    let value: String
    
    public init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
    
    public func apply(to request: inout URLRequest) {
        request.setValue(value, forHTTPHeaderField: key)
    }
}

/// Query parameter component
public struct QueryComponent: RequestComponent {
    let key: String
    let value: String
    
    public init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
    
    public func apply(to request: inout URLRequest) {
        guard let url = request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: key, value: value))
        components.queryItems = queryItems
        request.url = components.url
    }
}

/// Body component
public struct BodyComponent: RequestComponent {
    let data: Data
    
    public init(_ encodable: Encodable) throws {
        self.data = try JSONEncoder.networkingDefault.encode(AnyEncodable(encodable as! (Sendable & Encodable)))
    }
    
    public init(data: Data) {
        self.data = data
    }
    
    public func apply(to request: inout URLRequest) {
        request.httpBody = data
    }
}

// MARK: - Convenience Functions

/// Create a header component
public func header(_ key: String, _ value: String) -> HeaderComponent {
    HeaderComponent(key, value)
}

/// Create a query component
public func query(_ key: String, _ value: String) -> QueryComponent {
    QueryComponent(key, value)
}

/// Create a body component
public func body(_ encodable: Encodable) throws -> BodyComponent {
    try BodyComponent(encodable)
}
