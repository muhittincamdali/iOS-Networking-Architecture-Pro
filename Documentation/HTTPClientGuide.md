# 🔗 HTTP Client Guide

<!-- TOC START -->
## Table of Contents
- [🔗 HTTP Client Guide](#-http-client-guide)
- [📋 Table of Contents](#-table-of-contents)
- [🚀 Overview](#-overview)
  - [🎯 Key Features](#-key-features)
- [⚡ Quick Start](#-quick-start)
  - [Basic HTTP Client Setup](#basic-http-client-setup)
  - [Simple GET Request](#simple-get-request)
- [🔧 Configuration](#-configuration)
  - [HTTP Client Configuration](#http-client-configuration)
  - [Advanced Configuration](#advanced-configuration)
- [📤 Making Requests](#-making-requests)
  - [Request Builder](#request-builder)
  - [Request Methods](#request-methods)
  - [Request with Parameters](#request-with-parameters)
- [📥 Handling Responses](#-handling-responses)
  - [Response Parsing](#response-parsing)
  - [Response Validation](#response-validation)
- [🛠️ Request Interceptors](#-request-interceptors)
  - [Authentication Interceptor](#authentication-interceptor)
  - [Custom Interceptors](#custom-interceptors)
- [📊 Error Handling](#-error-handling)
  - [Error Types](#error-types)
  - [Error Recovery](#error-recovery)
- [🔐 Authentication](#-authentication)
  - [Bearer Token Authentication](#bearer-token-authentication)
  - [OAuth Authentication](#oauth-authentication)
- [📦 Caching](#-caching)
  - [Cache Configuration](#cache-configuration)
  - [Cache Implementation](#cache-implementation)
- [🔄 Retry Logic](#-retry-logic)
  - [Retry Configuration](#retry-configuration)
  - [Custom Retry Logic](#custom-retry-logic)
- [📱 Examples](#-examples)
  - [REST API Client](#rest-api-client)
- [🧪 Testing](#-testing)
  - [Unit Testing](#unit-testing)
  - [Integration Testing](#integration-testing)
- [📞 Support](#-support)
<!-- TOC END -->


## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [⚡ Quick Start](#-quick-start)
- [🔧 Configuration](#-configuration)
- [📤 Making Requests](#-making-requests)
- [📥 Handling Responses](#-handling-responses)
- [🛠️ Request Interceptors](#-request-interceptors)
- [📊 Error Handling](#-error-handling)
- [🔐 Authentication](#-authentication)
- [📦 Caching](#-caching)
- [🔄 Retry Logic](#-retry-logic)
- [📱 Examples](#-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**HTTP Client Guide** provides comprehensive documentation for implementing HTTP client functionality in iOS applications using the iOS Networking Architecture Pro framework.

### 🎯 Key Features

- **Request Builder**: Fluent API for building HTTP requests
- **Response Handling**: Comprehensive response parsing and validation
- **Error Handling**: Advanced error handling and recovery
- **Request Interceptors**: Request/response interceptors and middleware
- **URL Session Integration**: Native URLSession integration
- **Background Tasks**: Background network task management
- **Request Queuing**: Intelligent request queuing and prioritization
- **Progress Tracking**: Upload/download progress tracking

---

## ⚡ Quick Start

### Basic HTTP Client Setup

```swift
import NetworkingArchitecturePro

// Initialize HTTP client manager
let httpClient = HTTPClientManager()

// Configure HTTP client
let httpConfig = HTTPClientConfiguration()
httpConfig.baseURL = "https://api.company.com"
httpConfig.timeout = 30 // seconds
httpConfig.maxRetries = 3
httpConfig.enableCaching = true
httpConfig.enableLogging = true

// Setup HTTP client
httpClient.configure(httpConfig)

// Create HTTP request
let request = HTTPRequest()
    .method(.get)
    .path("/users/123")
    .header("Authorization", "Bearer token")
    .header("Content-Type", "application/json")

// Execute HTTP request
httpClient.execute(request) { result in
    switch result {
    case .success(let response):
        print("✅ HTTP request successful")
        print("Status code: \(response.statusCode)")
        print("Data: \(response.data)")
        print("Headers: \(response.headers)")
    case .failure(let error):
        print("❌ HTTP request failed: \(error)")
    }
}
```

### Simple GET Request

```swift
// Simple GET request
let simpleClient = SimpleHTTPClient()

// Make GET request
simpleClient.get("https://api.company.com/users/123") { result in
    switch result {
    case .success(let response):
        print("✅ HTTP GET successful")
        print("Response: \(response)")
    case .failure(let error):
        print("❌ HTTP GET failed: \(error)")
    }
}

// Make POST request
let userData = ["name": "John", "email": "john@company.com"]
simpleClient.post("https://api.company.com/users", data: userData) { result in
    switch result {
    case .success(let response):
        print("✅ HTTP POST successful")
        print("Response: \(response)")
    case .failure(let error):
        print("❌ HTTP POST failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### HTTP Client Configuration

```swift
// Configure HTTP client settings
let httpConfig = HTTPClientConfiguration()

// Basic settings
httpConfig.baseURL = "https://api.company.com"
httpConfig.timeout = 30 // seconds
httpConfig.maxRetries = 3
httpConfig.enableCaching = true
httpConfig.enableLogging = true

// Security settings
httpConfig.enableCertificateValidation = true
httpConfig.enableSSLPinning = true

// Performance settings
httpConfig.enableCompression = true
httpConfig.maxConcurrentRequests = 10

// Custom headers
httpConfig.defaultHeaders = [
    "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
    "Accept": "application/json",
    "Accept-Encoding": "gzip, deflate"
]

// Apply configuration
httpClient.configure(httpConfig)
```

### Advanced Configuration

```swift
// Advanced HTTP client configuration
let advancedConfig = HTTPClientConfiguration()

// Connection settings
advancedConfig.baseURL = "https://api.company.com"
advancedConfig.timeout = 60 // seconds
advancedConfig.maxRetries = 5
advancedConfig.retryDelay = 2.0 // seconds
advancedConfig.exponentialBackoff = true

// Caching settings
advancedConfig.enableCaching = true
advancedConfig.cachePolicy = .returnCacheDataElseLoad
advancedConfig.maxCacheAge = 3600 // 1 hour

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

// Performance settings
advancedConfig.enableCompression = true
advancedConfig.maxConcurrentRequests = 20
advancedConfig.requestQueueSize = 100

// Custom settings
advancedConfig.defaultHeaders = [
    "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
    "Accept": "application/json",
    "Accept-Encoding": "gzip, deflate",
    "Cache-Control": "no-cache"
]

httpClient.configure(advancedConfig)
```

---

## 📤 Making Requests

### Request Builder

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

### Request Methods

```swift
// GET request
httpClient.get("/users/123") { result in
    switch result {
    case .success(let response):
        print("✅ GET successful: \(response)")
    case .failure(let error):
        print("❌ GET failed: \(error)")
    }
}

// POST request
let userData = ["name": "John", "email": "john@company.com"]
httpClient.post("/users", data: userData) { result in
    switch result {
    case .success(let response):
        print("✅ POST successful: \(response)")
    case .failure(let error):
        print("❌ POST failed: \(error)")
    }
}

// PUT request
let updateData = ["name": "John Doe", "email": "john.doe@company.com"]
httpClient.put("/users/123", data: updateData) { result in
    switch result {
    case .success(let response):
        print("✅ PUT successful: \(response)")
    case .failure(let error):
        print("❌ PUT failed: \(error)")
    }
}

// DELETE request
httpClient.delete("/users/123") { result in
    switch result {
    case .success(let response):
        print("✅ DELETE successful: \(response)")
    case .failure(let error):
        print("❌ DELETE failed: \(error)")
    }
}
```

### Request with Parameters

```swift
// Request with query parameters
let request = HTTPRequestBuilder()
    .method(.get)
    .url("https://api.company.com/users")
    .parameter("page", "1")
    .parameter("limit", "10")
    .parameter("sort", "name")
    .parameter("order", "asc")
    .build()

// Request with path parameters
let request = HTTPRequestBuilder()
    .method(.get)
    .url("https://api.company.com/users/{id}/posts/{postId}")
    .pathParameter("id", "123")
    .pathParameter("postId", "456")
    .build()

// Request with custom headers
let request = HTTPRequestBuilder()
    .method(.post)
    .url("https://api.company.com/users")
    .header("Authorization", "Bearer token")
    .header("Content-Type", "application/json")
    .header("X-API-Version", "v1")
    .header("X-Client-ID", "ios-app")
    .build()
```

---

## 📥 Handling Responses

### Response Parsing

```swift
// Parse JSON response
httpClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let user = response.asJSON(User.self) {
            print("✅ User: \(user.name)")
            print("Email: \(user.email)")
        } else {
            print("❌ Failed to parse JSON response")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}

// Parse text response
httpClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let text = response.asText() {
            print("✅ Text response: \(text)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}

// Parse binary response
httpClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let data = response.body {
            // Handle binary data (e.g., image, file)
            print("✅ Binary data received: \(data.count) bytes")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

### Response Validation

```swift
// Validate response status
httpClient.execute(request) { result in
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
httpClient.execute(request) { result in
    switch result {
    case .success(let response):
        if let contentType = response.headers["Content-Type"] {
            print("Content-Type: \(contentType)")
        }
        
        if let contentLength = response.headers["Content-Length"] {
            print("Content-Length: \(contentLength)")
        }
        
    case .failure(let error):
        print("❌ Request failed: \(error)")
    }
}
```

---

## 🛠️ Request Interceptors

### Authentication Interceptor

```swift
// Request interceptor manager
let interceptorManager = RequestInterceptorManager()

// Add authentication interceptor
interceptorManager.addInterceptor(AuthenticationInterceptor()) { request in
    request.header("Authorization", "Bearer \(getAccessToken())")
    return request
}

// Add logging interceptor
interceptorManager.addInterceptor(LoggingInterceptor()) { request in
    print("🌐 Request: \(request.method) \(request.path)")
    return request
}

// Add caching interceptor
interceptorManager.addInterceptor(CachingInterceptor()) { request in
    if let cachedResponse = getCachedResponse(for: request) {
        return .cached(cachedResponse)
    }
    return request
}

// Execute request with interceptors
httpClient.executeWithInterceptors(request, interceptors: interceptorManager.interceptors) { result in
    switch result {
    case .success(let response):
        print("✅ Request with interceptors successful")
        print("Response: \(response)")
    case .failure(let error):
        print("❌ Request with interceptors failed: \(error)")
    }
}
```

### Custom Interceptors

```swift
// Custom authentication interceptor
class CustomAuthInterceptor: RequestInterceptor {
    private let tokenProvider: () -> String?
    
    init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    func intercept(_ request: HTTPRequest) -> HTTPRequest {
        var modifiedRequest = request
        if let token = tokenProvider() {
            modifiedRequest.headers["Authorization"] = "Bearer \(token)"
        }
        return modifiedRequest
    }
}

// Custom logging interceptor
class CustomLoggingInterceptor: RequestInterceptor {
    func intercept(_ request: HTTPRequest) -> HTTPRequest {
        print("🌐 [\(Date())] \(request.method.rawValue) \(request.url)")
        print("📋 Headers: \(request.headers)")
        if let body = request.body {
            print("📦 Body: \(String(data: body, encoding: .utf8) ?? "")")
        }
        return request
    }
}

// Custom retry interceptor
class CustomRetryInterceptor: RequestInterceptor {
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    
    init(maxRetries: Int = 3, retryDelay: TimeInterval = 2.0) {
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
    
    func intercept(_ request: HTTPRequest) -> HTTPRequest {
        // Add retry logic here
        return request
    }
}
```

---

## 📊 Error Handling

### Error Types

```swift
// Handle different error types
httpClient.execute(request) { result in
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
            
        case .sslError(let reason):
            print("❌ SSL error: \(reason)")
            // Handle SSL/TLS issues
            
        case .authenticationError(let reason):
            print("❌ Authentication error: \(reason)")
            // Handle authentication issues
            
        case .serverError(let reason):
            print("❌ Server error: \(reason)")
            // Handle server errors
            
        case .clientError(let reason):
            print("❌ Client error: \(reason)")
            // Handle client errors
            
        case .parsingError(let reason):
            print("❌ Parsing error: \(reason)")
            // Handle response parsing issues
            
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
class HTTPErrorRecovery {
    private let httpClient: HTTPClientManager
    private var errorCount = 0
    private let maxErrors = 5
    
    init(httpClient: HTTPClientManager) {
        self.httpClient = httpClient
    }
    
    func handleError(_ error: HTTPClientError) {
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
    private let httpClient: HTTPClientManager
    private var accessToken: String?
    
    init(httpClient: HTTPClientManager) {
        self.httpClient = httpClient
    }
    
    func authenticate(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let authRequest = HTTPRequestBuilder()
            .method(.post)
            .url("https://api.company.com/auth/login")
            .jsonBody([
                "username": username,
                "password": password
            ])
            .build()
        
        httpClient.execute(authRequest) { result in
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
    
    func makeAuthenticatedRequest(_ request: HTTPRequest, completion: @escaping (Result<HTTPResponse, HTTPClientError>) -> Void) {
        var authenticatedRequest = request
        if let token = accessToken {
            authenticatedRequest.headers["Authorization"] = "Bearer \(token)"
        }
        
        httpClient.execute(authenticatedRequest, completion: completion)
    }
}
```

### OAuth Authentication

```swift
// OAuth authentication
class OAuthAuthenticator {
    private let httpClient: HTTPClientManager
    private let clientId: String
    private let clientSecret: String
    private var accessToken: String?
    private var refreshToken: String?
    
    init(httpClient: HTTPClientManager, clientId: String, clientSecret: String) {
        self.httpClient = httpClient
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    func authenticate(completion: @escaping (Result<String, Error>) -> Void) {
        let authRequest = HTTPRequestBuilder()
            .method(.post)
            .url("https://auth.company.com/oauth/token")
            .header("Content-Type", "application/x-www-form-urlencoded")
            .formData([
                "grant_type": "client_credentials",
                "client_id": clientId,
                "client_secret": clientSecret
            ])
            .build()
        
        httpClient.execute(authRequest) { result in
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
        
        let refreshRequest = HTTPRequestBuilder()
            .method(.post)
            .url("https://auth.company.com/oauth/token")
            .header("Content-Type", "application/x-www-form-urlencoded")
            .formData([
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": clientId,
                "client_secret": clientSecret
            ])
            .build()
        
        httpClient.execute(refreshRequest) { result in
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
let cacheConfig = CacheConfiguration()
cacheConfig.enableCaching = true
cacheConfig.cachePolicy = .returnCacheDataElseLoad
cacheConfig.maxCacheAge = 3600 // 1 hour
cacheConfig.maxCacheSize = 50 * 1024 * 1024 // 50MB
cacheConfig.diskCacheEnabled = true
cacheConfig.memoryCacheEnabled = true

httpClient.configureCache(cacheConfig)
```

### Cache Implementation

```swift
// Custom cache implementation
class CustomHTTPCache: HTTPCache {
    private let memoryCache = NSCache<NSString, CachedResponse>()
    private let diskCache: DiskCache
    
    init() {
        self.diskCache = DiskCache()
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    func get(for request: HTTPRequest) -> CachedResponse? {
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
    
    func set(_ response: CachedResponse, for request: HTTPRequest) {
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
    
    private func cacheKey(for request: HTTPRequest) -> String {
        return "\(request.method.rawValue)_\(request.url.absoluteString)"
    }
}
```

---

## 🔄 Retry Logic

### Retry Configuration

```swift
// Configure retry logic
let retryConfig = RetryConfiguration()
retryConfig.maxRetries = 3
retryConfig.retryDelay = 2.0 // seconds
retryConfig.exponentialBackoff = true
retryConfig.backoffMultiplier = 2.0
retryConfig.maxRetryDelay = 60.0 // seconds

httpClient.configureRetry(retryConfig)
```

### Custom Retry Logic

```swift
// Custom retry implementation
class CustomRetryHandler {
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    private let exponentialBackoff: Bool
    
    init(maxRetries: Int = 3, retryDelay: TimeInterval = 2.0, exponentialBackoff: Bool = true) {
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
        self.exponentialBackoff = exponentialBackoff
    }
    
    func executeWithRetry<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                if attempt < maxRetries {
                    let delay = exponentialBackoff ? retryDelay * pow(2.0, Double(attempt)) : retryDelay
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? HTTPClientError.unknownError("Max retries exceeded")
    }
}
```

---

## 📱 Examples

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
    
    func testHTTPRequest() {
        let request = HTTPRequestBuilder()
            .method(.get)
            .url("https://api.company.com/users/123")
            .header("Authorization", "Bearer token")
            .build()
        
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.url.absoluteString, "https://api.company.com/users/123")
        XCTAssertEqual(request.headers["Authorization"], "Bearer token")
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
}
```

---

## 📞 Support

For additional support and questions about HTTP Client:

- **Documentation**: [HTTP Client API Reference](HTTPClientAPI.md)
- **Examples**: [HTTP Client Examples](../Examples/HTTPClientExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this guide helped you!**
