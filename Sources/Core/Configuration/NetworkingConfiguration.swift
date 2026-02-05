// NetworkingConfiguration.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import Logging

/// Global configuration for the networking framework
public struct NetworkingConfiguration: Sendable {
    
    // MARK: - Properties
    
    /// Default timeout for requests in seconds
    public var timeoutInterval: TimeInterval
    
    /// Maximum number of retry attempts
    public var maxRetryAttempts: Int
    
    /// Base delay for exponential backoff in seconds
    public var retryBaseDelay: TimeInterval
    
    /// Maximum delay between retries in seconds
    public var retryMaxDelay: TimeInterval
    
    /// Enable automatic retry on failure
    public var autoRetryEnabled: Bool
    
    /// Enable response caching
    public var cachingEnabled: Bool
    
    /// Default cache TTL in seconds
    public var defaultCacheTTL: TimeInterval
    
    /// Maximum cache size in bytes
    public var maxCacheSize: Int
    
    /// Enable request/response logging
    public var loggingEnabled: Bool
    
    /// Logging level
    public var logLevel: Logger.Level
    
    /// Enable SSL certificate pinning
    public var certificatePinningEnabled: Bool
    
    /// Pinned certificate hashes (SHA-256)
    public var pinnedCertificateHashes: [String]
    
    /// Custom user agent string
    public var userAgent: String?
    
    /// Additional default headers
    public var defaultHeaders: [String: String]
    
    /// Enable offline queue
    public var offlineQueueEnabled: Bool
    
    /// Maximum offline queue size
    public var maxOfflineQueueSize: Int
    
    /// Enable metrics collection
    public var metricsEnabled: Bool
    
    /// Custom JSON encoder
    public var jsonEncoder: JSONEncoder
    
    /// Custom JSON decoder
    public var jsonDecoder: JSONDecoder
    
    // MARK: - Initialization
    
    public init(
        timeoutInterval: TimeInterval = 30.0,
        maxRetryAttempts: Int = 3,
        retryBaseDelay: TimeInterval = 1.0,
        retryMaxDelay: TimeInterval = 30.0,
        autoRetryEnabled: Bool = true,
        cachingEnabled: Bool = true,
        defaultCacheTTL: TimeInterval = 300,
        maxCacheSize: Int = 50 * 1024 * 1024, // 50 MB
        loggingEnabled: Bool = true,
        logLevel: Logger.Level = .info,
        certificatePinningEnabled: Bool = false,
        pinnedCertificateHashes: [String] = [],
        userAgent: String? = nil,
        defaultHeaders: [String: String] = [:],
        offlineQueueEnabled: Bool = true,
        maxOfflineQueueSize: Int = 100,
        metricsEnabled: Bool = true,
        jsonEncoder: JSONEncoder = .networkingDefault,
        jsonDecoder: JSONDecoder = .networkingDefault
    ) {
        self.timeoutInterval = timeoutInterval
        self.maxRetryAttempts = maxRetryAttempts
        self.retryBaseDelay = retryBaseDelay
        self.retryMaxDelay = retryMaxDelay
        self.autoRetryEnabled = autoRetryEnabled
        self.cachingEnabled = cachingEnabled
        self.defaultCacheTTL = defaultCacheTTL
        self.maxCacheSize = maxCacheSize
        self.loggingEnabled = loggingEnabled
        self.logLevel = logLevel
        self.certificatePinningEnabled = certificatePinningEnabled
        self.pinnedCertificateHashes = pinnedCertificateHashes
        self.userAgent = userAgent
        self.defaultHeaders = defaultHeaders
        self.offlineQueueEnabled = offlineQueueEnabled
        self.maxOfflineQueueSize = maxOfflineQueueSize
        self.metricsEnabled = metricsEnabled
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: - Presets
    
    /// Default configuration
    public static let `default` = NetworkingConfiguration()
    
    /// Debug configuration with verbose logging
    public static let debug = NetworkingConfiguration(
        loggingEnabled: true,
        logLevel: .debug,
        metricsEnabled: true
    )
    
    /// Production configuration with security features
    public static let production = NetworkingConfiguration(
        maxRetryAttempts: 5,
        autoRetryEnabled: true,
        loggingEnabled: false,
        logLevel: .error,
        certificatePinningEnabled: true,
        offlineQueueEnabled: true,
        metricsEnabled: true
    )
    
    /// Minimal configuration for testing
    public static let testing = NetworkingConfiguration(
        timeoutInterval: 5.0,
        maxRetryAttempts: 0,
        autoRetryEnabled: false,
        cachingEnabled: false,
        loggingEnabled: true,
        logLevel: .trace,
        offlineQueueEnabled: false,
        metricsEnabled: false
    )
}

// MARK: - JSON Encoder/Decoder Extensions

public extension JSONEncoder {
    /// Default encoder for networking
    static var networkingDefault: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

public extension JSONDecoder {
    /// Default decoder for networking
    static var networkingDefault: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
