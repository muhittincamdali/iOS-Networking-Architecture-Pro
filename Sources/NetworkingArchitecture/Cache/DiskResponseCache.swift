import Foundation

/// Keeps responses as files in a directory, dropping the least recently used ones beyond
/// its size limit.
///
/// Each response is one file named after the SHA-256 hash of its key, so a key cannot
/// choose a path outside the directory. A file that cannot be read back (for example after
/// a crash during a write) is deleted and treated as a miss.
///
/// On iOS, tvOS, watchOS and visionOS the files are written with
/// `completeUntilFirstUserAuthentication` data protection, so they are encrypted until the
/// device is unlocked for the first time after a restart.
public actor DiskResponseCache: ResponseCache {
    private struct Entry: Codable {
        let key: String
        let response: CachedResponse
    }

    /// The directory the files are stored in.
    public let directory: URL

    /// The largest total size of the files kept, in bytes.
    public let byteLimit: Int

    private let fileManager = FileManager.default
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()

    /// Creates a cache in `directory`, creating the directory if needed.
    ///
    /// - Parameters:
    ///   - directory: The directory for the files. Use one directory per cache.
    ///   - byteLimit: The largest total size of the files kept. A single response larger
    ///     than this is not stored.
    public init(directory: URL, byteLimit: Int = 50 * 1024 * 1024) {
        self.directory = directory
        self.byteLimit = max(0, byteLimit)
        encoder.outputFormat = .binary
    }

    /// Creates a cache in a folder named `name` inside the app's caches directory.
    public init(name: String = "NetworkingArchitecture", byteLimit: Int = 50 * 1024 * 1024) {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let safeName = CacheKey.sha256(name).prefix(16)
        self.init(directory: caches.appendingPathComponent("ResponseCache-\(safeName)", isDirectory: true), byteLimit: byteLimit)
    }

    public func cachedResponse(for key: String) -> CachedResponse? {
        let file = fileURL(for: key)
        guard let data = try? Data(contentsOf: file) else { return nil }
        guard let entry = try? decoder.decode(Entry.self, from: data), entry.key == key else {
            try? fileManager.removeItem(at: file)
            return nil
        }
        // The modification date records the last use, for eviction.
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: file.path)
        return entry.response
    }

    public func store(_ response: CachedResponse, for key: String) {
        guard let data = try? encoder.encode(Entry(key: key, response: response)) else { return }
        let file = fileURL(for: key)
        guard data.count <= byteLimit else {
            try? fileManager.removeItem(at: file)
            return
        }
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: file, options: Self.writingOptions)
        } catch {
            return
        }
        trim(keeping: file)
    }

    public func removeResponse(for key: String) {
        try? fileManager.removeItem(at: fileURL(for: key))
    }

    public func removeAll() {
        try? fileManager.removeItem(at: directory)
    }

    /// The total size of the stored files, in bytes.
    public var totalBytes: Int {
        files().reduce(0) { $0 + $1.size }
    }

    private func fileURL(for key: String) -> URL {
        directory.appendingPathComponent(CacheKey.sha256(key) + ".response")
    }

    /// Deletes the least recently used files until the total fits the limit.
    private func trim(keeping newest: URL) {
        var entries = files().sorted { $0.used < $1.used }
        var total = entries.reduce(0) { $0 + $1.size }
        while total > byteLimit, let oldest = entries.first {
            entries.removeFirst()
            if oldest.url.standardizedFileURL == newest.standardizedFileURL { continue }
            try? fileManager.removeItem(at: oldest.url)
            total -= oldest.size
        }
    }

    private func files() -> [(url: URL, size: Int, used: Date)] {
        let keys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey]
        let urls = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: keys)) ?? []
        return urls.filter { $0.pathExtension == "response" }.map { url in
            let values = try? url.resourceValues(forKeys: Set(keys))
            return (url, values?.fileSize ?? 0, values?.contentModificationDate ?? .distantPast)
        }
    }

    private static var writingOptions: Data.WritingOptions {
        #if os(macOS)
        [.atomic]
        #else
        [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        #endif
    }
}
