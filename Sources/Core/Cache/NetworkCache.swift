// NetworkCache.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import Collections

/// Cache key for network responses
public struct CacheKey: Hashable, Sendable {
    public let url: URL
    public let method: String
    public let queryHash: Int?
    
    public init(url: URL, method: String = "GET", queryHash: Int? = nil) {
        self.url = url
        self.method = method
        self.queryHash = queryHash
    }
    
    /// Create key from URLRequest
    public init(request: URLRequest) {
        self.url = request.url ?? URL(string: "invalid://")!
        self.method = request.httpMethod ?? "GET"
        self.queryHash = request.httpBody?.hashValue
    }
}

/// Cache entry with metadata
public struct CacheEntry: Sendable {
    public let data: Data
    public let timestamp: Date
    public let ttl: TimeInterval?
    public let etag: String?
    public let lastModified: Date?
    
    public var isExpired: Bool {
        guard let ttl = ttl else { return false }
        return Date().timeIntervalSince(timestamp) > ttl
    }
    
    public init(
        data: Data,
        timestamp: Date = Date(),
        ttl: TimeInterval? = nil,
        etag: String? = nil,
        lastModified: Date? = nil
    ) {
        self.data = data
        self.timestamp = timestamp
        self.ttl = ttl
        self.etag = etag
        self.lastModified = lastModified
    }
}

/// Cache policy configuration
public struct CachePolicy: Sendable {
    public let shouldReadFromCache: Bool
    public let shouldWriteToCache: Bool
    public let ttl: TimeInterval?
    public let staleWhileRevalidate: Bool
    
    public init(
        shouldReadFromCache: Bool = true,
        shouldWriteToCache: Bool = true,
        ttl: TimeInterval? = nil,
        staleWhileRevalidate: Bool = false
    ) {
        self.shouldReadFromCache = shouldReadFromCache
        self.shouldWriteToCache = shouldWriteToCache
        self.ttl = ttl
        self.staleWhileRevalidate = staleWhileRevalidate
    }
    
    // MARK: - Presets
    
    /// Default caching behavior
    public static let `default` = CachePolicy()
    
    /// No caching
    public static let noCache = CachePolicy(shouldReadFromCache: false, shouldWriteToCache: false)
    
    /// Cache only (no network)
    public static let cacheOnly = CachePolicy(shouldReadFromCache: true, shouldWriteToCache: false)
    
    /// Network only (update cache)
    public static let networkOnly = CachePolicy(shouldReadFromCache: false, shouldWriteToCache: true)
    
    /// Short-lived cache (1 minute)
    public static let shortLived = CachePolicy(ttl: 60)
    
    /// Long-lived cache (1 hour)
    public static let longLived = CachePolicy(ttl: 3600)
    
    /// Stale while revalidate
    public static let staleWhileRevalidating = CachePolicy(staleWhileRevalidate: true)
}

/// Protocol for network cache implementations
public protocol NetworkCache: Actor {
    /// Get cached data for key
    func get(_ key: CacheKey) async throws -> Data?
    
    /// Set data in cache with optional TTL
    func set(_ data: Data, for key: CacheKey, ttl: TimeInterval?) async throws
    
    /// Remove entry for key
    func remove(_ key: CacheKey) async
    
    /// Clear all cached data
    func clear() async
    
    /// Get cache entry with metadata
    func getEntry(_ key: CacheKey) async -> CacheEntry?
    
    /// Check if key exists in cache
    func contains(_ key: CacheKey) async -> Bool
    
    /// Get cache size in bytes
    var size: Int { get async }
}

// MARK: - In-Memory Cache

/// Thread-safe in-memory cache with LRU eviction
public actor InMemoryCache: NetworkCache {
    private var cache: OrderedDictionary<CacheKey, CacheEntry>
    private let maxSize: Int
    private var currentSize: Int = 0
    
    public init(maxSize: Int = 50 * 1024 * 1024) { // 50 MB default
        self.maxSize = maxSize
        self.cache = OrderedDictionary()
    }
    
    public func get(_ key: CacheKey) async throws -> Data? {
        guard let entry = cache[key] else { return nil }
        
        if entry.isExpired {
            cache.removeValue(forKey: key)
            currentSize -= entry.data.count
            return nil
        }
        
        // Move to end (LRU)
        cache.removeValue(forKey: key)
        cache[key] = entry
        
        return entry.data
    }
    
    public func set(_ data: Data, for key: CacheKey, ttl: TimeInterval?) async throws {
        // Remove existing entry
        if let existing = cache.removeValue(forKey: key) {
            currentSize -= existing.data.count
        }
        
        // Evict if necessary
        while currentSize + data.count > maxSize && !cache.isEmpty {
            if let first = cache.keys.first, let entry = cache.removeValue(forKey: first) {
                currentSize -= entry.data.count
            }
        }
        
        let entry = CacheEntry(data: data, ttl: ttl)
        cache[key] = entry
        currentSize += data.count
    }
    
    public func remove(_ key: CacheKey) async {
        if let entry = cache.removeValue(forKey: key) {
            currentSize -= entry.data.count
        }
    }
    
    public func clear() async {
        cache.removeAll()
        currentSize = 0
    }
    
    public func getEntry(_ key: CacheKey) async -> CacheEntry? {
        cache[key]
    }
    
    public func contains(_ key: CacheKey) async -> Bool {
        if let entry = cache[key] {
            return !entry.isExpired
        }
        return false
    }
    
    public var size: Int {
        currentSize
    }
}

// MARK: - Disk Cache

/// Disk-based cache for persistence
public actor DiskCache: NetworkCache {
    private let cacheDirectory: URL
    private let maxSize: Int
    private var manifest: [CacheKey: CacheManifestEntry]
    private let fileManager: FileManager
    
    public init(
        directory: URL? = nil,
        maxSize: Int = 100 * 1024 * 1024 // 100 MB default
    ) throws {
        self.fileManager = FileManager.default
        self.maxSize = maxSize
        
        if let dir = directory {
            self.cacheDirectory = dir
        } else {
            let caches = try fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            self.cacheDirectory = caches.appendingPathComponent("NetworkingArchitecture", isDirectory: true)
        }
        
        // Create directory if needed
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Load manifest
        self.manifest = [:]
        try? loadManifest()
    }
    
    public func get(_ key: CacheKey) async throws -> Data? {
        guard let entry = manifest[key] else { return nil }
        
        if entry.isExpired {
            await remove(key)
            return nil
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(entry.filename)
        return try Data(contentsOf: fileURL)
    }
    
    public func set(_ data: Data, for key: CacheKey, ttl: TimeInterval?) async throws {
        let filename = UUID().uuidString
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        try data.write(to: fileURL)
        
        let entry = CacheManifestEntry(
            filename: filename,
            size: data.count,
            timestamp: Date(),
            ttl: ttl
        )
        
        manifest[key] = entry
        try saveManifest()
        
        // Cleanup if needed
        try await evictIfNeeded()
    }
    
    public func remove(_ key: CacheKey) async {
        guard let entry = manifest.removeValue(forKey: key) else { return }
        let fileURL = cacheDirectory.appendingPathComponent(entry.filename)
        try? fileManager.removeItem(at: fileURL)
        try? saveManifest()
    }
    
    public func clear() async {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        manifest.removeAll()
        try? saveManifest()
    }
    
    public func getEntry(_ key: CacheKey) async -> CacheEntry? {
        guard let manifestEntry = manifest[key],
              let data = try? await get(key) else {
            return nil
        }
        
        return CacheEntry(
            data: data,
            timestamp: manifestEntry.timestamp,
            ttl: manifestEntry.ttl
        )
    }
    
    public func contains(_ key: CacheKey) async -> Bool {
        if let entry = manifest[key] {
            return !entry.isExpired
        }
        return false
    }
    
    public var size: Int {
        manifest.values.reduce(0) { $0 + $1.size }
    }
    
    // MARK: - Private Methods
    
    private func loadManifest() throws {
        let manifestURL = cacheDirectory.appendingPathComponent("manifest.json")
        guard fileManager.fileExists(atPath: manifestURL.path) else { return }
        
        let data = try Data(contentsOf: manifestURL)
        let decoded = try JSONDecoder().decode([String: CacheManifestEntry].self, from: data)
        
        // Convert string keys back to CacheKey
        manifest = [:]
        for (keyString, entry) in decoded {
            if let url = URL(string: keyString) {
                let key = CacheKey(url: url)
                manifest[key] = entry
            }
        }
    }
    
    private func saveManifest() throws {
        let manifestURL = cacheDirectory.appendingPathComponent("manifest.json")
        
        // Convert CacheKey to string for JSON encoding
        var encodable: [String: CacheManifestEntry] = [:]
        for (key, entry) in manifest {
            encodable[key.url.absoluteString] = entry
        }
        
        let data = try JSONEncoder().encode(encodable)
        try data.write(to: manifestURL)
    }
    
    private func evictIfNeeded() async throws {
        var currentSize = await self.size
        let entries = manifest.sorted { $0.value.timestamp < $1.value.timestamp }
        
        for (key, entry) in entries {
            if currentSize <= maxSize { break }
            await remove(key)
            currentSize -= entry.size
        }
    }
}

// MARK: - Cache Manifest Entry

private struct CacheManifestEntry: Codable {
    let filename: String
    let size: Int
    let timestamp: Date
    let ttl: TimeInterval?
    
    var isExpired: Bool {
        guard let ttl = ttl else { return false }
        return Date().timeIntervalSince(timestamp) > ttl
    }
}

// MARK: - Hybrid Cache

/// Two-level cache (memory + disk)
public actor HybridCache: NetworkCache {
    private let memoryCache: InMemoryCache
    private let diskCache: DiskCache
    
    public init(
        memoryCacheSize: Int = 10 * 1024 * 1024, // 10 MB
        diskCacheSize: Int = 100 * 1024 * 1024   // 100 MB
    ) throws {
        self.memoryCache = InMemoryCache(maxSize: memoryCacheSize)
        self.diskCache = try DiskCache(maxSize: diskCacheSize)
    }
    
    public func get(_ key: CacheKey) async throws -> Data? {
        // Try memory first
        if let data = try await memoryCache.get(key) {
            return data
        }
        
        // Try disk
        if let data = try await diskCache.get(key) {
            // Promote to memory cache
            try await memoryCache.set(data, for: key, ttl: nil)
            return data
        }
        
        return nil
    }
    
    public func set(_ data: Data, for key: CacheKey, ttl: TimeInterval?) async throws {
        // Write to both
        try await memoryCache.set(data, for: key, ttl: ttl)
        try await diskCache.set(data, for: key, ttl: ttl)
    }
    
    public func remove(_ key: CacheKey) async {
        await memoryCache.remove(key)
        await diskCache.remove(key)
    }
    
    public func clear() async {
        await memoryCache.clear()
        await diskCache.clear()
    }
    
    public func getEntry(_ key: CacheKey) async -> CacheEntry? {
        if let entry = await memoryCache.getEntry(key) {
            return entry
        }
        return await diskCache.getEntry(key)
    }
    
    public func contains(_ key: CacheKey) async -> Bool {
        await memoryCache.contains(key) || await diskCache.contains(key)
    }
    
    public var size: Int {
        get async {
            await memoryCache.size + await diskCache.size
        }
    }
}
