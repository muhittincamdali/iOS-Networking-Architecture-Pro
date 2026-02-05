// NetworkLogger.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import Logging

/// Network-specific logger with structured logging
public struct NetworkLogger: Sendable {
    
    // MARK: - Properties
    
    private let logger: Logger
    private let config: LoggingConfiguration
    
    // MARK: - Initialization
    
    public init(
        label: String = "NetworkingArchitecture",
        configuration: LoggingConfiguration = .default
    ) {
        var logger = Logger(label: label)
        logger.logLevel = configuration.level
        self.logger = logger
        self.config = configuration
    }
    
    // MARK: - Request Logging
    
    /// Log an outgoing request
    public func logRequest(_ request: URLRequest, context: RequestContext? = nil) {
        guard config.logRequests else { return }
        
        var metadata: Logger.Metadata = [
            "method": "\(request.httpMethod ?? "?")",
            "url": "\(request.url?.absoluteString ?? "?")"
        ]
        
        if let id = context?.requestId {
            metadata["requestId"] = "\(id)"
        }
        
        if config.logHeaders, let headers = request.allHTTPHeaderFields {
            metadata["headers"] = "\(sanitizeHeaders(headers))"
        }
        
        if config.logBody, let body = request.httpBody {
            metadata["body"] = "\(formatBody(body))"
        }
        
        logger.log(level: config.level, "➡️ Request", metadata: metadata)
    }
    
    /// Log an incoming response
    public func logResponse(
        _ response: HTTPURLResponse?,
        data: Data?,
        duration: TimeInterval,
        context: RequestContext? = nil
    ) {
        guard config.logResponses else { return }
        
        let statusCode = response?.statusCode ?? 0
        let emoji = (200..<300).contains(statusCode) ? "✅" : "❌"
        
        var metadata: Logger.Metadata = [
            "statusCode": "\(statusCode)",
            "duration": "\(String(format: "%.2f", duration * 1000))ms"
        ]
        
        if let id = context?.requestId {
            metadata["requestId"] = "\(id)"
        }
        
        if let data = data {
            metadata["size"] = "\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary))"
        }
        
        if config.logHeaders, let headers = response?.allHeaderFields as? [String: String] {
            metadata["headers"] = "\(headers)"
        }
        
        if config.logBody, let data = data {
            metadata["body"] = "\(formatBody(data))"
        }
        
        logger.log(level: config.level, "\(emoji) Response", metadata: metadata)
    }
    
    /// Log an error
    public func logError(
        _ error: Error,
        request: URLRequest? = nil,
        context: RequestContext? = nil
    ) {
        guard config.logErrors else { return }
        
        var metadata: Logger.Metadata = [
            "error": "\(error.localizedDescription)"
        ]
        
        if let request = request {
            metadata["url"] = "\(request.url?.absoluteString ?? "?")"
            metadata["method"] = "\(request.httpMethod ?? "?")"
        }
        
        if let id = context?.requestId {
            metadata["requestId"] = "\(id)"
        }
        
        if let networkError = error as? NetworkError {
            metadata["errorType"] = "\(networkError)"
            if let statusCode = networkError.statusCode {
                metadata["statusCode"] = "\(statusCode)"
            }
        }
        
        logger.error("❌ Error", metadata: metadata)
    }
    
    /// Log cache operations
    public func logCache(operation: CacheOperation, key: String, hit: Bool = false) {
        guard config.logCache else { return }
        
        let emoji = hit ? "💾" : "🔍"
        let metadata: Logger.Metadata = [
            "operation": "\(operation)",
            "key": "\(key)",
            "hit": "\(hit)"
        ]
        
        logger.debug("\(emoji) Cache \(operation)", metadata: metadata)
    }
    
    /// Log retry attempts
    public func logRetry(attempt: Int, maxAttempts: Int, delay: TimeInterval, error: Error) {
        guard config.logRetries else { return }
        
        let metadata: Logger.Metadata = [
            "attempt": "\(attempt)/\(maxAttempts)",
            "delay": "\(String(format: "%.2f", delay))s",
            "error": "\(error.localizedDescription)"
        ]
        
        logger.warning("🔄 Retry", metadata: metadata)
    }
    
    // MARK: - Private Helpers
    
    private func sanitizeHeaders(_ headers: [String: String]) -> [String: String] {
        var sanitized = headers
        
        // Redact sensitive headers
        let sensitiveHeaders = ["Authorization", "Cookie", "X-API-Key", "X-Auth-Token"]
        for header in sensitiveHeaders {
            if sanitized[header] != nil {
                sanitized[header] = "[REDACTED]"
            }
        }
        
        return sanitized
    }
    
    private func formatBody(_ data: Data) -> String {
        guard config.logBody else { return "[body logging disabled]" }
        
        // Truncate large bodies
        let maxSize = config.maxBodyLogSize
        if data.count > maxSize {
            if let string = String(data: data.prefix(maxSize), encoding: .utf8) {
                return "\(string)... [truncated, \(data.count) bytes total]"
            }
        }
        
        if let string = String(data: data, encoding: .utf8) {
            // Try to pretty-print JSON
            if let json = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                return prettyString
            }
            return string
        }
        
        return "[binary data, \(data.count) bytes]"
    }
}

// MARK: - Logging Configuration

/// Configuration for network logging
public struct LoggingConfiguration: Sendable {
    public let level: Logger.Level
    public let logRequests: Bool
    public let logResponses: Bool
    public let logErrors: Bool
    public let logHeaders: Bool
    public let logBody: Bool
    public let logCache: Bool
    public let logRetries: Bool
    public let maxBodyLogSize: Int
    
    public init(
        level: Logger.Level = .info,
        logRequests: Bool = true,
        logResponses: Bool = true,
        logErrors: Bool = true,
        logHeaders: Bool = false,
        logBody: Bool = false,
        logCache: Bool = false,
        logRetries: Bool = true,
        maxBodyLogSize: Int = 4096
    ) {
        self.level = level
        self.logRequests = logRequests
        self.logResponses = logResponses
        self.logErrors = logErrors
        self.logHeaders = logHeaders
        self.logBody = logBody
        self.logCache = logCache
        self.logRetries = logRetries
        self.maxBodyLogSize = maxBodyLogSize
    }
    
    // MARK: - Presets
    
    public static let `default` = LoggingConfiguration()
    
    public static let verbose = LoggingConfiguration(
        level: .debug,
        logHeaders: true,
        logBody: true,
        logCache: true
    )
    
    public static let minimal = LoggingConfiguration(
        level: .warning,
        logRequests: false,
        logResponses: false
    )
    
    public static let production = LoggingConfiguration(
        level: .error,
        logRequests: false,
        logResponses: false,
        logHeaders: false,
        logBody: false
    )
}

// MARK: - Cache Operation

/// Type of cache operation
public enum CacheOperation: String, Sendable {
    case read = "READ"
    case write = "WRITE"
    case delete = "DELETE"
    case clear = "CLEAR"
    case hit = "HIT"
    case miss = "MISS"
}

// MARK: - Log Entry

/// Structured log entry
public struct NetworkLogEntry: Codable, Sendable {
    public let timestamp: Date
    public let level: String
    public let message: String
    public let requestId: UUID?
    public let url: String?
    public let method: String?
    public let statusCode: Int?
    public let duration: TimeInterval?
    public let error: String?
    public let metadata: [String: String]
    
    public init(
        timestamp: Date = Date(),
        level: String,
        message: String,
        requestId: UUID? = nil,
        url: String? = nil,
        method: String? = nil,
        statusCode: Int? = nil,
        duration: TimeInterval? = nil,
        error: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.requestId = requestId
        self.url = url
        self.method = method
        self.statusCode = statusCode
        self.duration = duration
        self.error = error
        self.metadata = metadata
    }
}

// MARK: - Log Storage

/// Protocol for storing logs
public protocol LogStorage: Actor {
    func store(_ entry: NetworkLogEntry) async
    func getEntries(limit: Int) async -> [NetworkLogEntry]
    func clear() async
}

/// In-memory log storage with circular buffer
public actor InMemoryLogStorage: LogStorage {
    private var entries: [NetworkLogEntry] = []
    private let maxEntries: Int
    
    public init(maxEntries: Int = 1000) {
        self.maxEntries = maxEntries
    }
    
    public func store(_ entry: NetworkLogEntry) async {
        entries.append(entry)
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }
    }
    
    public func getEntries(limit: Int) async -> [NetworkLogEntry] {
        Array(entries.suffix(limit))
    }
    
    public func clear() async {
        entries.removeAll()
    }
}
