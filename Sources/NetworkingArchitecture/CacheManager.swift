import Foundation

/// Advanced cache manager with multi-level caching and intelligent policies
public final class CacheManager {
    
    // MARK: - Properties
    private var memoryCache: NSCache<NSString, CacheEntry>
    private var diskCache: DiskCache
    private var configuration: CacheConfiguration
    private let queue = DispatchQueue(label: "com.networking.cache", qos: .utility)
    
    // MARK: - Initialization
    public init() {
        self.memoryCache = NSCache<NSString, CacheEntry>()
        self.diskCache = DiskCache()
        self.configuration = CacheConfiguration()
        
        setupMemoryCache()
    }
    
    // MARK: - Public Methods
    
    /// Store data in cache with optional TTL
    /// - Parameters:
    ///   - data: The data to cache
    ///   - key: Cache key
    ///   - ttl: Time to live in seconds
    public func set<T: Codable>(_ data: T, for key: String, ttl: TimeInterval = 3600) {
        let entry = CacheEntry(data: data, timestamp: Date(), ttl: ttl)
        
        // Store in memory cache
        memoryCache.setObject(entry, forKey: key as NSString)
        
        // Store in disk cache asynchronously
        queue.async { [weak self] in
            self?.diskCache.set(entry, for: key)
        }
    }
    
    /// Retrieve data from cache
    /// - Parameter key: Cache key
    /// - Returns: Cached data if available and not expired
    public func get<T: Codable>(for key: String) -> T? {
        // Check memory cache first
        if let entry = memoryCache.object(forKey: key as NSString) {
            if !entry.isExpired {
                return entry.data as? T
            } else {
                memoryCache.removeObject(forKey: key as NSString)
            }
        }
        
        // Check disk cache
        if let entry = diskCache.get(for: key), !entry.isExpired {
            // Restore to memory cache
            memoryCache.setObject(entry, forKey: key as NSString)
            return entry.data as? T
        }
        
        return nil
    }
    
    /// Remove data from cache
    /// - Parameter key: Cache key
    public func remove(for key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        queue.async { [weak self] in
            self?.diskCache.remove(for: key)
        }
    }
    
    /// Clear all cached data
    public func clear() {
        memoryCache.removeAllObjects()
        queue.async { [weak self] in
            self?.diskCache.clear()
        }
    }
    
    /// Configure cache settings
    /// - Parameter configuration: Cache configuration
    public func configure(_ configuration: CacheConfiguration) {
        self.configuration = configuration
        setupMemoryCache()
    }
    
    /// Get cache statistics
    /// - Returns: Cache statistics
    public func getStatistics() -> CacheStatistics {
        let memoryCount = memoryCache.totalCostLimit
        let diskSize = diskCache.getSize()
        let hitCount = getHitCount()
        let missCount = getMissCount()
        
        return CacheStatistics(
            memoryCount: memoryCount,
            diskSize: diskSize,
            hitCount: hitCount,
            missCount: missCount
        )
    }
    
    /// Clean expired entries
    public func cleanExpiredEntries() {
        // Clean memory cache
        let keys = memoryCache.allKeys
        for key in keys {
            if let entry = memoryCache.object(forKey: key), entry.isExpired {
                memoryCache.removeObject(forKey: key)
            }
        }
        
        // Clean disk cache
        queue.async { [weak self] in
            self?.diskCache.cleanExpiredEntries()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupMemoryCache() {
        memoryCache.totalCostLimit = configuration.memoryCapacity
        memoryCache.countLimit = 1000 // Maximum number of entries
    }
    
    private func getHitCount() -> Int {
        // Implementation for tracking cache hits
        return 0 // Placeholder
    }
    
    private func getMissCount() -> Int {
        // Implementation for tracking cache misses
        return 0 // Placeholder
    }
}

// MARK: - Cache Entry

/// Represents a cached entry with metadata
public struct CacheEntry {
    public let data: Any
    public let timestamp: Date
    public let ttl: TimeInterval
    
    public var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > ttl
    }
    
    public init(data: Any, timestamp: Date, ttl: TimeInterval) {
        self.data = data
        self.timestamp = timestamp
        self.ttl = ttl
    }
}

// MARK: - Disk Cache

/// Disk-based cache implementation
private final class DiskCache {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("NetworkingCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func set(_ entry: CacheEntry, for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
        } catch {
            print("Failed to write cache entry: \(error)")
        }
    }
    
    func get(for key: String) -> CacheEntry? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return try? JSONDecoder().decode(CacheEntry.self, from: data)
    }
    
    func remove(for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clear() {
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        contents?.forEach { url in
            try? fileManager.removeItem(at: url)
        }
    }
    
    func getSize() -> Int64 {
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        return contents?.reduce(0) { sum, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return sum + Int64(size)
        } ?? 0
    }
    
    func cleanExpiredEntries() {
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        contents?.forEach { url in
            if let entry = get(for: url.lastPathComponent), entry.isExpired {
                remove(for: url.lastPathComponent)
            }
        }
    }
}

// MARK: - Cache Statistics

/// Statistics about cache performance
public struct CacheStatistics {
    public let memoryCount: Int
    public let diskSize: Int64
    public let hitCount: Int
    public let missCount: Int
    
    public var hitRate: Double {
        let total = hitCount + missCount
        return total > 0 ? Double(hitCount) / Double(total) : 0.0
    }
    
    public init(memoryCount: Int, diskSize: Int64, hitCount: Int, missCount: Int) {
        self.memoryCount = memoryCount
        self.diskSize = diskSize
        self.hitCount = hitCount
        self.missCount = missCount
    }
}

// MARK: - Cache Policies

/// Different cache eviction policies
public enum CachePolicy {
    case lru // Least Recently Used
    case lfu // Least Frequently Used
    case fifo // First In, First Out
    case ttl // Time To Live
}

/// Cache configuration with advanced options
public struct CacheConfiguration {
    public var memoryCapacity: Int
    public var diskCapacity: Int
    public var ttl: TimeInterval
    public var policy: CachePolicy
    public var enableCompression: Bool
    public var enableEncryption: Bool
    
    public init(
        memoryCapacity: Int = 50 * 1024 * 1024,
        diskCapacity: Int = 100 * 1024 * 1024,
        ttl: TimeInterval = 3600,
        policy: CachePolicy = .lru,
        enableCompression: Bool = true,
        enableEncryption: Bool = false
    ) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.ttl = ttl
        self.policy = policy
        self.enableCompression = enableCompression
        self.enableEncryption = enableEncryption
    }
}
/// Advanced cache manager with multi-level caching and intelligent policies
public final class CacheManager {
    
    // MARK: - Properties
    private var memoryCache: NSCache<NSString, CacheEntry>
    private var diskCache: DiskCache
    private var configuration: CacheConfiguration
    private let queue = DispatchQueue(label: "com.networking.cache", qos: .utility)
    
    // MARK: - Initialization
    public init() {
        self.memoryCache = NSCache<NSString, CacheEntry>()
        self.diskCache = DiskCache()
        self.configuration = CacheConfiguration()
        
        setupMemoryCache()
    }
    
    // MARK: - Public Methods
    
    /// Store data in cache with optional TTL
    /// - Parameters:
    ///   - data: The data to cache
    ///   - key: Cache key
    ///   - ttl: Time to live in seconds
    public func set<T: Codable>(_ data: T, for key: String, ttl: TimeInterval = 3600) {
        let entry = CacheEntry(data: data, timestamp: Date(), ttl: ttl)
        
        // Store in memory cache
        memoryCache.setObject(entry, forKey: key as NSString)
        
        // Store in disk cache asynchronously
        queue.async { [weak self] in
            self?.diskCache.set(entry, for: key)
        }
    }
    
    /// Retrieve data from cache
    /// - Parameter key: Cache key
    /// - Returns: Cached data if available and not expired
    public func get<T: Codable>(for key: String) -> T? {
        // Check memory cache first
        if let entry = memoryCache.object(forKey: key as NSString) {
            if !entry.isExpired {
                return entry.data as? T
            } else {
                memoryCache.removeObject(forKey: key as NSString)
            }
        }
        
        // Check disk cache
        if let entry = diskCache.get(for: key), !entry.isExpired {
            // Restore to memory cache
            memoryCache.setObject(entry, forKey: key as NSString)
            return entry.data as? T
        }
        
        return nil
    }
    
    /// Remove data from cache
    /// - Parameter key: Cache key
    public func remove(for key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        queue.async { [weak self] in
            self?.diskCache.remove(for: key)
        }
    }
    
    /// Clear all cached data
    public func clear() {
        memoryCache.removeAllObjects()
        queue.async { [weak self] in
            self?.diskCache.clear()
        }
    }
    
    /// Configure cache settings
    /// - Parameter configuration: Cache configuration
    public func configure(_ configuration: CacheConfiguration) {
        self.configuration = configuration
        setupMemoryCache()
    }
    
    /// Get cache statistics
    /// - Returns: Cache statistics
    public func getStatistics() -> CacheStatistics {
        let memoryCount = memoryCache.totalCostLimit
        let diskSize = diskCache.getSize()
        let hitCount = getHitCount()
        let missCount = getMissCount()
        
        return CacheStatistics(
            memoryCount: memoryCount,
            diskSize: diskSize,
            hitCount: hitCount,
            missCount: missCount
        )
    }
    
    /// Clean expired entries
    public func cleanExpiredEntries() {
        // Clean memory cache
        let keys = memoryCache.allKeys
        for key in keys {
            if let entry = memoryCache.object(forKey: key), entry.isExpired {
                memoryCache.removeObject(forKey: key)
            }
        }
        
        // Clean disk cache
        queue.async { [weak self] in
            self?.diskCache.cleanExpiredEntries()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupMemoryCache() {
        memoryCache.totalCostLimit = configuration.memoryCapacity
        memoryCache.countLimit = 1000 // Maximum number of entries
    }
    
    private func getHitCount() -> Int {
        // Implementation for tracking cache hits
        return 0 // Placeholder
    }
    
    private func getMissCount() -> Int {
        // Implementation for tracking cache misses
        return 0 // Placeholder
    }
}

// MARK: - Cache Entry

/// Represents a cached entry with metadata
public struct CacheEntry {
    public let data: Any
    public let timestamp: Date
    public let ttl: TimeInterval
    
    public var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > ttl
    }
    
    public init(data: Any, timestamp: Date, ttl: TimeInterval) {
        self.data = data
        self.timestamp = timestamp
        self.ttl = ttl
    }
}

// MARK: - Disk Cache

/// Disk-based cache implementation
private final class DiskCache {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("NetworkingCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func set(_ entry: CacheEntry, for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
        } catch {
            print("Failed to write cache entry: \(error)")
        }
    }
    
    func get(for key: String) -> CacheEntry? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return try? JSONDecoder().decode(CacheEntry.self, from: data)
    }
    
    func remove(for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clear() {
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        contents?.forEach { url in
            try? fileManager.removeItem(at: url)
        }
    }
    
    func getSize() -> Int64 {
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        return contents?.reduce(0) { sum, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return sum + Int64(size)
        } ?? 0
    }
    
    func cleanExpiredEntries() {
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        contents?.forEach { url in
            if let entry = get(for: url.lastPathComponent), entry.isExpired {
                remove(for: url.lastPathComponent)
            }
        }
    }
}

// MARK: - Cache Statistics

/// Statistics about cache performance
public struct CacheStatistics {
    public let memoryCount: Int
    public let diskSize: Int64
    public let hitCount: Int
    public let missCount: Int
    
    public var hitRate: Double {
        let total = hitCount + missCount
        return total > 0 ? Double(hitCount) / Double(total) : 0.0
    }
    
    public init(memoryCount: Int, diskSize: Int64, hitCount: Int, missCount: Int) {
        self.memoryCount = memoryCount
        self.diskSize = diskSize
        self.hitCount = hitCount
        self.missCount = missCount
    }
}

// MARK: - Cache Policies

/// Different cache eviction policies
public enum CachePolicy {
    case lru // Least Recently Used
    case lfu // Least Frequently Used
    case fifo // First In, First Out
    case ttl // Time To Live
}

/// Cache configuration with advanced options
public struct CacheConfiguration {
    public var memoryCapacity: Int
    public var diskCapacity: Int
    public var ttl: TimeInterval
    public var policy: CachePolicy
    public var enableCompression: Bool
    public var enableEncryption: Bool
    
    public init(
        memoryCapacity: Int = 50 * 1024 * 1024,
        diskCapacity: Int = 100 * 1024 * 1024,
        ttl: TimeInterval = 3600,
        policy: CachePolicy = .lru,
        enableCompression: Bool = true,
        enableEncryption: Bool = false
    ) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.ttl = ttl
        self.policy = policy
        self.enableCompression = enableCompression
        self.enableEncryption = enableEncryption
    }
}
