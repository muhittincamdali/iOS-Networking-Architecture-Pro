import Foundation

/// Keeps responses in memory, dropping the least recently used ones beyond its limits.
///
/// The contents are lost when the app quits. Use ``HybridResponseCache`` to keep them on
/// disk too.
public actor MemoryResponseCache: ResponseCache {
    private var storage: LRUCache<String, CachedResponse>

    /// Creates a cache.
    ///
    /// - Parameters:
    ///   - countLimit: The most responses kept.
    ///   - byteLimit: The largest total size of the bodies kept. A single body larger than
    ///     this is not stored.
    public init(countLimit: Int = 200, byteLimit: Int = 10 * 1024 * 1024) {
        self.storage = LRUCache(countLimit: countLimit, costLimit: byteLimit)
    }

    public func cachedResponse(for key: String) -> CachedResponse? {
        storage.value(forKey: key)
    }

    public func store(_ response: CachedResponse, for key: String) {
        storage.setValue(response, forKey: key, cost: response.data.count)
    }

    public func removeResponse(for key: String) {
        storage.removeValue(forKey: key)
    }

    public func removeAll() {
        storage.removeAll()
    }

    /// The number of stored responses.
    public var count: Int { storage.count }

    /// The total size of the stored bodies, in bytes.
    public var totalBytes: Int { storage.totalCost }
}
