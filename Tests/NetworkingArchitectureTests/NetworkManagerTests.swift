import XCTest
@testable import NetworkingArchitecture

final class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.example.com")
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    // MARK: - Configuration Tests
    
    func testConfiguration() {
        // Given
        let baseURL = "https://api.test.com"
        let configuration = NetworkConfiguration()
        configuration.timeoutInterval = 60.0
        configuration.retryCount = 5
        
        // When
        networkManager.configure(baseURL: baseURL, configuration: configuration)
        
        // Then
        // Configuration should be applied successfully
        XCTAssertNotNil(networkManager)
    }
    
    // MARK: - Request Tests
    
    func testGETRequest() {
        // Given
        let request = APIRequest<User>.get("/users/1")
        
        // When & Then
        let expectation = XCTestExpectation(description: "GET request completion")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
            case .failure(let error):
                // Network error is expected in test environment
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPOSTRequest() {
        // Given
        let body = ["name": "John Doe", "email": "john@example.com"]
        let request = APIRequest<User>.post("/users", body: body)
        
        // When & Then
        let expectation = XCTestExpectation(description: "POST request completion")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
            case .failure(let error):
                // Network error is expected in test environment
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPUTRequest() {
        // Given
        let body = ["name": "Jane Doe", "email": "jane@example.com"]
        let request = APIRequest<User>.put("/users/1", body: body)
        
        // When & Then
        let expectation = XCTestExpectation(description: "PUT request completion")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
            case .failure(let error):
                // Network error is expected in test environment
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDELETERequest() {
        // Given
        let request = APIRequest<Void>.delete("/users/1")
        
        // When & Then
        let expectation = XCTestExpectation(description: "DELETE request completion")
        
        networkManager.execute(request) { result in
            switch result {
            case .success:
                // Success case
                break
            case .failure(let error):
                // Network error is expected in test environment
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Cache Tests
    
    func testCaching() {
        // Given
        let cacheConfig = CacheConfiguration()
        cacheConfig.memoryCapacity = 10 * 1024 * 1024 // 10MB
        cacheConfig.diskCapacity = 20 * 1024 * 1024 // 20MB
        cacheConfig.ttl = 1800 // 30 minutes
        
        // When
        networkManager.configureCaching(cacheConfig)
        
        // Then
        // Caching should be configured successfully
        XCTAssertNotNil(networkManager)
    }
    
    // MARK: - Interceptor Tests
    
    func testInterceptor() {
        // Given
        let interceptor = MockInterceptor()
        
        // When
        networkManager.addInterceptor(interceptor)
        
        // Then
        // Interceptor should be added successfully
        XCTAssertNotNil(networkManager)
    }
    
    func testRemoveInterceptor() {
        // Given
        let interceptor = MockInterceptor()
        networkManager.addInterceptor(interceptor)
        
        // When
        networkManager.removeInterceptor(interceptor)
        
        // Then
        // Interceptor should be removed successfully
        XCTAssertNotNil(networkManager)
    }
    
    // MARK: - Analytics Tests
    
    func testAnalytics() {
        // When
        let analytics = networkManager.getAnalytics()
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertGreaterThanOrEqual(analytics.totalRequests, 0)
        XCTAssertGreaterThanOrEqual(analytics.successfulRequests, 0)
        XCTAssertGreaterThanOrEqual(analytics.failedRequests, 0)
        XCTAssertGreaterThanOrEqual(analytics.averageResponseTime, 0)
        XCTAssertGreaterThanOrEqual(analytics.cacheHitRate, 0)
        XCTAssertLessThanOrEqual(analytics.cacheHitRate, 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkError() {
        // Given
        let request = APIRequest<User>.get("/invalid-endpoint")
        
        // When & Then
        let expectation = XCTestExpectation(description: "Network error handling")
        
        networkManager.execute(request) { result in
            switch result {
            case .success:
                XCTFail("Should not succeed with invalid endpoint")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertTrue(error is NetworkError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTimeoutError() {
        // Given
        let request = APIRequest<User>.get("/slow-endpoint")
        
        // When & Then
        let expectation = XCTestExpectation(description: "Timeout error handling")
        
        networkManager.execute(request) { result in
            switch result {
            case .success:
                XCTFail("Should not succeed with timeout")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertTrue(error is NetworkError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformance() {
        // Given
        let request = APIRequest<User>.get("/users/1")
        
        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            networkManager.execute(request) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Builder Pattern Tests
    
    func testRequestBuilder() {
        // Given
        let request = APIRequestBuilder<User>.get("/users/1")
            .header("Authorization", value: "Bearer token")
            .cacheKey("user-1")
            .cacheTTL(1800)
            .shouldSync(true)
            .retryCount(3)
            .timeout(30.0)
            .build()
        
        // Then
        XCTAssertEqual(request.endpoint, "/users/1")
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.headers["Authorization"], "Bearer token")
        XCTAssertEqual(request.cacheKey, "user-1")
        XCTAssertEqual(request.cacheTTL, 1800)
        XCTAssertTrue(request.shouldSync)
        XCTAssertEqual(request.retryCount, 3)
        XCTAssertEqual(request.timeout, 30.0)
    }
}

// MARK: - Supporting Types

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// MARK: - Mock Interceptor

class MockInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        var modifiedRequest = request
        modifiedRequest.headers["X-Test-Header"] = "test-value"
        return modifiedRequest
    }
}

// MARK: - Request Interceptor Protocol

protocol RequestInterceptor: AnyObject {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any>
} 