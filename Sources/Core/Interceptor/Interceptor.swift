// Interceptor.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import Logging

/// Protocol for request/response interceptors
public protocol Interceptor: Sendable {
    /// Intercept and optionally modify the request
    func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest
    
    /// Intercept and optionally modify the response
    func intercept<T: Sendable>(response: Response<T>, context: RequestContext) async throws -> Response<T>
}

// MARK: - Default Implementations

public extension Interceptor {
    func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        request
    }
    
    func intercept<T: Sendable>(response: Response<T>, context: RequestContext) async throws -> Response<T> {
        response
    }
}

// MARK: - Logging Interceptor

/// Interceptor for logging requests and responses
public struct LoggingInterceptor: Interceptor {
    private let logger: Logger
    private let logLevel: Logger.Level
    private let logBody: Bool
    private let logHeaders: Bool
    
    public init(
        label: String = "NetworkingArchitecture.HTTP",
        logLevel: Logger.Level = .info,
        logBody: Bool = false,
        logHeaders: Bool = false
    ) {
        self.logger = Logger(label: label)
        self.logLevel = logLevel
        self.logBody = logBody
        self.logHeaders = logHeaders
    }
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var message = "➡️ \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")"
        
        if logHeaders, let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            message += "\n  Headers: \(headers)"
        }
        
        if logBody, let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            message += "\n  Body: \(bodyString.prefix(1000))"
        }
        
        logger.log(level: logLevel, "\(message)")
        return request
    }
    
    public func intercept<T: Sendable>(response: Response<T>, context: RequestContext) async throws -> Response<T> {
        let emoji = response.isSuccess ? "✅" : "❌"
        var message = "\(emoji) \(response.statusCode) in \(String(format: "%.2f", response.metadata.totalTime * 1000))ms"
        
        if logHeaders, !response.headers.isEmpty {
            message += "\n  Headers: \(response.headers)"
        }
        
        logger.log(level: logLevel, "\(message)")
        return response
    }
}

// MARK: - Header Interceptor

/// Interceptor for adding custom headers
public struct HeaderInterceptor: Interceptor {
    private let headers: [String: String]
    
    public init(headers: [String: String]) {
        self.headers = headers
    }
    
    public init(_ key: String, _ value: String) {
        self.headers = [key: value]
    }
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var mutableRequest = request
        for (key, value) in headers {
            mutableRequest.setValue(value, forHTTPHeaderField: key)
        }
        return mutableRequest
    }
}

// MARK: - User Agent Interceptor

/// Interceptor for setting user agent
public struct UserAgentInterceptor: Interceptor {
    private let userAgent: String
    
    public init(userAgent: String) {
        self.userAgent = userAgent
    }
    
    public init(appName: String, appVersion: String) {
        #if os(iOS)
        let os = "iOS"
        #elseif os(macOS)
        let os = "macOS"
        #elseif os(tvOS)
        let os = "tvOS"
        #elseif os(watchOS)
        let os = "watchOS"
        #else
        let os = "Unknown"
        #endif
        
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        self.userAgent = "\(appName)/\(appVersion) (\(os); \(osVersion))"
    }
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return mutableRequest
    }
}

// MARK: - Request ID Interceptor

/// Interceptor for adding request ID header
public struct RequestIdInterceptor: Interceptor {
    private let headerName: String
    
    public init(headerName: String = "X-Request-ID") {
        self.headerName = headerName
    }
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue(context.requestId.uuidString, forHTTPHeaderField: headerName)
        return mutableRequest
    }
}

// MARK: - Timeout Interceptor

/// Interceptor for enforcing request timeout
public struct TimeoutInterceptor: Interceptor {
    private let timeout: TimeInterval
    
    public init(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.timeoutInterval = timeout
        return mutableRequest
    }
}

// MARK: - Compression Interceptor

/// Interceptor for enabling response compression
public struct CompressionInterceptor: Interceptor {
    public init() {}
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        return mutableRequest
    }
}

// MARK: - Metrics Interceptor

/// Interceptor for collecting performance metrics
public actor MetricsInterceptor: Interceptor {
    private var requestTimes: [UUID: Date] = [:]
    
    public init() {}
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        requestTimes[context.requestId] = Date()
        return request
    }
    
    public func intercept<T: Sendable>(response: Response<T>, context: RequestContext) async throws -> Response<T> {
        if let startTime = requestTimes[context.requestId] {
            let duration = Date().timeIntervalSince(startTime)
            requestTimes.removeValue(forKey: context.requestId)
            // Could emit metrics to analytics system here
        }
        return response
    }
}

// MARK: - Error Mapping Interceptor

/// Interceptor for mapping errors to custom types
public struct ErrorMappingInterceptor: Interceptor {
    public typealias ErrorMapper = @Sendable (NetworkError) -> Error
    
    private let mapper: ErrorMapper
    
    public init(mapper: @escaping ErrorMapper) {
        self.mapper = mapper
    }
    
    public func intercept<T: Sendable>(response: Response<T>, context: RequestContext) async throws -> Response<T> {
        if !response.isSuccess {
            if let statusCode = response.statusCode as Int?,
               let error = NetworkError.from(statusCode: statusCode, data: nil) {
                throw mapper(error)
            }
        }
        return response
    }
}

// MARK: - NetworkError Extension

private extension NetworkError {
    static func from(statusCode: Int, data: Data?) -> NetworkError? {
        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 429: return .rateLimited(retryAfter: nil)
        case 400..<500: return .clientError(statusCode: statusCode, data: data)
        case 500..<600: return .serverError(statusCode: statusCode, data: data)
        default: return nil
        }
    }
}

// MARK: - Interceptor Chain

/// Chain of interceptors for easy composition
public struct InterceptorChain: Interceptor {
    private let interceptors: [any Interceptor]
    
    public init(_ interceptors: [any Interceptor]) {
        self.interceptors = interceptors
    }
    
    public init(@InterceptorBuilder _ builder: () -> [any Interceptor]) {
        self.interceptors = builder()
    }
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var currentRequest = request
        for interceptor in interceptors {
            currentRequest = try await interceptor.intercept(request: currentRequest, context: context)
        }
        return currentRequest
    }
    
    public func intercept<T: Sendable>(response: Response<T>, context: RequestContext) async throws -> Response<T> {
        var currentResponse = response
        for interceptor in interceptors.reversed() {
            currentResponse = try await interceptor.intercept(response: currentResponse, context: context)
        }
        return currentResponse
    }
}

// MARK: - Interceptor Builder

@resultBuilder
public struct InterceptorBuilder {
    public static func buildBlock(_ interceptors: any Interceptor...) -> [any Interceptor] {
        interceptors
    }
    
    public static func buildArray(_ components: [[any Interceptor]]) -> [any Interceptor] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [any Interceptor]?) -> [any Interceptor] {
        component ?? []
    }
    
    public static func buildEither(first component: [any Interceptor]) -> [any Interceptor] {
        component
    }
    
    public static func buildEither(second component: [any Interceptor]) -> [any Interceptor] {
        component
    }
}
