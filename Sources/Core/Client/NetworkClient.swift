// NetworkClient.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import Logging

/// Main network client for executing requests
public actor NetworkClient {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let configuration: NetworkingConfiguration
    private var interceptors: [any Interceptor]
    private var authenticator: (any Authenticator)?
    private let cache: any NetworkCache
    private let retryHandler: RetryHandler
    private let offlineQueue: OfflineQueue
    private let metrics: NetworkMetrics
    private let logger: Logger
    
    // MARK: - Initialization
    
    public init(
        configuration: NetworkingConfiguration = .default,
        session: URLSession? = nil,
        interceptors: [any Interceptor] = [],
        authenticator: (any Authenticator)? = nil,
        cache: (any NetworkCache)? = nil
    ) {
        self.configuration = configuration
        self.interceptors = interceptors
        self.authenticator = authenticator
        self.cache = cache ?? InMemoryCache(maxSize: configuration.maxCacheSize)
        self.retryHandler = RetryHandler(configuration: configuration)
        self.offlineQueue = OfflineQueue(maxSize: configuration.maxOfflineQueueSize)
        self.metrics = NetworkMetrics()
        self.logger = Logger(label: "NetworkClient")
        
        // Configure URLSession
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.waitsForConnectivity = true
        sessionConfig.httpAdditionalHeaders = configuration.defaultHeaders
        
        if let userAgent = configuration.userAgent {
            sessionConfig.httpAdditionalHeaders?["User-Agent"] = userAgent
        }
        
        self.session = session ?? URLSession(configuration: sessionConfig)
    }
    
    // MARK: - Request Execution
    
    /// Execute a request and return decoded response
    public func execute<T: Decodable & Sendable>(_ request: Request<T>) async throws -> Response<T> {
        let context = RequestContext(requestId: request.id, tags: request.tags)
        var urlRequest = try request.endpoint.asURLRequest()
        
        // Apply interceptors (request phase)
        for interceptor in interceptors {
            urlRequest = try await interceptor.intercept(request: urlRequest, context: context)
        }
        
        // Apply authentication
        if request.endpoint.requiresAuthentication, let auth = authenticator {
            urlRequest = try await auth.authenticate(request: urlRequest)
        }
        
        // Check cache
        if request.endpoint.cachePolicy.shouldReadFromCache,
           request.endpoint.method.isCacheable {
            if let cached: T = try await checkCache(for: urlRequest) {
                if configuration.loggingEnabled {
                    logger.info("Cache hit for \(urlRequest.url?.absoluteString ?? "")")
                }
                return Response(
                    data: cached,
                    statusCode: 200,
                    metadata: ResponseMetadata(requestId: request.id, fromCache: true)
                )
            }
        }
        
        // Execute with retry
        let response = try await executeWithRetry(
            urlRequest: urlRequest,
            context: context,
            retryPolicy: request.endpoint.retryPolicy
        )
        
        // Decode response
        let decoder = request.decoder ?? configuration.jsonDecoder
        let decoded = try decoder.decode(T.self, from: response.data)
        
        // Cache response
        if request.endpoint.cachePolicy.shouldWriteToCache {
            try await cacheResponse(response.data, for: urlRequest, ttl: request.endpoint.cachePolicy.ttl)
        }
        
        // Apply interceptors (response phase)
        var result = Response(
            data: decoded,
            statusCode: response.statusCode,
            headers: response.headers,
            url: response.url,
            metadata: ResponseMetadata(
                requestId: request.id,
                responseSize: response.data.count,
                retryCount: context.retryCount
            )
        )
        
        for interceptor in interceptors.reversed() {
            result = try await interceptor.intercept(response: result, context: context)
        }
        
        return result
    }
    
    /// Execute a request and return raw response
    public func executeRaw(endpoint: any Endpoint) async throws -> RawResponse {
        var urlRequest = try endpoint.asURLRequest()
        let context = RequestContext()
        
        // Apply interceptors
        for interceptor in interceptors {
            urlRequest = try await interceptor.intercept(request: urlRequest, context: context)
        }
        
        // Apply authentication
        if endpoint.requiresAuthentication, let auth = authenticator {
            urlRequest = try await auth.authenticate(request: urlRequest)
        }
        
        let response = try await executeWithRetry(
            urlRequest: urlRequest,
            context: context,
            retryPolicy: endpoint.retryPolicy
        )
        
        return response
    }
    
    /// Execute request without decoding
    public func execute(endpoint: any Endpoint) async throws -> EmptyResponse {
        _ = try await executeRaw(endpoint: endpoint)
        return EmptyResponse()
    }
    
    // MARK: - Upload/Download
    
    /// Upload data with progress
    public func upload(
        data: Data,
        to endpoint: any Endpoint,
        onProgress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> RawResponse {
        var urlRequest = try endpoint.asURLRequest()
        urlRequest.httpBody = data
        
        let context = RequestContext()
        
        // Apply authentication
        if endpoint.requiresAuthentication, let auth = authenticator {
            urlRequest = try await auth.authenticate(request: urlRequest)
        }
        
        let (responseData, urlResponse) = try await session.data(for: urlRequest)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(reason: "Not an HTTP response")
        }
        
        return RawResponse(
            data: responseData,
            statusCode: httpResponse.statusCode,
            headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
            url: httpResponse.url
        )
    }
    
    /// Download data with progress
    public func download(
        from endpoint: any Endpoint,
        onProgress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> Data {
        let urlRequest = try endpoint.asURLRequest()
        let (data, _) = try await session.data(for: urlRequest)
        return data
    }
    
    // MARK: - Configuration
    
    /// Add an interceptor
    public func addInterceptor(_ interceptor: any Interceptor) {
        interceptors.append(interceptor)
    }
    
    /// Remove all interceptors
    public func clearInterceptors() {
        interceptors.removeAll()
    }
    
    /// Set authenticator
    public func setAuthenticator(_ authenticator: any Authenticator) {
        self.authenticator = authenticator
    }
    
    /// Clear cache
    public func clearCache() async {
        await cache.clear()
    }
    
    /// Get metrics
    public func getMetrics() -> NetworkMetrics.Snapshot {
        metrics.snapshot()
    }
    
    // MARK: - Private Methods
    
    private func executeWithRetry(
        urlRequest: URLRequest,
        context: RequestContext,
        retryPolicy: RetryPolicy
    ) async throws -> RawResponse {
        var lastError: Error?
        var mutableContext = context
        
        for attempt in 0...retryPolicy.maxAttempts {
            mutableContext.retryCount = attempt
            
            do {
                let startTime = Date()
                let (data, urlResponse) = try await session.data(for: urlRequest)
                let endTime = Date()
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse(reason: "Not an HTTP response")
                }
                
                // Record metrics
                metrics.recordRequest(
                    url: urlRequest.url?.absoluteString ?? "",
                    statusCode: httpResponse.statusCode,
                    duration: endTime.timeIntervalSince(startTime),
                    size: data.count
                )
                
                // Check for HTTP errors
                try validateHTTPResponse(httpResponse, data: data)
                
                return RawResponse(
                    data: data,
                    statusCode: httpResponse.statusCode,
                    headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
                    url: httpResponse.url
                )
                
            } catch let error as NetworkError {
                lastError = error
                
                // Check if we should retry
                guard error.isRecoverable && attempt < retryPolicy.maxAttempts else {
                    throw error
                }
                
                // Calculate delay with exponential backoff
                let delay = retryHandler.calculateDelay(for: attempt, policy: retryPolicy)
                
                if configuration.loggingEnabled {
                    logger.warning("Request failed, retrying in \(delay)s (attempt \(attempt + 1)/\(retryPolicy.maxAttempts))")
                }
                
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
            } catch let urlError as URLError {
                let networkError = NetworkError.from(urlError)
                lastError = networkError
                
                guard networkError.isRecoverable && attempt < retryPolicy.maxAttempts else {
                    throw networkError
                }
                
                let delay = retryHandler.calculateDelay(for: attempt, policy: retryPolicy)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
            } catch {
                throw NetworkError.unknown(reason: error.localizedDescription)
            }
        }
        
        throw lastError ?? NetworkError.maxRetriesExceeded(attempts: retryPolicy.maxAttempts)
    }
    
    private func validateHTTPResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200..<300:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            let retryAfter = response.value(forHTTPHeaderField: "Retry-After")
                .flatMap { TimeInterval($0) }
            throw NetworkError.rateLimited(retryAfter: retryAfter)
        case 400..<500:
            throw NetworkError.clientError(statusCode: response.statusCode, data: data)
        case 500..<600:
            throw NetworkError.serverError(statusCode: response.statusCode, data: data)
        default:
            throw NetworkError.invalidResponse(reason: "Unexpected status code: \(response.statusCode)")
        }
    }
    
    private func checkCache<T: Decodable>(for request: URLRequest) async throws -> T? {
        guard let url = request.url else { return nil }
        let key = CacheKey(url: url, method: request.httpMethod ?? "GET")
        return try await cache.get(key) as? T
    }
    
    private func cacheResponse(_ data: Data, for request: URLRequest, ttl: TimeInterval?) async throws {
        guard let url = request.url else { return }
        let key = CacheKey(url: url, method: request.httpMethod ?? "GET")
        try await cache.set(data, for: key, ttl: ttl)
    }
}

// MARK: - Retry Handler

/// Handles retry logic with exponential backoff
public struct RetryHandler: Sendable {
    private let configuration: NetworkingConfiguration
    
    public init(configuration: NetworkingConfiguration) {
        self.configuration = configuration
    }
    
    /// Calculate delay for retry attempt
    public func calculateDelay(for attempt: Int, policy: RetryPolicy) -> TimeInterval {
        switch policy.strategy {
        case .immediate:
            return 0
        case .constant(let delay):
            return delay
        case .exponential(let base, let multiplier):
            let delay = base * pow(multiplier, Double(attempt))
            return min(delay, configuration.retryMaxDelay)
        case .custom(let calculator):
            return calculator(attempt)
        }
    }
}

// MARK: - Network Metrics

/// Collects network performance metrics
public final class NetworkMetrics: @unchecked Sendable {
    private let lock = NSLock()
    private var totalRequests: Int = 0
    private var successfulRequests: Int = 0
    private var failedRequests: Int = 0
    private var totalDuration: TimeInterval = 0
    private var totalSize: Int = 0
    
    public func recordRequest(url: String, statusCode: Int, duration: TimeInterval, size: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        totalRequests += 1
        if (200..<300).contains(statusCode) {
            successfulRequests += 1
        } else {
            failedRequests += 1
        }
        totalDuration += duration
        totalSize += size
    }
    
    public func snapshot() -> Snapshot {
        lock.lock()
        defer { lock.unlock() }
        
        return Snapshot(
            totalRequests: totalRequests,
            successfulRequests: successfulRequests,
            failedRequests: failedRequests,
            averageDuration: totalRequests > 0 ? totalDuration / Double(totalRequests) : 0,
            totalDataTransferred: totalSize
        )
    }
    
    public struct Snapshot: Sendable {
        public let totalRequests: Int
        public let successfulRequests: Int
        public let failedRequests: Int
        public let averageDuration: TimeInterval
        public let totalDataTransferred: Int
        
        public var successRate: Double {
            totalRequests > 0 ? Double(successfulRequests) / Double(totalRequests) : 0
        }
    }
}
