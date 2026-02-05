// GRPCClient.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import NetworkingArchitecture

/// gRPC client implementation over HTTP/2
/// Note: This is a lightweight implementation. For production, consider using grpc-swift.
public actor GRPCClient {
    
    // MARK: - Properties
    
    private let host: String
    private let port: Int
    private let configuration: GRPCConfiguration
    private var metadata: GRPCMetadata
    
    // MARK: - Initialization
    
    public init(
        host: String,
        port: Int = 443,
        configuration: GRPCConfiguration = .default
    ) {
        self.host = host
        self.port = port
        self.configuration = configuration
        self.metadata = GRPCMetadata()
    }
    
    // MARK: - RPC Methods
    
    /// Unary RPC call
    public func unary<Request: GRPCMessage, Response: GRPCMessage>(
        service: String,
        method: String,
        request: Request
    ) async throws -> Response {
        let path = "/\(service)/\(method)"
        let requestData = try request.serialize()
        
        let responseData = try await performCall(
            path: path,
            requestData: requestData,
            callType: .unary
        )
        
        return try Response.deserialize(from: responseData)
    }
    
    /// Server streaming RPC
    public func serverStreaming<Request: GRPCMessage, Response: GRPCMessage>(
        service: String,
        method: String,
        request: Request
    ) -> AsyncThrowingStream<Response, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let path = "/\(service)/\(method)"
                    let requestData = try request.serialize()
                    
                    let stream = try await performStreamingCall(
                        path: path,
                        requestData: requestData,
                        callType: .serverStreaming
                    )
                    
                    for try await data in stream {
                        let response = try Response.deserialize(from: data)
                        continuation.yield(response)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Client streaming RPC
    public func clientStreaming<Request: GRPCMessage, Response: GRPCMessage>(
        service: String,
        method: String,
        requests: AsyncStream<Request>
    ) async throws -> Response {
        let path = "/\(service)/\(method)"
        var requestDatas: [Data] = []
        
        for await request in requests {
            requestDatas.append(try request.serialize())
        }
        
        let combinedData = requestDatas.reduce(Data()) { $0 + $1 }
        
        let responseData = try await performCall(
            path: path,
            requestData: combinedData,
            callType: .clientStreaming
        )
        
        return try Response.deserialize(from: responseData)
    }
    
    /// Bidirectional streaming RPC
    public func bidirectionalStreaming<Request: GRPCMessage, Response: GRPCMessage>(
        service: String,
        method: String,
        requests: AsyncStream<Request>
    ) -> AsyncThrowingStream<Response, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let path = "/\(service)/\(method)"
                    
                    // Simplified implementation
                    for await request in requests {
                        let requestData = try request.serialize()
                        let responseData = try await performCall(
                            path: path,
                            requestData: requestData,
                            callType: .bidirectionalStreaming
                        )
                        let response = try Response.deserialize(from: responseData)
                        continuation.yield(response)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Metadata
    
    /// Set metadata for requests
    public func setMetadata(_ metadata: GRPCMetadata) {
        self.metadata = metadata
    }
    
    /// Add metadata entry
    public func addMetadata(key: String, value: String) {
        metadata.add(key: key, value: value)
    }
    
    // MARK: - Private
    
    private func performCall(
        path: String,
        requestData: Data,
        callType: GRPCCallType
    ) async throws -> Data {
        let url = URL(string: "https://\(host):\(port)\(path)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = frameMessage(requestData)
        
        // gRPC headers
        request.setValue("application/grpc", forHTTPHeaderField: "Content-Type")
        request.setValue("identity", forHTTPHeaderField: "grpc-encoding")
        request.setValue("identity,gzip", forHTTPHeaderField: "grpc-accept-encoding")
        request.setValue(configuration.userAgent, forHTTPHeaderField: "User-Agent")
        
        // Custom metadata
        for (key, values) in metadata.entries {
            for value in values {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GRPCError.invalidResponse
        }
        
        // Check gRPC status
        if let grpcStatus = httpResponse.value(forHTTPHeaderField: "grpc-status"),
           let status = Int(grpcStatus), status != 0 {
            let message = httpResponse.value(forHTTPHeaderField: "grpc-message") ?? "Unknown error"
            throw GRPCError.rpcFailed(code: GRPCStatusCode(rawValue: status) ?? .unknown, message: message)
        }
        
        return try unframeMessage(data)
    }
    
    private func performStreamingCall(
        path: String,
        requestData: Data,
        callType: GRPCCallType
    ) async throws -> AsyncThrowingStream<Data, Error> {
        // Simplified streaming implementation
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let data = try await performCall(path: path, requestData: requestData, callType: callType)
                    continuation.yield(data)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Frame gRPC message with length prefix
    private func frameMessage(_ data: Data) -> Data {
        var framed = Data()
        framed.append(0) // Compression flag
        
        // Length as big-endian 32-bit integer
        var length = UInt32(data.count).bigEndian
        framed.append(Data(bytes: &length, count: 4))
        framed.append(data)
        
        return framed
    }
    
    /// Unframe gRPC message
    private func unframeMessage(_ data: Data) throws -> Data {
        guard data.count >= 5 else {
            throw GRPCError.invalidMessage
        }
        
        // Skip compression flag and length
        return data.subdata(in: 5..<data.count)
    }
}

// MARK: - gRPC Message Protocol

/// Protocol for gRPC messages
public protocol GRPCMessage: Sendable {
    /// Serialize message to binary format (typically Protocol Buffers)
    func serialize() throws -> Data
    
    /// Deserialize message from binary format
    static func deserialize(from data: Data) throws -> Self
}

// MARK: - JSON-based GRPCMessage implementation

/// Default JSON-based implementation for GRPCMessage
public extension GRPCMessage where Self: Codable {
    func serialize() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    static func deserialize(from data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}

// MARK: - gRPC Metadata

/// gRPC request/response metadata
public struct GRPCMetadata: Sendable {
    public var entries: [String: [String]]
    
    public init() {
        self.entries = [:]
    }
    
    public mutating func add(key: String, value: String) {
        if entries[key] == nil {
            entries[key] = []
        }
        entries[key]?.append(value)
    }
    
    public func get(key: String) -> [String]? {
        entries[key]
    }
}

// MARK: - gRPC Call Type

/// Type of gRPC call
public enum GRPCCallType {
    case unary
    case serverStreaming
    case clientStreaming
    case bidirectionalStreaming
}

// MARK: - gRPC Status Code

/// gRPC status codes
public enum GRPCStatusCode: Int, Sendable {
    case ok = 0
    case cancelled = 1
    case unknown = 2
    case invalidArgument = 3
    case deadlineExceeded = 4
    case notFound = 5
    case alreadyExists = 6
    case permissionDenied = 7
    case resourceExhausted = 8
    case failedPrecondition = 9
    case aborted = 10
    case outOfRange = 11
    case unimplemented = 12
    case `internal` = 13
    case unavailable = 14
    case dataLoss = 15
    case unauthenticated = 16
}

// MARK: - gRPC Error

/// gRPC-specific errors
public enum GRPCError: Error, LocalizedError, Sendable {
    case connectionFailed(String)
    case invalidResponse
    case invalidMessage
    case rpcFailed(code: GRPCStatusCode, message: String)
    case timeout
    case streamClosed
    
    public var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "gRPC connection failed: \(reason)"
        case .invalidResponse:
            return "Invalid gRPC response"
        case .invalidMessage:
            return "Invalid gRPC message format"
        case .rpcFailed(let code, let message):
            return "gRPC call failed (\(code)): \(message)"
        case .timeout:
            return "gRPC call timed out"
        case .streamClosed:
            return "gRPC stream was closed"
        }
    }
}

// MARK: - gRPC Configuration

/// gRPC configuration
public struct GRPCConfiguration: Sendable {
    public let timeout: TimeInterval
    public let userAgent: String
    public let maxMessageSize: Int
    public let keepAliveInterval: TimeInterval?
    public let useTLS: Bool
    
    public init(
        timeout: TimeInterval = 30,
        userAgent: String = "grpc-swift/1.0",
        maxMessageSize: Int = 4 * 1024 * 1024, // 4 MB
        keepAliveInterval: TimeInterval? = nil,
        useTLS: Bool = true
    ) {
        self.timeout = timeout
        self.userAgent = userAgent
        self.maxMessageSize = maxMessageSize
        self.keepAliveInterval = keepAliveInterval
        self.useTLS = useTLS
    }
    
    public static let `default` = GRPCConfiguration()
}

// MARK: - gRPC Service Descriptor

/// Descriptor for a gRPC service
public struct GRPCServiceDescriptor: Sendable {
    public let name: String
    public let methods: [GRPCMethodDescriptor]
    
    public init(name: String, methods: [GRPCMethodDescriptor]) {
        self.name = name
        self.methods = methods
    }
}

/// Descriptor for a gRPC method
public struct GRPCMethodDescriptor: Sendable {
    public let name: String
    public let isClientStreaming: Bool
    public let isServerStreaming: Bool
    
    public init(name: String, isClientStreaming: Bool = false, isServerStreaming: Bool = false) {
        self.name = name
        self.isClientStreaming = isClientStreaming
        self.isServerStreaming = isServerStreaming
    }
    
    public var callType: GRPCCallType {
        switch (isClientStreaming, isServerStreaming) {
        case (false, false): return .unary
        case (false, true): return .serverStreaming
        case (true, false): return .clientStreaming
        case (true, true): return .bidirectionalStreaming
        }
    }
}
