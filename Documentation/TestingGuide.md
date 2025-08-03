# Testing Guide

Complete testing strategy and implementation guide for iOS Networking Architecture Pro.

## 📋 Table of Contents

- [Overview](#overview)
- [Unit Testing](#unit-testing)
- [Integration Testing](#integration-testing)
- [Performance Testing](#performance-testing)
- [Security Testing](#security-testing)
- [UI Testing](#ui-testing)
- [Test Automation](#test-automation)

---

## Overview

Comprehensive testing is essential for reliable networking applications. This guide covers all testing strategies and best practices for the iOS Networking Architecture Pro framework.

### Testing Goals

- **100% Test Coverage**: All public APIs tested
- **Performance Validation**: Response time and throughput tests
- **Security Verification**: Security feature testing
- **Reliability Assurance**: Error handling and edge cases
- **Automation**: Continuous testing integration

---

## Unit Testing

### 1. NetworkManager Tests

Test the core networking functionality.

```swift
class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.test.com")
    }
    
    func testConfiguration() {
        // Test network manager configuration
        XCTAssertNotNil(networkManager)
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
    
    func testPOSTRequest() {
        let body = ["name": "John Doe", "email": "john@example.com"]
        let request = APIRequest<User>.post("/users", body: body)
        let expectation = XCTestExpectation(description: "POST request")
        
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

### 2. CacheManager Tests

Test caching functionality.

```swift
class CacheManagerTests: XCTestCase {
    var cacheManager: CacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager()
    }
    
    func testCacheStorage() {
        let user = User(id: 1, name: "John Doe", email: "john@example.com")
        cacheManager.set(user, for: "user-1", ttl: 3600)
        
        let cachedUser: User? = cacheManager.get(for: "user-1")
        XCTAssertNotNil(cachedUser)
        XCTAssertEqual(cachedUser?.name, "John Doe")
    }
    
    func testCacheExpiration() {
        let user = User(id: 1, name: "John Doe", email: "john@example.com")
        cacheManager.set(user, for: "user-1", ttl: 1) // 1 second TTL
        
        // Should be available immediately
        let cachedUser: User? = cacheManager.get(for: "user-1")
        XCTAssertNotNil(cachedUser)
        
        // Wait for expiration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let expiredUser: User? = self.cacheManager.get(for: "user-1")
            XCTAssertNil(expiredUser)
        }
    }
    
    func testCacheStatistics() {
        let stats = cacheManager.getStatistics()
        XCTAssertGreaterThanOrEqual(stats.hitCount, 0)
        XCTAssertGreaterThanOrEqual(stats.missCount, 0)
        XCTAssertGreaterThanOrEqual(stats.hitRate, 0)
        XCTAssertLessThanOrEqual(stats.hitRate, 1)
    }
}
```

### 3. APIRequest Tests

Test request configuration.

```swift
class APIRequestTests: XCTestCase {
    func testRequestBuilder() {
        let request = APIRequestBuilder<User>.get("/users/1")
            .header("Authorization", value: "Bearer token")
            .cacheKey("user-1")
            .cacheTTL(1800)
            .shouldSync(true)
            .retryCount(3)
            .timeout(30.0)
            .build()
        
        XCTAssertEqual(request.endpoint, "/users/1")
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.headers["Authorization"], "Bearer token")
        XCTAssertEqual(request.cacheKey, "user-1")
        XCTAssertEqual(request.cacheTTL, 1800)
        XCTAssertTrue(request.shouldSync)
        XCTAssertEqual(request.retryCount, 3)
        XCTAssertEqual(request.timeout, 30.0)
    }
    
    func testRequestConvenienceMethods() {
        let getRequest = APIRequest<User>.get("/users/1")
        XCTAssertEqual(getRequest.method, .get)
        
        let postRequest = APIRequest<User>.post("/users", body: ["name": "John"])
        XCTAssertEqual(postRequest.method, .post)
        XCTAssertNotNil(postRequest.body)
        
        let putRequest = APIRequest<User>.put("/users/1", body: ["name": "Jane"])
        XCTAssertEqual(putRequest.method, .put)
        
        let deleteRequest = APIRequest<User>.delete("/users/1")
        XCTAssertEqual(deleteRequest.method, .delete)
    }
}
```

---

## Integration Testing

### 1. End-to-End Tests

Test complete request flows.

```swift
class IntegrationTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://jsonplaceholder.typicode.com")
    }
    
    func testCompleteUserFlow() {
        // 1. Create user
        let createBody = ["name": "John Doe", "email": "john@example.com"]
        let createRequest = APIRequest<User>.post("/users", body: createBody)
        
        let createExpectation = XCTestExpectation(description: "Create user")
        
        networkManager.execute(createRequest) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user.id)
                XCTAssertEqual(user.name, "John Doe")
                
                // 2. Get user
                let getRequest = APIRequest<User>.get("/users/\(user.id)")
                let getExpectation = XCTestExpectation(description: "Get user")
                
                self.networkManager.execute(getRequest) { getResult in
                    switch getResult {
                    case .success(let retrievedUser):
                        XCTAssertEqual(retrievedUser.id, user.id)
                        XCTAssertEqual(retrievedUser.name, user.name)
                    case .failure(let error):
                        XCTFail("Failed to get user: \(error)")
                    }
                    getExpectation.fulfill()
                }
                
            case .failure(let error):
                XCTFail("Failed to create user: \(error)")
            }
            createExpectation.fulfill()
        }
        
        wait(for: [createExpectation, getExpectation], timeout: 20.0)
    }
}
```

### 2. Interceptor Tests

Test request/response interceptors.

```swift
class InterceptorTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.test.com")
    }
    
    func testAuthenticationInterceptor() {
        let interceptor = AuthenticationInterceptor(token: "test-token")
        networkManager.addInterceptor(interceptor)
        
        let request = APIRequest<User>.get("/users/1")
        let expectation = XCTestExpectation(description: "Authenticated request")
        
        networkManager.execute(request) { result in
            // Verify authentication header was added
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testLoggingInterceptor() {
        let interceptor = LoggingInterceptor()
        networkManager.addInterceptor(interceptor)
        
        let request = APIRequest<User>.get("/users/1")
        let expectation = XCTestExpectation(description: "Logged request")
        
        networkManager.execute(request) { result in
            // Verify logging occurred
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

---

## Performance Testing

### 1. Response Time Tests

Test API response times.

```swift
class PerformanceTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.test.com")
    }
    
    func testResponseTime() {
        let request = APIRequest<User>.get("/users/1")
        let expectation = XCTestExpectation(description: "Response time test")
        
        let startTime = Date()
        
        networkManager.execute(request) { result in
            let responseTime = Date().timeIntervalSince(startTime)
            
            // Response time should be less than 500ms
            XCTAssertLessThan(responseTime, 0.5)
            
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
    
    func testConcurrentRequests() {
        let expectation = XCTestExpectation(description: "Concurrent requests")
        expectation.expectedFulfillmentCount = 10
        
        let startTime = Date()
        
        for i in 1...10 {
            let request = APIRequest<User>.get("/users/\(i)")
            
            networkManager.execute(request) { result in
                XCTAssertNotNil(result)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        let totalTime = Date().timeIntervalSince(startTime)
        let averageTime = totalTime / 10.0
        
        // Average response time should be reasonable
        XCTAssertLessThan(averageTime, 1.0)
    }
}
```

### 2. Throughput Tests

Test request throughput.

```swift
class ThroughputTests: XCTestCase {
    func testRequestsPerSecond() {
        let networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.test.com")
        
        let startTime = Date()
        var completedRequests = 0
        let totalRequests = 100
        let expectation = XCTestExpectation(description: "Throughput test")
        expectation.expectedFulfillmentCount = totalRequests
        
        for i in 1...totalRequests {
            let request = APIRequest<User>.get("/users/\(i)")
            
            networkManager.execute(request) { result in
                completedRequests += 1
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        let totalTime = Date().timeIntervalSince(startTime)
        let requestsPerSecond = Double(totalRequests) / totalTime
        
        // Should handle at least 10 requests per second
        XCTAssertGreaterThan(requestsPerSecond, 10.0)
    }
}
```

---

## Security Testing

### 1. Certificate Pinning Tests

Test certificate pinning functionality.

```swift
class SecurityTests: XCTestCase {
    func testCertificatePinning() {
        let networkManager = NetworkManager.shared
        let config = NetworkConfiguration()
        config.enableCertificatePinning = true
        
        networkManager.configure(baseURL: "https://api.test.com", configuration: config)
        
        let request = APIRequest<User>.get("/users/1")
        let expectation = XCTestExpectation(description: "Certificate pinning test")
        
        networkManager.execute(request) { result in
            // Should succeed with valid certificate
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testRequestSigning() {
        let signer = RequestSigner(privateKey: testPrivateKey)
        let request = APIRequest<User>.get("/users/1")
        
        let signedRequest = signer.signRequest(request)
        
        // Verify signature was added
        XCTAssertNotNil(signedRequest.headers["X-Signature"])
        XCTAssertNotNil(signedRequest.headers["X-Timestamp"])
    }
}
```

### 2. Input Validation Tests

Test input validation.

```swift
class InputValidationTests: XCTestCase {
    func testMaliciousInput() {
        let networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.test.com")
        
        // Test SQL injection attempt
        let maliciousRequest = APIRequest<User>.get("/users/1'; DROP TABLE users; --")
        let expectation = XCTestExpectation(description: "Malicious input test")
        
        networkManager.execute(maliciousRequest) { result in
            // Should handle malicious input gracefully
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

---

## UI Testing

### 1. Network UI Tests

Test UI components that use networking.

```swift
class NetworkUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testUserListLoading() {
        // Navigate to user list
        app.tabBars.buttons["Users"].tap()
        
        // Wait for loading indicator
        let loadingIndicator = app.activityIndicators["LoadingIndicator"]
        XCTAssertTrue(loadingIndicator.exists)
        
        // Wait for user list to load
        let userList = app.tables["UserList"]
        XCTAssertTrue(userList.waitForExistence(timeout: 10))
        
        // Verify user list has content
        XCTAssertGreaterThan(userList.cells.count, 0)
    }
    
    func testUserDetailLoading() {
        // Navigate to user list
        app.tabBars.buttons["Users"].tap()
        
        // Tap first user
        let userList = app.tables["UserList"]
        userList.cells.element(boundBy: 0).tap()
        
        // Wait for user detail to load
        let userDetail = app.otherElements["UserDetail"]
        XCTAssertTrue(userDetail.waitForExistence(timeout: 10))
        
        // Verify user detail has content
        XCTAssertTrue(app.staticTexts["UserName"].exists)
        XCTAssertTrue(app.staticTexts["UserEmail"].exists)
    }
}
```

---

## Test Automation

### 1. CI/CD Integration

Automate testing in continuous integration.

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Select Xcode
      run: sudo xcode-select -switch /Applications/Xcode_15.0.app
    
    - name: Build and Test
      run: |
        xcodebuild test \
          -scheme NetworkingArchitecture \
          -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
          -enableCodeCoverage YES
```

### 2. Test Coverage

Monitor test coverage.

```swift
class TestCoverageTests: XCTestCase {
    func testCodeCoverage() {
        // Verify all public APIs are tested
        let publicAPIs = [
            "NetworkManager.configure",
            "NetworkManager.execute",
            "NetworkManager.addInterceptor",
            "CacheManager.set",
            "CacheManager.get",
            "APIRequest.init",
            "APIRequestBuilder.build"
        ]
        
        for api in publicAPIs {
            // Verify API is covered by tests
            XCTAssertTrue(isAPICovered(api), "API \(api) is not covered by tests")
        }
    }
}
```

### 3. Performance Regression Tests

Test for performance regressions.

```swift
class PerformanceRegressionTests: XCTestCase {
    func testResponseTimeRegression() {
        let baselineResponseTime: TimeInterval = 0.2 // 200ms baseline
        
        let request = APIRequest<User>.get("/users/1")
        let expectation = XCTestExpectation(description: "Performance regression test")
        
        let startTime = Date()
        
        networkManager.execute(request) { result in
            let responseTime = Date().timeIntervalSince(startTime)
            
            // Response time should not exceed baseline by more than 50%
            XCTAssertLessThan(responseTime, baselineResponseTime * 1.5)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

---

## Test Utilities

### 1. Mock Network

Create mock network responses for testing.

```swift
class MockNetworkManager: NetworkManager {
    var mockResponses: [String: Any] = [:]
    var mockErrors: [String: NetworkError] = [:]
    
    override func execute<T: Codable>(_ request: APIRequest<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let key = "\(request.method.rawValue)\(request.endpoint)"
        
        if let error = mockErrors[key] {
            completion(.failure(error))
            return
        }
        
        if let response = mockResponses[key] as? T {
            completion(.success(response))
            return
        }
        
        // Default mock response
        let defaultUser = User(id: 1, name: "Mock User", email: "mock@example.com")
        completion(.success(defaultUser as! T))
    }
    
    func setMockResponse<T>(_ response: T, for request: APIRequest<T>) {
        let key = "\(request.method.rawValue)\(request.endpoint)"
        mockResponses[key] = response
    }
    
    func setMockError(_ error: NetworkError, for request: APIRequest<Any>) {
        let key = "\(request.method.rawValue)\(request.endpoint)"
        mockErrors[key] = error
    }
}
```

### 2. Test Helpers

Create helper functions for testing.

```swift
class TestHelpers {
    static func createTestUser() -> User {
        return User(id: 1, name: "Test User", email: "test@example.com")
    }
    
    static func createTestRequest() -> APIRequest<User> {
        return APIRequest<User>.get("/users/1")
    }
    
    static func waitForAsyncOperation(timeout: TimeInterval = 10.0) {
        let expectation = XCTestExpectation(description: "Async operation")
        expectation.fulfill()
        XCTWaiter().wait(for: [expectation], timeout: timeout)
    }
}
```

---

## Testing Best Practices

### 1. Test Organization

```swift
// Organize tests by functionality
class NetworkManagerTests: XCTestCase {
    // MARK: - Configuration Tests
    func testConfiguration() { }
    func testInvalidConfiguration() { }
    
    // MARK: - Request Tests
    func testGETRequest() { }
    func testPOSTRequest() { }
    func testPUTRequest() { }
    func testDELETERequest() { }
    
    // MARK: - Error Tests
    func testNetworkError() { }
    func testTimeoutError() { }
    func testDecodingError() { }
}
```

### 2. Test Data Management

```swift
class TestDataManager {
    static let shared = TestDataManager()
    
    private var testUsers: [User] = []
    private var testProducts: [Product] = []
    
    func setupTestData() {
        testUsers = [
            User(id: 1, name: "User 1", email: "user1@test.com"),
            User(id: 2, name: "User 2", email: "user2@test.com"),
            User(id: 3, name: "User 3", email: "user3@test.com")
        ]
    }
    
    func cleanupTestData() {
        testUsers.removeAll()
        testProducts.removeAll()
    }
}
```

### 3. Test Reporting

```swift
class TestReporter {
    static func generateTestReport() -> TestReport {
        return TestReport(
            totalTests: getTotalTestCount(),
            passedTests: getPassedTestCount(),
            failedTests: getFailedTestCount(),
            coverage: getCodeCoverage(),
            performance: getPerformanceMetrics()
        )
    }
}
```

---

## Testing Checklist

### ✅ Test Implementation Checklist

- [ ] Unit tests for all public APIs
- [ ] Integration tests for complete flows
- [ ] Performance tests for response times
- [ ] Security tests for vulnerabilities
- [ ] UI tests for network interactions
- [ ] Mock network for isolated testing
- [ ] Test coverage monitoring
- [ ] Performance regression tests
- [ ] CI/CD integration
- [ ] Test automation

### ✅ Test Quality Checklist

- [ ] Tests are fast and reliable
- [ ] Tests are isolated and independent
- [ ] Tests cover edge cases
- [ ] Tests validate error conditions
- [ ] Tests use descriptive names
- [ ] Tests have proper assertions
- [ ] Tests clean up after themselves
- [ ] Tests are maintainable

---

## Examples

### Basic Test Setup

```swift
class BasicNetworkTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.configure(baseURL: "https://api.test.com")
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    func testBasicRequest() {
        let request = APIRequest<User>.get("/users/1")
        let expectation = XCTestExpectation(description: "Basic request test")
        
        networkManager.execute(request) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

### Advanced Test Implementation

```swift
class AdvancedNetworkTests: XCTestCase {
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
    }
    
    func testMockResponse() {
        let testUser = User(id: 1, name: "Test User", email: "test@example.com")
        let request = APIRequest<User>.get("/users/1")
        
        mockNetworkManager.setMockResponse(testUser, for: request)
        
        let expectation = XCTestExpectation(description: "Mock response test")
        
        mockNetworkManager.execute(request) { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user.name, "Test User")
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
```

---

This testing guide provides comprehensive information about implementing and maintaining tests for your iOS applications using the iOS Networking Architecture Pro framework. 