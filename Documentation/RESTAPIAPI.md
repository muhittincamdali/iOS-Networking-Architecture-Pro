# 📡 REST API API Reference

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [📦 RESTAPIClient](#-restapiclient)
- [🔗 APIEndpoint](#-apiendpoint)
- [📤 APIRequest](#-apirequest)
- [📥 APIResponse](#-apiresponse)
- [⚙️ RESTAPIConfiguration](#-restapiconfiguration)
- [🛠️ APIMapper](#-apimapper)
- [❌ RESTAPIError](#-restapierror)
- [📊 APIStatistics](#-apistatistics)
- [📱 Usage Examples](#-usage-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**REST API API Reference** provides comprehensive documentation for all REST API-related classes, protocols, and utilities in the iOS Networking Architecture Pro framework.

### 🎯 Key Components

- **RESTAPIClient**: Main REST API client implementation
- **APIEndpoint**: Endpoint configuration and management
- **APIRequest**: Request structure and builder
- **APIResponse**: Response structure and parsing
- **RESTAPIConfiguration**: Client configuration options
- **APIMapper**: Response mapping and serialization
- **RESTAPIError**: Error types and handling
- **APIStatistics**: Performance and statistics

---

## 📦 RESTAPIClient

### Class Definition

```swift
public class RESTAPIClient {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: RESTAPIConfiguration
    
    /// API endpoints
    public private(set) var endpoints: [String: APIEndpoint]
    
    /// Response mapper
    public private(set) var mapper: APIMapper
    
    /// API statistics
    public private(set) var statistics: APIStatistics
    
    /// Whether the client is active
    public var isActive: Bool
    
    // MARK: - Event Handlers
    
    /// Called when API request starts
    public var onRequestStart: ((APIRequest) -> Void)?
    
    /// Called when API request completes
    public var onRequestComplete: ((APIRequest, APIResponse) -> Void)?
    
    /// Called when API request fails
    public var onRequestFailure: ((APIRequest, RESTAPIError) -> Void)?
    
    /// Called when API response is received
    public var onResponseReceived: ((APIResponse) -> Void)?
}
```

### Initialization

```swift
// Create REST API client
let restClient = RESTAPIClient()

// Create with configuration
let config = RESTAPIConfiguration()
config.baseURL = "https://api.company.com"
let restClient = RESTAPIClient(configuration: config)

// Create with custom mapper
let mapper = APIMapper()
let restClient = RESTAPIClient(mapper: mapper)
```

### Configuration Methods

```swift
// Configure REST API client
func configure(_ configuration: RESTAPIConfiguration)

// Update configuration
func updateConfiguration(_ configuration: RESTAPIConfiguration)

// Reset configuration to defaults
func resetConfiguration()
```

### Endpoint Management

```swift
// Register API endpoint
func registerEndpoint(_ endpoint: APIEndpoint, for key: String)

// Register multiple endpoints
func registerEndpoints(_ endpoints: [String: APIEndpoint])

// Get endpoint by key
func getEndpoint(for key: String) -> APIEndpoint?

// Remove endpoint
func removeEndpoint(for key: String)

// Clear all endpoints
func clearEndpoints()
```

### Request Methods

```swift
// Execute API request
func execute(_ request: APIRequest, completion: @escaping (Result<APIResponse, RESTAPIError>) -> Void)

// Execute request with retry
func executeWithRetry(_ request: APIRequest, maxRetries: Int, completion: @escaping (Result<APIResponse, RESTAPIError>) -> Void)

// Execute request with custom timeout
func execute(_ request: APIRequest, timeout: TimeInterval, completion: @escaping (Result<APIResponse, RESTAPIError>) -> Void)

// Execute request with caching
func executeWithCache(_ request: APIRequest, cachePolicy: APICachePolicy, completion: @escaping (Result<APIResponse, RESTAPIError>) -> Void)
```

### Utility Methods

```swift
// Cancel all pending requests
func cancelAllRequests()

// Cancel specific request
func cancelRequest(_ request: APIRequest)

// Get API statistics
func getAPIStats() -> APIStatistics

// Clear API cache
func clearCache()

// Set cache policy
func setCachePolicy(_ policy: APICachePolicy)
```

---

## 🔗 APIEndpoint

### Structure Definition

```swift
public struct APIEndpoint {
    /// Endpoint path
    public let path: String
    
    /// HTTP method
    public let method: HTTPMethod
    
    /// Required headers
    public let requiredHeaders: [String: String]
    
    /// Optional headers
    public let optionalHeaders: [String: String]
    
    /// Query parameters
    public let queryParameters: [String: String]
    
    /// Request timeout
    public let timeout: TimeInterval
    
    /// Cache policy
    public let cachePolicy: APICachePolicy
    
    /// Retry policy
    public let retryPolicy: APIRetryPolicy
    
    /// Authentication required
    public let requiresAuthentication: Bool
    
    /// Rate limiting
    public let rateLimit: APIRateLimit?
    
    /// Response validation
    public let responseValidation: APIResponseValidation?
}
```

### Endpoint Configuration

```swift
public extension APIEndpoint {
    /// Create GET endpoint
    static func get(_ path: String, headers: [String: String] = [:]) -> APIEndpoint
    
    /// Create POST endpoint
    static func post(_ path: String, headers: [String: String] = [:]) -> APIEndpoint
    
    /// Create PUT endpoint
    static func put(_ path: String, headers: [String: String] = [:]) -> APIEndpoint
    
    /// Create PATCH endpoint
    static func patch(_ path: String, headers: [String: String] = [:]) -> APIEndpoint
    
    /// Create DELETE endpoint
    static func delete(_ path: String, headers: [String: String] = [:]) -> APIEndpoint
}
```

### Usage Examples

```swift
// Create user endpoints
let getUserEndpoint = APIEndpoint.get("/users/{id}", headers: [
    "Accept": "application/json"
])

let createUserEndpoint = APIEndpoint.post("/users", headers: [
    "Content-Type": "application/json"
])

let updateUserEndpoint = APIEndpoint.put("/users/{id}", headers: [
    "Content-Type": "application/json"
])

let deleteUserEndpoint = APIEndpoint.delete("/users/{id}")

// Register endpoints
restClient.registerEndpoint(getUserEndpoint, for: "getUser")
restClient.registerEndpoint(createUserEndpoint, for: "createUser")
restClient.registerEndpoint(updateUserEndpoint, for: "updateUser")
restClient.registerEndpoint(deleteUserEndpoint, for: "deleteUser")
```

---

## 📤 APIRequest

### Structure Definition

```swift
public struct APIRequest {
    /// Request endpoint
    public let endpoint: APIEndpoint
    
    /// Request parameters
    public var parameters: [String: Any]
    
    /// Request body
    public var body: Data?
    
    /// Request headers
    public var headers: [String: String]
    
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

### Request Builder

```swift
public class APIRequestBuilder {
    private var request: APIRequest
    
    public init(endpoint: APIEndpoint) {
        self.request = APIRequest(endpoint: endpoint)
    }
    
    // Add parameter
    func parameter(_ key: String, _ value: Any) -> APIRequestBuilder
    
    // Add parameters
    func parameters(_ params: [String: Any]) -> APIRequestBuilder
    
    // Set body
    func body(_ data: Data) -> APIRequestBuilder
    
    // Set JSON body
    func jsonBody<T: Encodable>(_ object: T) -> APIRequestBuilder
    
    // Add header
    func header(_ key: String, _ value: String) -> APIRequestBuilder
    
    // Add headers
    func headers(_ headers: [String: String]) -> APIRequestBuilder
    
    // Set timeout
    func timeout(_ timeout: TimeInterval) -> APIRequestBuilder
    
    // Add metadata
    func metadata(_ key: String, _ value: Any) -> APIRequestBuilder
    
    // Build request
    func build() -> APIRequest
}
```

### Usage Examples

```swift
// Create GET request
let getUserRequest = APIRequestBuilder(endpoint: getUserEndpoint)
    .parameter("id", "123")
    .header("Authorization", "Bearer token")
    .timeout(30.0)
    .build()

// Create POST request with JSON body
let user = User(name: "John", email: "john@company.com")
let createUserRequest = APIRequestBuilder(endpoint: createUserEndpoint)
    .jsonBody(user)
    .header("Authorization", "Bearer token")
    .timeout(30.0)
    .build()

// Create PUT request with parameters
let updateUserRequest = APIRequestBuilder(endpoint: updateUserEndpoint)
    .parameter("id", "123")
    .jsonBody(user)
    .header("Authorization", "Bearer token")
    .timeout(30.0)
    .build()

// Create DELETE request
let deleteUserRequest = APIRequestBuilder(endpoint: deleteUserEndpoint)
    .parameter("id", "123")
    .header("Authorization", "Bearer token")
    .timeout(30.0)
    .build()
```

---

## 📥 APIResponse

### Structure Definition

```swift
public struct APIResponse {
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
    
    /// Response validation result
    public let validationResult: APIResponseValidationResult?
}
```

### Response Parsing

```swift
public extension APIResponse {
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
    
    /// Check if response is successful
    var isSuccess: Bool { statusCode >= 200 && statusCode < 300 }
    
    /// Check if response is client error
    var isClientError: Bool { statusCode >= 400 && statusCode < 500 }
    
    /// Check if response is server error
    var isServerError: Bool { statusCode >= 500 && statusCode < 600 }
}
```

---

## ⚙️ RESTAPIConfiguration

### Structure Definition

```swift
public struct RESTAPIConfiguration {
    /// Base URL for API
    public var baseURL: String?
    
    /// API version
    public var apiVersion: String?
    
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
    
    /// Enable rate limiting
    public var enableRateLimiting: Bool
    
    /// Default headers for all requests
    public var defaultHeaders: [String: String]
    
    /// Authentication configuration
    public var authConfig: APIAuthenticationConfiguration
    
    /// Cache configuration
    public var cacheConfig: APICacheConfiguration
    
    /// Rate limiting configuration
    public var rateLimitConfig: APIRateLimitConfiguration
}
```

### Default Configuration

```swift
public extension RESTAPIConfiguration {
    /// Default configuration
    static let `default` = RESTAPIConfiguration(
        baseURL: nil,
        apiVersion: nil,
        timeout: 30.0,
        maxRetries: 3,
        enableCaching: true,
        enableLogging: false,
        enableCompression: true,
        enableRateLimiting: true,
        defaultHeaders: [:],
        authConfig: .default,
        cacheConfig: .default,
        rateLimitConfig: .default
    )
}
```

---

## 🛠️ APIMapper

### Class Definition

```swift
public class APIMapper {
    /// JSON encoder
    private let encoder: JSONEncoder
    
    /// JSON decoder
    private let decoder: JSONDecoder
    
    /// Date formatter
    private let dateFormatter: DateFormatter
    
    public init(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.encoder = encoder
        self.decoder = decoder
        self.dateFormatter = DateFormatter()
        
        // Configure date formatting
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
}
```

### Mapping Methods

```swift
// Map object to JSON
func mapToJSON<T: Encodable>(_ object: T) -> Data?

// Map JSON to object
func mapFromJSON<T: Decodable>(_ data: Data, as type: T.Type) -> T?

// Map response to object
func mapResponse<T: Decodable>(_ response: APIResponse, as type: T.Type) -> T?

// Map request body
func mapRequestBody<T: Encodable>(_ object: T) -> Data?

// Map query parameters
func mapQueryParameters(_ parameters: [String: Any]) -> String?
```

---

## ❌ RESTAPIError

### Error Types

```swift
public enum RESTAPIError: Error, LocalizedError {
    /// Network error
    case networkError(String)
    
    /// Timeout error
    case timeoutError(String)
    
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
    
    /// Validation error
    case validationError(String)
    
    /// Rate limit error
    case rateLimitError(String)
    
    /// Cache error
    case cacheError(String)
    
    /// Configuration error
    case configurationError(String)
    
    /// Unknown error
    case unknownError(String)
}
```

---

## 📊 APIStatistics

### Structure Definition

```swift
public struct APIStatistics {
    /// Total API requests
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

---

## 📱 Usage Examples

### Basic REST API Usage

```swift
// Create REST API client
let restClient = RESTAPIClient()

// Configure client
let config = RESTAPIConfiguration(
    baseURL: "https://api.company.com",
    apiVersion: "v1",
    timeout: 30.0,
    maxRetries: 3,
    enableCaching: true
)
restClient.configure(config)

// Register endpoints
let getUserEndpoint = APIEndpoint.get("/users/{id}")
restClient.registerEndpoint(getUserEndpoint, for: "getUser")

// Create request
let request = APIRequestBuilder(endpoint: getUserEndpoint)
    .parameter("id", "123")
    .header("Authorization", "Bearer token")
    .build()

// Execute request
restClient.execute(request) { result in
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

### Advanced REST API Usage

```swift
// Create advanced REST API client
let restClient = RESTAPIClient()

// Configure with advanced settings
let advancedConfig = RESTAPIConfiguration(
    baseURL: "https://api.company.com",
    apiVersion: "v1",
    timeout: 60.0,
    maxRetries: 5,
    enableCaching: true,
    enableLogging: true,
    enableCompression: true,
    enableRateLimiting: true,
    defaultHeaders: [
        "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
        "Accept": "application/json",
        "Accept-Encoding": "gzip, deflate"
    ]
)
restClient.configure(advancedConfig)

// Register multiple endpoints
let endpoints = [
    "getUser": APIEndpoint.get("/users/{id}"),
    "createUser": APIEndpoint.post("/users"),
    "updateUser": APIEndpoint.put("/users/{id}"),
    "deleteUser": APIEndpoint.delete("/users/{id}")
]
restClient.registerEndpoints(endpoints)

// Create and execute multiple requests
let user = User(name: "John", email: "john@company.com")

// Create user
let createRequest = APIRequestBuilder(endpoint: endpoints["createUser"]!)
    .jsonBody(user)
    .header("Authorization", "Bearer token")
    .build()

restClient.execute(createRequest) { result in
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

---

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import NetworkingArchitecturePro

class RESTAPITests: XCTestCase {
    var restClient: RESTAPIClient!
    
    override func setUp() {
        super.setUp()
        restClient = RESTAPIClient()
    }
    
    override func tearDown() {
        restClient = nil
        super.tearDown()
    }
    
    func testRESTAPIConfiguration() {
        let config = RESTAPIConfiguration(
            baseURL: "https://api.company.com",
            apiVersion: "v1",
            timeout: 30.0,
            maxRetries: 3,
            enableCaching: true
        )
        
        restClient.configure(config)
        
        XCTAssertEqual(restClient.configuration.baseURL, "https://api.company.com")
        XCTAssertEqual(restClient.configuration.apiVersion, "v1")
        XCTAssertEqual(restClient.configuration.timeout, 30.0)
        XCTAssertEqual(restClient.configuration.maxRetries, 3)
        XCTAssertTrue(restClient.configuration.enableCaching)
    }
    
    func testAPIEndpoint() {
        let endpoint = APIEndpoint.get("/users/{id}", headers: [
            "Accept": "application/json"
        ])
        
        XCTAssertEqual(endpoint.path, "/users/{id}")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.requiredHeaders["Accept"], "application/json")
    }
    
    func testAPIRequest() {
        let endpoint = APIEndpoint.get("/users/{id}")
        let request = APIRequestBuilder(endpoint: endpoint)
            .parameter("id", "123")
            .header("Authorization", "Bearer token")
            .build()
        
        XCTAssertEqual(request.endpoint.path, "/users/{id}")
        XCTAssertEqual(request.parameters["id"] as? String, "123")
        XCTAssertEqual(request.headers["Authorization"], "Bearer token")
    }
}
```

### Integration Testing

```swift
class RESTAPIIntegrationTests: XCTestCase {
    func testRESTAPIWithRealServer() {
        let expectation = XCTestExpectation(description: "REST API request")
        
        let restClient = RESTAPIClient()
        let config = RESTAPIConfiguration(
            baseURL: "https://jsonplaceholder.typicode.com",
            timeout: 30.0,
            maxRetries: 3
        )
        restClient.configure(config)
        
        let endpoint = APIEndpoint.get("/users/1")
        restClient.registerEndpoint(endpoint, for: "getUser")
        
        let request = APIRequestBuilder(endpoint: endpoint)
            .build()
        
        restClient.execute(request) { result in
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
                XCTFail("REST API request failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

---

## 📞 Support

For additional support and questions about REST API:

- **Documentation**: [REST API Guide](RESTAPIGuide.md)
- **Examples**: [REST API Examples](../Examples/RESTAPIExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this API reference helped you!**
