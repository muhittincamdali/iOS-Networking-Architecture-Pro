import Foundation

/// A memory cache in front of a disk cache.
///
/// Reads try memory first, then disk; a response found on disk is copied into memory.
/// Writes go to both, so stored responses survive an app restart.
///
/// ```swift
/// var configuration = NetworkClient.Configuration()
/// configuration.cache = HybridResponseCache()
/// ```
public struct HybridResponseCache: ResponseCache {
    /// The fast layer.
    public let memory: MemoryResponseCache

    /// The persistent layer.
    public let disk: DiskResponseCache

    /// Creates a cache from two layers.
    public init(memory: MemoryResponseCache = MemoryResponseCache(), disk: DiskResponseCache = DiskResponseCache()) {
        self.memory = memory
        self.disk = disk
    }

    public func cachedResponse(for key: String) async -> CachedResponse? {
        if let response = await memory.cachedResponse(for: key) {
            return response
        }
        guard let response = await disk.cachedResponse(for: key) else { return nil }
        await memory.store(response, for: key)
        return response
    }

    public func store(_ response: CachedResponse, for key: String) async {
        await memory.store(response, for: key)
        await disk.store(response, for: key)
    }

    public func removeResponse(for key: String) async {
        await memory.removeResponse(for: key)
        await disk.removeResponse(for: key)
    }

    public func removeAll() async {
        await memory.removeAll()
        await disk.removeAll()
    }
}
