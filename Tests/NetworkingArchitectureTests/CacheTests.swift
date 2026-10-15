import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

@Suite("LRU cache")
struct LRUCacheTests {
    @Test func evictsTheLeastRecentlyUsedEntry() {
        var cache = LRUCache<String, Int>(countLimit: 3)
        cache.setValue(1, forKey: "a")
        cache.setValue(2, forKey: "b")
        cache.setValue(3, forKey: "c")
        _ = cache.value(forKey: "a")
        cache.setValue(4, forKey: "d")
        #expect(cache.keys == ["d", "a", "c"])
        #expect(cache.peek("b") == nil)
    }

    @Test func peekDoesNotChangeTheOrder() {
        var cache = LRUCache<String, Int>(countLimit: 2)
        cache.setValue(1, forKey: "a")
        cache.setValue(2, forKey: "b")
        _ = cache.peek("a")
        cache.setValue(3, forKey: "c")
        #expect(cache.keys == ["c", "b"])
    }

    @Test func evictsByTotalCost() {
        var cache = LRUCache<String, String>(costLimit: 10)
        cache.setValue("a", forKey: "a", cost: 4)
        cache.setValue("b", forKey: "b", cost: 4)
        cache.setValue("c", forKey: "c", cost: 4)
        #expect(cache.keys == ["c", "b"])
        #expect(cache.totalCost == 8)
    }

    @Test func entryLargerThanTheLimitIsNotStoredAndReplacesNothing() {
        var cache = LRUCache<String, String>(costLimit: 10)
        cache.setValue("small", forKey: "k", cost: 2)
        cache.setValue("huge", forKey: "k", cost: 11)
        #expect(cache.peek("k") == nil)
        #expect(cache.totalCost == 0)
    }

    @Test func replacingAKeyUpdatesTheCost() {
        var cache = LRUCache<String, String>()
        cache.setValue("x", forKey: "k", cost: 5)
        cache.setValue("y", forKey: "k", cost: 3)
        #expect(cache.count == 1)
        #expect(cache.totalCost == 3)
        #expect(cache.removeValue(forKey: "k") == "y")
        #expect(cache.totalCost == 0)
    }

    @Test func extremeLimitsAndCostsDoNotTrap() {
        var cache = LRUCache<Int, Int>(countLimit: .max, costLimit: .max)
        cache.setValue(1, forKey: 1, cost: .max)
        cache.setValue(2, forKey: 2, cost: .max)
        #expect(cache.keys == [2])
        cache.setValue(3, forKey: 3, cost: .min)
        #expect(cache.totalCost == .max)

        var empty = LRUCache<Int, Int>(countLimit: -5, costLimit: -5)
        empty.setValue(1, forKey: 1)
        #expect(empty.count == 0)
    }

    @Test func slotsAreReusedAfterRemoval() {
        var cache = LRUCache<Int, Int>(countLimit: 2)
        for key in 0..<1_000 {
            cache.setValue(key, forKey: key)
        }
        #expect(cache.keys == [999, 998])
        cache.removeAll()
        #expect(cache.count == 0 && cache.keys.isEmpty)
    }
}

@Suite("Response caches")
struct ResponseCacheStorageTests {
    private func response(_ text: String, age: TimeInterval = 0) -> CachedResponse {
        CachedResponse(data: Data(text.utf8), statusCode: 200, headers: ["ETag": "\"\(text)\""],
                       url: nil, storedAt: Date().addingTimeInterval(-age))
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("cache-\(UUID().uuidString)")
    }

    @Test func memoryCacheRespectsItsByteLimit() async {
        let cache = MemoryResponseCache(countLimit: 10, byteLimit: 10)
        await cache.store(response("123456"), for: "a")
        await cache.store(response("123456"), for: "b")
        #expect(await cache.cachedResponse(for: "a") == nil)
        #expect(await cache.cachedResponse(for: "b")?.data == Data("123456".utf8))
        #expect(await cache.totalBytes == 6)
    }

    @Test func diskCacheRoundTripsAndSurvivesANewInstance() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let stored = response("hello")
        await DiskResponseCache(directory: directory).store(stored, for: "GET https://x/y")
        let reloaded = await DiskResponseCache(directory: directory).cachedResponse(for: "GET https://x/y")
        #expect(reloaded == stored)
    }

    @Test func diskFileNamesCannotEscapeTheDirectory() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = DiskResponseCache(directory: directory)
        await cache.store(response("x"), for: "../../escape/../../etc/passwd")
        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        #expect(files.count == 1)
        #expect(files.first?.count == 64 + ".response".count)
    }

    @Test func corruptFilesAreDeletedAndMissed() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = DiskResponseCache(directory: directory)
        await cache.store(response("x"), for: "key")
        let file = try #require(try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil).first)
        try Data("garbage".utf8).write(to: file)
        #expect(await cache.cachedResponse(for: "key") == nil)
        #expect(!FileManager.default.fileExists(atPath: file.path))
    }

    @Test func diskCacheEvictsTheLeastRecentlyUsedFiles() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let body = String(repeating: "x", count: 1_000)
        await DiskResponseCache(directory: directory).store(response(body), for: "a")
        let entrySize = await DiskResponseCache(directory: directory).totalBytes
        // Room for two entries but not three.
        let limit = entrySize * 5 / 2
        let cache = DiskResponseCache(directory: directory, byteLimit: limit)
        await cache.store(response(body), for: "b")
        // Mark "a" as older than "b" regardless of the file system's timestamp resolution.
        for (key, age) in [("a", 100.0), ("b", 50.0)] {
            let name = CacheKey.sha256(key) + ".response"
            try FileManager.default.setAttributes(
                [.modificationDate: Date().addingTimeInterval(-age)],
                ofItemAtPath: directory.appendingPathComponent(name).path
            )
        }
        await cache.store(response(body), for: "c")
        #expect(await cache.cachedResponse(for: "a") == nil)
        #expect(await cache.cachedResponse(for: "b") != nil)
        #expect(await cache.cachedResponse(for: "c") != nil)
        #expect(await cache.totalBytes <= limit)
    }

    @Test func hybridCacheFillsMemoryFromDisk() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let disk = DiskResponseCache(directory: directory)
        await disk.store(response("from disk"), for: "k")
        let memory = MemoryResponseCache()
        let hybrid = HybridResponseCache(memory: memory, disk: disk)
        #expect(await memory.cachedResponse(for: "k") == nil)
        #expect(await hybrid.cachedResponse(for: "k")?.data == Data("from disk".utf8))
        #expect(await memory.cachedResponse(for: "k") != nil)
        await hybrid.removeAll()
        #expect(await hybrid.cachedResponse(for: "k") == nil)
    }
}

@Suite("Cache policies")
struct CachePolicyTests {
    private func client(_ transport: MockTransport, cache: any ResponseCache = MemoryResponseCache(),
                        interceptors: [any RequestInterceptor] = []) -> NetworkClient {
        NetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            configuration: .init(interceptors: interceptors, retryPolicy: .none, cache: cache),
            transport: transport
        )
    }

    @Test func cacheFirstAnswersFromTheCacheWhileFresh() async throws {
        let transport = MockTransport()
        transport.register(.get, "users/1", try .json(User(id: 1, name: "Ada")))
        let client = client(transport)
        let endpoint = Endpoint<User>.get("users/1").with(\.cachePolicy, .cacheFirst(maxAge: .seconds(60)))
        let first = try await client.response(for: endpoint)
        let second = try await client.response(for: endpoint)
        #expect(first.source == .network)
        #expect(second.source == .cache)
        #expect(second.attempts == 0)
        #expect(second.value == first.value)
        #expect(transport.requests.count == 1)
    }

    @Test func cacheFirstReloadsAfterMaxAge() async throws {
        let transport = MockTransport()
        transport.register(.get, "x", .text("\"v\""))
        let client = client(transport)
        let endpoint = Endpoint<String>.get("x").with(\.cachePolicy, .cacheFirst(maxAge: .zero))
        _ = try await client.send(endpoint)
        _ = try await client.send(endpoint)
        #expect(transport.requests.count == 2)
    }

    @Test func networkFirstFallsBackToAStaleResponseWhenOffline() async throws {
        let transport = MockTransport()
        transport.register(.get, "feed", .text("\"cached\""), .failure(.notConnectedToInternet))
        let client = client(transport)
        let endpoint = Endpoint<String>.get("feed").with(\.cachePolicy, .networkFirst(maxStale: .seconds(3_600)))
        #expect(try await client.response(for: endpoint).source == .network)
        let fallback = try await client.response(for: endpoint)
        #expect(fallback.source == .staleCache)
        #expect(fallback.value == "cached")
    }

    @Test func networkFirstDoesNotHideClientErrors() async throws {
        let transport = MockTransport()
        transport.register(.get, "feed", .text("\"cached\""), .status(404))
        let client = client(transport)
        let endpoint = Endpoint<String>.get("feed").with(\.cachePolicy, .networkFirst(maxStale: .seconds(3_600)))
        _ = try await client.send(endpoint)
        await #expect(throws: NetworkError.self) { try await client.send(endpoint) }
    }

    @Test func revalidateSendsValidatorsAndUsesTheStoredBodyOn304() async throws {
        let transport = MockTransport()
        transport.register(
            .get, "doc",
            MockResponse(headers: ["ETag": "\"v1\"", "Last-Modified": "Wed, 21 Oct 2015 07:28:00 GMT"], body: Data("\"body\"".utf8)),
            .status(304, headers: ["ETag": "\"v1\""])
        )
        let client = client(transport)
        let endpoint = Endpoint<String>.get("doc").with(\.cachePolicy, .revalidate)
        _ = try await client.send(endpoint)
        let second = try await client.response(for: endpoint)
        #expect(second.source == .revalidatedCache)
        #expect(second.value == "body")
        let conditional = try #require(transport.requests.last)
        #expect(conditional.value(forHTTPHeaderField: "If-None-Match") == "\"v1\"")
        #expect(conditional.value(forHTTPHeaderField: "If-Modified-Since") == "Wed, 21 Oct 2015 07:28:00 GMT")
    }

    @Test func noStoreResponsesAreNotCached() async throws {
        let transport = MockTransport()
        transport.register(.get, "secret", MockResponse(headers: ["Cache-Control": "private, No-Store"], body: Data("\"s\"".utf8)))
        let cache = MemoryResponseCache()
        let client = client(transport, cache: cache)
        let endpoint = Endpoint<String>.get("secret").with(\.cachePolicy, .cacheFirst(maxAge: .seconds(60)))
        _ = try await client.send(endpoint)
        _ = try await client.send(endpoint)
        #expect(transport.requests.count == 2)
        #expect(await cache.count == 0)
    }

    @Test func errorsAndPostsAreNotCached() async throws {
        let transport = MockTransport()
        transport.register(.get, "missing", .status(404))
        transport.register(.post, "create", .text("\"ok\""))
        let cache = MemoryResponseCache()
        let client = client(transport, cache: cache)
        _ = try? await client.send(Endpoint<Data>.get("missing").with(\.cachePolicy, .cacheFirst(maxAge: .seconds(60))))
        _ = try await client.send(Endpoint<String>.post("create").with(\.cachePolicy, .cacheFirst(maxAge: .seconds(60))))
        #expect(await cache.count == 0)
    }

    @Test func differentUsersDoNotShareCachedResponses() async throws {
        struct Token: RequestInterceptor {
            let user: Locked<String>
            func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
                var request = request
                request.setValue("Bearer \(user.withLock { $0 })", forHTTPHeaderField: "Authorization")
                return request
            }
        }
        let user = Locked("alice")
        let transport = MockTransport { request in
            .text("\"\(request.value(forHTTPHeaderField: "Authorization") ?? "")\"")
        }
        let client = client(transport, interceptors: [Token(user: user)])
        let endpoint = Endpoint<String>.get("me").with(\.cachePolicy, .cacheFirst(maxAge: .seconds(60)))
        #expect(try await client.send(endpoint) == "Bearer alice")
        user.withLock { $0 = "bob" }
        #expect(try await client.send(endpoint) == "Bearer bob")
        user.withLock { $0 = "alice" }
        #expect(try await client.send(endpoint) == "Bearer alice")
        #expect(transport.requests.count == 2)
    }

    @Test func cacheKeyHashesTheAuthorizationHeader() {
        var request = URLRequest(url: URL(string: "https://api.example.com/me")!)
        request.setValue("Bearer secret-token", forHTTPHeaderField: "Authorization")
        let key = CacheKey.make(for: request)
        #expect(!key.contains("secret-token"))
        #expect(key.hasPrefix("GET https://api.example.com/me"))
    }
}
