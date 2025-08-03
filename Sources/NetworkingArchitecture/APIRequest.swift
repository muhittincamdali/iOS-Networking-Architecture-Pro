import Foundation

/// Represents an API request with comprehensive configuration options
public struct APIRequest<T: Codable> {
    
    // MARK: - Properties
    public let endpoint: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: [String: Any]?
    public let cacheKey: String
    public let cacheTTL: TimeInterval
    public let shouldSync: Bool
    public let retryCount: Int
    public let timeout: TimeInterval
    
    // MARK: - Initialization
    public init(
        endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: [String: Any]? = nil,
        cacheKey: String? = nil,
        cacheTTL: TimeInterval = 3600,
        shouldSync: Bool = false,
        retryCount: Int = 3,
        timeout: TimeInterval = 30.0
    ) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.body = body
        self.cacheKey = cacheKey ?? endpoint
        self.cacheTTL = cacheTTL
        self.shouldSync = shouldSync
        self.retryCount = retryCount
        self.timeout = timeout
    }
    
    // MARK: - Convenience Initializers
    
    /// Create a GET request
    public static func get(_ endpoint: String, headers: [String: String] = [:]) -> APIRequest<T> {
        return APIRequest(endpoint: endpoint, method: .get, headers: headers)
    }
    
    /// Create a POST request with body
    public static func post(_ endpoint: String, body: [String: Any], headers: [String: String] = [:]) -> APIRequest<T> {
        return APIRequest(endpoint: endpoint, method: .post, headers: headers, body: body)
    }
    
    /// Create a PUT request with body
    public static func put(_ endpoint: String, body: [String: Any], headers: [String: String] = [:]) -> APIRequest<T> {
        return APIRequest(endpoint: endpoint, method: .put, headers: headers, body: body)
    }
    
    /// Create a DELETE request
    public static func delete(_ endpoint: String, headers: [String: String] = [:]) -> APIRequest<T> {
        return APIRequest(endpoint: endpoint, method: .delete, headers: headers)
    }
    
    /// Create a PATCH request with body
    public static func patch(_ endpoint: String, body: [String: Any], headers: [String: String] = [:]) -> APIRequest<T> {
        return APIRequest(endpoint: endpoint, method: .patch, headers: headers, body: body)
    }
}

// MARK: - HTTP Method

/// HTTP methods supported by the networking framework
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
}

// MARK: - Network Error

/// Comprehensive network error types
public enum NetworkError: Error, LocalizedError {
    case invalidRequest
    case noData
    case decodingError(Error)
    case networkError(Error)
    case httpError(Int)
    case timeout
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case cacheError
    case syncError
    
    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request configuration"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .timeout:
            return "Request timed out"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Internal server error"
        case .cacheError:
            return "Cache operation failed"
        case .syncError:
            return "Synchronization failed"
        }
    }
}

// MARK: - Request Builder

/// Builder pattern for creating complex API requests
public class APIRequestBuilder<T: Codable> {
    private var endpoint: String = ""
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var body: [String: Any]?
    private var cacheKey: String?
    private var cacheTTL: TimeInterval = 3600
    private var shouldSync: Bool = false
    private var retryCount: Int = 3
    private var timeout: TimeInterval = 30.0
    
    public init() {}
    
    /// Set the endpoint
    @discardableResult
    public func endpoint(_ endpoint: String) -> APIRequestBuilder<T> {
        self.endpoint = endpoint
        return self
    }
    
    /// Set the HTTP method
    @discardableResult
    public func method(_ method: HTTPMethod) -> APIRequestBuilder<T> {
        self.method = method
        return self
    }
    
    /// Add a header
    @discardableResult
    public func header(_ key: String, value: String) -> APIRequestBuilder<T> {
        headers[key] = value
        return self
    }
    
    /// Add multiple headers
    @discardableResult
    public func headers(_ headers: [String: String]) -> APIRequestBuilder<T> {
        self.headers.merge(headers) { _, new in new }
        return self
    }
    
    /// Set the request body
    @discardableResult
    public func body(_ body: [String: Any]) -> APIRequestBuilder<T> {
        self.body = body
        return self
    }
    
    /// Set the cache key
    @discardableResult
    public func cacheKey(_ cacheKey: String) -> APIRequestBuilder<T> {
        self.cacheKey = cacheKey
        return self
    }
    
    /// Set the cache TTL
    @discardableResult
    public func cacheTTL(_ ttl: TimeInterval) -> APIRequestBuilder<T> {
        self.cacheTTL = ttl
        return self
    }
    
    /// Enable synchronization
    @discardableResult
    public func shouldSync(_ shouldSync: Bool) -> APIRequestBuilder<T> {
        self.shouldSync = shouldSync
        return self
    }
    
    /// Set retry count
    @discardableResult
    public func retryCount(_ count: Int) -> APIRequestBuilder<T> {
        self.retryCount = count
        return self
    }
    
    /// Set timeout
    @discardableResult
    public func timeout(_ timeout: TimeInterval) -> APIRequestBuilder<T> {
        self.timeout = timeout
        return self
    }
    
    /// Build the API request
    public func build() -> APIRequest<T> {
        return APIRequest<T>(
            endpoint: endpoint,
            method: method,
            headers: headers,
            body: body,
            cacheKey: cacheKey,
            cacheTTL: cacheTTL,
            shouldSync: shouldSync,
            retryCount: retryCount,
            timeout: timeout
        )
    }
}

// MARK: - Convenience Extensions

public extension APIRequestBuilder {
    /// Create a GET request
    static func get<T>(_ endpoint: String) -> APIRequestBuilder<T> {
        return APIRequestBuilder<T>().endpoint(endpoint).method(.get)
    }
    
    /// Create a POST request
    static func post<T>(_ endpoint: String) -> APIRequestBuilder<T> {
        return APIRequestBuilder<T>().endpoint(endpoint).method(.post)
    }
    
    /// Create a PUT request
    static func put<T>(_ endpoint: String) -> APIRequestBuilder<T> {
        return APIRequestBuilder<T>().endpoint(endpoint).method(.put)
    }
    
    /// Create a DELETE request
    static func delete<T>(_ endpoint: String) -> APIRequestBuilder<T> {
        return APIRequestBuilder<T>().endpoint(endpoint).method(.delete)
    }
    
    /// Create a PATCH request
    static func patch<T>(_ endpoint: String) -> APIRequestBuilder<T> {
        return APIRequestBuilder<T>().endpoint(endpoint).method(.patch)
    }
} 