# 📡 REST API Guide

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [⚡ Quick Start](#-quick-start)
- [🔧 Configuration](#-configuration)
- [📤 Making Requests](#-making-requests)
- [📥 Handling Responses](#-handling-responses)
- [🛠️ API Endpoints](#-api-endpoints)
- [📊 Error Handling](#-error-handling)
- [🔐 Authentication](#-authentication)
- [📦 Caching](#-caching)
- [🔄 Rate Limiting](#-rate-limiting)
- [📱 Examples](#-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**REST API Guide** provides comprehensive documentation for implementing REST API functionality in iOS applications using the iOS Networking Architecture Pro framework.

### 🎯 Key Features

- **API Client**: Type-safe REST API client generation
- **Endpoint Management**: Centralized endpoint configuration
- **Response Mapping**: Automatic response mapping and serialization
- **Request Validation**: Request validation and sanitization
- **API Versioning**: API version management and compatibility
- **Rate Limiting**: Request rate limiting and throttling
- **Caching**: Intelligent API response caching
- **Mocking**: API mocking for testing and development

---

## ⚡ Quick Start

### Basic REST API Setup

```swift
import NetworkingArchitecturePro

// Initialize REST API client
let restClient = RESTAPIClient()

// Configure REST API
let restConfig = RESTAPIConfiguration()
restConfig.baseURL = "https://api.company.com"
restConfig.apiVersion = "v1"
restConfig.enableCaching = true
restConfig.enableRateLimiting = true

// Setup REST API client
restClient.configure(restConfig)

// Define API endpoints
let userAPI = UserAPI(client: restClient)

// Get user by ID
userAPI.getUser(id: "123") { result in
    switch result {
    case .success(let user):
        print("✅ User retrieved successfully")
        print("User: \(user.name)")
        print("Email: \(user.email)")
        print("Created: \(user.createdAt)")
    case .failure(let error):
        print("❌ User retrieval failed: \(error)")
    }
}
```

### Simple REST API Usage

```swift
// REST API integration
let restAPI = RESTAPIIntegration()

// Configure API endpoints
restAPI.configureEndpoints([
    "users": "/users",
    "posts": "/posts",
    "comments": "/comments"
])

// Get users with pagination
restAPI.getUsers(page: 1, limit: 10) { result in
    switch result {
    case .success(let users):
        print("✅ Users retrieved successfully")
        print("Total users: \(users.count)")
        for user in users {
            print("User: \(user.name)")
        }
    case .failure(let error):
        print("❌ Users retrieval failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### REST API Configuration

```swift
// Configure REST API settings
let restConfig = RESTAPIConfiguration()

// Basic settings
restConfig.baseURL = "https://api.company.com"
restConfig.apiVersion = "v1"
restConfig.timeout = 30.0
restConfig.maxRetries = 3
restConfig.enableCaching = true
restConfig.enableLogging = true

// Performance settings
restConfig.enableCompression = true
restConfig.enableRateLimiting = true
restConfig.maxConcurrentRequests = 10

// Custom headers
restConfig.defaultHeaders = [
    "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
    "Accept": "application/json",
    "Accept-Encoding": "gzip, deflate"
]

// Apply configuration
restClient.configure(restConfig)
```

### Advanced Configuration

```swift
// Advanced REST API configuration
let advancedConfig = RESTAPIConfiguration()

// Connection settings
advancedConfig.baseURL = "https://api.company.com"
advancedConfig.apiVersion = "v1"
advancedConfig.timeout = 60.0
advancedConfig.maxRetries = 5
advancedConfig.retryDelay = 2.0
advancedConfig.exponentialBackoff = true

// Caching settings
advancedConfig.enableCaching = true
advancedConfig.cachePolicy = .returnCacheDataElseLoad
advancedConfig.maxCacheAge = 3600 // 1 hour
advancedConfig.maxCacheSize = 50 * 1024 * 1024 // 50MB

// Rate limiting settings
advancedConfig.enableRateLimiting = true
advancedConfig.rateLimitRequests = 100 // requests per minute
advancedConfig.rateLimitWindow = 60.0 // seconds

// Security settings
advancedConfig.enableCertificateValidation = true
advancedConfig.enableSSLPinning = true
advancedConfig.allowedCipherSuites = [
    .TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
    .TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
]

// Logging settings
advancedConfig.enableLogging = true
advancedConfig.logLevel = .debug
advancedConfig.logRequests = true
advancedConfig.logResponses = true
advancedConfig.logErrors = true

// Custom settings
advancedConfig.defaultHeaders = [
    "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
    "Accept": "application/json",
    "Accept-Encoding": "gzip, deflate",
    "Cache-Control": "no-cache"
]

restClient.configure(advancedConfig)
```

---

## 📤 Making Requests

### API Endpoint Definition

```swift
// Define API endpoints
let endpoints = [
    "getUser": APIEndpoint.get("/users/{id}"),
    "createUser": APIEndpoint.post("/users"),
    "updateUser": APIEndpoint.put("/users/{id}"),
    "deleteUser": APIEndpoint.delete("/users/{id}"),
    "getUsers": APIEndpoint.get("/users"),
    "getUserPosts": APIEndpoint.get("/users/{id}/posts"),
    "createPost": APIEndpoint.post("/posts"),
    "updatePost": APIEndpoint.put("/posts/{id}"),
    "deletePost": APIEndpoint.delete("/posts/{id}")
]

// Register endpoints
restClient.registerEndpoints(endpoints)
```

### Request Methods

```swift
// GET request
restClient.get("/users/123") { result in
    switch result {
    case .success(let response):
        if let user = response.asJSON(User.self) {
            print("✅ User: \(user.name)")
        }
    case .failure(let error):
        print("❌ GET failed: \(error)")
    }
}

// POST request
let userData = ["name": "John", "email": "john@company.com"]
restClient.post("/users", data: userData) { result in
    switch result {
    case .success(let response):
        if let createdUser = response.asJSON(User.self) {
            print("✅ Created user: \(createdUser.name)")
        }
    case .failure(let error):
        print("❌ POST failed: \(error)")
    }
}

// PUT request
let updateData = ["name": "John Doe", "email": "john.doe@company.com"]
restClient.put("/users/123", data: updateData) { result in
    switch result {
    case .success(let response):
        if let updatedUser = response.asJSON(User.self) {
            print("✅ Updated user: \(updatedUser.name)")
        }
    case .failure(let error):
        print("❌ PUT failed: \(error)")
    }
}

// DELETE request
restClient.delete("/users/123") { result in
    switch result {
    case .success:
        print("✅ User deleted successfully")
    case .failure(let error):
        print("❌ DELETE failed: \(error)")
    }
}
```

### Request with Parameters

```swift
// Request with query parameters
let request = APIRequestBuilder(endpoint: endpoints["getUsers"]!)
    .parameter("page", "1")
    .parameter("limit", "10")
    .parameter("sort", "name")
    .parameter("order", "asc")
    .build()

// Request with path parameters
let request = APIRequestBuilder(endpoint: endpoints["getUser"]!)
    .pathParameter("id", "123")
    .build()

// Request with custom headers
let request = APIRequestBuilder(endpoint: endpoints["createUser"]!)
    .header("Authorization", "Bearer token")
    .header("Content-Type", "application/json")
    .header("X-API-Version", "v1")
    .jsonBody(userData)
    .build()
```

---

## 📥 Handling Responses

### Response Parsing

```swift
// Parse JSON response
restClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let user = response.asJSON(User.self) {
            print("✅ User: \(user.name)")
            print("Email: \(user.email)")
            print("Created: \(user.createdAt)")
        } else {
            print("❌ Failed to parse JSON response")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}

// Parse array response
restClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let users = response.asJSON([User].self) {
            print("✅ Users: \(users.count)")
            for user in users {
                print("- \(user.name)")
            }
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}

// Parse paginated response
restClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let paginatedResponse = response.asJSON(PaginatedResponse<User>.self) {
            print("✅ Page: \(paginatedResponse.page)")
            print("Total: \(paginatedResponse.total)")
            print("Users: \(paginatedResponse.data.count)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

### Response Validation

```swift
// Validate response status
restClient.execute(request) { result in
    switch result {
    case .success(let response):
        if response.isSuccess {
            print("✅ Request successful")
            // Handle success response
        } else if response.isClientError {
            print("❌ Client error: \(response.statusCode)")
            // Handle client error
        } else if response.isServerError {
            print("❌ Server error: \(response.statusCode)")
            // Handle server error
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}

// Check response headers
restClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let contentType = response.headers["Content-Type"] {
            print("Content-Type: \(contentType)")
        }
        
        if let contentLength = response.headers["Content-Length"] {
            print("Content-Length: \(contentLength)")
        }
        
        if let rateLimitRemaining = response.headers["X-RateLimit-Remaining"] {
            print("Rate limit remaining: \(rateLimitRemaining)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

---

## 🛠️ API Endpoints

### Endpoint Management

```swift
// Register API endpoint
restClient.registerEndpoint(getUserEndpoint, for: "getUser")

// Register multiple endpoints
let endpoints = [
    "getUser": APIEndpoint.get("/users/{id}"),
    "createUser": APIEndpoint.post("/users"),
    "updateUser": APIEndpoint.put("/users/{id}"),
    "deleteUser": APIEndpoint.delete("/users/{id}"),
    "getUsers": APIEndpoint.get("/users"),
    "getUserPosts": APIEndpoint.get("/users/{id}/posts"),
    "createPost": APIEndpoint.post("/posts"),
    "updatePost": APIEndpoint.put("/posts/{id}"),
    "deletePost": APIEndpoint.delete("/posts/{id}")
]
restClient.registerEndpoints(endpoints)

// Get endpoint by key
if let endpoint = restClient.getEndpoint(for: "getUser") {
    print("Endpoint: \(endpoint.path)")
}

// Remove endpoint
restClient.removeEndpoint(for: "getUser")

// Clear all endpoints
restClient.clearEndpoints()
```

### Endpoint Configuration

```swift
// Configure endpoint with custom settings
let customEndpoint = APIEndpoint.get("/users/{id}")
    .header("Authorization", "Bearer token")
    .timeout(60.0)
    .cachePolicy(.returnCacheDataElseLoad)
    .retryPolicy(.exponentialBackoff(maxRetries: 5))
    .rateLimit(requests: 100, window: 60.0)
    .requiresAuthentication(true)
    .responseValidation { response in
        return response.statusCode == 200
    }

// Register custom endpoint
restClient.registerEndpoint(customEndpoint, for: "getUserCustom")
```

---

## 📊 Error Handling

### Error Types

```swift
// Handle different error types
restClient.execute(request) { result in
    switch result {
    case .success(let response):
        print("✅ Request successful")
        
    case .failure(let error):
        switch error {
        case .networkError(let reason):
            print("❌ Network error: \(reason)")
            // Handle network connectivity issues
            
        case .timeoutError(let reason):
            print("❌ Timeout error: \(reason)")
            // Handle timeout issues
            
        case .authenticationError(let reason):
            print("❌ Authentication error: \(reason)")
            // Handle authentication issues
            
        case .authorizationError(let reason):
            print("❌ Authorization error: \(reason)")
            // Handle authorization issues
            
        case .serverError(let reason):
            print("❌ Server error: \(reason)")
            // Handle server errors
            
        case .clientError(let reason):
            print("❌ Client error: \(reason)")
            // Handle client errors
            
        case .parsingError(let reason):
            print("❌ Parsing error: \(reason)")
            // Handle response parsing issues
            
        case .rateLimitError(let reason):
            print("❌ Rate limit error: \(reason)")
            // Handle rate limiting issues
            
        case .validationError(let reason):
            print("❌ Validation error: \(reason)")
            // Handle validation issues
            
        case .configurationError(let reason):
            print("❌ Configuration error: \(reason)")
            // Handle configuration issues
            
        case .unknownError(let reason):
            print("❌ Unknown error: \(reason)")
            // Handle unknown errors
        }
    }
}
```

### Error Recovery

```swift
// Error recovery strategies
class RESTAPIErrorRecovery {
    private let restClient: RESTAPIClient
    private var errorCount = 0
    private let maxErrors = 5
    
    init(restClient: RESTAPIClient) {
        self.restClient = restClient
    }
    
    func handleError(_ error: RESTAPIError) {
        errorCount += 1
        
        if errorCount >= maxErrors {
            print("⚠️ Too many errors, stopping retry")
            return
        }
        
        switch error {
        case .networkError:
            // Retry with exponential backoff
            let delay = pow(2.0, Double(errorCount))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.retryRequest()
            }
            
        case .timeoutError:
            // Increase timeout and retry
            increaseTimeout()
            retryRequest()
            
        case .authenticationError:
            // Refresh token and retry
            refreshToken { success in
                if success {
                    self.retryRequest()
                }
            }
            
        case .rateLimitError:
            // Wait and retry
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                self.retryRequest()
            }
            
        case .serverError:
            // Wait and retry
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.retryRequest()
            }
            
        default:
            // Log error and continue
            print("❌ Unhandled error: \(error)")
        }
    }
    
    private func retryRequest() {
        // Implement retry logic
    }
    
    private func increaseTimeout() {
        // Increase timeout configuration
    }
    
    private func refreshToken(completion: @escaping (Bool) -> Void) {
        // Implement token refresh
        completion(true)
    }
}
```

---

## 🔐 Authentication

### Bearer Token Authentication

```swift
// Bearer token authentication
class BearerTokenAuthenticator {
    private let restClient: RESTAPIClient
    private var accessToken: String?
    
    init(restClient: RESTAPIClient) {
        self.restClient = restClient
    }
    
    func authenticate(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let authRequest = APIRequestBuilder(endpoint: APIEndpoint.post("/auth/login"))
            .jsonBody([
                "username": username,
                "password": password
            ])
            .build()
        
        restClient.execute(authRequest) { result in
            switch result {
            case .success(let response):
                if let authResponse = response.asJSON(AuthResponse.self) {
                    self.accessToken = authResponse.accessToken
                    completion(.success(authResponse.accessToken))
                } else {
                    completion(.failure(AuthenticationError.invalidCredentials("Failed to parse auth response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makeAuthenticatedRequest(_ request: APIRequest, completion: @escaping (Result<APIResponse, RESTAPIError>) -> Void) {
        var authenticatedRequest = request
        if let token = accessToken {
            authenticatedRequest.headers["Authorization"] = "Bearer \(token)"
        }
        
        restClient.execute(authenticatedRequest, completion: completion)
    }
}
```

### OAuth Authentication

```swift
// OAuth authentication
class OAuthAuthenticator {
    private let restClient: RESTAPIClient
    private let clientId: String
    private let clientSecret: String
    private var accessToken: String?
    private var refreshToken: String?
    
    init(restClient: RESTAPIClient, clientId: String, clientSecret: String) {
        self.restClient = restClient
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    func authenticate(completion: @escaping (Result<String, Error>) -> Void) {
        let authRequest = APIRequestBuilder(endpoint: APIEndpoint.post("/oauth/token"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .formData([
                "grant_type": "client_credentials",
                "client_id": clientId,
                "client_secret": clientSecret
            ])
            .build()
        
        restClient.execute(authRequest) { result in
            switch result {
            case .success(let response):
                if let oauthResponse = response.asJSON(OAuthResponse.self) {
                    self.accessToken = oauthResponse.accessToken
                    self.refreshToken = oauthResponse.refreshToken
                    completion(.success(oauthResponse.accessToken))
                } else {
                    completion(.failure(AuthenticationError.invalidCredentials("Failed to parse OAuth response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func refreshAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let refreshToken = refreshToken else {
            completion(.failure(AuthenticationError.tokenNotFound("No refresh token available")))
            return
        }
        
        let refreshRequest = APIRequestBuilder(endpoint: APIEndpoint.post("/oauth/token"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .formData([
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": clientId,
                "client_secret": clientSecret
            ])
            .build()
        
        restClient.execute(refreshRequest) { result in
            switch result {
            case .success(let response):
                if let oauthResponse = response.asJSON(OAuthResponse.self) {
                    self.accessToken = oauthResponse.accessToken
                    self.refreshToken = oauthResponse.refreshToken
                    completion(.success(oauthResponse.accessToken))
                } else {
                    completion(.failure(AuthenticationError.invalidCredentials("Failed to parse refresh response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
```

---

## 📦 Caching

### Cache Configuration

```swift
// Configure caching
let cacheConfig = APICacheConfiguration()
cacheConfig.enableCaching = true
cacheConfig.cachePolicy = .returnCacheDataElseLoad
cacheConfig.maxCacheAge = 3600 // 1 hour
cacheConfig.maxCacheSize = 50 * 1024 * 1024 // 50MB
cacheConfig.diskCacheEnabled = true
cacheConfig.memoryCacheEnabled = true

restClient.configureCache(cacheConfig)
```

### Cache Implementation

```swift
// Custom cache implementation
class CustomAPICache: APICache {
    private let memoryCache = NSCache<NSString, CachedResponse>()
    private let diskCache: DiskCache
    
    init() {
        self.diskCache = DiskCache()
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    func get(for request: APIRequest) -> CachedResponse? {
        let key = cacheKey(for: request)
        
        // Check memory cache first
        if let cachedResponse = memoryCache.object(forKey: key as NSString) {
            return cachedResponse
        }
        
        // Check disk cache
        if let cachedResponse = diskCache.get(for: key) {
            // Store in memory cache
            memoryCache.setObject(cachedResponse, forKey: key as NSString)
            return cachedResponse
        }
        
        return nil
    }
    
    func set(_ response: CachedResponse, for request: APIRequest) {
        let key = cacheKey(for: request)
        
        // Store in memory cache
        memoryCache.setObject(response, forKey: key as NSString)
        
        // Store in disk cache
        diskCache.set(response, for: key)
    }
    
    func clear() {
        memoryCache.removeAllObjects()
        diskCache.clear()
    }
    
    private func cacheKey(for request: APIRequest) -> String {
        return "\(request.endpoint.method.rawValue)_\(request.endpoint.path)"
    }
}
```

---

## 🔄 Rate Limiting

### Rate Limiting Configuration

```swift
// Configure rate limiting
let rateLimitConfig = APIRateLimitConfiguration()
rateLimitConfig.enableRateLimiting = true
rateLimitConfig.requestsPerMinute = 100
rateLimitConfig.requestsPerHour = 1000
rateLimitConfig.requestsPerDay = 10000
rateLimitConfig.enableRetryAfter = true
rateLimitConfig.retryAfterDelay = 60.0 // seconds

restClient.configureRateLimiting(rateLimitConfig)
```

### Rate Limiting Implementation

```swift
// Custom rate limiting implementation
class CustomRateLimiter: APIRateLimiter {
    private var requestCounts: [String: Int] = [:]
    private var lastResetTimes: [String: Date] = [:]
    private let maxRequests: Int
    private let timeWindow: TimeInterval
    
    init(maxRequests: Int = 100, timeWindow: TimeInterval = 60.0) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }
    
    func canMakeRequest(for endpoint: String) -> Bool {
        let now = Date()
        let key = endpoint
        
        // Reset counter if time window has passed
        if let lastReset = lastResetTimes[key], now.timeIntervalSince(lastReset) >= timeWindow {
            requestCounts[key] = 0
            lastResetTimes[key] = now
        }
        
        let currentCount = requestCounts[key] ?? 0
        return currentCount < maxRequests
    }
    
    func recordRequest(for endpoint: String) {
        let key = endpoint
        let currentCount = requestCounts[key] ?? 0
        requestCounts[key] = currentCount + 1
        
        if lastResetTimes[key] == nil {
            lastResetTimes[key] = Date()
        }
    }
    
    func getRemainingRequests(for endpoint: String) -> Int {
        let key = endpoint
        let currentCount = requestCounts[key] ?? 0
        return max(0, maxRequests - currentCount)
    }
    
    func getResetTime(for endpoint: String) -> Date? {
        let key = endpoint
        guard let lastReset = lastResetTimes[key] else { return nil }
        return lastReset.addingTimeInterval(timeWindow)
    }
}
```

---

## 📱 Examples

### REST API Client Implementation

```swift
// REST API client implementation
class RESTAPIClient {
    private let restClient: RESTAPIClient
    private let baseURL: String
    
    init(baseURL: String) {
        self.restClient = RESTAPIClient()
        self.baseURL = baseURL
        
        let config = RESTAPIConfiguration(
            baseURL: baseURL,
            apiVersion: "v1",
            timeout: 30.0,
            maxRetries: 3,
            enableCaching: true
        )
        restClient.configure(config)
    }
    
    // GET request
    func get<T: Decodable>(_ path: String, completion: @escaping (Result<T, RESTAPIError>) -> Void) {
        let request = APIRequestBuilder(endpoint: APIEndpoint.get(path))
            .build()
        
        restClient.execute(request) { result in
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
    func post<T: Encodable, U: Decodable>(_ path: String, body: T, completion: @escaping (Result<U, RESTAPIError>) -> Void) {
        let request = APIRequestBuilder(endpoint: APIEndpoint.post(path))
            .header("Content-Type", "application/json")
            .jsonBody(body)
            .build()
        
        restClient.execute(request) { result in
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
    func put<T: Encodable, U: Decodable>(_ path: String, body: T, completion: @escaping (Result<U, RESTAPIError>) -> Void) {
        let request = APIRequestBuilder(endpoint: APIEndpoint.put(path))
            .header("Content-Type", "application/json")
            .jsonBody(body)
            .build()
        
        restClient.execute(request) { result in
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
    func delete(_ path: String, completion: @escaping (Result<Void, RESTAPIError>) -> Void) {
        let request = APIRequestBuilder(endpoint: APIEndpoint.delete(path))
            .build()
        
        restClient.execute(request) { result in
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
apiClient.get("/users/123") { (result: Result<User, RESTAPIError>) in
    switch result {
    case .success(let user):
        print("✅ User: \(user.name)")
    case .failure(let error):
        print("❌ Error: \(error)")
    }
}

// Create user
let newUser = User(name: "John", email: "john@company.com")
apiClient.post("/users", body: newUser) { (result: Result<User, RESTAPIError>) in
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
            .pathParameter("id", "123")
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

- **Documentation**: [REST API API Reference](RESTAPIAPI.md)
- **Examples**: [REST API Examples](../Examples/RESTAPIExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this guide helped you!**
