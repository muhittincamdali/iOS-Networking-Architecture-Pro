// Response.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Network response container with metadata
public struct Response<T: Sendable>: Sendable {
    
    // MARK: - Properties
    
    /// Decoded response body
    public let data: T
    
    /// HTTP status code
    public let statusCode: Int
    
    /// Response headers
    public let headers: [String: String]
    
    /// Response URL
    public let url: URL?
    
    /// Response metadata
    public let metadata: ResponseMetadata
    
    // MARK: - Initialization
    
    public init(
        data: T,
        statusCode: Int,
        headers: [String: String] = [:],
        url: URL? = nil,
        metadata: ResponseMetadata = ResponseMetadata()
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.url = url
        self.metadata = metadata
    }
    
    // MARK: - Computed Properties
    
    /// Whether the response was successful (2xx)
    public var isSuccess: Bool {
        (200..<300).contains(statusCode)
    }
    
    /// Whether the response was a redirect (3xx)
    public var isRedirect: Bool {
        (300..<400).contains(statusCode)
    }
    
    /// Whether the response was a client error (4xx)
    public var isClientError: Bool {
        (400..<500).contains(statusCode)
    }
    
    /// Whether the response was a server error (5xx)
    public var isServerError: Bool {
        (500..<600).contains(statusCode)
    }
    
    // MARK: - Header Accessors
    
    /// Content-Type header
    public var contentType: String? {
        headers["Content-Type"]
    }
    
    /// Content-Length header
    public var contentLength: Int? {
        headers["Content-Length"].flatMap { Int($0) }
    }
    
    /// Cache-Control header
    public var cacheControl: String? {
        headers["Cache-Control"]
    }
    
    /// ETag header
    public var etag: String? {
        headers["ETag"]
    }
    
    /// Last-Modified header
    public var lastModified: Date? {
        headers["Last-Modified"].flatMap { DateFormatter.httpDate.date(from: $0) }
    }
    
    /// Rate limit headers
    public var rateLimit: RateLimitInfo? {
        guard let limit = headers["X-RateLimit-Limit"].flatMap({ Int($0) }),
              let remaining = headers["X-RateLimit-Remaining"].flatMap({ Int($0) }) else {
            return nil
        }
        let reset = headers["X-RateLimit-Reset"].flatMap { TimeInterval($0) }
        return RateLimitInfo(limit: limit, remaining: remaining, resetTime: reset)
    }
    
    // MARK: - Transformation
    
    /// Map response data to another type
    public func map<U: Sendable>(_ transform: (T) throws -> U) rethrows -> Response<U> {
        Response<U>(
            data: try transform(data),
            statusCode: statusCode,
            headers: headers,
            url: url,
            metadata: metadata
        )
    }
}

// MARK: - Response Metadata

/// Metadata about the response
public struct ResponseMetadata: Sendable {
    
    /// Request ID
    public let requestId: UUID
    
    /// Request start time
    public let requestStartTime: Date
    
    /// Response receive time
    public let responseTime: Date
    
    /// Time to first byte
    public let timeToFirstByte: TimeInterval?
    
    /// Total response time
    public var totalTime: TimeInterval {
        responseTime.timeIntervalSince(requestStartTime)
    }
    
    /// Response size in bytes
    public let responseSize: Int
    
    /// Whether response was from cache
    public let fromCache: Bool
    
    /// Number of retries
    public let retryCount: Int
    
    // MARK: - Initialization
    
    public init(
        requestId: UUID = UUID(),
        requestStartTime: Date = Date(),
        responseTime: Date = Date(),
        timeToFirstByte: TimeInterval? = nil,
        responseSize: Int = 0,
        fromCache: Bool = false,
        retryCount: Int = 0
    ) {
        self.requestId = requestId
        self.requestStartTime = requestStartTime
        self.responseTime = responseTime
        self.timeToFirstByte = timeToFirstByte
        self.responseSize = responseSize
        self.fromCache = fromCache
        self.retryCount = retryCount
    }
}

// MARK: - Rate Limit Info

/// Rate limit information from response headers
public struct RateLimitInfo: Sendable {
    /// Maximum requests allowed
    public let limit: Int
    
    /// Remaining requests
    public let remaining: Int
    
    /// Time until reset (seconds since epoch)
    public let resetTime: TimeInterval?
    
    /// Time until reset as Date
    public var resetDate: Date? {
        resetTime.map { Date(timeIntervalSince1970: $0) }
    }
    
    /// Whether rate limit is exhausted
    public var isExhausted: Bool {
        remaining <= 0
    }
}

// MARK: - Empty Response

/// Empty response type for requests with no body
public struct EmptyResponse: Codable, Sendable, Equatable {
    public init() {}
}

// MARK: - Raw Response

/// Raw data response without decoding
public struct RawResponse: Sendable {
    public let data: Data
    public let statusCode: Int
    public let headers: [String: String]
    public let url: URL?
    
    public init(data: Data, statusCode: Int, headers: [String: String], url: URL?) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.url = url
    }
    
    /// Decode as specific type
    public func decode<T: Decodable>(as type: T.Type, using decoder: JSONDecoder = .networkingDefault) throws -> T {
        try decoder.decode(type, from: data)
    }
    
    /// Convert to string
    public func string(encoding: String.Encoding = .utf8) -> String? {
        String(data: data, encoding: encoding)
    }
}

// MARK: - Date Formatter Extension

private extension DateFormatter {
    static let httpDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()
}

// MARK: - Pagination Support

/// Paginated response wrapper
public struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {
    public let items: [T]
    public let pagination: PaginationInfo
    
    public init(items: [T], pagination: PaginationInfo) {
        self.items = items
        self.pagination = pagination
    }
}

/// Pagination information
public struct PaginationInfo: Codable, Sendable {
    public let page: Int
    public let perPage: Int
    public let totalItems: Int
    public let totalPages: Int
    
    public var hasNextPage: Bool {
        page < totalPages
    }
    
    public var hasPreviousPage: Bool {
        page > 1
    }
    
    public init(page: Int, perPage: Int, totalItems: Int, totalPages: Int) {
        self.page = page
        self.perPage = perPage
        self.totalItems = totalItems
        self.totalPages = totalPages
    }
}
