# API Reference

<!-- TOC START -->
## Table of Contents
- [API Reference](#api-reference)
- [📋 Table of Contents](#-table-of-contents)
- [NetworkManager](#networkmanager)
  - [Properties](#properties)
  - [Methods](#methods)
    - [configure(baseURL:configuration:)](#configurebaseurlconfiguration)
    - [execute(_:completion:)](#executecompletion)
    - [addInterceptor(_:)](#addinterceptor)
    - [removeInterceptor(_:)](#removeinterceptor)
    - [configureCaching(_:)](#configurecaching)
    - [enableSync(_:)](#enablesync)
    - [getAnalytics()](#getanalytics)
- [APIRequest](#apirequest)
  - [Properties](#properties)
  - [Initialization](#initialization)
  - [Convenience Initializers](#convenience-initializers)
    - [get(_:headers:)](#getheaders)
    - [post(_:body:headers:)](#postbodyheaders)
    - [put(_:body:headers:)](#putbodyheaders)
    - [delete(_:headers:)](#deleteheaders)
    - [patch(_:body:headers:)](#patchbodyheaders)
- [CacheManager](#cachemanager)
  - [Methods](#methods)
    - [set(_:for:ttl:)](#setforttl)
    - [get(for:)](#getfor)
    - [remove(for:)](#removefor)
    - [clear()](#clear)
    - [configure(_:)](#configure)
    - [getStatistics()](#getstatistics)
    - [cleanExpiredEntries()](#cleanexpiredentries)
- [NetworkConfiguration](#networkconfiguration)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [CacheConfiguration](#cacheconfiguration)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [SyncConfiguration](#syncconfiguration)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [NetworkError](#networkerror)
  - [Cases](#cases)
  - [Properties](#properties)
    - [errorDescription](#errordescription)
- [RequestInterceptor](#requestinterceptor)
  - [Methods](#methods)
    - [intercept(_:)](#intercept)
- [HTTPMethod](#httpmethod)
  - [Cases](#cases)
- [CachePolicy](#cachepolicy)
  - [Cases](#cases)
- [AnalyticsData](#analyticsdata)
  - [Properties](#properties)
  - [Initialization](#initialization)
- [CacheStatistics](#cachestatistics)
  - [Properties](#properties)
  - [Computed Properties](#computed-properties)
    - [hitRate](#hitrate)
  - [Initialization](#initialization)
- [CacheEntry](#cacheentry)
  - [Properties](#properties)
  - [Computed Properties](#computed-properties)
    - [isExpired](#isexpired)
  - [Initialization](#initialization)
<!-- TOC END -->


Complete API documentation for iOS Networking Architecture Pro.

## 📋 Table of Contents

- [NetworkManager](#networkmanager)
- [APIRequest](#apirequest)
- [CacheManager](#cachemanager)
- [NetworkConfiguration](#networkconfiguration)
- [CacheConfiguration](#cacheconfiguration)
- [SyncConfiguration](#syncconfiguration)
- [NetworkError](#networkerror)
- [RequestInterceptor](#requestinterceptor)

---

## NetworkManager

The main networking manager that handles all network operations.

### Properties

```swift
public static let shared: NetworkManager
```

### Methods

#### configure(baseURL:configuration:)

Configures the network manager with base URL and optional configuration.

```swift
public func configure(baseURL: String, configuration: NetworkConfiguration? = nil)
```

**Parameters:**
- `baseURL`: The base URL for all API requests
- `configuration`: Optional configuration for advanced settings

**Example:**
```swift
let networkManager = NetworkManager.shared
networkManager.configure(baseURL: "https://api.yourapp.com")
```

#### execute(_:completion:)

Executes an API request with automatic caching and analytics.

```swift
public func execute<T: Codable>(_ request: APIRequest<T>, completion: @escaping (Result<T, NetworkError>) -> Void)
```

**Parameters:**
- `request`: The API request to execute
- `completion`: Completion handler with result

**Example:**
```swift
let request = APIRequest<User>.get("/users/1")
networkManager.execute(request) { result in
    switch result {
    case .success(let user):
        print("User: \(user)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

#### addInterceptor(_:)

Adds a request interceptor for dynamic request modification.

```swift
public func addInterceptor(_ interceptor: RequestInterceptor)
```

**Parameters:**
- `interceptor`: The interceptor to add

**Example:**
```swift
let authInterceptor = AuthenticationInterceptor(token: "your-token")
networkManager.addInterceptor(authInterceptor)
```

#### removeInterceptor(_:)

Removes a specific interceptor.

```swift
public func removeInterceptor(_ interceptor: RequestInterceptor)
```

**Parameters:**
- `interceptor`: The interceptor to remove

#### configureCaching(_:)

Configures caching with custom settings.

```swift
public func configureCaching(_ configuration: CacheConfiguration)
```

**Parameters:**
- `configuration`: Cache configuration

**Example:**
```swift
let cacheConfig = CacheConfiguration()
cacheConfig.memoryCapacity = 50 * 1024 * 1024 // 50MB
cacheConfig.diskCapacity = 100 * 1024 * 1024  // 100MB
cacheConfig.ttl = 3600 // 1 hour

networkManager.configureCaching(cacheConfig)
```

#### enableSync(_:)

Enables real-time synchronization.

```swift
public func enableSync(_ configuration: SyncConfiguration)
```

**Parameters:**
- `configuration`: Sync configuration

**Example:**
```swift
let syncConfig = SyncConfiguration()
syncConfig.enableWebSocket = true
syncConfig.syncInterval = 5.0
syncConfig.enableConflictResolution = true

networkManager.enableSync(syncConfig)
```

#### getAnalytics()

Gets network analytics data.

```swift
public func getAnalytics() -> AnalyticsData
```

**Returns:** Current analytics data

**Example:**
```swift
let analytics = networkManager.getAnalytics()
print("Total requests: \(analytics.totalRequests)")
print("Success rate: \(analytics.successfulRequests)")
print("Average response time: \(analytics.averageResponseTime)s")
print("Cache hit rate: \(analytics.cacheHitRate * 100)%")
```

---

## APIRequest

Represents an API request with comprehensive configuration options.

### Properties

```swift
public let endpoint: String
public let method: HTTPMethod
public let headers: [String: String]
public let body: [String: Any]?
public let cacheKey: String
public let cacheTTL: TimeInterval
public let shouldSync: Bool
public let retryCount: Int
public let timeout: TimeInterval
```

### Initialization

```swift
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
)
```

### Convenience Initializers

#### get(_:headers:)

Creates a GET request.

```swift
public static func get<T>(_ endpoint: String, headers: [String: String] = [:]) -> APIRequest<T>
```

**Example:**
```swift
let request = APIRequest<User>.get("/users/1")
```

#### post(_:body:headers:)

Creates a POST request with body.

```swift
public static func post<T>(_ endpoint: String, body: [String: Any], headers: [String: String] = [:]) -> APIRequest<T>
```

**Example:**
```swift
let body = ["name": "John Doe", "email": "john@example.com"]
let request = APIRequest<User>.post("/users", body: body)
```

#### put(_:body:headers:)

Creates a PUT request with body.

```swift
public static func put<T>(_ endpoint: String, body: [String: Any], headers: [String: String] = [:]) -> APIRequest<T>
```

#### delete(_:headers:)

Creates a DELETE request.

```swift
public static func delete<T>(_ endpoint: String, headers: [String: String] = [:]) -> APIRequest<T>
```

#### patch(_:body:headers:)

Creates a PATCH request with body.

```swift
public static func patch<T>(_ endpoint: String, body: [String: Any], headers: [String: String] = [:]) -> APIRequest<T>
```

---

## CacheManager

Advanced cache manager with multi-level caching and intelligent policies.

### Methods

#### set(_:for:ttl:)

Stores data in cache with optional TTL.

```swift
public func set<T: Codable>(_ data: T, for key: String, ttl: TimeInterval = 3600)
```

**Parameters:**
- `data`: The data to cache
- `key`: Cache key
- `ttl`: Time to live in seconds

**Example:**
```swift
let user = User(id: 1, name: "John Doe", email: "john@example.com")
cacheManager.set(user, for: "user-1", ttl: 1800) // 30 minutes
```

#### get(for:)

Retrieves data from cache.

```swift
public func get<T: Codable>(for key: String) -> T?
```

**Parameters:**
- `key`: Cache key

**Returns:** Cached data if available and not expired

**Example:**
```swift
if let user: User = cacheManager.get(for: "user-1") {
    print("Cached user: \(user.name)")
}
```

#### remove(for:)

Removes data from cache.

```swift
public func remove(for key: String)
```

**Parameters:**
- `key`: Cache key

#### clear()

Clears all cached data.

```swift
public func clear()
```

#### configure(_:)

Configures cache settings.

```swift
public func configure(_ configuration: CacheConfiguration)
```

**Parameters:**
- `configuration`: Cache configuration

#### getStatistics()

Gets cache statistics.

```swift
public func getStatistics() -> CacheStatistics
```

**Returns:** Cache statistics

**Example:**
```swift
let stats = cacheManager.getStatistics()
print("Memory count: \(stats.memoryCount)")
print("Disk size: \(stats.diskSize)")
print("Hit rate: \(stats.hitRate * 100)%")
```

#### cleanExpiredEntries()

Cleans expired entries.

```swift
public func cleanExpiredEntries()
```

---

## NetworkConfiguration

Network configuration for advanced settings.

### Properties

```swift
public var timeoutInterval: TimeInterval = 30.0
public var retryCount: Int = 3
public var enableCompression: Bool = true
public var enableCertificatePinning: Bool = true
```

### Initialization

```swift
public init()
```

**Example:**
```swift
let config = NetworkConfiguration()
config.timeoutInterval = 60.0
config.retryCount = 5
config.enableCompression = true
config.enableCertificatePinning = true

networkManager.configure(baseURL: "https://api.yourapp.com", configuration: config)
```

---

## CacheConfiguration

Cache configuration with advanced options.

### Properties

```swift
public var memoryCapacity: Int
public var diskCapacity: Int
public var ttl: TimeInterval
public var policy: CachePolicy
public var enableCompression: Bool
public var enableEncryption: Bool
```

### Initialization

```swift
public init(
    memoryCapacity: Int = 50 * 1024 * 1024,
    diskCapacity: Int = 100 * 1024 * 1024,
    ttl: TimeInterval = 3600,
    policy: CachePolicy = .lru,
    enableCompression: Bool = true,
    enableEncryption: Bool = false
)
```

**Example:**
```swift
let cacheConfig = CacheConfiguration(
    memoryCapacity: 50 * 1024 * 1024, // 50MB
    diskCapacity: 100 * 1024 * 1024,  // 100MB
    ttl: 3600, // 1 hour
    policy: .lru,
    enableCompression: true,
    enableEncryption: false
)
```

---

## SyncConfiguration

Sync configuration for real-time synchronization.

### Properties

```swift
public var enableWebSocket: Bool = true
public var syncInterval: TimeInterval = 5.0
public var enableConflictResolution: Bool = true
```

### Initialization

```swift
public init()
```

**Example:**
```swift
let syncConfig = SyncConfiguration()
syncConfig.enableWebSocket = true
syncConfig.syncInterval = 5.0
syncConfig.enableConflictResolution = true

networkManager.enableSync(syncConfig)
```

---

## NetworkError

Comprehensive network error types.

### Cases

```swift
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
```

### Properties

#### errorDescription

Returns a localized error description.

```swift
public var errorDescription: String?
```

**Example:**
```swift
switch error {
case .httpError(let statusCode):
    print("HTTP error: \(statusCode)")
case .networkError(let underlyingError):
    print("Network error: \(underlyingError.localizedDescription)")
case .timeout:
    print("Request timed out")
default:
    print("Other error")
}
```

---

## RequestInterceptor

Protocol for request interceptors.

### Methods

#### intercept(_:)

Intercepts and modifies a request.

```swift
func intercept(_ request: APIRequest<Any>) -> APIRequest<Any>
```

**Parameters:**
- `request`: The request to intercept

**Returns:** Modified request

**Example:**
```swift
class CustomInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        var modifiedRequest = request
        modifiedRequest.headers["X-Custom-Header"] = "custom-value"
        return modifiedRequest
    }
}

let interceptor = CustomInterceptor()
networkManager.addInterceptor(interceptor)
```

---

## HTTPMethod

HTTP methods supported by the networking framework.

### Cases

```swift
case get = "GET"
case post = "POST"
case put = "PUT"
case delete = "DELETE"
case patch = "PATCH"
case head = "HEAD"
case options = "OPTIONS"
```

---

## CachePolicy

Different cache eviction policies.

### Cases

```swift
case lru // Least Recently Used
case lfu // Least Frequently Used
case fifo // First In, First Out
case ttl // Time To Live
```

---

## AnalyticsData

Analytics data for monitoring network performance.

### Properties

```swift
public let totalRequests: Int
public let successfulRequests: Int
public let failedRequests: Int
public let averageResponseTime: TimeInterval
public let cacheHitRate: Double
```

### Initialization

```swift
public init(
    totalRequests: Int,
    successfulRequests: Int,
    failedRequests: Int,
    averageResponseTime: TimeInterval,
    cacheHitRate: Double
)
```

---

## CacheStatistics

Statistics about cache performance.

### Properties

```swift
public let memoryCount: Int
public let diskSize: Int64
public let hitCount: Int
public let missCount: Int
```

### Computed Properties

#### hitRate

Calculates the cache hit rate.

```swift
public var hitRate: Double
```

### Initialization

```swift
public init(memoryCount: Int, diskSize: Int64, hitCount: Int, missCount: Int)
```

---

## CacheEntry

Represents a cached entry with metadata.

### Properties

```swift
public let data: Any
public let timestamp: Date
public let ttl: TimeInterval
```

### Computed Properties

#### isExpired

Checks if the cache entry is expired.

```swift
public var isExpired: Bool
```

### Initialization

```swift
public init(data: Any, timestamp: Date, ttl: TimeInterval)
```

---

This API reference provides comprehensive documentation for all public interfaces in the iOS Networking Architecture Pro framework. For more detailed examples and usage patterns, see the [Getting Started Guide](GettingStarted.md) and [Examples](../Examples/). 