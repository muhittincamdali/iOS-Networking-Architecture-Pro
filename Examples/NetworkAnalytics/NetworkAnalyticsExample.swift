import Foundation
import NetworkingArchitecture

/// Network analytics example demonstrating comprehensive monitoring and performance tracking
class NetworkAnalyticsExample {
    
    private let networkManager = NetworkManager.shared
    
    init() {
        setupAnalytics()
    }
    
    // MARK: - Setup
    
    private func setupAnalytics() {
        print("✅ Network analytics initialized")
    }
    
    // MARK: - Performance Metrics Example
    
    func demonstratePerformanceMetrics() {
        print("\n📊 Performance Metrics Example")
        print("==============================")
        
        // Simulate multiple requests with different response times
        let requests = [
            ("/users/1", 150), // 150ms
            ("/users/2", 200), // 200ms
            ("/users/3", 100), // 100ms
            ("/users/4", 300), // 300ms
            ("/users/5", 180)  // 180ms
        ]
        
        print("📤 Simulating requests with different response times:")
        
        for (endpoint, responseTime) in requests {
            print("   - \(endpoint): \(responseTime)ms")
            
            // Simulate request
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(responseTime) / 1000) {
                self.recordRequest(endpoint: endpoint, responseTime: Double(responseTime) / 1000)
            }
        }
        
        // Wait for all requests to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.displayPerformanceMetrics()
        }
    }
    
    private func recordRequest(endpoint: String, responseTime: TimeInterval) {
        print("✅ Request completed: \(endpoint) (\(String(format: "%.2f", responseTime))s)")
    }
    
    private func displayPerformanceMetrics() {
        print("\n📈 Performance Metrics Summary:")
        print("   Total requests: 5")
        print("   Average response time: 186ms")
        print("   Fastest request: 100ms")
        print("   Slowest request: 300ms")
        print("   Response time distribution:")
        print("     - < 150ms: 2 requests")
        print("     - 150-200ms: 2 requests")
        print("     - > 200ms: 1 request")
    }
    
    // MARK: - Error Tracking Example
    
    func demonstrateErrorTracking() {
        print("\n❌ Error Tracking Example")
        print("=========================")
        
        let errorScenarios = [
            ("/invalid-endpoint", NetworkError.notFound),
            ("/timeout-endpoint", NetworkError.timeout),
            ("/server-error", NetworkError.serverError),
            ("/unauthorized", NetworkError.unauthorized)
        ]
        
        print("📤 Simulating error scenarios:")
        
        for (endpoint, error) in errorScenarios {
            print("   - \(endpoint): \(error.localizedDescription)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.recordError(endpoint: endpoint, error: error)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.displayErrorMetrics()
        }
    }
    
    private func recordError(endpoint: String, error: NetworkError) {
        print("❌ Error recorded: \(endpoint) - \(error.localizedDescription)")
    }
    
    private func displayErrorMetrics() {
        print("\n📊 Error Metrics Summary:")
        print("   Total errors: 4")
        print("   Error rate: 44.4%")
        print("   Error breakdown:")
        print("     - 404 Not Found: 1")
        print("     - Timeout: 1")
        print("     - Server Error: 1")
        print("     - Unauthorized: 1")
    }
    
    // MARK: - Cache Analytics Example
    
    func demonstrateCacheAnalytics() {
        print("\n💾 Cache Analytics Example")
        print("==========================")
        
        // Simulate cache operations
        let cacheOperations = [
            ("user-1", true),   // Cache hit
            ("user-2", false),  // Cache miss
            ("user-3", true),   // Cache hit
            ("user-4", false),  // Cache miss
            ("user-5", true),   // Cache hit
            ("user-6", true),   // Cache hit
            ("user-7", false),  // Cache miss
            ("user-8", true)    // Cache hit
        ]
        
        print("💾 Simulating cache operations:")
        
        for (key, isHit) in cacheOperations {
            if isHit {
                print("   ✅ Cache HIT: \(key)")
            } else {
                print("   ❌ Cache MISS: \(key)")
            }
        }
        
        displayCacheMetrics()
    }
    
    private func displayCacheMetrics() {
        print("\n📊 Cache Performance Metrics:")
        print("   Total requests: 8")
        print("   Cache hits: 5")
        print("   Cache misses: 3")
        print("   Cache hit rate: 62.5%")
        print("   Memory cache size: 45MB")
        print("   Disk cache size: 120MB")
        print("   Cache efficiency: Good")
    }
    
    // MARK: - User Analytics Example
    
    func demonstrateUserAnalytics() {
        print("\n👤 User Analytics Example")
        print("=========================")
        
        let userBehavior = [
            UserBehavior(userId: 1, requests: 25, avgResponseTime: 180, errors: 2),
            UserBehavior(userId: 2, requests: 15, avgResponseTime: 220, errors: 1),
            UserBehavior(userId: 3, requests: 40, avgResponseTime: 150, errors: 0),
            UserBehavior(userId: 4, requests: 8, avgResponseTime: 300, errors: 3),
            UserBehavior(userId: 5, requests: 32, avgResponseTime: 190, errors: 1)
        ]
        
        print("👤 User behavior analysis:")
        
        for behavior in userBehavior {
            print("   User \(behavior.userId):")
            print("     - Requests: \(behavior.requests)")
            print("     - Avg response time: \(behavior.avgResponseTime)ms")
            print("     - Errors: \(behavior.errors)")
        }
        
        displayUserMetrics(userBehavior)
    }
    
    private func displayUserMetrics(_ behaviors: [UserBehavior]) {
        let totalRequests = behaviors.reduce(0) { $0 + $1.requests }
        let totalErrors = behaviors.reduce(0) { $0 + $1.errors }
        let avgResponseTime = behaviors.reduce(0) { $0 + $1.avgResponseTime } / behaviors.count
        
        print("\n📊 User Analytics Summary:")
        print("   Total users: \(behaviors.count)")
        print("   Total requests: \(totalRequests)")
        print("   Average response time: \(avgResponseTime)ms")
        print("   Total errors: \(totalErrors)")
        print("   Error rate: \(String(format: "%.1f", Double(totalErrors) / Double(totalRequests) * 100))%")
        
        // User segmentation
        let heavyUsers = behaviors.filter { $0.requests > 20 }.count
        let lightUsers = behaviors.filter { $0.requests <= 20 }.count
        
        print("   User segmentation:")
        print("     - Heavy users (>20 requests): \(heavyUsers)")
        print("     - Light users (≤20 requests): \(lightUsers)")
    }
    
    // MARK: - Health Monitoring Example
    
    func demonstrateHealthMonitoring() {
        print("\n🏥 Health Monitoring Example")
        print("============================")
        
        let healthMetrics = HealthMetrics(
            uptime: 99.8,
            responseTime: 186,
            errorRate: 2.1,
            throughput: 1250,
            activeConnections: 45,
            memoryUsage: 78.5,
            cpuUsage: 23.2
        )
        
        print("🏥 System health metrics:")
        print("   Uptime: \(healthMetrics.uptime)%")
        print("   Average response time: \(healthMetrics.responseTime)ms")
        print("   Error rate: \(healthMetrics.errorRate)%")
        print("   Throughput: \(healthMetrics.throughput) requests/min")
        print("   Active connections: \(healthMetrics.activeConnections)")
        print("   Memory usage: \(healthMetrics.memoryUsage)%")
        print("   CPU usage: \(healthMetrics.cpuUsage)%")
        
        analyzeHealthStatus(healthMetrics)
    }
    
    private func analyzeHealthStatus(_ metrics: HealthMetrics) {
        print("\n📊 Health Status Analysis:")
        
        var issues = 0
        
        if metrics.uptime < 99.5 {
            print("   ⚠️ Uptime below threshold (99.5%)")
            issues += 1
        }
        
        if metrics.responseTime > 500 {
            print("   ⚠️ Response time too high (>500ms)")
            issues += 1
        }
        
        if metrics.errorRate > 5.0 {
            print("   ⚠️ Error rate too high (>5%)")
            issues += 1
        }
        
        if metrics.memoryUsage > 90 {
            print("   ⚠️ Memory usage critical (>90%)")
            issues += 1
        }
        
        if issues == 0 {
            print("   ✅ System health: Excellent")
        } else if issues <= 2 {
            print("   ⚠️ System health: Warning")
        } else {
            print("   ❌ System health: Critical")
        }
    }
    
    // MARK: - Custom Events Example
    
    func demonstrateCustomEvents() {
        print("\n🎯 Custom Events Example")
        print("========================")
        
        let customEvents = [
            CustomEvent(name: "user_login", properties: ["method": "email", "platform": "iOS"]),
            CustomEvent(name: "payment_success", properties: ["amount": "99.99", "currency": "USD"]),
            CustomEvent(name: "feature_usage", properties: ["feature": "sync", "duration": "30s"]),
            CustomEvent(name: "error_occurred", properties: ["type": "network", "severity": "medium"])
        ]
        
        print("🎯 Tracking custom events:")
        
        for event in customEvents {
            print("   📊 Event: \(event.name)")
            print("     Properties: \(event.properties)")
            trackCustomEvent(event)
        }
    }
    
    private func trackCustomEvent(_ event: CustomEvent) {
        print("   ✅ Event tracked: \(event.name)")
    }
    
    // MARK: - Real-Time Dashboard Example
    
    func demonstrateRealTimeDashboard() {
        print("\n📊 Real-Time Dashboard Example")
        print("==============================")
        
        let dashboard = RealTimeDashboard(
            activeUsers: 1250,
            requestsPerMinute: 850,
            averageResponseTime: 186,
            errorRate: 2.1,
            cacheHitRate: 62.5,
            topEndpoints: [
                ("/users", 45),
                ("/products", 32),
                ("/orders", 28),
                ("/search", 15)
            ]
        )
        
        print("📊 Real-time dashboard data:")
        print("   👥 Active users: \(dashboard.activeUsers)")
        print("   📤 Requests/min: \(dashboard.requestsPerMinute)")
        print("   ⏱️ Avg response time: \(dashboard.averageResponseTime)ms")
        print("   ❌ Error rate: \(dashboard.errorRate)%")
        print("   💾 Cache hit rate: \(dashboard.cacheHitRate)%")
        
        print("\n📈 Top endpoints:")
        for (endpoint, count) in dashboard.topEndpoints {
            print("   - \(endpoint): \(count) requests")
        }
        
        // Update dashboard every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.updateDashboard()
        }
    }
    
    private func updateDashboard() {
        print("🔄 Dashboard updated: \(Date())")
    }
}

// MARK: - Usage Example

func runNetworkAnalyticsExample() {
    let example = NetworkAnalyticsExample()
    
    // Run all demonstrations
    example.demonstratePerformanceMetrics()
    example.demonstrateErrorTracking()
    example.demonstrateCacheAnalytics()
    example.demonstrateUserAnalytics()
    example.demonstrateHealthMonitoring()
    example.demonstrateCustomEvents()
    example.demonstrateRealTimeDashboard()
}

// MARK: - Supporting Types

struct UserBehavior {
    let userId: Int
    let requests: Int
    let avgResponseTime: Int
    let errors: Int
}

struct HealthMetrics {
    let uptime: Double
    let responseTime: Int
    let errorRate: Double
    let throughput: Int
    let activeConnections: Int
    let memoryUsage: Double
    let cpuUsage: Double
}

struct CustomEvent {
    let name: String
    let properties: [String: Any]
}

struct RealTimeDashboard {
    let activeUsers: Int
    let requestsPerMinute: Int
    let averageResponseTime: Int
    let errorRate: Double
    let cacheHitRate: Double
    let topEndpoints: [(String, Int)]
} 