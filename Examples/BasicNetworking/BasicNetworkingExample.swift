import Foundation
import NetworkingArchitecture

/// Basic networking example demonstrating simple API requests
class BasicNetworkingExample {
    
    private let networkManager = NetworkManager.shared
    
    init() {
        // Configure the network manager
        networkManager.configure(baseURL: "https://jsonplaceholder.typicode.com")
    }
    
    // MARK: - GET Request Example
    
    func fetchUser(id: Int) {
        let request = APIRequest<User>.get("/users/\(id)")
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ User fetched successfully:")
                print("   ID: \(user.id)")
                print("   Name: \(user.name)")
                print("   Email: \(user.email)")
                
            case .failure(let error):
                print("❌ Failed to fetch user: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - POST Request Example
    
    func createUser(name: String, email: String) {
        let body = [
            "name": name,
            "email": email,
            "username": name.lowercased().replacingOccurrences(of: " ", with: "")
        ]
        
        let request = APIRequest<User>.post("/users", body: body)
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ User created successfully:")
                print("   ID: \(user.id)")
                print("   Name: \(user.name)")
                print("   Email: \(user.email)")
                
            case .failure(let error):
                print("❌ Failed to create user: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - PUT Request Example
    
    func updateUser(id: Int, name: String, email: String) {
        let body = [
            "name": name,
            "email": email
        ]
        
        let request = APIRequest<User>.put("/users/\(id)", body: body)
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ User updated successfully:")
                print("   ID: \(user.id)")
                print("   Name: \(user.name)")
                print("   Email: \(user.email)")
                
            case .failure(let error):
                print("❌ Failed to update user: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - DELETE Request Example
    
    func deleteUser(id: Int) {
        let request = APIRequest<Void>.delete("/users/\(id)")
        
        networkManager.execute(request) { result in
            switch result {
            case .success:
                print("✅ User deleted successfully")
                
            case .failure(let error):
                print("❌ Failed to delete user: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Builder Pattern Example
    
    func fetchUserWithBuilder(id: Int) {
        let request = APIRequestBuilder<User>.get("/users/\(id)")
            .header("Authorization", value: "Bearer your-token-here")
            .header("Accept", value: "application/json")
            .cacheKey("user-\(id)")
            .cacheTTL(1800) // 30 minutes
            .shouldSync(false)
            .retryCount(3)
            .timeout(30.0)
            .build()
        
        networkManager.execute(request) { result in
            switch result {
            case .success(let user):
                print("✅ User fetched with builder:")
                print("   ID: \(user.id)")
                print("   Name: \(user.name)")
                print("   Email: \(user.email)")
                
            case .failure(let error):
                print("❌ Failed to fetch user: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Batch Requests Example
    
    func fetchMultipleUsers(ids: [Int]) {
        let group = DispatchGroup()
        var users: [User] = []
        var errors: [Error] = []
        
        for id in ids {
            group.enter()
            
            let request = APIRequest<User>.get("/users/\(id)")
            
            networkManager.execute(request) { result in
                switch result {
                case .success(let user):
                    users.append(user)
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("📊 Batch request completed:")
            print("   Successfully fetched: \(users.count) users")
            print("   Errors: \(errors.count)")
            
            for user in users {
                print("   - \(user.name) (\(user.email))")
            }
        }
    }
    
    // MARK: - Error Handling Example
    
    func demonstrateErrorHandling() {
        // Test with invalid endpoint
        let invalidRequest = APIRequest<User>.get("/invalid-endpoint")
        
        networkManager.execute(invalidRequest) { result in
            switch result {
            case .success:
                print("❌ Unexpected success for invalid endpoint")
                
            case .failure(let error):
                print("✅ Properly handled error:")
                print("   Error: \(error.localizedDescription)")
                
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpError(let statusCode):
                        print("   Status Code: \(statusCode)")
                    case .networkError(let underlyingError):
                        print("   Network Error: \(underlyingError.localizedDescription)")
                    case .timeout:
                        print("   Timeout Error")
                    default:
                        print("   Other Error")
                    }
                }
            }
        }
    }
}

// MARK: - Usage Example

func runBasicNetworkingExample() {
    let example = BasicNetworkingExample()
    
    print("🚀 Basic Networking Example")
    print("==========================")
    
    // Fetch a user
    example.fetchUser(id: 1)
    
    // Create a new user
    example.createUser(name: "John Doe", email: "john@example.com")
    
    // Update a user
    example.updateUser(id: 1, name: "Jane Doe", email: "jane@example.com")
    
    // Delete a user
    example.deleteUser(id: 1)
    
    // Fetch with builder pattern
    example.fetchUserWithBuilder(id: 2)
    
    // Batch requests
    example.fetchMultipleUsers(ids: [1, 2, 3, 4, 5])
    
    // Error handling
    example.demonstrateErrorHandling()
}

// MARK: - Supporting Types

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let username: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, username
    }
} 