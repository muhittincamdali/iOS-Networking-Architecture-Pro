import Foundation

/// Turns an ``Endpoint`` into a `URLRequest`.
enum URLRequestBuilder {
    /// Characters left unencoded in a query name or value: the RFC 3986 unreserved set.
    /// Everything else, including `+`, `&`, `=` and `/`, is percent-encoded.
    private static let queryAllowed = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )

    static func makeRequest<Response>(
        for endpoint: Endpoint<Response>,
        baseURL: URL?,
        defaultHeaders: HTTPHeaders,
        encoder: JSONEncoder
    ) throws -> URLRequest {
        let url = try makeURL(path: endpoint.path, query: endpoint.query, baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        var headers = defaultHeaders
        if let body = endpoint.body {
            do {
                request.httpBody = try body.data(using: encoder)
            } catch {
                throw NetworkError.encodingFailed(error)
            }
            if let contentType = body.contentType {
                headers["Content-Type"] = contentType
            }
        }
        headers.merge(endpoint.headers)
        if let unsafe = headers.firstUnsafeField {
            throw NetworkError.invalidRequest("the header \"\(unsafe)\" is empty or contains a line break")
        }
        for field in headers {
            request.setValue(field.value, forHTTPHeaderField: field.name)
        }

        if let timeout = endpoint.timeout {
            request.timeoutInterval = try timeoutInterval(timeout)
        }
        return request
    }

    static func makeURL(path: String, query: [URLQueryItem], baseURL: URL?) throws -> URL {
        var components: URLComponents
        if let absolute = absoluteComponents(path) {
            components = absolute
        } else {
            guard let baseURL, var base = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
                throw NetworkError.invalidRequest("\"\(path)\" is not a full URL and the client has no base URL")
            }
            let (pathPart, queryPart) = split(path)
            base.path = join(base.path, pathPart)
            if let queryPart {
                base.percentEncodedQuery = [base.percentEncodedQuery, queryPart]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: "&")
            }
            components = base
        }
        if !query.isEmpty {
            let encoded = query.map(encode).joined(separator: "&")
            let existing = components.percentEncodedQuery.flatMap { $0.isEmpty ? nil : $0 }
            components.percentEncodedQuery = [existing, encoded].compactMap { $0 }.joined(separator: "&")
        }
        guard let url = components.url, url.scheme != nil, url.host != nil else {
            throw NetworkError.invalidRequest("\"\(path)\" does not form a valid URL")
        }
        return url
    }

    static func encode(_ item: URLQueryItem) -> String {
        let name = item.name.addingPercentEncoding(withAllowedCharacters: queryAllowed) ?? ""
        guard let value = item.value else { return name }
        return name + "=" + (value.addingPercentEncoding(withAllowedCharacters: queryAllowed) ?? "")
    }

    /// Converts a timeout to seconds, rejecting zero, negative and non-finite values
    /// instead of passing them to `URLRequest`.
    static func timeoutInterval(_ duration: Duration) throws -> TimeInterval {
        let seconds = duration.timeInterval
        guard seconds.isFinite, seconds > 0 else {
            throw NetworkError.invalidRequest("the timeout must be longer than zero")
        }
        return seconds
    }

    private static func absoluteComponents(_ path: String) -> URLComponents? {
        let lowercased = path.lowercased()
        guard lowercased.hasPrefix("http://") || lowercased.hasPrefix("https://")
            || lowercased.hasPrefix("ws://") || lowercased.hasPrefix("wss://") else { return nil }
        return URLComponents(string: path)
    }

    private static func split(_ path: String) -> (path: String, query: String?) {
        guard let index = path.firstIndex(of: "?") else { return (path, nil) }
        return (String(path[..<index]), String(path[path.index(after: index)...]))
    }

    private static func join(_ base: String, _ path: String) -> String {
        guard !path.isEmpty else { return base }
        let trimmedBase = base.hasSuffix("/") ? String(base.dropLast()) : base
        let trimmedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return trimmedBase + "/" + trimmedPath
    }
}

extension Duration {
    /// The duration in seconds as a floating-point number.
    var timeInterval: TimeInterval {
        let (seconds, attoseconds) = components
        return TimeInterval(seconds) + TimeInterval(attoseconds) / 1e18
    }

    /// Creates a duration from seconds, clamping non-finite and out-of-range values so the
    /// conversion cannot trap. NaN and negative values become zero.
    static func clamped(seconds: Double, max: Duration) -> Duration {
        // Int64 nanoseconds reach about 9.2e9 seconds; stay below that before multiplying.
        let maxSeconds = Swift.min(max.timeInterval, 9.0e9)
        guard seconds.isFinite, seconds > 0 else { return seconds == .infinity ? max : .zero }
        guard seconds < maxSeconds else { return max }
        return .nanoseconds(Int64(seconds * 1e9))
    }
}
