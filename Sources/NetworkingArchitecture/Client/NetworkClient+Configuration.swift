import Foundation

extension NetworkClient {
    /// The settings of a ``NetworkClient``.
    ///
    /// ```swift
    /// var configuration = NetworkClient.Configuration()
    /// configuration.headers["X-Client-Version"] = "2.0"
    /// configuration.decoder.keyDecodingStrategy = .convertFromSnakeCase
    /// configuration.interceptors = [authenticator]
    /// configuration.cache = HybridResponseCache()
    ///
    /// let client = NetworkClient(baseURL: apiURL, configuration: configuration)
    /// ```
    public struct Configuration: Sendable {
        /// The URL that endpoint paths are appended to.
        public var baseURL: URL?

        /// Headers sent with every request. An endpoint's headers replace fields with the same
        /// name. The default asks for JSON.
        public var headers: HTTPHeaders

        /// Encodes ``RequestBody/json(_:encoder:)`` bodies.
        public var encoder: JSONEncoder

        /// Decodes `Decodable` responses.
        public var decoder: JSONDecoder

        /// Adapt and retry requests, in this order. See ``RequestInterceptor``.
        public var interceptors: [any RequestInterceptor]

        /// Observe every request, for logging or metrics.
        public var monitors: [any NetworkEventMonitor]

        /// Retries for endpoints that do not set their own ``Endpoint/retryPolicy``.
        public var retryPolicy: RetryPolicy

        /// Where responses are cached for endpoints whose ``Endpoint/cachePolicy`` is not
        /// ``CachePolicy/disabled``. `nil` turns caching off for every endpoint.
        public var cache: (any ResponseCache)?

        /// The largest response body read into memory, in bytes; a larger one fails with
        /// ``NetworkError/responseTooLarge(limit:)`` instead of exhausting memory. `nil` reads
        /// any size. Downloads are written to disk and are not limited. The default is 50 MB.
        public var maximumResponseSize: Int?

        /// Creates a configuration. See the properties for what each value means.
        public init(
            baseURL: URL? = nil,
            headers: HTTPHeaders = ["Accept": "application/json"],
            encoder: JSONEncoder = JSONEncoder(),
            decoder: JSONDecoder = JSONDecoder(),
            interceptors: [any RequestInterceptor] = [],
            monitors: [any NetworkEventMonitor] = [],
            retryPolicy: RetryPolicy = .default,
            cache: (any ResponseCache)? = nil,
            maximumResponseSize: Int? = 50 * 1024 * 1024
        ) {
            self.baseURL = baseURL
            self.headers = headers
            self.encoder = encoder
            self.decoder = decoder
            self.interceptors = interceptors
            self.monitors = monitors
            self.retryPolicy = retryPolicy
            self.cache = cache
            self.maximumResponseSize = maximumResponseSize
        }
    }
}
