# 🔍 GraphQL Guide

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [⚡ Quick Start](#-quick-start)
- [🔧 Configuration](#-configuration)
- [📤 Making Queries](#-making-queries)
- [📥 Handling Responses](#-handling-responses)
- [🛠️ Schema Introspection](#-schema-introspection)
- [📊 Error Handling](#-error-handling)
- [🔐 Authentication](#-authentication)
- [📦 Caching](#-caching)
- [🔄 Subscriptions](#-subscriptions)
- [📱 Examples](#-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**GraphQL Guide** provides comprehensive documentation for implementing GraphQL functionality in iOS applications using the iOS Networking Architecture Pro framework.

### 🎯 Key Features

- **GraphQL Client**: Full-featured GraphQL client
- **Query Builder**: Type-safe GraphQL query builder
- **Schema Introspection**: GraphQL schema introspection
- **Query Optimization**: Query optimization and batching
- **Subscription Support**: Real-time GraphQL subscriptions
- **Fragment Management**: GraphQL fragment management
- **Error Handling**: GraphQL-specific error handling
- **Caching**: GraphQL query result caching

---

## ⚡ Quick Start

### Basic GraphQL Setup

```swift
import NetworkingArchitecturePro

// Initialize GraphQL client
let graphQLClient = GraphQLClient()

// Configure GraphQL client
let graphQLConfig = GraphQLConfiguration()
graphQLConfig.endpoint = "https://api.company.com/graphql"
graphQLConfig.enableCaching = true
graphQLConfig.enableSubscriptions = true

// Setup GraphQL client
graphQLClient.configure(graphQLConfig)

// Define GraphQL query
let userQuery = GraphQLQuery("""
    query GetUser($id: ID!) {
        user(id: $id) {
            id
            name
            email
            profile {
                avatar
                bio
            }
        }
    }
""")

// Execute GraphQL query
graphQLClient.query(
    userQuery,
    variables: ["id": "123"]
) { result in
    switch result {
    case .success(let response):
        print("✅ GraphQL query successful")
        print("User: \(response.data.user.name)")
        print("Email: \(response.data.user.email)")
        print("Avatar: \(response.data.user.profile.avatar)")
    case .failure(let error):
        print("❌ GraphQL query failed: \(error)")
    }
}
```

### Simple GraphQL Usage

```swift
// GraphQL client implementation
let graphQLClient = GraphQLClient()

// Configure client
let config = GraphQLConfiguration(
    endpoint: "https://api.company.com/graphql",
    timeout: 30.0,
    enableCaching: true
)
graphQLClient.configure(config)

// Simple query
let query = GraphQLQuery("""
    query {
        users {
            id
            name
            email
        }
    }
""")

graphQLClient.query(query) { result in
    switch result {
    case .success(let response):
        if let users = response.data?["users"] as? [[String: Any]] {
            print("✅ Users: \(users.count)")
            for user in users {
                print("- \(user["name"] ?? "")")
            }
        }
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### GraphQL Configuration

```swift
// Configure GraphQL settings
let graphQLConfig = GraphQLConfiguration()

// Basic settings
graphQLConfig.endpoint = "https://api.company.com/graphql"
graphQLConfig.timeout = 30.0
graphQLConfig.enableCaching = true
graphQLConfig.enableLogging = true

// Performance settings
graphQLConfig.enableCompression = true
graphQLConfig.enableIntrospection = true
graphQLConfig.enableValidation = true

// Custom headers
graphQLConfig.headers = [
    "Authorization": "Bearer token",
    "Content-Type": "application/json"
]

// Apply configuration
graphQLClient.configure(graphQLConfig)
```

### Advanced Configuration

```swift
// Advanced GraphQL configuration
let advancedConfig = GraphQLConfiguration()

// Connection settings
advancedConfig.endpoint = "https://api.company.com/graphql"
advancedConfig.timeout = 60.0
advancedConfig.enableCaching = true
advancedConfig.enableLogging = true

// Performance settings
advancedConfig.enableCompression = true
advancedConfig.enableIntrospection = true
advancedConfig.enableValidation = true
advancedConfig.enableSubscriptions = true

// Caching settings
advancedConfig.cachePolicy = .returnCacheDataElseLoad
advancedConfig.maxCacheAge = 3600 // 1 hour
advancedConfig.maxCacheSize = 50 * 1024 * 1024 // 50MB

// Security settings
advancedConfig.enableCertificateValidation = true
advancedConfig.enableSSLPinning = true

// Custom settings
advancedConfig.headers = [
    "Authorization": "Bearer token",
    "Content-Type": "application/json",
    "X-API-Version": "v1"
]

graphQLClient.configure(advancedConfig)
```

---

## 📤 Making Queries

### Query Builder

```swift
// Create query with builder
let query = GraphQLQueryBuilder()
    .query("""
        query GetUser($id: ID!) {
            user(id: $id) {
                id
                name
                email
                profile {
                    avatar
                    bio
                }
            }
        }
    """)
    .operationName("GetUser")
    .operationType(.query)
    .variable("id", "123")
    .build()

// Execute query
graphQLClient.query(query) { result in
    switch result {
    case .success(let response):
        print("✅ Query successful")
        if let userData = response.data?["user"] as? [String: Any] {
            print("User: \(userData["name"] ?? "")")
        }
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}
```

### Query Methods

```swift
// Simple query
let query = GraphQLQuery("""
    query {
        users {
            id
            name
            email
        }
    }
""")

graphQLClient.query(query) { result in
    switch result {
    case .success(let response):
        print("✅ Query successful")
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}

// Query with variables
let query = GraphQLQuery("""
    query GetUser($id: ID!) {
        user(id: $id) {
            id
            name
            email
        }
    }
""")

graphQLClient.query(query, variables: ["id": "123"]) { result in
    switch result {
    case .success(let response):
        print("✅ Query successful")
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}

// Query with retry
graphQLClient.queryWithRetry(query, maxRetries: 3) { result in
    switch result {
    case .success(let response):
        print("✅ Query successful")
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}
```

### Mutation Queries

```swift
// Create user mutation
let mutation = GraphQLQuery("""
    mutation CreateUser($input: CreateUserInput!) {
        createUser(input: $input) {
            id
            name
            email
            createdAt
        }
    }
""")

let variables = [
    "input": [
        "name": "John Doe",
        "email": "john@company.com"
    ]
]

graphQLClient.mutation(mutation, variables: variables) { result in
    switch result {
    case .success(let response):
        print("✅ User created successfully")
        if let userData = response.data?["createUser"] as? [String: Any] {
            print("User ID: \(userData["id"] ?? "")")
        }
    case .failure(let error):
        print("❌ Mutation failed: \(error)")
    }
}
```

---

## 📥 Handling Responses

### Response Parsing

```swift
// Parse JSON response
graphQLClient.query(query) { result in
    switch result {
    case .success(let response):
        if let userData = response.data?["user"] as? [String: Any] {
            print("✅ User: \(userData["name"] ?? "")")
            print("Email: \(userData["email"] ?? "")")
        } else {
            print("❌ Failed to parse response")
        }
        
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}

// Parse with Codable
struct User: Codable {
    let id: String
    let name: String
    let email: String
}

struct UserResponse: Codable {
    let user: User
}

graphQLClient.query(query) { result in
    switch result {
    case .success(let response):
        if let userResponse = response.asJSON(UserResponse.self) {
            print("✅ User: \(userResponse.user.name)")
        } else {
            print("❌ Failed to parse JSON response")
        }
        
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}
```

### Error Handling

```swift
// Handle GraphQL errors
graphQLClient.query(query) { result in
    switch result {
    case .success(let response):
        if let errors = response.errors, !errors.isEmpty {
            print("⚠️ GraphQL errors:")
            for error in errors {
                print("- \(error.message)")
            }
        } else {
            print("✅ Query successful")
        }
        
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}
```

---

## 🛠️ Schema Introspection

### Introspect Schema

```swift
// Introspect GraphQL schema
graphQLClient.introspectSchema { result in
    switch result {
    case .success(let schema):
        print("✅ Schema introspected successfully")
        print("Types: \(schema.types.count)")
        print("Queries: \(schema.queries.count)")
        print("Mutations: \(schema.mutations.count)")
        
        // Get available types
        if let userType = schema.getType("User") {
            print("User type fields: \(userType.fields.count)")
        }
        
    case .failure(let error):
        print("❌ Schema introspection failed: \(error)")
    }
}
```

### Schema Validation

```swift
// Validate query against schema
let query = GraphQLQuery("""
    query GetUser($id: ID!) {
        user(id: $id) {
            id
            name
            email
        }
    }
""")

if graphQLClient.validateQuery(query) {
    print("✅ Query is valid")
} else {
    print("❌ Query is invalid")
}
```

---

## 📊 Error Handling

### Error Types

```swift
// Handle different error types
graphQLClient.query(query) { result in
    switch result {
    case .success(let response):
        print("✅ Query successful")
        
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
            
        case .serverError(let reason):
            print("❌ Server error: \(reason)")
            // Handle server errors
            
        case .parsingError(let reason):
            print("❌ Parsing error: \(reason)")
            // Handle response parsing issues
            
        case .validationError(let reason):
            print("❌ Validation error: \(reason)")
            // Handle query validation issues
            
        case .schemaError(let reason):
            print("❌ Schema error: \(reason)")
            // Handle schema issues
            
        case .queryError(let reason):
            print("❌ Query error: \(reason)")
            // Handle query issues
            
        case .subscriptionError(let reason):
            print("❌ Subscription error: \(reason)")
            // Handle subscription issues
            
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
class GraphQLErrorRecovery {
    private let graphQLClient: GraphQLClient
    private var errorCount = 0
    private let maxErrors = 5
    
    init(graphQLClient: GraphQLClient) {
        self.graphQLClient = graphQLClient
    }
    
    func handleError(_ error: GraphQLError) {
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
                self.retryQuery()
            }
            
        case .timeoutError:
            // Increase timeout and retry
            increaseTimeout()
            retryQuery()
            
        case .authenticationError:
            // Refresh token and retry
            refreshToken { success in
                if success {
                    self.retryQuery()
                }
            }
            
        case .serverError:
            // Wait and retry
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.retryQuery()
            }
            
        default:
            // Log error and continue
            print("❌ Unhandled error: \(error)")
        }
    }
    
    private func retryQuery() {
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
class GraphQLBearerAuthenticator {
    private let graphQLClient: GraphQLClient
    private var accessToken: String?
    
    init(graphQLClient: GraphQLClient) {
        self.graphQLClient = graphQLClient
    }
    
    func authenticate(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let authQuery = GraphQLQuery("""
            mutation Login($username: String!, $password: String!) {
                login(username: $username, password: $password) {
                    accessToken
                    refreshToken
                }
            }
        """)
        
        let variables = [
            "username": username,
            "password": password
        ]
        
        graphQLClient.mutation(authQuery, variables: variables) { result in
            switch result {
            case .success(let response):
                if let loginData = response.data?["login"] as? [String: Any] {
                    self.accessToken = loginData["accessToken"] as? String
                    completion(.success(loginData["accessToken"] as? String ?? ""))
                } else {
                    completion(.failure(AuthenticationError.invalidCredentials("Failed to parse auth response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makeAuthenticatedQuery(_ query: GraphQLQuery, variables: [String: Any]? = nil, completion: @escaping (Result<GraphQLResponse, GraphQLError>) -> Void) {
        var authenticatedQuery = query
        if let token = accessToken {
            authenticatedQuery.headers["Authorization"] = "Bearer \(token)"
        }
        
        graphQLClient.query(authenticatedQuery, variables: variables, completion: completion)
    }
}
```

---

## 📦 Caching

### Cache Configuration

```swift
// Configure GraphQL caching
let cacheConfig = GraphQLCacheConfiguration()
cacheConfig.enableCaching = true
cacheConfig.cachePolicy = .returnCacheDataElseLoad
cacheConfig.maxCacheAge = 3600 // 1 hour
cacheConfig.maxCacheSize = 50 * 1024 * 1024 // 50MB
cacheConfig.diskCacheEnabled = true
cacheConfig.memoryCacheEnabled = true

graphQLClient.configureCache(cacheConfig)
```

### Cache Implementation

```swift
// Custom GraphQL cache implementation
class CustomGraphQLCache: GraphQLCache {
    private let memoryCache = NSCache<NSString, CachedResponse>()
    private let diskCache: DiskCache
    
    init() {
        self.diskCache = DiskCache()
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    func get(for query: GraphQLQuery) -> CachedResponse? {
        let key = cacheKey(for: query)
        
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
    
    func set(_ response: CachedResponse, for query: GraphQLQuery) {
        let key = cacheKey(for: query)
        
        // Store in memory cache
        memoryCache.setObject(response, forKey: key as NSString)
        
        // Store in disk cache
        diskCache.set(response, for: key)
    }
    
    func clear() {
        memoryCache.removeAllObjects()
        diskCache.clear()
    }
    
    private func cacheKey(for query: GraphQLQuery) -> String {
        return "\(query.query)_\(query.variables?.description ?? "")"
    }
}
```

---

## 🔄 Subscriptions

### Subscription Setup

```swift
// GraphQL subscription manager
let subscriptionManager = GraphQLSubscriptionManager()

// Configure subscription management
let subscriptionConfig = SubscriptionConfiguration()
subscriptionConfig.enableSubscriptions = true
subscriptionConfig.connectionTimeout = 30.0
subscriptionConfig.reconnectDelay = 5.0
subscriptionConfig.maxReconnectionAttempts = 10

subscriptionManager.configure(subscriptionConfig)

// Define subscription
let userUpdateSubscription = GraphQLSubscription("""
    subscription OnUserUpdate($userId: ID!) {
        userUpdate(userId: $userId) {
            id
            name
            email
            updatedAt
        }
    }
""")

// Subscribe to user updates
subscriptionManager.subscribe(
    userUpdateSubscription,
    variables: ["userId": "123"]
) { result in
    switch result {
    case .success(let update):
        print("✅ User update received")
        if let userData = update.data?["userUpdate"] as? [String: Any] {
            print("User: \(userData["name"] ?? "")")
            print("Updated: \(userData["updatedAt"] ?? "")")
        }
    case .failure(let error):
        print("❌ Subscription failed: \(error)")
    }
}
```

### Subscription Management

```swift
// Monitor subscription status
subscriptionManager.onConnectionStatusChange { status in
    switch status {
    case .connected:
        print("✅ Subscription connected")
    case .disconnected:
        print("❌ Subscription disconnected")
    case .connecting:
        print("🔄 Subscription connecting...")
    case .reconnecting:
        print("🔄 Subscription reconnecting...")
    }
}

// Handle subscription errors
subscriptionManager.onError { error in
    print("❌ Subscription error: \(error)")
}

// Unsubscribe from subscription
subscriptionManager.unsubscribe(userUpdateSubscription) { result in
    switch result {
    case .success:
        print("✅ Unsubscribed successfully")
    case .failure(let error):
        print("❌ Unsubscribe failed: \(error)")
    }
}
```

---

## 📱 Examples

### GraphQL Client Implementation

```swift
// GraphQL client implementation
class GraphQLAPIClient {
    private let graphQLClient: GraphQLClient
    private let endpoint: String
    
    init(endpoint: String) {
        self.graphQLClient = GraphQLClient()
        self.endpoint = endpoint
        
        let config = GraphQLConfiguration(
            endpoint: endpoint,
            timeout: 30.0,
            enableCaching: true
        )
        graphQLClient.configure(config)
    }
    
    // Query method
    func query<T: Decodable>(_ queryString: String, variables: [String: Any]? = nil, completion: @escaping (Result<T, GraphQLError>) -> Void) {
        let query = GraphQLQuery(queryString)
        
        graphQLClient.query(query, variables: variables) { result in
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
    
    // Mutation method
    func mutation<T: Encodable, U: Decodable>(_ mutationString: String, variables: [String: Any]? = nil, completion: @escaping (Result<U, GraphQLError>) -> Void) {
        let mutation = GraphQLQuery(mutationString)
        
        graphQLClient.mutation(mutation, variables: variables) { result in
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
    
    // Subscription method
    func subscribe<T: Decodable>(_ subscriptionString: String, variables: [String: Any]? = nil, completion: @escaping (Result<T, GraphQLError>) -> Void) {
        let subscription = GraphQLSubscription(subscriptionString)
        
        let subscriptionManager = GraphQLSubscriptionManager()
        subscriptionManager.subscribe(subscription, variables: variables) { result in
            switch result {
            case .success(let update):
                if let object = update.asJSON(T.self) {
                    completion(.success(object))
                } else {
                    completion(.failure(.parsingError("Failed to parse response")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Usage example
let graphQLClient = GraphQLAPIClient(endpoint: "https://api.company.com/graphql")

// Query users
let userQuery = """
query {
    users {
        id
        name
        email
    }
}
"""

graphQLClient.query(userQuery) { (result: Result<[User], GraphQLError>) in
    switch result {
    case .success(let users):
        print("✅ Users: \(users.count)")
        for user in users {
            print("- \(user.name)")
        }
    case .failure(let error):
        print("❌ Error: \(error)")
    }
}

// Create user mutation
let createUserMutation = """
mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
        id
        name
        email
    }
}
"""

let variables = [
    "input": [
        "name": "John Doe",
        "email": "john@company.com"
    ]
]

graphQLClient.mutation(createUserMutation, variables: variables) { (result: Result<User, GraphQLError>) in
    switch result {
    case .success(let user):
        print("✅ Created user: \(user.name)")
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

class GraphQLTests: XCTestCase {
    var graphQLClient: GraphQLClient!
    
    override func setUp() {
        super.setUp()
        graphQLClient = GraphQLClient()
    }
    
    override func tearDown() {
        graphQLClient = nil
        super.tearDown()
    }
    
    func testGraphQLConfiguration() {
        let config = GraphQLConfiguration(
            endpoint: "https://api.company.com/graphql",
            timeout: 30.0,
            enableCaching: true
        )
        
        graphQLClient.configure(config)
        
        XCTAssertEqual(graphQLClient.configuration.endpoint, "https://api.company.com/graphql")
        XCTAssertEqual(graphQLClient.configuration.timeout, 30.0)
        XCTAssertTrue(graphQLClient.configuration.enableCaching)
    }
    
    func testGraphQLQuery() {
        let query = GraphQLQuery("""
            query {
                user {
                    id
                    name
                }
            }
        """)
        
        XCTAssertEqual(query.query, """
            query {
                user {
                    id
                    name
                }
            }
        """)
        XCTAssertEqual(query.type, .query)
    }
    
    func testGraphQLResponse() {
        let responseData = [
            "data": [
                "user": [
                    "id": "123",
                    "name": "John Doe",
                    "email": "john@company.com"
                ]
            ]
        ]
        
        let response = GraphQLResponse(
            data: responseData["data"],
            errors: nil,
            extensions: nil,
            statusCode: 200,
            headers: [:],
            timestamp: Date(),
            duration: 0.5,
            metadata: [:]
        )
        
        XCTAssertTrue(response.isSuccess)
        XCTAssertFalse(response.hasErrors)
        
        if let userData = response.data?["user"] as? [String: Any] {
            XCTAssertEqual(userData["name"] as? String, "John Doe")
            XCTAssertEqual(userData["email"] as? String, "john@company.com")
        } else {
            XCTFail("Failed to parse response data")
        }
    }
}
```

### Integration Testing

```swift
class GraphQLIntegrationTests: XCTestCase {
    func testGraphQLWithRealServer() {
        let expectation = XCTestExpectation(description: "GraphQL query")
        
        let graphQLClient = GraphQLClient()
        let config = GraphQLConfiguration(
            endpoint: "https://api.github.com/graphql",
            timeout: 30.0,
            enableCaching: true
        )
        graphQLClient.configure(config)
        
        let query = GraphQLQuery("""
            query {
                viewer {
                    login
                    name
                    email
                }
            }
        """)
        
        graphQLClient.query(query) { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.isSuccess)
                XCTAssertFalse(response.hasErrors)
                
                if let viewerData = response.data?["viewer"] as? [String: Any] {
                    XCTAssertNotNil(viewerData["login"])
                    expectation.fulfill()
                } else {
                    XCTFail("Failed to parse response data")
                }
                
            case .failure(let error):
                XCTFail("GraphQL query failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

---

## 📞 Support

For additional support and questions about GraphQL:

- **Documentation**: [GraphQL API Reference](GraphQLAPI.md)
- **Examples**: [GraphQL Examples](../Examples/GraphQLExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this guide helped you!**
