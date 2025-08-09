# 🔍 GraphQL API Reference

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [📦 GraphQLClient](#-graphqlclient)
- [📤 GraphQLQuery](#-graphqlquery)
- [📥 GraphQLResponse](#-graphqlresponse)
- [⚙️ GraphQLConfiguration](#-graphqlconfiguration)
- [🛠️ GraphQLSchema](#-graphqlschema)
- [❌ GraphQLError](#-graphqlerror)
- [📊 GraphQLStatistics](#-graphqlstatistics)
- [📱 Usage Examples](#-usage-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**GraphQL API Reference** provides comprehensive documentation for all GraphQL-related classes, protocols, and utilities in the iOS Networking Architecture Pro framework.

### 🎯 Key Components

- **GraphQLClient**: Main GraphQL client implementation
- **GraphQLQuery**: Query structure and builder
- **GraphQLResponse**: Response structure and parsing
- **GraphQLConfiguration**: Client configuration options
- **GraphQLSchema**: Schema introspection and validation
- **GraphQLError**: Error types and handling
- **GraphQLStatistics**: Performance and statistics

---

## 📦 GraphQLClient

### Class Definition

```swift
public class GraphQLClient {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: GraphQLConfiguration
    
    /// GraphQL schema
    public private(set) var schema: GraphQLSchema?
    
    /// GraphQL statistics
    public private(set) var statistics: GraphQLStatistics
    
    /// Whether the client is active
    public var isActive: Bool
    
    // MARK: - Event Handlers
    
    /// Called when GraphQL query starts
    public var onQueryStart: ((GraphQLQuery) -> Void)?
    
    /// Called when GraphQL query completes
    public var onQueryComplete: ((GraphQLQuery, GraphQLResponse) -> Void)?
    
    /// Called when GraphQL query fails
    public var onQueryFailure: ((GraphQLQuery, GraphQLError) -> Void)?
    
    /// Called when GraphQL response is received
    public var onResponseReceived: ((GraphQLResponse) -> Void)?
}
```

### Initialization

```swift
// Create GraphQL client
let graphQLClient = GraphQLClient()

// Create with configuration
let config = GraphQLConfiguration()
config.endpoint = "https://api.company.com/graphql"
let graphQLClient = GraphQLClient(configuration: config)

// Create with schema
let schema = GraphQLSchema()
let graphQLClient = GraphQLClient(schema: schema)
```

### Configuration Methods

```swift
// Configure GraphQL client
func configure(_ configuration: GraphQLConfiguration)

// Update configuration
func updateConfiguration(_ configuration: GraphQLConfiguration)

// Reset configuration to defaults
func resetConfiguration()
```

### Query Methods

```swift
// Execute GraphQL query
func query(_ query: GraphQLQuery, completion: @escaping (Result<GraphQLResponse, GraphQLError>) -> Void)

// Execute query with variables
func query(_ query: GraphQLQuery, variables: [String: Any], completion: @escaping (Result<GraphQLResponse, GraphQLError>) -> Void)

// Execute query with retry
func queryWithRetry(_ query: GraphQLQuery, maxRetries: Int, completion: @escaping (Result<GraphQLResponse, GraphQLError>) -> Void)

// Execute query with caching
func queryWithCache(_ query: GraphQLQuery, cachePolicy: GraphQLCachePolicy, completion: @escaping (Result<GraphQLResponse, GraphQLError>) -> Void)
```

### Schema Methods

```swift
// Introspect schema
func introspectSchema(completion: @escaping (Result<GraphQLSchema, GraphQLError>) -> Void)

// Validate query against schema
func validateQuery(_ query: GraphQLQuery) -> Bool

// Get schema types
func getSchemaTypes() -> [GraphQLType]?

// Get schema queries
func getSchemaQueries() -> [GraphQLField]?

// Get schema mutations
func getSchemaMutations() -> [GraphQLField]?

// Get schema subscriptions
func getSchemaSubscriptions() -> [GraphQLField]?
```

### Utility Methods

```swift
// Cancel all pending queries
func cancelAllQueries()

// Cancel specific query
func cancelQuery(_ query: GraphQLQuery)

// Get GraphQL statistics
func getGraphQLStats() -> GraphQLStatistics

// Clear query cache
func clearCache()

// Set cache policy
func setCachePolicy(_ policy: GraphQLCachePolicy)
```

---

## 📤 GraphQLQuery

### Structure Definition

```swift
public struct GraphQLQuery {
    /// Query string
    public let query: String
    
    /// Query variables
    public var variables: [String: Any]
    
    /// Query operation name
    public let operationName: String?
    
    /// Query type (query, mutation, subscription)
    public let type: GraphQLOperationType
    
    /// Query fragments
    public var fragments: [GraphQLFragment]
    
    /// Query directives
    public var directives: [GraphQLDirective]
    
    /// Query ID
    public let id: String
    
    /// Query timestamp
    public let timestamp: Date
    
    /// Query metadata
    public var metadata: [String: Any]
}
```

### Operation Types

```swift
public enum GraphQLOperationType {
    case query
    case mutation
    case subscription
}
```

### Query Builder

```swift
public class GraphQLQueryBuilder {
    private var query: GraphQLQuery
    
    public init() {
        self.query = GraphQLQuery()
    }
    
    // Set query string
    func query(_ queryString: String) -> GraphQLQueryBuilder
    
    // Set operation name
    func operationName(_ name: String) -> GraphQLQueryBuilder
    
    // Set operation type
    func operationType(_ type: GraphQLOperationType) -> GraphQLQueryBuilder
    
    // Add variable
    func variable(_ key: String, _ value: Any) -> GraphQLQueryBuilder
    
    // Add variables
    func variables(_ vars: [String: Any]) -> GraphQLQueryBuilder
    
    // Add fragment
    func fragment(_ fragment: GraphQLFragment) -> GraphQLQueryBuilder
    
    // Add fragments
    func fragments(_ fragments: [GraphQLFragment]) -> GraphQLQueryBuilder
    
    // Add directive
    func directive(_ directive: GraphQLDirective) -> GraphQLQueryBuilder
    
    // Add directives
    func directives(_ directives: [GraphQLDirective]) -> GraphQLQueryBuilder
    
    // Add metadata
    func metadata(_ key: String, _ value: Any) -> GraphQLQueryBuilder
    
    // Build query
    func build() -> GraphQLQuery
}
```

### Usage Examples

```swift
// Create user query
let userQuery = GraphQLQueryBuilder()
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

// Create create user mutation
let createUserMutation = GraphQLQueryBuilder()
    .query("""
        mutation CreateUser($input: CreateUserInput!) {
            createUser(input: $input) {
                id
                name
                email
                createdAt
            }
        }
    """)
    .operationName("CreateUser")
    .operationType(.mutation)
    .variable("input", [
        "name": "John Doe",
        "email": "john@company.com"
    ])
    .build()

// Create user subscription
let userSubscription = GraphQLQueryBuilder()
    .query("""
        subscription OnUserUpdate($userId: ID!) {
            userUpdate(userId: $userId) {
                id
                name
                email
                updatedAt
            }
        }
    """)
    .operationName("OnUserUpdate")
    .operationType(.subscription)
    .variable("userId", "123")
    .build()
```

---

## 📥 GraphQLResponse

### Structure Definition

```swift
public struct GraphQLResponse {
    /// Response data
    public let data: [String: Any]?
    
    /// Response errors
    public let errors: [GraphQLError]?
    
    /// Response extensions
    public let extensions: [String: Any]?
    
    /// Response status code
    public let statusCode: Int
    
    /// Response headers
    public let headers: [String: String]
    
    /// Response timestamp
    public let timestamp: Date
    
    /// Response duration
    public let duration: TimeInterval
    
    /// Response metadata
    public var metadata: [String: Any]
}
```

### Response Parsing

```swift
public extension GraphQLResponse {
    /// Check if response has errors
    var hasErrors: Bool { errors?.isEmpty == false }
    
    /// Check if response is successful
    var isSuccess: Bool { data != nil && !hasErrors }
    
    /// Get first error
    var firstError: GraphQLError? { errors?.first }
    
    /// Parse response data
    func parseData<T: Decodable>(_ type: T.Type) -> T?
    
    /// Parse specific field
    func parseField<T>(_ field: String, as type: T.Type) -> T?
    
    /// Get response as dictionary
    var asDictionary: [String: Any]? { data }
}
```

---

## ⚙️ GraphQLConfiguration

### Structure Definition

```swift
public struct GraphQLConfiguration {
    /// GraphQL endpoint URL
    public var endpoint: String
    
    /// HTTP headers
    public var headers: [String: String]
    
    /// Request timeout
    public var timeout: TimeInterval
    
    /// Enable query caching
    public var enableCaching: Bool
    
    /// Enable query logging
    public var enableLogging: Bool
    
    /// Enable query compression
    public var enableCompression: Bool
    
    /// Enable schema introspection
    public var enableIntrospection: Bool
    
    /// Enable query validation
    public var enableValidation: Bool
    
    /// Cache configuration
    public var cacheConfig: GraphQLCacheConfiguration
    
    /// Authentication configuration
    public var authConfig: GraphQLAuthConfiguration
}
```

### Default Configuration

```swift
public extension GraphQLConfiguration {
    /// Default configuration
    static let `default` = GraphQLConfiguration(
        endpoint: "",
        headers: [:],
        timeout: 30.0,
        enableCaching: true,
        enableLogging: false,
        enableCompression: true,
        enableIntrospection: true,
        enableValidation: true
    )
}
```

---

## 🛠️ GraphQLSchema

### Class Definition

```swift
public class GraphQLSchema {
    /// Schema types
    public private(set) var types: [String: GraphQLType]
    
    /// Schema queries
    public private(set) var queries: [String: GraphQLField]
    
    /// Schema mutations
    public private(set) var mutations: [String: GraphQLField]
    
    /// Schema subscriptions
    public private(set) var subscriptions: [String: GraphQLField]
    
    /// Schema directives
    public private(set) var directives: [String: GraphQLDirective]
    
    public init() {
        self.types = [:]
        self.queries = [:]
        self.mutations = [:]
        self.subscriptions = [:]
        self.directives = [:]
    }
}
```

### Schema Methods

```swift
// Add type to schema
func addType(_ type: GraphQLType)

// Add query to schema
func addQuery(_ query: GraphQLField)

// Add mutation to schema
func addMutation(_ mutation: GraphQLField)

// Add subscription to schema
func addSubscription(_ subscription: GraphQLField)

// Add directive to schema
func addDirective(_ directive: GraphQLDirective)

// Get type by name
func getType(_ name: String) -> GraphQLType?

// Get query by name
func getQuery(_ name: String) -> GraphQLField?

// Get mutation by name
func getMutation(_ name: String) -> GraphQLField?

// Get subscription by name
func getSubscription(_ name: String) -> GraphQLField?

// Validate query against schema
func validateQuery(_ query: GraphQLQuery) -> Bool
```

---

## ❌ GraphQLError

### Error Types

```swift
public enum GraphQLError: Error, LocalizedError {
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
    
    /// Schema error
    case schemaError(String)
    
    /// Query error
    case queryError(String)
    
    /// Subscription error
    case subscriptionError(String)
    
    /// Unknown error
    case unknownError(String)
}
```

---

## 📊 GraphQLStatistics

### Structure Definition

```swift
public struct GraphQLStatistics {
    /// Total queries executed
    public let totalQueries: Int
    
    /// Successful queries
    public let successfulQueries: Int
    
    /// Failed queries
    public let failedQueries: Int
    
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

### Basic GraphQL Usage

```swift
// Create GraphQL client
let graphQLClient = GraphQLClient()

// Configure client
let config = GraphQLConfiguration(
    endpoint: "https://api.company.com/graphql",
    timeout: 30.0,
    enableCaching: true
)
graphQLClient.configure(config)

// Create query
let query = GraphQLQueryBuilder()
    .query("""
        query GetUser($id: ID!) {
            user(id: $id) {
                id
                name
                email
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
        if let userData = response.data?["user"] as? [String: Any] {
            print("✅ User: \(userData["name"] ?? "")")
        }
        
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}
```

### Advanced GraphQL Usage

```swift
// Create advanced GraphQL client
let graphQLClient = GraphQLClient()

// Configure with advanced settings
let advancedConfig = GraphQLConfiguration(
    endpoint: "https://api.company.com/graphql",
    headers: [
        "Authorization": "Bearer token",
        "Content-Type": "application/json"
    ],
    timeout: 60.0,
    enableCaching: true,
    enableLogging: true,
    enableCompression: true,
    enableIntrospection: true,
    enableValidation: true
)
graphQLClient.configure(advancedConfig)

// Introspect schema
graphQLClient.introspectSchema { result in
    switch result {
    case .success(let schema):
        print("✅ Schema introspected successfully")
        print("Types: \(schema.types.count)")
        print("Queries: \(schema.queries.count)")
        print("Mutations: \(schema.mutations.count)")
        
    case .failure(let error):
        print("❌ Schema introspection failed: \(error)")
    }
}

// Create mutation
let mutation = GraphQLQueryBuilder()
    .query("""
        mutation CreateUser($input: CreateUserInput!) {
            createUser(input: $input) {
                id
                name
                email
                createdAt
            }
        }
    """)
    .operationName("CreateUser")
    .operationType(.mutation)
    .variable("input", [
        "name": "John Doe",
        "email": "john@company.com"
    ])
    .build()

// Execute mutation with retry
graphQLClient.queryWithRetry(mutation, maxRetries: 3) { result in
    switch result {
    case .success(let response):
        if let userData = response.data?["createUser"] as? [String: Any] {
            print("✅ User created: \(userData["name"] ?? "")")
        }
        
    case .failure(let error):
        print("❌ Mutation failed: \(error)")
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
        let query = GraphQLQueryBuilder()
            .query("query { user { id name } }")
            .operationName("GetUser")
            .operationType(.query)
            .build()
        
        XCTAssertEqual(query.query, "query { user { id name } }")
        XCTAssertEqual(query.operationName, "GetUser")
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
        
        let query = GraphQLQueryBuilder()
            .query("""
                query {
                    viewer {
                        login
                        name
                        email
                    }
                }
            """)
            .operationName("GetViewer")
            .operationType(.query)
            .build()
        
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

For additional support and questions about GraphQL API:

- **Documentation**: [GraphQL Guide](GraphQLGuide.md)
- **Examples**: [GraphQL Examples](../Examples/GraphQLExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this API reference helped you!**
