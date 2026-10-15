import CryptoKit
import Foundation

/// Whether and how an ``Endpoint``'s response is read from and written to the client's
/// ``ResponseCache``.
///
/// Only `GET` and `HEAD` requests are cached, only `2xx` responses are stored, and a
/// response with `Cache-Control: no-store` is never stored.
public enum CachePolicy: Sendable, Hashable {
    /// The cache is neither read nor written. This is the default.
    case disabled

    /// A stored response younger than `maxAge` is returned without contacting the server;
    /// otherwise the request is sent and its response stored.
    case cacheFirst(maxAge: Duration)

    /// The request is always sent. When it fails because the device is offline or the
    /// server answers `5xx`, a stored response younger than `maxStale` is returned instead.
    case networkFirst(maxStale: Duration)

    /// The request is always sent, with `If-None-Match` and `If-Modified-Since` from the
    /// stored response. A `304 Not Modified` answer returns the stored body.
    case revalidate
}

/// A response stored in a ``ResponseCache``.
public struct CachedResponse: Sendable, Codable, Hashable {
    /// The body.
    public var data: Data
    /// The status code.
    public var statusCode: Int
    /// The response headers.
    public var headers: HTTPHeaders
    /// The URL of the response.
    public var url: URL?
    /// When the response was received or last revalidated.
    public var storedAt: Date

    /// Creates a stored response. You only need this to fill a cache yourself or in tests.
    public init(data: Data, statusCode: Int, headers: HTTPHeaders, url: URL?, storedAt: Date = Date()) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.url = url
        self.storedAt = storedAt
    }

    /// How old the response is at `now`.
    ///
    /// A response stored more than a minute "in the future", because the device clock was set
    /// back after it was stored, has an unknown age and counts as the oldest possible, so it is
    /// never treated as fresh.
    public func age(at now: Date = Date()) -> Duration {
        let seconds = now.timeIntervalSince(storedAt)
        guard seconds >= -Self.clockSkewTolerance else { return Self.longestAge }
        return Duration.clamped(seconds: seconds, max: Self.longestAge)
    }

    private static let clockSkewTolerance: TimeInterval = 60
    private static let longestAge = Duration.seconds(Int64(Int32.max))

    /// The `ETag` header.
    public var entityTag: String? { headers["ETag"] }

    /// The `Last-Modified` header.
    public var lastModified: String? { headers["Last-Modified"] }

    var httpResponse: HTTPResponse<Data> {
        HTTPResponse(value: data, statusCode: statusCode, headers: headers, url: url, source: .cache, attempts: 0)
    }
}

/// Storage for cached responses, keyed by a string derived from the request.
///
/// The package has three: ``MemoryResponseCache``, ``DiskResponseCache`` and
/// ``HybridResponseCache``. Set one as ``NetworkClient/Configuration/cache`` and choose a
/// ``CachePolicy`` per endpoint.
public protocol ResponseCache: Sendable {
    /// The response stored for `key`, if any.
    func cachedResponse(for key: String) async -> CachedResponse?
    /// Stores `response` for `key`, replacing any older one.
    func store(_ response: CachedResponse, for key: String) async
    /// Removes the response stored for `key`.
    func removeResponse(for key: String) async
    /// Removes every stored response.
    func removeAll() async
}

/// Builds cache keys from requests.
enum CacheKey {
    /// The method, the URL and the headers that change the response: `Accept`,
    /// `Accept-Language` and, hashed together, every credential header (each header whose
    /// name or value a ``Redactor`` would hide, such as `Authorization`, `Cookie`, `X-API-Key`
    /// or `X-Upstream: Bearer …`), so two users of one client never share a cached response.
    static func make(for request: URLRequest) -> String {
        var key = (request.httpMethod ?? "GET") + " " + (request.url?.absoluteString ?? "")
        for name in ["Accept", "Accept-Language"] {
            if let value = request.value(forHTTPHeaderField: name) {
                key += "\n\(name): \(value)"
            }
        }
        let credentials = (request.allHTTPHeaderFields ?? [:])
            .filter { Redactor.default.isSensitive($0.key) || Redactor.default.containsSecret($0.value) }
            .map { "\($0.key.lowercased()): \($0.value)" }
            .sorted()
        if !credentials.isEmpty {
            key += "\nCredentials: " + sha256(credentials.joined(separator: "\n"))
        }
        return key
    }

    static func sha256(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
