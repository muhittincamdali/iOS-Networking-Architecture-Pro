// NetworkError.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Comprehensive network error type with detailed information
public enum NetworkError: Error, Equatable, Sendable {
    
    // MARK: - Request Errors
    
    /// Invalid URL provided
    case invalidURL(String)
    
    /// Invalid request configuration
    case invalidRequest(reason: String)
    
    /// Request encoding failed
    case encodingFailed(reason: String)
    
    /// Request was cancelled
    case cancelled
    
    // MARK: - Response Errors
    
    /// No response received
    case noResponse
    
    /// No data received
    case noData
    
    /// Response decoding failed
    case decodingFailed(reason: String)
    
    /// Invalid response format
    case invalidResponse(reason: String)
    
    // MARK: - HTTP Errors
    
    /// Client error (4xx)
    case clientError(statusCode: Int, data: Data?)
    
    /// Server error (5xx)
    case serverError(statusCode: Int, data: Data?)
    
    /// Unauthorized (401)
    case unauthorized
    
    /// Forbidden (403)
    case forbidden
    
    /// Not found (404)
    case notFound
    
    /// Rate limited (429)
    case rateLimited(retryAfter: TimeInterval?)
    
    // MARK: - Network Errors
    
    /// Network connection unavailable
    case noConnection
    
    /// Request timed out
    case timeout
    
    /// SSL/TLS error
    case sslError(reason: String)
    
    /// DNS resolution failed
    case dnsLookupFailed
    
    /// Connection refused
    case connectionRefused
    
    /// Connection reset
    case connectionReset
    
    // MARK: - Authentication Errors
    
    /// Authentication required
    case authenticationRequired
    
    /// Token expired
    case tokenExpired
    
    /// Token refresh failed
    case tokenRefreshFailed(reason: String)
    
    // MARK: - Cache Errors
    
    /// Cache miss
    case cacheMiss
    
    /// Cache expired
    case cacheExpired
    
    /// Cache write failed
    case cacheWriteFailed(reason: String)
    
    // MARK: - Other Errors
    
    /// Maximum retries exceeded
    case maxRetriesExceeded(attempts: Int)
    
    /// Offline queue full
    case offlineQueueFull
    
    /// Unknown error with underlying error
    case unknown(reason: String)
    
    // MARK: - Equatable
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let l), .invalidURL(let r)): return l == r
        case (.invalidRequest(let l), .invalidRequest(let r)): return l == r
        case (.encodingFailed(let l), .encodingFailed(let r)): return l == r
        case (.cancelled, .cancelled): return true
        case (.noResponse, .noResponse): return true
        case (.noData, .noData): return true
        case (.decodingFailed(let l), .decodingFailed(let r)): return l == r
        case (.invalidResponse(let l), .invalidResponse(let r)): return l == r
        case (.clientError(let lc, _), .clientError(let rc, _)): return lc == rc
        case (.serverError(let lc, _), .serverError(let rc, _)): return lc == rc
        case (.unauthorized, .unauthorized): return true
        case (.forbidden, .forbidden): return true
        case (.notFound, .notFound): return true
        case (.rateLimited(let l), .rateLimited(let r)): return l == r
        case (.noConnection, .noConnection): return true
        case (.timeout, .timeout): return true
        case (.sslError(let l), .sslError(let r)): return l == r
        case (.dnsLookupFailed, .dnsLookupFailed): return true
        case (.connectionRefused, .connectionRefused): return true
        case (.connectionReset, .connectionReset): return true
        case (.authenticationRequired, .authenticationRequired): return true
        case (.tokenExpired, .tokenExpired): return true
        case (.tokenRefreshFailed(let l), .tokenRefreshFailed(let r)): return l == r
        case (.cacheMiss, .cacheMiss): return true
        case (.cacheExpired, .cacheExpired): return true
        case (.cacheWriteFailed(let l), .cacheWriteFailed(let r)): return l == r
        case (.maxRetriesExceeded(let l), .maxRetriesExceeded(let r)): return l == r
        case (.offlineQueueFull, .offlineQueueFull): return true
        case (.unknown(let l), .unknown(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidRequest(let reason):
            return "Invalid request: \(reason)"
        case .encodingFailed(let reason):
            return "Request encoding failed: \(reason)"
        case .cancelled:
            return "Request was cancelled"
        case .noResponse:
            return "No response received from server"
        case .noData:
            return "No data received from server"
        case .decodingFailed(let reason):
            return "Response decoding failed: \(reason)"
        case .invalidResponse(let reason):
            return "Invalid response: \(reason)"
        case .clientError(let code, _):
            return "Client error with status code: \(code)"
        case .serverError(let code, _):
            return "Server error with status code: \(code)"
        case .unauthorized:
            return "Unauthorized - authentication required"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .rateLimited(let retryAfter):
            if let retry = retryAfter {
                return "Rate limited - retry after \(Int(retry)) seconds"
            }
            return "Rate limited"
        case .noConnection:
            return "No network connection available"
        case .timeout:
            return "Request timed out"
        case .sslError(let reason):
            return "SSL/TLS error: \(reason)"
        case .dnsLookupFailed:
            return "DNS lookup failed"
        case .connectionRefused:
            return "Connection refused by server"
        case .connectionReset:
            return "Connection reset by server"
        case .authenticationRequired:
            return "Authentication required"
        case .tokenExpired:
            return "Authentication token has expired"
        case .tokenRefreshFailed(let reason):
            return "Token refresh failed: \(reason)"
        case .cacheMiss:
            return "Cache miss - data not found in cache"
        case .cacheExpired:
            return "Cached data has expired"
        case .cacheWriteFailed(let reason):
            return "Failed to write to cache: \(reason)"
        case .maxRetriesExceeded(let attempts):
            return "Maximum retry attempts (\(attempts)) exceeded"
        case .offlineQueueFull:
            return "Offline queue is full"
        case .unknown(let reason):
            return "Unknown error: \(reason)"
        }
    }
}

// MARK: - Error Classification

public extension NetworkError {
    /// Whether the error is recoverable
    var isRecoverable: Bool {
        switch self {
        case .timeout, .noConnection, .connectionReset, .rateLimited, .serverError:
            return true
        default:
            return false
        }
    }
    
    /// Whether the error requires authentication
    var requiresAuthentication: Bool {
        switch self {
        case .unauthorized, .tokenExpired, .authenticationRequired:
            return true
        default:
            return false
        }
    }
    
    /// Whether the error is a network connectivity issue
    var isConnectivityIssue: Bool {
        switch self {
        case .noConnection, .timeout, .dnsLookupFailed, .connectionRefused, .connectionReset:
            return true
        default:
            return false
        }
    }
    
    /// HTTP status code if applicable
    var statusCode: Int? {
        switch self {
        case .clientError(let code, _), .serverError(let code, _):
            return code
        case .unauthorized:
            return 401
        case .forbidden:
            return 403
        case .notFound:
            return 404
        case .rateLimited:
            return 429
        default:
            return nil
        }
    }
}

// MARK: - URLError Conversion

public extension NetworkError {
    /// Create NetworkError from URLError
    static func from(_ urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .cancelled:
            return .cancelled
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        case .cannotFindHost, .dnsLookupFailed:
            return .dnsLookupFailed
        case .cannotConnectToHost:
            return .connectionRefused
        case .secureConnectionFailed, .serverCertificateUntrusted:
            return .sslError(reason: urlError.localizedDescription)
        default:
            return .unknown(reason: urlError.localizedDescription)
        }
    }
}
