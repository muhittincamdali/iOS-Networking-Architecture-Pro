import Foundation

/// A decoded response together with its status code, headers and where it came from.
///
/// ``NetworkClient/send(_:)`` returns only the value; ``NetworkClient/response(for:)`` returns
/// this type when you also need the headers, for example a pagination link:
///
/// ```swift
/// let page = try await client.response(for: API.repositories(page: 2))
/// let next = page.headers["Link"]
/// ```
public struct HTTPResponse<Value: Sendable>: Sendable {
    /// The decoded body.
    public let value: Value

    /// The HTTP status code, such as `200`.
    public let statusCode: Int

    /// The response header fields.
    public let headers: HTTPHeaders

    /// The URL of the response, after any redirects.
    public let url: URL?

    /// Where the response came from.
    public let source: ResponseSource

    /// How many times the request was sent, including the first time. `0` when the response
    /// came from the cache without contacting the server.
    public let attempts: Int

    /// Creates a response. You only need this to build responses in tests.
    public init(
        value: Value,
        statusCode: Int,
        headers: HTTPHeaders = [:],
        url: URL? = nil,
        source: ResponseSource = .network,
        attempts: Int = 1
    ) {
        self.value = value
        self.statusCode = statusCode
        self.headers = headers
        self.url = url
        self.source = source
        self.attempts = attempts
    }

    /// Returns the same response with a different value.
    public func map<NewValue: Sendable>(_ transform: (Value) throws -> NewValue) rethrows -> HTTPResponse<NewValue> {
        HTTPResponse<NewValue>(
            value: try transform(value),
            statusCode: statusCode,
            headers: headers,
            url: url,
            source: source,
            attempts: attempts
        )
    }

    func with(source: ResponseSource, attempts: Int) -> HTTPResponse {
        HTTPResponse(value: value, statusCode: statusCode, headers: headers, url: url, source: source, attempts: attempts)
    }
}

/// Where a response came from.
public enum ResponseSource: Sendable, Hashable {
    /// The server sent it for this request.
    case network
    /// It was read from the client's ``ResponseCache`` without contacting the server.
    case cache
    /// The server answered `304 Not Modified`, so the cached body was used.
    case revalidatedCache
    /// The request failed and a stale cached response was used instead
    /// (``CachePolicy/networkFirst(maxStale:)``).
    case staleCache
}
