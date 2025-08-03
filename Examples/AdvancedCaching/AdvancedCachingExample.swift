import Foundation
import NetworkingArchitecture

/// Advanced caching example demonstrating multi-level caching and intelligent policies
class AdvancedCachingExample {
    
    private let networkManager = NetworkManager.shared
    private let cacheManager = CacheManager()
    
    init() {
        setupAdvancedCaching()
    }
    
    // MARK: - Setup
    
    private func setupAdvancedCaching() {
        // Configure advanced caching
        let cacheConfig = CacheConfiguration(
            memoryCapacity: 100 * 1024 * 1024, // 100MB
            diskCapacity: 500 * 1024 * 1024,   // 500MB
            ttl: 7200, // 2 hours
            policy: .lru,
            enableCompression: true,
            enableEncryption: false
        )
        
        networkManager.configureCaching(cacheConfig)
        print("✅ Advanced caching configured")
    }
    
    // MARK: - Multi-Level Caching Example
    
    func demonstrateMultiLevelCaching() {
        print("\n🔄 Multi-Level Caching Example")
        print("================================")
        
        // Store data in cache
        let user = User(id: 1, name: "John Doe", email: "john@example.com")
        cacheManager.set(user, for: "user-1", ttl: 3600)
        print("📦 Data stored in cache")
        
        // Retrieve from cache
        if let cachedUser: User = cacheManager.get(for: "user-1") {
            print("✅ Retrieved from cache: \(cachedUser.name)")
        } else {
            print("❌ Cache miss")
        }
        
        // Demonstrate cache statistics
        let stats = cacheManager.getStatistics()
        print("📊 Cache Statistics:")
        print("   Memory count: \(stats.memoryCount)")
        print("   Disk size: \(stats.diskSize) bytes")
        print("   Hit count: \(stats.hitCount)")
        print("   Miss count: \(stats.missCount)")
        print("   Hit rate: \(String(format: "%.2f", stats.hitRate * 100))%")
    }
    
    // MARK: - Cache Policies Example
    
    func demonstrateCachePolicies() {
        print("\n🎯 Cache Policies Example")
        print("=========================")
        
        // LRU Policy (Least Recently Used)
        demonstrateLRUPolicy()
        
        // LFU Policy (Least Frequently Used)
        demonstrateLFUPolicy()
        
        // TTL Policy (Time To Live)
        demonstrateTTLPolicy()
    }
    
    private func demonstrateLRUPolicy() {
        print("\n📋 LRU Policy Demo:")
        
        // Store multiple items
        let users = [
            User(id: 1, name: "Alice", email: "alice@example.com"),
            User(id: 2, name: "Bob", email: "bob@example.com"),
            User(id: 3, name: "Charlie", email: "charlie@example.com")
        ]
        
        for (index, user) in users.enumerated() {
            cacheManager.set(user, for: "user-\(index + 1)", ttl: 1800)
            print("   Stored: \(user.name)")
        }
        
        // Access items to change LRU order
        if let _: User = cacheManager.get(for: "user-1") {
            print("   Accessed: Alice (now most recently used)")
        }
        
        if let _: User = cacheManager.get(for: "user-2") {
            print("   Accessed: Bob (now most recently used)")
        }
        
        print("   LRU order: Bob > Alice > Charlie")
    }
    
    private func demonstrateLFUPolicy() {
        print("\n📊 LFU Policy Demo:")
        
        // Store items
        let products = [
            Product(id: 1, name: "iPhone", price: 999.99),
            Product(id: 2, name: "MacBook", price: 1999.99),
            Product(id: 3, name: "iPad", price: 799.99)
        ]
        
        for (index, product) in products.enumerated() {
            cacheManager.set(product, for: "product-\(index + 1)", ttl: 3600)
            print("   Stored: \(product.name)")
        }
        
        // Access items multiple times to simulate frequency
        for _ in 1...3 {
            if let _: Product = cacheManager.get(for: "product-1") {
                print("   Accessed: iPhone (frequency: 3)")
            }
        }
        
        for _ in 1...2 {
            if let _: Product = cacheManager.get(for: "product-2") {
                print("   Accessed: MacBook (frequency: 2)")
            }
        }
        
        if let _: Product = cacheManager.get(for: "product-3") {
            print("   Accessed: iPad (frequency: 1)")
        }
        
        print("   LFU order: iPhone > MacBook > iPad")
    }
    
    private func demonstrateTTLPolicy() {
        print("\n⏰ TTL Policy Demo:")
        
        // Store with short TTL
        let tempData = TemporaryData(id: 1, content: "Temporary content", expiresAt: Date().addingTimeInterval(60))
        cacheManager.set(tempData, for: "temp-data", ttl: 60) // 1 minute
        print("   Stored temporary data (TTL: 60s)")
        
        // Check if still available
        if let _: TemporaryData = cacheManager.get(for: "temp-data") {
            print("   ✅ Temporary data still available")
        } else {
            print("   ❌ Temporary data expired")
        }
        
        // Wait and check again (simulated)
        print("   ⏳ Waiting for expiration...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let _: TemporaryData = self.cacheManager.get(for: "temp-data") {
                print("   ✅ Temporary data still available")
            } else {
                print("   ❌ Temporary data expired")
            }
        }
    }
    
    // MARK: - Cache Invalidation Example
    
    func demonstrateCacheInvalidation() {
        print("\n🗑️ Cache Invalidation Example")
        print("=============================")
        
        // Store data
        let user = User(id: 1, name: "John Doe", email: "john@example.com")
        cacheManager.set(user, for: "user-1", ttl: 3600)
        print("📦 Stored user data")
        
        // Verify it's cached
        if let cachedUser: User = cacheManager.get(for: "user-1") {
            print("✅ User found in cache: \(cachedUser.name)")
        }
        
        // Invalidate specific item
        cacheManager.remove(for: "user-1")
        print("🗑️ Removed user from cache")
        
        // Verify it's gone
        if let _: User = cacheManager.get(for: "user-1") {
            print("❌ User still in cache (unexpected)")
        } else {
            print("✅ User successfully removed from cache")
        }
        
        // Clear all cache
        cacheManager.clear()
        print("🗑️ Cleared all cache")
    }
    
    // MARK: - Cache Compression Example
    
    func demonstrateCacheCompression() {
        print("\n🗜️ Cache Compression Example")
        print("============================")
        
        // Large data structure
        let largeData = LargeData(
            id: 1,
            title: "Large Dataset",
            content: String(repeating: "This is a large content block. ", count: 1000),
            metadata: ["key1": "value1", "key2": "value2", "key3": "value3"]
        )
        
        let originalSize = MemoryLayout.size(ofValue: largeData)
        print("📏 Original size: \(originalSize) bytes")
        
        // Store with compression
        cacheManager.set(largeData, for: "large-data", ttl: 7200)
        print("🗜️ Stored with compression")
        
        // Retrieve and verify
        if let cachedData: LargeData = cacheManager.get(for: "large-data") {
            print("✅ Retrieved compressed data: \(cachedData.title)")
            print("📝 Content length: \(cachedData.content.count) characters")
        }
    }
    
    // MARK: - Cache Analytics Example
    
    func demonstrateCacheAnalytics() {
        print("\n📊 Cache Analytics Example")
        print("===========================")
        
        // Simulate cache usage
        for i in 1...10 {
            let user = User(id: i, name: "User \(i)", email: "user\(i)@example.com")
            cacheManager.set(user, for: "user-\(i)", ttl: 1800)
        }
        
        // Access some items
        for i in 1...5 {
            if let _: User = cacheManager.get(for: "user-\(i)") {
                print("   Accessed: User \(i)")
            }
        }
        
        // Get analytics
        let stats = cacheManager.getStatistics()
        print("\n📈 Cache Performance:")
        print("   Total items: \(stats.memoryCount)")
        print("   Disk usage: \(stats.diskSize) bytes")
        print("   Cache hits: \(stats.hitCount)")
        print("   Cache misses: \(stats.missCount)")
        print("   Hit rate: \(String(format: "%.1f", stats.hitRate * 100))%")
        
        // Performance analysis
        if stats.hitRate > 0.8 {
            print("   🎯 Excellent cache performance!")
        } else if stats.hitRate > 0.6 {
            print("   ✅ Good cache performance")
        } else {
            print("   ⚠️ Cache performance needs improvement")
        }
    }
    
    // MARK: - Cache Cleanup Example
    
    func demonstrateCacheCleanup() {
        print("\n🧹 Cache Cleanup Example")
        print("========================")
        
        // Store items with different TTLs
        let shortTTL = TemporaryData(id: 1, content: "Short TTL", expiresAt: Date().addingTimeInterval(30))
        let longTTL = User(id: 1, name: "Long TTL User", email: "user@example.com")
        
        cacheManager.set(shortTTL, for: "short-ttl", ttl: 30) // 30 seconds
        cacheManager.set(longTTL, for: "long-ttl", ttl: 3600) // 1 hour
        
        print("📦 Stored items with different TTLs")
        
        // Clean expired entries
        cacheManager.cleanExpiredEntries()
        print("🧹 Cleaned expired entries")
        
        // Check what remains
        if let _: TemporaryData = cacheManager.get(for: "short-ttl") {
            print("✅ Short TTL item still available")
        } else {
            print("❌ Short TTL item expired")
        }
        
        if let _: User = cacheManager.get(for: "long-ttl") {
            print("✅ Long TTL item still available")
        } else {
            print("❌ Long TTL item expired")
        }
    }
}

// MARK: - Usage Example

func runAdvancedCachingExample() {
    let example = AdvancedCachingExample()
    
    // Run all demonstrations
    example.demonstrateMultiLevelCaching()
    example.demonstrateCachePolicies()
    example.demonstrateCacheInvalidation()
    example.demonstrateCacheCompression()
    example.demonstrateCacheAnalytics()
    example.demonstrateCacheCleanup()
}

// MARK: - Supporting Types

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct Product: Codable {
    let id: Int
    let name: String
    let price: Double
}

struct TemporaryData: Codable {
    let id: Int
    let content: String
    let expiresAt: Date
}

struct LargeData: Codable {
    let id: Int
    let title: String
    let content: String
    let metadata: [String: String]
} 