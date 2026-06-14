<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/Platform-iOS%20|%20macOS%20|%20visionOS-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="Platform"/>
  <img src="https://img.shields.io/badge/Standard-Unified%20Core-5856D6?style=for-the-badge" alt="Standard"/>
</p>

---

> **🛡️ PART OF THE 2026 UNIFIED CORE**
> This repository is a verified component of 'The Endless March' initiative. Purified for Swift 6, zero-dependency, and engineered for maximum hardware saturation.
> 
> *Flagship Engines:* [SwiftNetwork](https://github.com/muhittincamdali/SwiftNetwork) | [SwiftAI](https://github.com/muhittincamdali/SwiftAI) | [LiquidGlassKit](https://github.com/muhittincamdali/LiquidGlassKit)

---

# iOS-Networking-Architecture-Pro

## 🚀 Killer Feature: Zero-Copy Streaming Decoder
Process gigabytes of JSON data without memory spikes. Our `ZeroCopyDecoder` reads directly from the `AsyncStream` buffer, parsing JSON entities on-the-fly and drastically reducing heap allocations.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)
[![CI](https://github.com/muhittincamli/iOS-Networking-Architecture-Pro/workflows/CI/badge.svg)](https://github.com/muhittincamli/iOS-Networking-Architecture-Pro/actions)

A **production-ready**, **type-safe** networking architecture for iOS applications. Built with modern Swift concurrency (async/await), Clean Architecture principles, and support for multiple protocols including REST, GraphQL, WebSocket, Server-Sent Events, and gRPC.

## ✨ Features

### Core Architecture
- 🏗️ **Clean Architecture** - Separation of concerns with Repository pattern
- 🔒 **Type-Safe Endpoints** - Compile-time safety with protocol-based design
- ⚡ **Modern Async/Await** - Native Swift concurrency support
- 🎯 **Actor-Based** - Thread-safe by design

### Multi-Protocol Support
| Protocol | Description | Use Case |
|----------|-------------|----------|
| 🌐 REST | Full RESTful API support | Standard API calls |
| 📊 GraphQL | Query & Mutation support | Flexible data fetching |
| 🔌 WebSocket | Real-time bidirectional | Chat, live updates |
| 📡 SSE | Server-Sent Events | Live feeds, notifications |
| ⚡ gRPC | High-performance RPC | Microservices |

### Enterprise Features
- 🔐 **Authentication** - Bearer, OAuth2, API Key, Basic Auth
- 💾 **Caching** - Memory, Disk, and Hybrid caching with LRU eviction
- 🔄 **Retry Policies** - Exponential backoff with jitter
- 🔌 **Interceptors** - Request/Response transformation pipeline
- 📴 **Offline Queue** - Queue requests for later execution
- 📊 **Metrics** - Performance monitoring and analytics
- 📝 **Logging** - Structured logging with privacy controls

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamli/iOS-Networking-Architecture-Pro.git", from: "2.0.0")
]
```

Choose your modules:

```swift
// Core only
.product(name: "NetworkingArchitecture", package: "iOS-Networking-Architecture-Pro")

// With REST
.product(name: "NetworkingREST", package: "iOS-Networking-Architecture-Pro")

// Full bundle (all protocols)
.product(name: "NetworkingArchitectureFull", package: "iOS-Networking-Architecture-Pro")
```

## 🚀 Quick Start

### Basic REST Request

```swift
import NetworkingArchitecture
import NetworkingREST

// Define your model
struct User: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

// Create client
let client = await RESTClient(
    baseURL: URL(string: "https://api.example.com")!
)

// Make request
let user: User = try await client.get("/users/1")
print("User: \(user.name)")
```

### Type-Safe Endpoints

```swift
import NetworkingArchitecture

// Define endpoint
struct GetUserEndpoint: Endpoint {
    let userId: Int
    
    var baseURL: URL { URL(string: "https://api.example.com")! }
    var path: String { "/users/\(userId)" }
    var method: HTTPMethod { .get }
    var requiresAuthentication: Bool { true }
}

// Execute
let client = NetworkClient()
let request = Request<User>(endpoint: GetUserEndpoint(userId: 1))
let response = try await client.execute(request)
print("User: \(response.data.name)")
```

### With Authentication

```swift
// Bearer token
let authenticator = BearerTokenAuthenticator(
    token: "your-access-token",
    refreshHandler: {
        // Return refreshed token
        return TokenResponse(accessToken: "new-token")
    }
)

let client = NetworkClient(authenticator: authenticator)

// OAuth2
let oauth = OAuth2Authenticator(configuration: .init(
    clientId: "your-client-id",
    authorizeURL: URL(string: "https://auth.example.com/authorize")!,
    tokenURL: URL(string: "https://auth.example.com/token")!,
    redirectURL: URL(string: "yourapp://callback")!
))
```

### Caching

```swift
// Memory cache
let memoryCache = InMemoryCache(maxSize: 10 * 1024 * 1024) // 10 MB

// Disk cache
let diskCache = try DiskCache(maxSize: 100 * 1024 * 1024) // 100 MB

// Hybrid (memory + disk)
let hybridCache = try HybridCache(
    memoryCacheSize: 10 * 1024 * 1024,
    diskCacheSize: 100 * 1024 * 1024
)

// Use with client
let client = NetworkClient(cache: hybridCache)

// Endpoint with cache policy
struct CachedEndpoint: Endpoint {
    var cachePolicy: CachePolicy { .longLived } // 1 hour TTL
}
```

### Retry with Exponential Backoff

```swift
// Default retry policy
let policy = RetryPolicy.default // 3 attempts with exponential backoff

// Custom policy
let customPolicy = RetryPolicy(
    maxAttempts: 5,
    strategy: .exponential(base: 1.0, multiplier: 2.0),
    retryableStatusCodes: [429, 500, 502, 503, 504]
)

// Endpoint with retry
struct ReliableEndpoint: Endpoint {
    var retryPolicy: RetryPolicy { .aggressive }
}
```

### Interceptors

```swift
// Add logging
let loggingInterceptor = LoggingInterceptor(
    logLevel: .debug,
    logBody: true,
    logHeaders: true
)

// Add custom headers
let headerInterceptor = HeaderInterceptor(headers: [
    "X-App-Version": "2.0.0",
    "X-Platform": "iOS"
])

// Compose interceptors
let client = NetworkClient(
    interceptors: [
        loggingInterceptor,
        headerInterceptor,
        RequestIdInterceptor(),
        CompressionInterceptor()
    ]
)
```

### GraphQL

```swift
import NetworkingGraphQL

let graphQL = GraphQLClient(
    endpoint: URL(string: "https://api.example.com/graphql")!
)

// Query
struct UserQuery: GraphQLQuery {
    typealias Response = UserData
    
    let userId: Int
    
    var queryString: String {
        """
        query GetUser($id: ID!) {
            user(id: $id) {
                id
                name
                email
            }
        }
        """
    }
    
    var variables: [String: Any]? {
        ["id": userId]
    }
}

let userData = try await graphQL.query(UserQuery(userId: 1))
```

### WebSocket

```swift
import NetworkingWebSocket

let ws = WebSocketClient(
    url: URL(string: "wss://api.example.com/ws")!,
    configuration: .init(
        autoReconnect: true,
        maxReconnectAttempts: 5
    )
)

try await ws.connect()

// Send message
try await ws.send("Hello, server!")

// Receive messages
for await message in ws.messages() {
    switch message {
    case .text(let text):
        print("Received: \(text)")
    case .data(let data):
        print("Received \(data.count) bytes")
    }
}
```

### Server-Sent Events

```swift
import NetworkingSSE

let sse = SSEClient(url: URL(string: "https://api.example.com/events")!)

try await sse.connect()

// Subscribe to specific event
await sse.on("notification") { event in
    print("Notification: \(event.data ?? "")")
}

// Or use AsyncStream
for await event in sse.events(ofType: "update") {
    let update = try event.decode(as: SystemUpdate.self)
    print("Update: \(update)")
}
```

### Repository Pattern

```swift
// Define repository
let userRepository = NetworkRepository<User>(
    client: client,
    baseEndpoint: "https://api.example.com/users"
)

// CRUD operations
let users = try await userRepository.getAll()
let user = try await userRepository.get(id: 1)
let created = try await userRepository.create(newUser)
let updated = try await userRepository.update(modifiedUser)
try await userRepository.delete(id: 1)

// Pagination
let page = try await userRepository.getPage(page: 1, pageSize: 20)
```

### Offline Queue

```swift
let offlineQueue = OfflineQueue(maxSize: 100)

// Queue request when offline
try offlineQueue.enqueue(urlRequest, priority: 1)

// Process when back online
await offlineQueue.processQueue(using: client) { request, result in
    switch result {
    case .success:
        print("Request succeeded")
    case .failure(let error):
        print("Request failed: \(error)")
    }
}
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Application Layer                         │
├─────────────────────────────────────────────────────────────────┤
│  Repository      │  Use Cases      │  View Models               │
├─────────────────────────────────────────────────────────────────┤
│                        Domain Layer                              │
├─────────────────────────────────────────────────────────────────┤
│  Entities        │  Protocols      │  Business Logic            │
├─────────────────────────────────────────────────────────────────┤
│                        Data Layer                                │
├─────────────────────────────────────────────────────────────────┤
│                    NetworkingArchitecture                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │   REST   │ │ GraphQL  │ │WebSocket │ │   SSE    │ │  gRPC   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Core Module                           │    │
│  │  Client │ Cache │ Auth │ Interceptor │ Retry │ Queue    │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Module Structure

```
Sources/
├── Core/
│   ├── Client/          # NetworkClient, metrics
│   ├── Request/         # Endpoint, Request, HTTPMethod
│   ├── Response/        # Response, pagination
│   ├── Cache/           # Memory, Disk, Hybrid cache
│   ├── Auth/            # Authenticators (Bearer, OAuth2, etc)
│   ├── Interceptor/     # Request/Response interceptors
│   ├── Retry/           # Retry policies, circuit breaker
│   ├── Queue/           # Offline queue, sync manager
│   ├── Repository/      # Repository pattern implementation
│   ├── Error/           # NetworkError types
│   └── Logging/         # Structured logging
├── REST/                # RESTClient, RESTResource
├── GraphQL/             # GraphQLClient, queries, mutations
├── WebSocket/           # WebSocketClient, channels
├── SSE/                 # SSEClient, EventSource
└── gRPC/                # GRPCClient, messages
```

## 🧪 Testing

```swift
// Use testing configuration
let client = NetworkClient(configuration: .testing)

// Mock endpoint
struct MockEndpoint: Endpoint {
    var baseURL: URL { URL(string: "https://mock.local")! }
    var path: String { "/test" }
    var method: HTTPMethod { .get }
}

// Run tests
swift test
```

## ⚡ Performance

- **Zero-copy data handling** where possible
- **Connection pooling** via URLSession
- **Efficient caching** with LRU eviction
- **Request batching** for high-throughput scenarios
- **Memory-efficient** streaming for large responses

## 📋 Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## 📮 Support

- 📖 [Documentation](Documentation/)
- 🐛 [Issues](https://github.com/muhittincamli/iOS-Networking-Architecture-Pro/issues)
- 💬 [Discussions](https://github.com/muhittincamli/iOS-Networking-Architecture-Pro/discussions)

---

**Built with ❤️ for the iOS community**
