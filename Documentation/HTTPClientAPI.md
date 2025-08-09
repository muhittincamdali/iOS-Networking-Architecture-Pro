# 🔗 HTTP Client API Reference

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [📦 HTTPClientManager](#-httpclientmanager)
- [📤 HTTPRequest](#-httprequest)
- [📥 HTTPResponse](#-httpresponse)
- [⚙️ HTTPClientConfiguration](#-httpclientconfiguration)
- [🛠️ RequestInterceptorManager](#-requestinterceptormanager)
- [❌ HTTPClientError](#-httpclienterror)
- [📊 HTTPClientStats](#-httpclientstats)
- [📱 Usage Examples](#-usage-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**HTTP Client API Reference** provides comprehensive documentation for all HTTP client-related classes, protocols, and utilities in the iOS Networking Architecture Pro framework.

### 🎯 Key Components

- **HTTPClientManager**: Main HTTP client implementation
- **HTTPRequest**: Request structure and builder
- **HTTPResponse**: Response structure and parsing
- **HTTPClientConfiguration**: Client configuration options
- **RequestInterceptorManager**: Request/response interceptors
- **HTTPClientError**: Error types and handling
- **HTTPClientStats**: Performance and statistics

---

## 📦 HTTPClientManager

### Class Definition

```swift
public class HTTPClientManager {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: HTTPClientConfiguration
    
    /// Request interceptor manager
    public private(set) var interceptorManager: RequestInterceptorManager
    
    /// HTTP client statistics
    public private(set) var stats: HTTPClientStats
    
    /// Whether the client is active
    public var isActive: Bool
    
    /// Current session
    public private(set) var session: URLSession
    
    // MARK: - Event Handlers
    
    /// Called when request starts
    public var onRequestStart: ((HTTPRequest) -> Void)?
    
    /// Called when request completes
    public var onRequestComplete: ((HTTPRequest, HTTPResponse) -> Void)?
    
    /// Called when request fails
    public var onRequestFailure: ((HTTPRequest, HTTPClientError) -> Void)?
    
    /// Called when response is received
    public var onResponseReceived: ((HTTPResponse) -> Void)?
}
```

### Initialization

```swift
// Create HTTP client manager
let httpClient = HTTPClientManager()

// Create with configuration
let config = HTTPClientConfiguration()
config.baseURL = "https://api.company.com"
let httpClient = HTTPClientManager(configuration: config)

// Create with custom session
let session = URLSession(configuration: .default)
let httpClient = HTTPClientManager(session: session)
```

### Configuration Methods

```swift
// Configure HTTP client
func configure(_ configuration: HTTPClientConfiguration)

// Update configuration
func updateConfiguration(_ configuration: HTTPClientConfiguration)

// Reset configuration to defaults
func resetConfiguration()
```

### Request Methods

```swift
// Execute HTTP request
func execute(_ request: HTTPRequest, completion: @escaping (Result<HTTPResponse, HTTPClientError>) -> Void)

// Execute request with interceptors
func executeWithInterceptors(_ request: HTTPRequest, interceptors: [RequestInterceptor], completion: @escaping (Result<HTTPResponse, HTTPClientError>) -> Void)

// Execute request with custom timeout
func execute(_ request: HTTPRequest, timeout: TimeInterval, completion: @escaping (Result<HTTPResponse, HTTPClientError>) -> Void)

// Execute request with retry
func executeWithRetry(_ request: HTTPRequest, maxRetries: Int, completion: @escaping (Result<HTTPResponse, HTTPClientError>) -> Void)
```

### Utility Methods

```swift
// Cancel all pending requests
func cancelAllRequests()

// Cancel specific request
func cancelRequest(_ request: HTTPRequest)

// Get request statistics
func getRequestStats() -> HTTPRequestStats

// Clear request cache
func clearCache()

// Set cache policy
func setCachePolicy(_ policy: HTTPCachePolicy)
```

---

## 📤 HTTPRequest

### Structure Definition

```swift
public struct HTTPRequest {
    /// Request method
    public let method: HTTPMethod
    
    /// Request URL
    public let url: URL
    
    /// Request headers
    public var headers: [String: String]
    
    /// Request body
    public var body: Data?
    
    /// Request parameters
    public var parameters: [String: Any]
    
    /// Request timeout
    public var timeout: TimeInterval
    
    /// Request ID
    public let id: String
    
    /// Request timestamp
    public let timestamp: Date
    
    /// Request metadata
    public var metadata: [String: Any]
}
```

### HTTP Methods

```swift
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}
```

### Request Builder

```swift
public class HTTPRequestBuilder {
    private var request: HTTPRequest
    
    public init() {
        self.request = HTTPRequest()
    }
    
    // Set HTTP method
    func method(_ method: HTTPMethod) -> HTTPRequestBuilder
    
    // Set URL
    func url(_ url: URL) -> HTTPRequestBuilder
    
    // Set URL string
    func url(_ urlString: String) -> HTTPRequestBuilder
    
    // Add header
    func header(_ key: String, _ value: String) -> HTTPRequestBuilder
    
    // Add headers
    func headers(_ headers: [String: String]) -> HTTPRequestBuilder
    
    // Set body
    func body(_ data: Data) -> HTTPRequestBuilder
    
    // Set JSON body
    func jsonBody<T: Encodable>(_ object: T) -> HTTPRequestBuilder
    
    // Set form data
    func formData(_ data: [String: String]) -> HTTPRequestBuilder
    
    // Add parameter
    func parameter(_ key: String, _ value: Any) -> HTTPRequestBuilder
    
    // Add parameters
    func parameters(_ params: [String: Any]) -> HTTPRequestBuilder
    
    // Set timeout
    func timeout(_ timeout: TimeInterval) -> HTTPRequestBuilder
    
    // Add metadata
    func metadata(_ key: String, _ value: Any) -> HTTPRequestBuilder
    
    // Build request
    func build() -> HTTPRequest
}
```

### Usage Examples

```swift
// Create GET request
let getRequest = HTTPRequestBuilder()
    .method(.get)
    .url("https://api.company.com/users/123")
    .header("Authorization", "Bearer token")
    .header("Content-Type", "application/json")
    .timeout(30.0)
    .build()

// Create POST request with JSON body
let user = User(name: "John", email: "john@company.com")
let postRequest = HTTPRequestBuilder()
    .method(.post)
    .url("https://api.company.com/users")
    .header("Authorization", "Bearer token")
    .header("Content-Type", "application/json")
    .jsonBody(user)
    .timeout(30.0)
    .build()

// Create PUT request with form data
let putRequest = HTTPRequestBuilder()
    .method(.put)
    .url("https://api.company.com/users/123")
    .header("Authorization", "Bearer token")
    .formData([
        "name": "John Doe",
        "email": "john.doe@company.com"
    ])
    .timeout(30.0)
    .build()

// Create DELETE request
let deleteRequest = HTTPRequestBuilder()
    .method(.delete)
    .url("https://api.company.com/users/123")
    .header("Authorization", "Bearer token")
    .timeout(30.0)
    .build()
```

---

## 📥 HTTPResponse

### Structure Definition

```swift
public struct HTTPResponse {
    /// Response status code
    public let statusCode: Int
    
    /// Response headers
    public let headers: [String: String]
    
    /// Response body
    public let body: Data?
    
    /// Response URL
    public let url: URL?
    
    /// Response timestamp
    public let timestamp: Date
    
    /// Response size
    public let size: Int
    
    /// Response duration
    public let duration: TimeInterval
    
    /// Response metadata
    public var metadata: [String: Any]
}
```

### Status Code Categories

```swift
public extension HTTPResponse {
    /// Whether response is successful (2xx)
    var isSuccess: Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    /// Whether response is client error (4xx)
    var isClientError: Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    /// Whether response is server error (5xx)
    var isServerError: Bool {
        return statusCode >= 500 && statusCode < 600
    }
    
    /// Whether response is redirect (3xx)
    var isRedirect: Bool {
        return statusCode >= 300 && statusCode < 400
    }
    
    /// Whether response is informational (1xx)
    var isInformational: Bool {
        return statusCode >= 100 && statusCode < 200
    }
}
```

### Response Parsing

```swift
public extension HTTPResponse {
    /// Parse response as text
    func asText() -> String?
    
    /// Parse response as JSON
    func asJSON<T: Decodable>(_ type: T.Type) -> T?
    
    /// Parse response as dictionary
    func asDictionary() -> [String: Any]?
    
    /// Parse response as array
    func asArray() -> [Any]?
    
    /// Get response content type
    var contentType: String?
    
    /// Get response encoding
    var encoding: String.Encoding?
    
    /// Get response size in bytes
    var sizeInBytes: Int { size }
    
    /// Get response size in KB
    var sizeInKB: Double { Double(size) / 1024.0 }
    
    /// Get response size in MB
    var sizeInMB: Double { Double(size) / (1024.0 * 1024.0) }
}
```

### Usage Examples

```swift
// Parse JSON response
httpClient.execute(userRequest) { result in
    switch result {
    case .success(let response):
        if let user = response.asJSON(User.self) {
            print("✅ User retrieved: \(user.name)")
        } else {
            print("❌ Failed to parse user response")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}

// Parse text response
httpClient.execute(textRequest) { result in
    switch result {
    case .success(let response):
        if let text = response.asText() {
            print("✅ Text response: \(text)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}

// Check response status
httpClient.execute(apiRequest) { result in
    switch result {
    case .success(let response):
        if response.isSuccess {
            print("✅ Request successful")
        } else if response.isClientError {
            print("❌ Client error: \(response.statusCode)")
        } else if response.isServerError {
            print("❌ Server error: \(response.statusCode)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

---

## ⚙️ HTTPClientConfiguration

### Structure Definition

```swift
public struct HTTPClientConfiguration {
    /// Base URL for requests
    public var baseURL: String?
    
    /// Request timeout in seconds
    public var timeout: TimeInterval
    
    /// Maximum retry attempts
    public var maxRetries: Int
    
    /// Enable request caching
    public var enableCaching: Bool
    
    /// Enable request logging
    public var enableLogging: Bool
    
    /// Enable request compression
    public var enableCompression: Bool
    
    /// Enable SSL certificate validation
    public var enableCertificateValidation: Bool
    
    /// Enable SSL certificate pinning
    public var enableSSLPinning: Bool
    
    /// Custom headers for all requests
    public var defaultHeaders: [String: String]
    
    /// Request interceptor configuration
    public var interceptorConfig: InterceptorConfiguration
    
    /// Cache configuration
    public var cacheConfig: CacheConfiguration
    
    /// Security configuration
    public var securityConfig: SecurityConfiguration
}
```

### Default Configuration

```swift
public extension HTTPClientConfiguration {
    /// Default configuration
    static let `default` = HTTPClientConfiguration(
        baseURL: nil,
        timeout: 30.0,
        maxRetries: 3,
        enableCaching: true,
        enableLogging: false,
        enableCompression: true,
        enableCertificateValidation: true,
        enableSSLPinning: false,
        defaultHeaders: [:],
        interceptorConfig: .default,
        cacheConfig: .default,
        securityConfig: .default
    )
}
```

### Configuration Examples

```swift
// Basic configuration
let basicConfig = HTTPClientConfiguration(
    baseURL: "https://api.company.com",
    timeout: 30.0,
    maxRetries: 3,
    enableCaching: true
)

// Advanced configuration
let advancedConfig = HTTPClientConfiguration(
    baseURL: "https://api.company.com",
    timeout: 60.0,
    maxRetries: 5,
    enableCaching: true,
    enableLogging: true,
    enableCompression: true,
    enableCertificateValidation: true,
    enableSSLPinning: true,
    defaultHeaders: [
        "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
        "Accept": "application/json",
        "Accept-Encoding": "gzip, deflate"
    ]
)
```

---

## 🛠️ RequestInterceptorManager

### Class Definition

```swift
public class RequestInterceptorManager {
    /// Request interceptors
    public private(set) var requestInterceptors: [RequestInterceptor]
    
    /// Response interceptors
    public private(set) var responseInterceptors: [ResponseInterceptor]
    
    /// Error interceptors
    public private(set) var errorInterceptors: [ErrorInterceptor]
    
    public init() {
        self.requestInterceptors = []
        self.responseInterceptors = []
        self.errorInterceptors = []
    }
}
```

### Interceptor Types

```swift
// Request interceptor
public protocol RequestInterceptor {
    func intercept(_ request: HTTPRequest) -> HTTPRequest
}

// Response interceptor
public protocol ResponseInterceptor {
    func intercept(_ response: HTTPResponse) -> HTTPResponse
}

// Error interceptor
public protocol ErrorInterceptor {
    func intercept(_ error: HTTPClientError) -> HTTPClientError
}
```

### Built-in Interceptors

```swift
// Authentication interceptor
public class AuthenticationInterceptor: RequestInterceptor {
    private let tokenProvider: () -> String?
    
    public init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    public func intercept(_ request: HTTPRequest) -> HTTPRequest {
        var modifiedRequest = request
        if let token = tokenProvider() {
            modifiedRequest.headers["Authorization"] = "Bearer \(token)"
        }
        return modifiedRequest
    }
}

// Logging interceptor
public class LoggingInterceptor: RequestInterceptor {
    public func intercept(_ request: HTTPRequest) -> HTTPRequest {
        print("🌐 HTTP Request: \(request.method.rawValue) \(request.url)")
        print("📋 Headers: \(request.headers)")
        if let body = request.body {
            print("📦 Body: \(String(data: body, encoding: .utf8) ?? "")")
        }
        return request
    }
}

// Caching interceptor
public class CachingInterceptor: RequestInterceptor {
    private let cache: HTTPCache
    
    public init(cache: HTTPCache) {
        self.cache = cache
    }
    
    public func intercept(_ request: HTTPRequest) -> HTTPRequest {
        if let cachedResponse = cache.get(for: request) {
            // Return cached response
            return request
        }
        return request
    }
}
```

### Interceptor Management

```swift
// Add request interceptor
func addRequestInterceptor(_ interceptor: RequestInterceptor)

// Add response interceptor
func addResponseInterceptor(_ interceptor: ResponseInterceptor)

// Add error interceptor
func addErrorInterceptor(_ interceptor: ErrorInterceptor)

// Remove request interceptor
func removeRequestInterceptor(_ interceptor: RequestInterceptor)

// Remove response interceptor
func removeResponseInterceptor(_ interceptor: ResponseInterceptor)

// Remove error interceptor
func removeErrorInterceptor(_ interceptor: ErrorInterceptor)

// Clear all interceptors
func clearAllInterceptors()

// Clear request interceptors
func clearRequestInterceptors()

// Clear response interceptors
func clearResponseInterceptors()

// Clear error interceptors
func clearErrorInterceptors()
```

### Usage Examples

```swift
// Create interceptor manager
let interceptorManager = RequestInterceptorManager()

// Add authentication interceptor
let authInterceptor = AuthenticationInterceptor {
    return getAccessToken()
}
interceptorManager.addRequestInterceptor(authInterceptor)

// Add logging interceptor
let loggingInterceptor = LoggingInterceptor()
interceptorManager.addRequestInterceptor(loggingInterceptor)

// Add caching interceptor
let cache = HTTPCache()
let cachingInterceptor = CachingInterceptor(cache: cache)
interceptorManager.addRequestInterceptor(cachingInterceptor)

// Use interceptors with HTTP client
httpClient.interceptorManager = interceptorManager

// Execute request with interceptors
httpClient.executeWithInterceptors(
    request,
    interceptors: interceptorManager.requestInterceptors
) { result in
    switch result {
    case .success(let response):
        print("✅ Request successful")
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

---

## ❌ HTTPClientError

### Error Types

```swift
public enum HTTPClientError: Error, LocalizedError {
    /// Network error
    case networkError(String)
    
    /// Timeout error
    case timeoutError(String)
    
    /// SSL/TLS error
    case sslError(String)
    
    /// Authentication error
    case authenticationError(String)
    
    /// Authorization error
    case authorizationError(String)
    
    /// Server error
    case serverError(String)
    
    /// Client error
    case clientError(String)
    
    /// Parsing error
    case parsingError(String)
    
    /// Configuration error
    case configurationError(String)
    
    /// Cache error
    case cacheError(String)
    
    /// Interceptor error
    case interceptorError(String)
    
    /// Unknown error
    case unknownError(String)
}
```

### Error Properties

```swift
public extension HTTPClientError {
    /// Error description
    var errorDescription: String? {
        switch self {
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .timeoutError(let reason):
            return "Timeout error: \(reason)"
        case .sslError(let reason):
            return "SSL error: \(reason)"
        case .authenticationError(let reason):
            return "Authentication error: \(reason)"
        case .authorizationError(let reason):
            return "Authorization error: \(reason)"
        case .serverError(let reason):
            return "Server error: \(reason)"
        case .clientError(let reason):
            return "Client error: \(reason)"
        case .parsingError(let reason):
            return "Parsing error: \(reason)"
        case .configurationError(let reason):
            return "Configuration error: \(reason)"
        case .cacheError(let reason):
            return "Cache error: \(reason)"
        case .interceptorError(let reason):
            return "Interceptor error: \(reason)"
        case .unknownError(let reason):
            return "Unknown error: \(reason)"
        }
    }
    
    /// Error recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Check your internet connection and try again"
        case .timeoutError:
            return "Increase timeout value or check network speed"
        case .sslError:
            return "Check your SSL certificate configuration"
        case .authenticationError:
            return "Check your authentication credentials"
        case .authorizationError:
            return "Check your authorization permissions"
        case .serverError:
            return "Contact server administrator"
        case .clientError:
            return "Check your request parameters"
        case .parsingError:
            return "Check your response format"
        case .configurationError:
            return "Check your HTTP client configuration"
        case .cacheError:
            return "Check your cache configuration"
        case .interceptorError:
            return "Check your interceptor configuration"
        case .unknownError:
            return "Try again or contact support"
        }
    }
}
```

---

## 📊 HTTPClientStats

### Structure Definition

```swift
public struct HTTPClientStats {
    /// Total requests made
    public let totalRequests: Int
    
    /// Successful requests
    public let successfulRequests: Int
    
    /// Failed requests
    public let failedRequests: Int
    
    /// Average response time
    public let averageResponseTime: TimeInterval
    
    /// Total bytes sent
    public let totalBytesSent: Int64
    
    /// Total bytes received
    public let totalBytesReceived: Int64
    
    /// Cache hit rate
    public let cacheHitRate: Double
    
    /// Error rate
    public let errorRate: Double
    
    /// Success rate
    public let successRate: Double
}
```

### Statistics Calculation

```swift
public extension HTTPClientStats {
    /// Calculate success rate
    var successRate: Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(successfulRequests) / Double(totalRequests)
    }
    
    /// Calculate error rate
    var errorRate: Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(failedRequests) / Double(totalRequests)
    }
    
    /// Calculate cache hit rate
    var cacheHitRate: Double {
        // Implementation depends on cache statistics
        return 0.0
    }
    
    /// Get statistics as dictionary
    var asDictionary: [String: Any] {
        return [
            "totalRequests": totalRequests,
            "successfulRequests": successfulRequests,
            "failedRequests": failedRequests,
            "averageResponseTime": averageResponseTime,
            "totalBytesSent": totalBytesSent,
            "totalBytesReceived": totalBytesReceived,
            "cacheHitRate": cacheHitRate,
            "errorRate": errorRate,
            "successRate": successRate
        ]
    }
}
```

---

## 📱 Usage Examples

### Basic HTTP Client Usage

```swift
// Create HTTP client
let httpClient = HTTPClientManager()

// Configure client
let config = HTTPClientConfiguration(
    baseURL: "https://api.company.com",
    timeout: 30.0,
    maxRetries: 3,
    enableCaching: true
)
httpClient.configure(config)

// Create GET request
let getRequest = HTTPRequestBuilder()
    .method(.get)
    .url("https://api.company.com/users/123")
    .header("Authorization", "Bearer token")
    .build()

// Execute request
httpClient.execute(getRequest) { result in
    switch result {
    case .success(let response):
        if let user = response.asJSON(User.self) {
            print("✅ User retrieved: \(user.name)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

### Advanced HTTP Client Usage

```swift
// Create advanced HTTP client
let httpClient = HTTPClientManager()

// Configure with advanced settings
let advancedConfig = HTTPClientConfiguration(
    baseURL: "https://api.company.com",
    timeout: 60.0,
    maxRetries: 5,
    enableCaching: true,
    enableLogging: true,
    enableCompression: true,
    enableCertificateValidation: true,
    enableSSLPinning: true,
    defaultHeaders: [
        "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
        "Accept": "application/json",
        "Accept-Encoding": "gzip, deflate"
    ]
)
httpClient.configure(advancedConfig)

// Add interceptors
let interceptorManager = RequestInterceptorManager()

// Authentication interceptor
let authInterceptor = AuthenticationInterceptor {
    return getAccessToken()
}
interceptorManager.addRequestInterceptor(authInterceptor)

// Logging interceptor
let loggingInterceptor = LoggingInterceptor()
interceptorManager.addRequestInterceptor(loggingInterceptor)

// Caching interceptor
let cache = HTTPCache()
let cachingInterceptor = CachingInterceptor(cache: cache)
interceptorManager.addRequestInterceptor(cachingInterceptor)

httpClient.interceptorManager = interceptorManager

// Create POST request with JSON body
let user = User(name: "John", email: "john@company.com")
let postRequest = HTTPRequestBuilder()
    .method(.post)
    .url("https://api.company.com/users")
    .header("Content-Type", "application/json")
    .jsonBody(user)
    .timeout(30.0)
    .build()

// Execute request with retry
httpClient.executeWithRetry(postRequest, maxRetries: 3) { result in
    switch result {
    case .success(let response):
        if let createdUser = response.asJSON(User.self) {
            print("✅ User created: \(createdUser.name)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

### REST API Client

```swift
// REST API client implementation
class RESTAPIClient {
    private let httpClient: HTTPClientManager
    private let baseURL: String
    
    init(baseURL: String) {
        self.httpClient = HTTPClientManager()
        self.baseURL = baseURL
        
        let config = HTTPClientConfiguration(
            baseURL: baseURL,
            timeout: 30.0,
            maxRetries: 3,
            enableCaching: true
        )
        httpClient.configure(config)
    }
    
    // GET request
    func get<T: Decodable>(_ path: String, completion: @escaping (Result<T, HTTPClientError>) -> Void) {
        let request = HTTPRequestBuilder()
            .method(.get)
            .url("\(baseURL)\(path)")
            .build()
        
        httpClient.execute(request) { result in
            switch result {
            case .success(let response):
                if let object = response.asJSON(T.self) {
                    completion(.success(object))
                } else {
                    completion(.failure(.parsingError("Failed to parse response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // POST request
    func post<T: Encodable, U: Decodable>(_ path: String, body: T, completion: @escaping (Result<U, HTTPClientError>) -> Void) {
        let request = HTTPRequestBuilder()
            .method(.post)
            .url("\(baseURL)\(path)")
            .header("Content-Type", "application/json")
            .jsonBody(body)
            .build()
        
        httpClient.execute(request) { result in
            switch result {
            case .success(let response):
                if let object = response.asJSON(U.self) {
                    completion(.success(object))
                } else {
                    completion(.failure(.parsingError("Failed to parse response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // PUT request
    func put<T: Encodable, U: Decodable>(_ path: String, body: T, completion: @escaping (Result<U, HTTPClientError>) -> Void) {
        let request = HTTPRequestBuilder()
            .method(.put)
            .url("\(baseURL)\(path)")
            .header("Content-Type", "application/json")
            .jsonBody(body)
            .build()
        
        httpClient.execute(request) { result in
            switch result {
            case .success(let response):
                if let object = response.asJSON(U.self) {
                    completion(.success(object))
                } else {
                    completion(.failure(.parsingError("Failed to parse response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // DELETE request
    func delete(_ path: String, completion: @escaping (Result<Void, HTTPClientError>) -> Void) {
        let request = HTTPRequestBuilder()
            .method(.delete)
            .url("\(baseURL)\(path)")
            .build()
        
        httpClient.execute(request) { result in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Usage example
let apiClient = RESTAPIClient(baseURL: "https://api.company.com")

// Get user
apiClient.get("/users/123") { (result: Result<User, HTTPClientError>) in
    switch result {
    case .success(let user):
        print("✅ User: \(user.name)")
    case .failure(let error):
        print("❌ Error: \(error)")
    }
}

// Create user
let newUser = User(name: "John", email: "john@company.com")
apiClient.post("/users", body: newUser) { (result: Result<User, HTTPClientError>) in
    switch result {
    case .success(let createdUser):
        print("✅ Created user: \(createdUser.name)")
    case .failure(let error):
        print("❌ Error: \(error)")
    }
}
```

---

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import NetworkingArchitecturePro

class HTTPClientTests: XCTestCase {
    var httpClient: HTTPClientManager!
    
    override func setUp() {
        super.setUp()
        httpClient = HTTPClientManager()
    }
    
    override func tearDown() {
        httpClient = nil
        super.tearDown()
    }
    
    func testHTTPClientConfiguration() {
        let config = HTTPClientConfiguration(
            baseURL: "https://api.company.com",
            timeout: 30.0,
            maxRetries: 3,
            enableCaching: true
        )
        
        httpClient.configure(config)
        
        XCTAssertEqual(httpClient.configuration.baseURL, "https://api.company.com")
        XCTAssertEqual(httpClient.configuration.timeout, 30.0)
        XCTAssertEqual(httpClient.configuration.maxRetries, 3)
        XCTAssertTrue(httpClient.configuration.enableCaching)
    }
    
    func testHTTPRequestBuilder() {
        let request = HTTPRequestBuilder()
            .method(.get)
            .url("https://api.company.com/users/123")
            .header("Authorization", "Bearer token")
            .header("Content-Type", "application/json")
            .timeout(30.0)
            .build()
        
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.url.absoluteString, "https://api.company.com/users/123")
        XCTAssertEqual(request.headers["Authorization"], "Bearer token")
        XCTAssertEqual(request.headers["Content-Type"], "application/json")
        XCTAssertEqual(request.timeout, 30.0)
    }
    
    func testHTTPRequest() {
        let request = HTTPRequestBuilder()
            .method(.post)
            .url("https://api.company.com/users")
            .jsonBody(User(name: "John", email: "john@company.com"))
            .build()
        
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.url.absoluteString, "https://api.company.com/users")
        XCTAssertNotNil(request.body)
    }
    
    func testHTTPResponse() {
        let responseData = """
        {
            "id": "123",
            "name": "John Doe",
            "email": "john@company.com"
        }
        """.data(using: .utf8)!
        
        let response = HTTPResponse(
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            body: responseData,
            url: URL(string: "https://api.company.com/users/123"),
            timestamp: Date(),
            size: responseData.count,
            duration: 0.5,
            metadata: [:]
        )
        
        XCTAssertTrue(response.isSuccess)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertNotNil(response.body)
        
        if let user = response.asJSON(User.self) {
            XCTAssertEqual(user.name, "John Doe")
            XCTAssertEqual(user.email, "john@company.com")
        } else {
            XCTFail("Failed to parse JSON response")
        }
    }
}
```

### Integration Testing

```swift
class HTTPClientIntegrationTests: XCTestCase {
    func testHTTPClientWithRealServer() {
        let expectation = XCTestExpectation(description: "HTTP request")
        
        let httpClient = HTTPClientManager()
        let config = HTTPClientConfiguration(
            baseURL: "https://jsonplaceholder.typicode.com",
            timeout: 30.0,
            maxRetries: 3
        )
        httpClient.configure(config)
        
        let request = HTTPRequestBuilder()
            .method(.get)
            .url("https://jsonplaceholder.typicode.com/users/1")
            .build()
        
        httpClient.execute(request) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.isSuccess)
                XCTAssertEqual(response.statusCode, 200)
                
                if let user = response.asJSON(User.self) {
                    XCTAssertNotNil(user.name)
                    XCTAssertNotNil(user.email)
                    expectation.fulfill()
                } else {
                    XCTFail("Failed to parse JSON response")
                }
                
            case .failure(let error):
                XCTFail("HTTP request failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testHTTPClientWithInterceptors() {
        let expectation = XCTestExpectation(description: "HTTP request with interceptors")
        
        let httpClient = HTTPClientManager()
        let interceptorManager = RequestInterceptorManager()
        
        // Add logging interceptor
        let loggingInterceptor = LoggingInterceptor()
        interceptorManager.addRequestInterceptor(loggingInterceptor)
        
        httpClient.interceptorManager = interceptorManager
        
        let request = HTTPRequestBuilder()
            .method(.get)
            .url("https://jsonplaceholder.typicode.com/posts/1")
            .build()
        
        httpClient.executeWithInterceptors(
            request,
            interceptors: interceptorManager.requestInterceptors
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.isSuccess)
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("HTTP request failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

---

## 📞 Support

For additional support and questions about HTTP Client API:

- **Documentation**: [HTTP Client Guide](HTTPClientGuide.md)
- **Examples**: [HTTP Client Examples](../Examples/HTTPClientExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this API reference helped you!**
