import Foundation

/// A description of one HTTP request and the type its response decodes to.
///
/// Describe each call of your API once, then send it with a ``NetworkClient``:
///
/// ```swift
/// enum API {
///     static func user(id: Int) -> Endpoint<User> {
///         .get("users/\(id)")
///     }
///
///     static func createUser(_ user: NewUser) -> Endpoint<User> {
///         .post("users", body: .json(user))
///     }
///
///     static func deleteUser(id: Int) -> Endpoint<Void> {
///         .delete("users/\(id)")
///     }
/// }
///
/// let user = try await client.send(API.user(id: 42))
/// ```
///
/// The path is resolved against the client's base URL by appending it, so `"users/42"` on a
/// base URL of `https://api.example.com/v1` requests `https://api.example.com/v1/users/42`.
/// A path that is a full URL (`https://…`) is used as it is.
///
/// `Response` decides how the body is read:
/// - a `Decodable` type is decoded from JSON with the client's decoder;
/// - `Data` returns the body unchanged;
/// - `Void` ignores the body.
public struct Endpoint<Response: Sendable>: Sendable {
    /// The request method.
    public var method: HTTPMethod

    /// The path appended to the client's base URL, or a full URL. Write it unencoded:
    /// `"search/swift concurrency"` is sent as `search/swift%20concurrency`. Wrap user input
    /// in ``PathSegment`` so it cannot add segments or a query.
    public var path: String

    /// The query items. A `+` in a value is sent as `%2B`, so servers do not read it as a space.
    public var query: [URLQueryItem]

    /// Header fields sent with this request, in addition to the client's default headers.
    public var headers: HTTPHeaders

    /// The request body.
    public var body: RequestBody?

    /// How long to wait for the server before the request fails with a timeout. `nil` uses
    /// the transport's timeout.
    public var timeout: Duration?

    /// Status codes treated as success. Any other code throws
    /// ``NetworkError/unacceptableStatusCode(_:_:)``.
    public var acceptableStatusCodes: Set<Int>

    /// Whether and how the response is cached. See ``CachePolicy``.
    public var cachePolicy: CachePolicy

    /// Overrides the client's ``RetryPolicy`` for this endpoint. `nil` uses the client's.
    public var retryPolicy: RetryPolicy?

    let decode: @Sendable (Data, JSONDecoder) throws -> Response

    /// Creates an endpoint that reads its response with `decode`.
    public init(
        method: HTTPMethod,
        path: String,
        query: [URLQueryItem] = [],
        headers: HTTPHeaders = [:],
        body: RequestBody? = nil,
        timeout: Duration? = nil,
        acceptableStatusCodes: Set<Int> = Endpoint.successCodes,
        cachePolicy: CachePolicy = .disabled,
        retryPolicy: RetryPolicy? = nil,
        decode: @escaping @Sendable (Data, JSONDecoder) throws -> Response
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
        self.timeout = timeout
        self.acceptableStatusCodes = acceptableStatusCodes
        self.cachePolicy = cachePolicy
        self.retryPolicy = retryPolicy
        self.decode = decode
    }

    /// The status codes 200 to 299.
    public static var successCodes: Set<Int> { Set(200..<300) }

    /// Returns a copy with one property changed, for chaining:
    /// `API.user(id: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(60)))`.
    public func with<Value>(_ keyPath: WritableKeyPath<Endpoint, Value>, _ value: Value) -> Endpoint {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }

    /// Returns an endpoint that sends the same request and transforms the decoded response.
    public func map<NewResponse: Sendable>(
        _ transform: @escaping @Sendable (Response) throws -> NewResponse
    ) -> Endpoint<NewResponse> {
        let decode = self.decode
        return Endpoint<NewResponse>(
            method: method, path: path, query: query, headers: headers, body: body,
            timeout: timeout, acceptableStatusCodes: acceptableStatusCodes,
            cachePolicy: cachePolicy, retryPolicy: retryPolicy
        ) { data, decoder in
            try transform(decode(data, decoder))
        }
    }
}

extension Endpoint where Response: Decodable {
    /// Creates an endpoint whose response is decoded from JSON (or returned unchanged when
    /// `Response` is `Data`).
    public init(
        method: HTTPMethod,
        path: String,
        query: [URLQueryItem] = [],
        headers: HTTPHeaders = [:],
        body: RequestBody? = nil
    ) {
        self.init(method: method, path: path, query: query, headers: headers, body: body) { data, decoder in
            if let data = data as? Response {
                return data
            }
            return try decoder.decode(Response.self, from: data)
        }
    }

    /// A `GET` request.
    public static func get(_ path: String, query: [URLQueryItem] = [], headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .get, path: path, query: query, headers: headers)
    }

    /// A `POST` request.
    public static func post(_ path: String, body: RequestBody? = nil, headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .post, path: path, headers: headers, body: body)
    }

    /// A `PUT` request.
    public static func put(_ path: String, body: RequestBody? = nil, headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .put, path: path, headers: headers, body: body)
    }

    /// A `PATCH` request.
    public static func patch(_ path: String, body: RequestBody? = nil, headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .patch, path: path, headers: headers, body: body)
    }

    /// A `DELETE` request.
    public static func delete(_ path: String, query: [URLQueryItem] = [], headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .delete, path: path, query: query, headers: headers)
    }
}

extension Endpoint where Response == Void {
    /// Creates an endpoint whose response body is ignored.
    public init(
        method: HTTPMethod,
        path: String,
        query: [URLQueryItem] = [],
        headers: HTTPHeaders = [:],
        body: RequestBody? = nil
    ) {
        self.init(method: method, path: path, query: query, headers: headers, body: body) { _, _ in () }
    }

    /// A `GET` request whose body is ignored.
    public static func get(_ path: String, query: [URLQueryItem] = [], headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .get, path: path, query: query, headers: headers)
    }

    /// A `HEAD` request.
    public static func head(_ path: String, query: [URLQueryItem] = [], headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .head, path: path, query: query, headers: headers)
    }

    /// A `POST` request whose response body is ignored.
    public static func post(_ path: String, body: RequestBody? = nil, headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .post, path: path, headers: headers, body: body)
    }

    /// A `PUT` request whose response body is ignored.
    public static func put(_ path: String, body: RequestBody? = nil, headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .put, path: path, headers: headers, body: body)
    }

    /// A `PATCH` request whose response body is ignored.
    public static func patch(_ path: String, body: RequestBody? = nil, headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .patch, path: path, headers: headers, body: body)
    }

    /// A `DELETE` request whose response body is ignored.
    public static func delete(_ path: String, query: [URLQueryItem] = [], headers: HTTPHeaders = [:]) -> Endpoint {
        Endpoint(method: .delete, path: path, query: query, headers: headers)
    }
}
