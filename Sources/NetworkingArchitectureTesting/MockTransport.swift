import Foundation
import NetworkingArchitecture

/// An ``HTTPTransport`` that answers from canned responses instead of the network, for
/// tests, previews and offline demos.
///
/// Register an answer per method and path; a path matches the end of the request path, so
/// `"users/1"` answers `https://api.example.com/v1/users/1`. When several responses are
/// registered for one route they are used in order and the last one repeats, which is how
/// you script a server that fails twice and then succeeds:
///
/// ```swift
/// let transport = MockTransport()
/// transport.register(.get, "users/1", .status(503), .status(503), try .json(user))
///
/// let client = NetworkClient(baseURL: apiURL, transport: transport)
/// let loaded = try await client.send(Endpoint<User>.get("users/1"))
/// #expect(transport.requests.count == 3)
/// ```
///
/// Requests without a route get a `404`. For full control, create the transport with a
/// handler that builds each response from the request.
public final class MockTransport: HTTPTransport, @unchecked Sendable {
    private struct Route {
        let method: HTTPMethod
        let path: String
        var responses: [MockResponse]
    }

    private struct State {
        var routes: [Route] = []
        var requests: [URLRequest] = []
    }

    private let lock = NSLock()
    private var state = State()
    private let handler: (@Sendable (URLRequest) async throws -> MockResponse)?

    /// Creates a transport that answers from registered routes.
    public init() {
        self.handler = nil
    }

    /// Creates a transport that answers every request with the response `handler` returns.
    public init(handler: @escaping @Sendable (URLRequest) async throws -> MockResponse) {
        self.handler = handler
    }

    /// Answers requests with `method` whose path ends with `path`. With several responses,
    /// each request takes the next one and the last one repeats. Registering the same route
    /// again replaces it.
    public func register(_ method: HTTPMethod = .get, _ path: String, _ responses: MockResponse...) {
        let route = Route(method: method, path: Self.trimmed(path), responses: responses)
        withState { state in
            state.routes.removeAll { $0.method == route.method && $0.path == route.path }
            state.routes.append(route)
        }
    }

    /// Every request received so far, in order, with its body in `httpBody`.
    public var requests: [URLRequest] {
        withState { $0.requests }
    }

    /// Forgets the recorded requests and the registered routes.
    public func reset() {
        withState { $0 = State() }
    }

    public func send(_ request: URLRequest, maximumResponseSize: Int?) async throws -> (Data, HTTPURLResponse) {
        let mock = try await answer(request)
        if let limit = maximumResponseSize, mock.body.count > limit {
            throw NetworkError.responseTooLarge(limit: limit)
        }
        return (mock.body, try httpResponse(mock, for: request))
    }

    public func stream(_ request: URLRequest) async throws -> (HTTPURLResponse, AsyncThrowingStream<Data, any Error>) {
        let mock = try await answer(request)
        let response = try httpResponse(mock, for: request)
        let chunks = mock.chunks
        let pause = mock.chunkDelay
        let stream = AsyncThrowingStream<Data, any Error> { continuation in
            let task = Task {
                for (index, chunk) in chunks.enumerated() {
                    if index > 0, pause > .zero {
                        try? await Pause.sleep(for: pause)
                    }
                    guard !Task.isCancelled else { break }
                    continuation.yield(chunk)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
        return (response, stream)
    }

    private func answer(_ request: URLRequest) async throws -> MockResponse {
        withState { $0.requests.append(request) }
        let mock: MockResponse
        if let handler {
            mock = try await handler(request)
        } else {
            mock = nextResponse(for: request)
        }
        if mock.delay > .zero {
            try await Pause.sleep(for: mock.delay)
        }
        if let error = mock.error {
            throw error
        }
        return mock
    }

    private func nextResponse(for request: URLRequest) -> MockResponse {
        let method = HTTPMethod(rawValue: request.httpMethod ?? "GET")
        let path = Self.trimmed(request.url?.path ?? "")
        return withState { state in
            guard let index = state.routes.lastIndex(where: { route in
                route.method == method && (path == route.path || path.hasSuffix("/" + route.path))
            }) else {
                return MockResponse(statusCode: 404, body: Data("No mock for \(method) /\(path)".utf8))
            }
            let responses = state.routes[index].responses
            guard let first = responses.first else { return .status(204) }
            if responses.count > 1 {
                state.routes[index].responses.removeFirst()
            }
            return first
        }
    }

    private func httpResponse(_ mock: MockResponse, for request: URLRequest) throws -> HTTPURLResponse {
        guard let url = request.url,
              let response = HTTPURLResponse(
                url: url, statusCode: mock.statusCode, httpVersion: "HTTP/1.1", headerFields: mock.headers.dictionary
              ) else {
            throw NetworkError.invalidResponse
        }
        return response
    }

    private func withState<Result>(_ body: (inout State) -> Result) -> Result {
        lock.lock()
        defer { lock.unlock() }
        return body(&state)
    }

    private static func trimmed(_ path: String) -> String {
        var path = path
        while path.hasPrefix("/") { path.removeFirst() }
        while path.hasSuffix("/") { path.removeLast() }
        return path
    }
}
