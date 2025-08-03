# Caching Guide

Complete guide to caching strategies and implementation in iOS Networking Architecture Pro.

## 📋 Table of Contents

- [Overview](#overview)
- [Cache Levels](#cache-levels)
- [Cache Policies](#cache-policies)
- [Configuration](#configuration)
- [Best Practices](#best-practices)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)

---

## Overview

The iOS Networking Architecture Pro provides a comprehensive multi-level caching system designed for optimal performance and user experience. This guide covers all aspects of caching implementation and configuration.

### Key Features

- **Multi-Level Caching**: Memory and disk storage
- **Intelligent Policies**: LRU, LFU, FIFO, TTL
- **Automatic Management**: Expiration and cleanup
- **Performance Analytics**: Hit rates and statistics
- **Configurable**: Flexible settings for different use cases

---

## Cache Levels

### 1. Memory Cache (L1)

Fastest access level with limited capacity.

**Characteristics:**
- **Speed**: Sub-millisecond access
- **Capacity**: Configurable (default: 50MB)
- **Persistence**: Lost on app termination
- **Cost**: High memory usage

**Use Cases:**
- Frequently accessed data
- Small objects
- Temporary data
- Real-time information

**Example:**
```swift
// Store in memory cache
cacheManager.set(user, for: "user-1", ttl: 1800) // 30 minutes
```

### 2. Disk Cache (L2)

Persistent storage with larger capacity.

**Characteristics:**
- **Speed**: 10-100ms access
- **Capacity**: Configurable (default: 100MB)
- **Persistence**: Survives app restarts
- **Cost**: Disk space usage

**Use Cases:**
- Large data objects
- Images and media
- Persistent data
- Offline content

**Example:**
```swift
// Store large data in disk cache
cacheManager.set(largeImage, for: "image-1", ttl: 86400) // 24 hours
```

### 3. Network Cache (L3)

HTTP cache headers for shared resources.

**Characteristics:**
- **Speed**: Network dependent
- **Capacity**: Unlimited
- **Persistence**: Server controlled
- **Cost**: Network bandwidth

**Use Cases:**
- Static resources
- CDN content
- Shared data
- Public information

---

## Cache Policies

### 1. LRU (Least Recently Used)

Evicts the least recently accessed items first.

**Algorithm:**
```swift
public enum CachePolicy {
    case lru // Least Recently Used
}
```

**Use Cases:**
- General purpose caching
- User data
- Frequently changing content

**Example:**
```swift
let config = CacheConfiguration(policy: .lru)
cacheManager.configure(config)
```

### 2. LFU (Least Frequently Used)

Evicts the least frequently accessed items first.

**Algorithm:**
```swift
public enum CachePolicy {
    case lfu // Least Frequently Used
}
```

**Use Cases:**
- Popular content
- Trending data
- Viral content

**Example:**
```swift
let config = CacheConfiguration(policy: .lfu)
cacheManager.configure(config)
```

### 3. FIFO (First In, First Out)

Evicts items in the order they were added.

**Algorithm:**
```swift
public enum CachePolicy {
    case fifo // First In, First Out
}
```

**Use Cases:**
- Queue-based systems
- Time-sensitive data
- Sequential processing

**Example:**
```swift
let config = CacheConfiguration(policy: .fifo)
cacheManager.configure(config)
```

### 4. TTL (Time To Live)

Evicts items based on expiration time.

**Algorithm:**
```swift
public enum CachePolicy {
    case ttl // Time To Live
}
```

**Use Cases:**
- Time-sensitive data
- Expiring content
- Temporary information

**Example:**
```swift
let config = CacheConfiguration(policy: .ttl)
cacheManager.configure(config)
```

---

## Configuration

### Basic Configuration

```swift
let cacheConfig = CacheConfiguration(
    memoryCapacity: 50 * 1024 * 1024, // 50MB
    diskCapacity: 100 * 1024 * 1024,  // 100MB
    ttl: 3600, // 1 hour
    policy: .lru,
    enableCompression: true,
    enableEncryption: false
)

networkManager.configureCaching(cacheConfig)
```

### Advanced Configuration

```swift
let advancedConfig = CacheConfiguration(
    memoryCapacity: 100 * 1024 * 1024, // 100MB
    diskCapacity: 500 * 1024 * 1024,   // 500MB
    ttl: 7200, // 2 hours
    policy: .lfu,
    enableCompression: true,
    enableEncryption: true
)

cacheManager.configure(advancedConfig)
```

### Per-Request Configuration

```swift
let request = APIRequest<User>.get("/users/1")
    .cacheKey("user-1")
    .cacheTTL(1800) // 30 minutes
    .build()
```

---

## Best Practices

### 1. Cache Key Strategy

**Use descriptive, unique keys:**
```swift
// Good
cacheManager.set(user, for: "user-1-profile", ttl: 1800)
cacheManager.set(products, for: "products-category-electronics", ttl: 3600)

// Avoid
cacheManager.set(user, for: "data", ttl: 1800)
cacheManager.set(products, for: "list", ttl: 3600)
```

### 2. TTL Configuration

**Choose appropriate TTL values:**
```swift
// Static content (long TTL)
cacheManager.set(staticData, for: "static-content", ttl: 86400) // 24 hours

// User data (medium TTL)
cacheManager.set(userData, for: "user-profile", ttl: 1800) // 30 minutes

// Real-time data (short TTL)
cacheManager.set(liveData, for: "live-feed", ttl: 60) // 1 minute
```

### 3. Memory Management

**Monitor memory usage:**
```swift
let stats = cacheManager.getStatistics()
print("Memory usage: \(stats.memoryCount) bytes")
print("Disk usage: \(stats.diskSize) bytes")

if stats.memoryCount > 80 * 1024 * 1024 { // 80MB
    cacheManager.cleanExpiredEntries()
}
```

### 4. Cache Invalidation

**Invalidate when data changes:**
```swift
// Update user data
updateUser(user)

// Invalidate related cache
cacheManager.remove(for: "user-\(user.id)-profile")
cacheManager.remove(for: "user-\(user.id)-settings")
```

### 5. Error Handling

**Handle cache failures gracefully:**
```swift
do {
    cacheManager.set(data, for: key, ttl: ttl)
} catch {
    print("Cache write failed: \(error)")
    // Continue without caching
}
```

---

## Performance Optimization

### 1. Cache Hit Rate Optimization

**Monitor and optimize hit rates:**
```swift
let stats = cacheManager.getStatistics()
let hitRate = stats.hitRate

if hitRate < 0.6 {
    // Optimize cache strategy
    increaseCacheSize()
    adjustTTL()
    reviewCacheKeys()
}
```

### 2. Memory Optimization

**Configure appropriate memory limits:**
```swift
let config = CacheConfiguration(
    memoryCapacity: calculateOptimalMemorySize(),
    diskCapacity: calculateOptimalDiskSize(),
    ttl: calculateOptimalTTL()
)
```

### 3. Compression

**Enable compression for large data:**
```swift
let config = CacheConfiguration(
    enableCompression: true,
    enableEncryption: false
)
```

### 4. Background Cleanup

**Schedule regular cleanup:**
```swift
Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
    cacheManager.cleanExpiredEntries()
}
```

---

## Advanced Features

### 1. Custom Cache Policies

**Implement custom eviction strategies:**
```swift
class CustomCachePolicy: CachePolicy {
    case customStrategy
}

extension CacheManager {
    func applyCustomPolicy() {
        // Custom implementation
    }
}
```

### 2. Cache Analytics

**Track detailed metrics:**
```swift
let analytics = CacheAnalytics(
    hitCount: stats.hitCount,
    missCount: stats.missCount,
    memoryUsage: stats.memoryCount,
    diskUsage: stats.diskSize
)
```

### 3. Cache Warming

**Pre-populate cache with frequently accessed data:**
```swift
func warmCache() {
    let frequentlyAccessedData = [
        "user-profile",
        "app-settings",
        "static-content"
    ]
    
    for key in frequentlyAccessedData {
        fetchAndCache(key)
    }
}
```

### 4. Cache Synchronization

**Sync cache across devices:**
```swift
func syncCache() {
    let localCache = cacheManager.getStatistics()
    uploadCacheToCloud(localCache)
    downloadCacheFromCloud()
}
```

---

## Troubleshooting

### Common Issues

#### 1. High Memory Usage

**Symptoms:**
- App crashes
- Slow performance
- Memory warnings

**Solutions:**
```swift
// Reduce memory capacity
let config = CacheConfiguration(
    memoryCapacity: 25 * 1024 * 1024 // 25MB
)

// Increase cleanup frequency
Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
    cacheManager.cleanExpiredEntries()
}
```

#### 2. Low Cache Hit Rate

**Symptoms:**
- Poor performance
- High network usage
- Slow response times

**Solutions:**
```swift
// Increase cache size
let config = CacheConfiguration(
    memoryCapacity: 100 * 1024 * 1024, // 100MB
    diskCapacity: 500 * 1024 * 1024    // 500MB
)

// Optimize TTL
let config = CacheConfiguration(ttl: 7200) // 2 hours
```

#### 3. Cache Corruption

**Symptoms:**
- Invalid data
- App crashes
- Unexpected behavior

**Solutions:**
```swift
// Clear corrupted cache
cacheManager.clear()

// Enable encryption
let config = CacheConfiguration(enableEncryption: true)
```

#### 4. Disk Space Issues

**Symptoms:**
- Cache failures
- Disk full errors
- Poor performance

**Solutions:**
```swift
// Reduce disk capacity
let config = CacheConfiguration(
    diskCapacity: 50 * 1024 * 1024 // 50MB
)

// Implement cleanup
cacheManager.cleanExpiredEntries()
```

### Debugging

#### Enable Debug Logging

```swift
// Add debug interceptor
class DebugCacheInterceptor: RequestInterceptor {
    func intercept(_ request: APIRequest<Any>) -> APIRequest<Any> {
        print("Cache debug: \(request.cacheKey)")
        return request
    }
}

networkManager.addInterceptor(DebugCacheInterceptor())
```

#### Monitor Cache Statistics

```swift
func monitorCache() {
    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
        let stats = cacheManager.getStatistics()
        print("Cache stats: \(stats)")
    }
}
```

---

## Examples

### Basic Caching

```swift
// Configure caching
let cacheConfig = CacheConfiguration(
    memoryCapacity: 50 * 1024 * 1024,
    diskCapacity: 100 * 1024 * 1024,
    ttl: 3600
)

networkManager.configureCaching(cacheConfig)

// Cache user data
let user = User(id: 1, name: "John Doe", email: "john@example.com")
cacheManager.set(user, for: "user-1", ttl: 1800)

// Retrieve cached data
if let cachedUser: User = cacheManager.get(for: "user-1") {
    print("Cached user: \(cachedUser.name)")
}
```

### Advanced Caching

```swift
// Custom cache configuration
let advancedConfig = CacheConfiguration(
    memoryCapacity: 100 * 1024 * 1024,
    diskCapacity: 500 * 1024 * 1024,
    ttl: 7200,
    policy: .lfu,
    enableCompression: true,
    enableEncryption: true
)

cacheManager.configure(advancedConfig)

// Cache with custom key strategy
let products = fetchProducts()
cacheManager.set(products, for: "products-category-\(category)-page-\(page)", ttl: 3600)

// Cache invalidation
func updateProduct(_ product: Product) {
    // Update product
    updateProductInDatabase(product)
    
    // Invalidate related cache
    cacheManager.remove(for: "products-category-\(product.category)")
    cacheManager.remove(for: "product-\(product.id)")
}
```

---

This caching guide provides comprehensive information about implementing and optimizing caching in your iOS applications using the iOS Networking Architecture Pro framework. 