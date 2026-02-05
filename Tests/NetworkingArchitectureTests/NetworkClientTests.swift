// NetworkClientTests.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import XCTest
@testable import NetworkingArchitecture

final class NetworkClientTests: XCTestCase {
    
    var client: NetworkClient!
    
    override func setUp() async throws {
        client = NetworkClient(configuration: .testing)
    }
    
    // MARK: - Request Tests
    
    func testBasicGETRequest() async throws {
        // Setup mock endpoint
        let endpoint = MockEndpoint<User>(
            baseURL: URL(string: "https://api.example.com")!,
            path: "/users/1",
            method: .get
        )
        
        let request = Request(endpoint: endpoint)
        
        // Verify request can be built
        let urlRequest = try endpoint.asURLRequest()
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url?.path, "/users/1")
    }
    
    func testPOSTRequestWithBody() async throws {
        let user = User(id: 1, name: "Test", email: "test@example.com")
        
        let endpoint = MockEndpoint<User>(
            baseURL: URL(string: "https://api.example.com")!,
            path: "/users",
            method: .post,
            body: .json(user)
        )
        
        let urlRequest = try endpoint.asURLRequest()
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertNotNil(urlRequest.httpBody)
    }
    
    func testQueryParameters() async throws {
        let endpoint = MockEndpoint<[User]>(
            baseURL: URL(string: "https://api.example.com")!,
            path: "/users",
            method: .get,
            queryParameters: ["page": 1, "limit": 10]
        )
        
        let urlRequest = try endpoint.asURLRequest()
        XCTAssertTrue(urlRequest.url?.absoluteString.contains("page=1") ?? false)
        XCTAssertTrue(urlRequest.url?.absoluteString.contains("limit=10") ?? false)
    }
    
    // MARK: - Cache Tests
    
    func testCacheHit() async throws {
        let cache = InMemoryCache(maxSize: 1024)
        let key = CacheKey(url: URL(string: "https://example.com/test")!)
        
        let testData = "test".data(using: .utf8)!
        try await cache.set(testData, for: key, ttl: 60)
        
        let retrieved = try await cache.get(key)
        XCTAssertEqual(retrieved, testData)
    }
    
    func testCacheMiss() async throws {
        let cache = InMemoryCache(maxSize: 1024)
        let key = CacheKey(url: URL(string: "https://example.com/nonexistent")!)
        
        let retrieved = try await cache.get(key)
        XCTAssertNil(retrieved)
    }
    
    func testCacheExpiration() async throws {
        let cache = InMemoryCache(maxSize: 1024)
        let key = CacheKey(url: URL(string: "https://example.com/test")!)
        
        let testData = "test".data(using: .utf8)!
        try await cache.set(testData, for: key, ttl: 0.1) // 100ms TTL
        
        // Wait for expiration
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let retrieved = try await cache.get(key)
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Retry Tests
    
    func testRetryPolicyExponentialBackoff() {
        let policy = RetryPolicy(
            maxAttempts: 3,
            strategy: .exponential(base: 1.0, multiplier: 2.0)
        )
        
        XCTAssertEqual(policy.strategy.delay(for: 0), 1.0)
        XCTAssertEqual(policy.strategy.delay(for: 1), 2.0)
        XCTAssertEqual(policy.strategy.delay(for: 2), 4.0)
    }
    
    func testRetryPolicyConstantDelay() {
        let policy = RetryPolicy(
            maxAttempts: 3,
            strategy: .constant(2.0)
        )
        
        XCTAssertEqual(policy.strategy.delay(for: 0), 2.0)
        XCTAssertEqual(policy.strategy.delay(for: 1), 2.0)
        XCTAssertEqual(policy.strategy.delay(for: 2), 2.0)
    }
    
    func testShouldRetryOnRecoverableError() {
        let policy = RetryPolicy.default
        
        XCTAssertTrue(policy.shouldRetry(error: .timeout, attempt: 0))
        XCTAssertTrue(policy.shouldRetry(error: .noConnection, attempt: 0))
        XCTAssertFalse(policy.shouldRetry(error: .notFound, attempt: 0))
    }
    
    // MARK: - Error Tests
    
    func testNetworkErrorEquality() {
        XCTAssertEqual(NetworkError.timeout, NetworkError.timeout)
        XCTAssertEqual(NetworkError.unauthorized, NetworkError.unauthorized)
        XCTAssertNotEqual(NetworkError.timeout, NetworkError.noConnection)
    }
    
    func testNetworkErrorFromURLError() {
        let timeoutError = URLError(.timedOut)
        let networkError = NetworkError.from(timeoutError)
        XCTAssertEqual(networkError, .timeout)
        
        let noConnectionError = URLError(.notConnectedToInternet)
        let networkError2 = NetworkError.from(noConnectionError)
        XCTAssertEqual(networkError2, .noConnection)
    }
    
    // MARK: - Interceptor Tests
    
    func testHeaderInterceptor() async throws {
        let interceptor = HeaderInterceptor(headers: ["X-Custom": "Value"])
        let context = RequestContext()
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = try await interceptor.intercept(request: request, context: context)
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Custom"), "Value")
    }
    
    func testRequestIdInterceptor() async throws {
        let interceptor = RequestIdInterceptor()
        let context = RequestContext(requestId: UUID())
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = try await interceptor.intercept(request: request, context: context)
        
        XCTAssertNotNil(request.value(forHTTPHeaderField: "X-Request-ID"))
    }
    
    // MARK: - Authentication Tests
    
    func testBearerTokenAuthentication() async throws {
        let authenticator = BearerTokenAuthenticator(token: "test-token")
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = try await authenticator.authenticate(request: request)
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
    }
    
    func testAPIKeyAuthentication() async throws {
        let authenticator = APIKeyAuthenticator(apiKey: "api-key-123")
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = try await authenticator.authenticate(request: request)
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-API-Key"), "api-key-123")
    }
    
    func testBasicAuthAuthentication() async throws {
        let authenticator = BasicAuthAuthenticator(username: "user", password: "pass")
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = try await authenticator.authenticate(request: request)
        
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertTrue(authHeader?.hasPrefix("Basic ") ?? false)
    }
}

// MARK: - Mock Types

struct User: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

struct MockEndpoint<Response>: Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    var headers: [String: String] = [:]
    var queryParameters: [String: Any]?
    var body: RequestBody?
    var timeoutInterval: TimeInterval?
    var cachePolicy: CachePolicy = .default
    var retryPolicy: RetryPolicy = .default
    var requiresAuthentication: Bool = false
    var contentType: ContentType = .json
    var acceptType: ContentType = .json
}
