// QuickStart.swift
// iOS-Networking-Architecture-Pro
//
// Quick start examples showing basic usage patterns.

import Foundation
import NetworkingArchitecture
import NetworkingREST

// MARK: - Models

struct User: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatar: URL?
}

struct Post: Codable, Sendable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct CreateUserRequest: Codable, Sendable {
    let name: String
    let email: String
}

// MARK: - Basic Usage

@main
struct QuickStartExample {
    static func main() async throws {
        print("🚀 iOS-Networking-Architecture-Pro Quick Start\n")
        
        // Example 1: Simple GET request
        try await simpleGetRequest()
        
        // Example 2: POST with body
        try await createResource()
        
        // Example 3: With authentication
        try await authenticatedRequest()
        
        // Example 4: With caching
        try await cachedRequest()
        
        // Example 5: Error handling
        try await errorHandling()
        
        print("\n✅ All examples completed!")
    }
    
    // MARK: - Example 1: Simple GET Request
    
    static func simpleGetRequest() async throws {
        print("📖 Example 1: Simple GET Request")
        
        let client = await RESTClient(
            baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
        )
        
        // Fetch single user
        let user: User = try await client.get("/users/1")
        print("  User: \(user.name) <\(user.email)>")
        
        // Fetch with query parameters
        let posts: [Post] = try await client.get("/posts", query: ["userId": 1, "_limit": 3])
        print("  Posts: \(posts.count) fetched")
    }
    
    // MARK: - Example 2: POST with Body
    
    static func createResource() async throws {
        print("\n📝 Example 2: POST with Body")
        
        let client = await RESTClient(
            baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
        )
        
        let newUser = CreateUserRequest(name: "John Doe", email: "john@example.com")
        let created: User = try await client.post("/users", body: newUser)
        print("  Created user with ID: \(created.id)")
    }
    
    // MARK: - Example 3: Authenticated Request
    
    static func authenticatedRequest() async throws {
        print("\n🔐 Example 3: Authenticated Request")
        
        // Bearer token authentication
        let authenticator = BearerTokenAuthenticator(token: "your-api-token")
        
        let client = NetworkClient(
            configuration: .default,
            authenticator: authenticator
        )
        
        print("  Client configured with Bearer authentication")
        
        // API Key authentication
        let apiKeyAuth = APIKeyAuthenticator(
            apiKey: "your-api-key",
            headerName: "X-API-Key"
        )
        
        print("  API Key authenticator ready")
    }
    
    // MARK: - Example 4: Cached Request
    
    static func cachedRequest() async throws {
        print("\n💾 Example 4: Cached Request")
        
        // Create cache
        let cache = InMemoryCache(maxSize: 10 * 1024 * 1024) // 10 MB
        
        // Client with cache
        let client = NetworkClient(
            configuration: .default,
            cache: cache
        )
        
        print("  Cache configured with 10 MB capacity")
        print("  Current cache size: \(await cache.size) bytes")
    }
    
    // MARK: - Example 5: Error Handling
    
    static func errorHandling() async throws {
        print("\n⚠️ Example 5: Error Handling")
        
        let client = await RESTClient(
            baseURL: URL(string: "https://jsonplaceholder.typicode.com")!
        )
        
        do {
            // This will fail (404)
            let _: User = try await client.get("/users/999999")
        } catch let error as NetworkError {
            switch error {
            case .notFound:
                print("  Handled: Resource not found (404)")
            case .unauthorized:
                print("  Handled: Authentication required")
            case .timeout:
                print("  Handled: Request timed out")
            case .noConnection:
                print("  Handled: No network connection")
            default:
                print("  Handled: \(error.localizedDescription)")
            }
        }
        
        print("  Error handling demonstrated successfully")
    }
}
