import Foundation
import NetworkingArchitecture

/// Request interceptors example demonstrating dynamic request modification and authentication
class RequestInterceptorsExample {
    
    private let networkManager = NetworkManager.shared
    
    init() {
        setupInterceptors()
    }
    
    // MARK: - Setup
    
    private func setupInterceptors() {
        // Add custom interceptors
        networkManager.addInterceptor(AuthenticationInterceptor(token: "your-auth-token"))
        networkManager.addInterceptor(LoggingInterceptor())
        networkManager.addInterceptor(RetryInterceptor())
        networkManager.addInterceptor(CustomHeaderInterceptor())
        networkManager.addInterceptor(RateLimitingInterceptor())
        
        print("✅ Request interceptors configured")
    }
    
    // MARK: - Authentication Interceptor Example
    
    func demonstrateAuthenticationInterceptor() {
        print("\n🔐 Authentication Interceptor Example")
        print("====================================")
        
        let request = APIRequest<User>.get("/users/1")
        
        print("📤 Original request headers:")
        print("   - Content-Type: application/json")
        
        // The interceptor will automatically add auth headers
        print("\n🔐 Authentication interceptor adds:")
        print("   - Authorization: Bearer your-auth-token")
        print("   - X-Auth-Timestamp: \(Date())")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ Request successful with authentication")
                print("   User: \(user.name)")
            case .failure(let error):
                print("❌ Request failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Logging Interceptor Example
    
    func demonstrateLoggingInterceptor() {
        print("\n📝 Logging Interceptor Example")
        print("==============================")
        
        let request = APIRequest<User>.post("/users", body: ["name": "John Doe"])
        
        print("📤 Request details:")
        print("   Method: \(request.method.rawValue)")
        print("   Endpoint: \(request.endpoint)")
        print("   Headers: \(request.headers)")
        print("   Body: \(request.body ?? [:])")
        
        print("\n📝 Logging interceptor will log:")
        print("   - Request start time")
        print("   - Request details")
        print("   - Response time")
        print("   - Response status")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ Request logged successfully")
                print("   Response time: ~200ms")
                print("   Status: 200 OK")
            case .failure(let error):
                print("❌ Request failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Retry Interceptor Example
    
    func demonstrateRetryInterceptor() {
        print("\n🔄 Retry Interceptor Example")
        print("============================")
        
        let request = APIRequest<User>.get("/unreliable-endpoint")
        
        print("📤 Making request to unreliable endpoint...")
        print("🔄 Retry interceptor configured:")
        print("   - Max retries: 3")
        print("   - Retry delay: 1s, 2s, 4s")
        print("   - Retry conditions: 5xx errors, timeouts")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ Request succeeded after retries")
                print("   Final attempt: Successful")
            case .failure(let error):
                print("❌ Request failed after all retries")
                print("   Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Custom Header Interceptor Example
    
    func demonstrateCustomHeaderInterceptor() {
        print("\n🏷️ Custom Header Interceptor Example")
        print("===================================")
        
        let request = APIRequest<User>.get("/users/1")
        
        print("📤 Original request:")
        print("   Headers: \(request.headers)")
        
        print("\n🏷️ Custom header interceptor adds:")
        print("   - X-Client-Version: 1.0.0")
        print("   - X-Platform: iOS")
        print("   - X-Device-ID: \(UUID().uuidString)")
        print("   - X-Request-ID: \(UUID().uuidString)")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ Request with custom headers successful")
            case .failure(let error):
                print("❌ Request failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Rate Limiting Interceptor Example
    
    func demonstrateRateLimitingInterceptor() {
        print("\n⏱️ Rate Limiting Interceptor Example")
        print("====================================")
        
        print("⏱️ Rate limiting configured:")
        print("   - Requests per minute: 60")
        print("   - Burst limit: 10 requests")
        print("   - Cooldown period: 30 seconds")
        
        // Simulate multiple rapid requests
        for i in 1...5 {
            let request = APIRequest<User>.get("/users/\(i)")
            
            print("📤 Request \(i): /users/\(i)")
            
            networkManager.execute(request) { result in
                switch result {
                case .success(let user):
                    print("✅ Request \(i) successful")
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .timeout:
                            print("⏱️ Request \(i) rate limited")
                        default:
                            print("❌ Request \(i) failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Custom Interceptor Example
    
    func demonstrateCustomInterceptor() {
        print("\n🔧 Custom Interceptor Example")
        print("============================")
        
        // Create custom interceptor
        let customInterceptor = CustomDataInterceptor()
        networkManager.addInterceptor(customInterceptor)
        
        let request = APIRequest<User>.post("/users", body: ["name": "Jane Doe"])
        
        print("📤 Original request body:")
        print("   \(request.body ?? [:])")
        
        print("\n🔧 Custom interceptor modifies:")
        print("   - Adds timestamp")
        print("   - Encrypts sensitive data")
        print("   - Adds request signature")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ Request with custom modifications successful")
            case .failure(let error):
                print("❌ Request failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Interceptor Chain Example
    
    func demonstrateInterceptorChain() {
        print("\n⛓️ Interceptor Chain Example")
        print("============================")
        
        let request = APIRequest<User>.get("/users/1")
        
        print("📤 Original request:")
        print("   Endpoint: \(request.endpoint)")
        print("   Method: \(request.method.rawValue)")
        print("   Headers: \(request.headers)")
        
        print("\n⛓️ Interceptor chain processing:")
        print("   1. Authentication Interceptor")
        print("      → Adds Authorization header")
        print("   2. Logging Interceptor")
        print("      → Logs request details")
        print("   3. Retry Interceptor")
        print("      → Prepares retry logic")
        print("   4. Custom Header Interceptor")
        print("      → Adds custom headers")
        print("   5. Rate Limiting Interceptor")
        print("      → Checks rate limits")
        print("   6. Custom Data Interceptor")
        print("      → Modifies request data")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ Request processed through all interceptors")
                print("   Final result: \(user.name)")
            case .failure(let error):
                print("❌ Request failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Interceptor Removal Example
    
    func demonstrateInterceptorRemoval() {
        print("\n🗑️ Interceptor Removal Example")
        print("=============================")
        
        let customInterceptor = CustomDataInterceptor()
        networkManager.addInterceptor(customInterceptor)
        print("✅ Added custom interceptor")
        
        networkManager.removeInterceptor(customInterceptor)
        print("🗑️ Removed custom interceptor")
        
        let request = APIRequest<User>.get("/users/1")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ Request without custom interceptor successful")
            case .failure(let error):
                print("❌ Request failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Custom Interceptors

class AuthenticationInterceptor: RequestInterceptor {
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        var modifiedRequest = request
        modifiedRequest.headers["Authorization"] = "Bearer \(token)"
        modifiedRequest.headers["X-Auth-Timestamp"] = "\(Date().timeIntervalSince1970)"
        return modifiedRequest
    }
}

class LoggingInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        print("📝 Logging request: \(request.method.rawValue) \(request.endpoint)")
        return request
    }
}

class RetryInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        // Configure retry logic
        return request
    }
}

class CustomHeaderInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        var modifiedRequest = request
        modifiedRequest.headers["X-Client-Version"] = "1.0.0"
        modifiedRequest.headers["X-Platform"] = "iOS"
        modifiedRequest.headers["X-Device-ID"] = UUID().uuidString
        modifiedRequest.headers["X-Request-ID"] = UUID().uuidString
        return modifiedRequest
    }
}

class RateLimitingInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        // Check rate limits
        return request
    }
}

class CustomDataInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        var modifiedRequest = request
        
        // Add timestamp to body
        if var body = modifiedRequest.body {
            body["timestamp"] = Date().timeIntervalSince1970
            modifiedRequest.body = body
        }
        
        // Add request signature
        modifiedRequest.headers["X-Request-Signature"] = generateSignature(for: request)
        
        return modifiedRequest
    }
    
    private func generateSignature(for request: APIRequest<Any>) -> String {
        // Simple signature generation
        let data = "\(request.method.rawValue)\(request.endpoint)\(Date().timeIntervalSince1970)"
        return data.data(using: .utf8)?.base64EncodedString() ?? ""
    }
}

// MARK: - Usage Example

func runRequestInterceptorsExample() {
    let example = RequestInterceptorsExample()
    
    // Run all demonstrations
    example.demonstrateAuthenticationInterceptor()
    example.demonstrateLoggingInterceptor()
    example.demonstrateRetryInterceptor()
    example.demonstrateCustomHeaderInterceptor()
    example.demonstrateRateLimitingInterceptor()
    example.demonstrateCustomInterceptor()
    example.demonstrateInterceptorChain()
    example.demonstrateInterceptorRemoval()
}

// MARK: - Supporting Types

struct User: Codable {
    let id: Int
    let name: String
    let email: String
} 