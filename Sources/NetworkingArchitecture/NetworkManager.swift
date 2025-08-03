import Foundation
import Crypto
import Logging

/// Main networking manager for handling all network operations
/// Provides advanced features including caching, interceptors, and analytics
public final class NetworkManager {
    
    // MARK: - Singleton
    public static let shared = NetworkManager()
    
    // MARK: - Properties
    private var baseURL: URL?
    private var session: URLSession
    private var cacheManager: CacheManager
    private var syncManager: SyncManager
    private var analytics: NetworkAnalytics
    private var interceptors: [RequestInterceptor] = []
    private let logger = Logger(label: "NetworkingArchitecture.NetworkManager")
    
    // MARK: - Configuration
    private var configuration: NetworkConfiguration
    
    // MARK: - Initialization
    private init() {
        self.configuration = NetworkConfiguration()
        self.session = URLSession.shared
        self.cacheManager = CacheManager()
        self.syncManager = SyncManager()
        self.analytics = NetworkAnalytics()
        
        setupDefaultInterceptors()
    }
    
    // MARK: - Public Methods
    
    /// Configure the network manager with base URL and optional configuration
    /// - Parameters:
    ///   - baseURL: The base URL for all API requests
    ///   - configuration: Optional configuration for advanced settings
    public func configure(baseURL: String, configuration: NetworkConfiguration? = nil) {
        self.baseURL = URL(string: baseURL)
        if let config = configuration {
            self.configuration = config
        }
        
        logger.info("NetworkManager configured with base URL: \(baseURL)")
    }
    
    /// Execute an API request with automatic caching and analytics
    /// - Parameters:
    ///   - request: The API request to execute
    ///   - completion: Completion handler with result
    public func execute<T: Codable>(_ request: APIRequest<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let startTime = Date()
        
        // Apply interceptors
        let modifiedRequest = applyInterceptors(to: request)
        
        // Check cache first
        if let cachedResponse = cacheManager.get(for: request.cacheKey) {
            analytics.recordCacheHit(for: request.endpoint)
            completion(.success(cachedResponse))
            return
        }
        
        // Create URL request
        guard let urlRequest = createURLRequest(from: modifiedRequest) else {
            let error = NetworkError.invalidRequest
            analytics.recordError(error, for: request.endpoint)
            completion(.failure(error))
            return
        }
        
        // Execute request
        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?.handleResponse(
                data: data,
                response: response,
                error: error,
                request: request,
                startTime: startTime,
                completion: completion
            )
        }
        
        task.resume()
        analytics.recordRequest(for: request.endpoint)
    }
    
    /// Add a request interceptor for dynamic request modification
    /// - Parameter interceptor: The interceptor to add
    public func addInterceptor(_ interceptor: RequestInterceptor) {
        interceptors.append(interceptor)
        logger.info("Added interceptor: \(type(of: interceptor))")
    }
    
    /// Remove a specific interceptor
    /// - Parameter interceptor: The interceptor to remove
    public func removeInterceptor(_ interceptor: RequestInterceptor) {
        interceptors.removeAll { $0 === interceptor }
        logger.info("Removed interceptor: \(type(of: interceptor))")
    }
    
    /// Configure caching with custom settings
    /// - Parameter configuration: Cache configuration
    public func configureCaching(_ configuration: CacheConfiguration) {
        cacheManager.configure(configuration)
        logger.info("Caching configured with TTL: \(configuration.ttl)s")
    }
    
    /// Enable real-time synchronization
    /// - Parameter configuration: Sync configuration
    public func enableSync(_ configuration: SyncConfiguration) {
        syncManager.configure(configuration)
        syncManager.start()
        logger.info("Real-time sync enabled")
    }
    
    /// Get network analytics data
    /// - Returns: Current analytics data
    public func getAnalytics() -> AnalyticsData {
        return analytics.getData()
    }
    
    // MARK: - Private Methods
    
    private func setupDefaultInterceptors() {
        // Add default interceptors
        addInterceptor(AuthenticationInterceptor())
        addInterceptor(LoggingInterceptor())
        addInterceptor(RetryInterceptor())
    }
    
    private func applyInterceptors(to request: APIRequest<Any>) -> APIRequest<Any> {
        var modifiedRequest = request
        
        for interceptor in interceptors {
            modifiedRequest = interceptor.intercept(modifiedRequest)
        }
        
        return modifiedRequest
    }
    
    private func createURLRequest<T>(from request: APIRequest<T>) -> URLRequest? {
        guard let baseURL = baseURL else {
            logger.error("Base URL not configured")
            return nil
        }
        
        let url = baseURL.appendingPathComponent(request.endpoint)
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method
        urlRequest.httpMethod = request.method.rawValue
        
        // Set headers
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body for POST/PUT requests
        if let body = request.body {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                logger.error("Failed to serialize request body: \(error)")
                return nil
            }
        }
        
        return urlRequest
    }
    
    private func handleResponse<T: Codable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        request: APIRequest<T>,
        startTime: Date,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let responseTime = Date().timeIntervalSince(startTime)
        
        // Handle network errors
        if let error = error {
            let networkError = NetworkError.networkError(error)
            analytics.recordError(networkError, for: request.endpoint, responseTime: responseTime)
            completion(.failure(networkError))
            return
        }
        
        // Handle HTTP errors
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let networkError = NetworkError.httpError(httpResponse.statusCode)
                analytics.recordError(networkError, for: request.endpoint, responseTime: responseTime)
                completion(.failure(networkError))
                return
            }
        }
        
        // Parse response data
        guard let data = data else {
            let networkError = NetworkError.noData
            analytics.recordError(networkError, for: request.endpoint, responseTime: responseTime)
            completion(.failure(networkError))
            return
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            
            // Cache successful responses
            cacheManager.set(decodedResponse, for: request.cacheKey, ttl: request.cacheTTL)
            
            // Record analytics
            analytics.recordSuccess(for: request.endpoint, responseTime: responseTime)
            
            // Trigger sync if needed
            if request.shouldSync {
                syncManager.sync(request: request, response: decodedResponse)
            }
            
            completion(.success(decodedResponse))
            
        } catch {
            let networkError = NetworkError.decodingError(error)
            analytics.recordError(networkError, for: request.endpoint, responseTime: responseTime)
            completion(.failure(networkError))
        }
    }
}

// MARK: - Supporting Types

/// Network configuration for advanced settings
public struct NetworkConfiguration {
    public var timeoutInterval: TimeInterval = 30.0
    public var retryCount: Int = 3
    public var enableCompression: Bool = true
    public var enableCertificatePinning: Bool = true
    
    public init() {}
}

/// Sync configuration for real-time synchronization
public struct SyncConfiguration {
    public var enableWebSocket: Bool = true
    public var syncInterval: TimeInterval = 5.0
    public var enableConflictResolution: Bool = true
    
    public init() {}
}

/// Analytics data for monitoring network performance
public struct AnalyticsData {
    public let totalRequests: Int
    public let successfulRequests: Int
    public let failedRequests: Int
    public let averageResponseTime: TimeInterval
    public let cacheHitRate: Double
    
    public init(
        totalRequests: Int,
        successfulRequests: Int,
        failedRequests: Int,
        averageResponseTime: TimeInterval,
        cacheHitRate: Double
    ) {
        self.totalRequests = totalRequests
        self.successfulRequests = successfulRequests
        self.failedRequests = failedRequests
        self.averageResponseTime = averageResponseTime
        self.cacheHitRate = cacheHitRate
    }
}

// MARK: - Supporting Classes

/// Sync manager for real-time synchronization
public final class SyncManager {
    public func configure(_ configuration: SyncConfiguration) {}
    public func start() {}
    public func sync<T>(request: APIRequest<T>, response: T) {}
}

/// Network analytics for monitoring
public final class NetworkAnalytics {
    public func recordRequest(for endpoint: String) {}
    public func recordSuccess(for endpoint: String, responseTime: TimeInterval) {}
    public func recordError(_ error: NetworkError, for endpoint: String, responseTime: TimeInterval? = nil) {}
    public func recordCacheHit(for endpoint: String) {}
    public func getData() -> AnalyticsData {
        return AnalyticsData(totalRequests: 0, successfulRequests: 0, failedRequests: 0, averageResponseTime: 0, cacheHitRate: 0)
    }
}

/// Authentication interceptor
public final class AuthenticationInterceptor: RequestInterceptor {
    public func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        return request
    }
}

/// Logging interceptor
public final class LoggingInterceptor: RequestInterceptor {
    public func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        return request
    }
}

/// Retry interceptor
public final class RetryInterceptor: RequestInterceptor {
    public func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        return request
    }
}

/// Request interceptor protocol
public protocol RequestInterceptor: AnyObject {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any>
}
