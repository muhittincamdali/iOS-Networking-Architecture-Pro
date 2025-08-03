# Getting Started Guide

Welcome to iOS Networking Architecture Pro! This guide will help you get started with the framework and understand its core concepts.

## 📋 Table of Contents

- [Installation](#installation)
- [Basic Setup](#basic-setup)
- [Making Your First Request](#making-your-first-request)
- [Understanding the Architecture](#understanding-the-architecture)
- [Next Steps](#next-steps)

---

## 🚀 Installation

### Swift Package Manager (Recommended)

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git`
3. Click Add Package

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'iOS-Networking-Architecture-Pro', '~> 1.0.0'
```

Then run:
```bash
pod install
```

### Carthage

Add the following to your `Cartfile`:

```
github "muhittincamdali/iOS-Networking-Architecture-Pro" ~> 1.0.0
```

Then run:
```bash
carthage update
```

---

## ⚡ Basic Setup

### 1. Import the Framework

```swift
import NetworkingArchitecture
```

### 2. Configure the Network Manager

```swift
// Get the shared instance
let networkManager = NetworkManager.shared

// Configure with your API base URL
networkManager.configure(baseURL: "https://api.yourapp.com")
```

### 3. Optional: Configure Advanced Settings

```swift
let configuration = NetworkConfiguration()
configuration.timeoutInterval = 60.0
configuration.retryCount = 3
configuration.enableCompression = true

networkManager.configure(baseURL: "https://api.yourapp.com", configuration: configuration)
```

---

## 📡 Making Your First Request

### Simple GET Request

```swift
// Define your data model
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// Create a GET request
let request = APIRequest<User>.get("/users/1")

// Execute the request
networkManager.execute(request) { result in
    switch result {
    case .success(let user):
        print("User: \(user.name)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### POST Request with Body

```swift
// Create a POST request with data
let body = [
    "name": "John Doe",
    "email": "john@example.com"
]

let request = APIRequest<User>.post("/users", body: body)

networkManager.execute(request) { result in
    switch result {
    case .success(let user):
        print("Created user: \(user.name)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Using the Builder Pattern

```swift
// Create a request with advanced configuration
let request = APIRequestBuilder<User>.get("/users/1")
    .header("Authorization", value: "Bearer your-token")
    .cacheKey("user-1")
    .cacheTTL(1800) // 30 minutes
    .shouldSync(true)
    .retryCount(3)
    .timeout(30.0)
    .build()

networkManager.execute(request) { result in
    // Handle result
}
```

---

## 🏗️ Understanding the Architecture

### Core Components

The framework is built around several key components:

#### 1. NetworkManager
- Central orchestrator for all network operations
- Handles request execution, caching, and analytics
- Manages interceptors and configuration

#### 2. APIRequest
- Represents a network request with all its parameters
- Supports different HTTP methods (GET, POST, PUT, DELETE, etc.)
- Includes caching and synchronization options

#### 3. CacheManager
- Multi-level caching (memory and disk)
- Intelligent cache policies (LRU, LFU, TTL)
- Automatic cache invalidation

#### 4. Request Interceptors
- Modify requests before they're sent
- Add authentication, logging, or custom headers
- Chain multiple interceptors together

#### 5. Network Analytics
- Track request performance and success rates
- Monitor cache hit rates
- Real-time network health monitoring

### Design Patterns

The framework uses several design patterns:

- **Singleton Pattern**: NetworkManager.shared for global access
- **Builder Pattern**: APIRequestBuilder for complex request configuration
- **Strategy Pattern**: Different caching and sync strategies
- **Observer Pattern**: Real-time updates and notifications
- **Factory Pattern**: Request and response object creation

---

## 🔧 Advanced Features

### Caching

```swift
// Configure caching
let cacheConfig = CacheConfiguration()
cacheConfig.memoryCapacity = 50 * 1024 * 1024 // 50MB
cacheConfig.diskCapacity = 100 * 1024 * 1024  // 100MB
cacheConfig.ttl = 3600 // 1 hour

networkManager.configureCaching(cacheConfig)
```

### Request Interceptors

```swift
// Add authentication interceptor
let authInterceptor = AuthenticationInterceptor(token: "your-token")
networkManager.addInterceptor(authInterceptor)

// Add custom logging interceptor
let loggingInterceptor = LoggingInterceptor()
networkManager.addInterceptor(loggingInterceptor)
```

### Real-Time Synchronization

```swift
// Enable real-time sync
let syncConfig = SyncConfiguration()
syncConfig.enableWebSocket = true
syncConfig.syncInterval = 5.0
syncConfig.enableConflictResolution = true

networkManager.enableSync(syncConfig)
```

### Analytics

```swift
// Get network analytics
let analytics = networkManager.getAnalytics()
print("Total requests: \(analytics.totalRequests)")
print("Success rate: \(analytics.successfulRequests)")
print("Average response time: \(analytics.averageResponseTime)s")
print("Cache hit rate: \(analytics.cacheHitRate * 100)%")
```

---

## 🧪 Testing

### Unit Tests

```swift
import XCTest
@testable import NetworkingArchitecture

class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.example.com")
    }
    
    func testGETRequest() {
        let request = APIRequest<User>.get("/users/1")
        let expectation = XCTestExpectation(description: "GET request")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

---

## 📚 Next Steps

Now that you have the basics, explore these advanced topics:

1. **[API Reference](APIReference.md)** - Complete API documentation
2. **[Architecture Guide](ArchitectureGuide.md)** - Deep dive into the architecture
3. **[Caching Guide](CachingGuide.md)** - Advanced caching strategies
4. **[Synchronization Guide](SyncGuide.md)** - Real-time sync implementation
5. **[Security Guide](SecurityGuide.md)** - Security best practices
6. **[Performance Guide](PerformanceGuide.md)** - Optimization techniques
7. **[Testing Guide](TestingGuide.md)** - Comprehensive testing strategies

### Examples

Check out the `Examples/` folder for complete sample applications:

- **[Basic Networking](Examples/BasicNetworking/)** - Simple API requests
- **[Advanced Caching](Examples/AdvancedCaching/)** - Multi-level caching
- **[Real-Time Sync](Examples/RealTimeSync/)** - WebSocket communication
- **[Request Interceptors](Examples/RequestInterceptors/)** - Dynamic request modification
- **[Network Analytics](Examples/NetworkAnalytics/)** - Performance monitoring

---

## 🤝 Getting Help

- **Documentation**: Check the [Documentation](Documentation/) folder
- **Examples**: Explore the [Examples](Examples/) folder
- **Issues**: Report bugs on [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: Join the [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**Happy coding! 🚀** 