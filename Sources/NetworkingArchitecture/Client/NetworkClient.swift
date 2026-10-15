import Foundation

/// Sends ``Endpoint``s and decodes their responses.
///
/// ```swift
/// let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!)
///
/// let user = try await client.send(Endpoint<User>.get("users/42"))
/// ```
///
/// For every request the client builds a `URLRequest` from the endpoint, lets each
/// ``RequestInterceptor`` adapt it, sends it through its ``HTTPTransport``, checks the status
/// code, and retries failures that the interceptors or the ``RetryPolicy`` allow, at most
/// ``RetryPolicy/attemptLimit`` times. ``NetworkEventMonitor``s see every step.
///
/// A client holds no mutable state, so one instance can be shared by the whole app and used
/// from any task.
public final class NetworkClient: Sendable {
    /// The settings the client was created with.
    public let configuration: Configuration

    /// The transport that sends the requests.
    public let transport: any HTTPTransport

    /// Creates a client.
    ///
    /// - Parameters:
    ///   - baseURL: The URL that endpoint paths are appended to. It replaces
    ///     `configuration.baseURL` when not `nil`.
    ///   - configuration: Headers, coders, interceptors and policies.
    ///   - transport: How requests are sent. The default uses `URLSession.shared`.
    public init(
        baseURL: URL? = nil,
        configuration: Configuration = Configuration(),
        transport: any HTTPTransport = URLSessionTransport()
    ) {
        var configuration = configuration
        if let baseURL {
            configuration.baseURL = baseURL
        }
        self.configuration = configuration
        self.transport = transport
    }

    /// Sends `endpoint` and returns its decoded response.
    ///
    /// - Throws: ``NetworkError``, or the error an interceptor threw.
    @discardableResult
    public func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        try await response(for: endpoint).value
    }

    /// Sends `endpoint` and returns its decoded response with the status code and headers.
    public func response<Response>(for endpoint: Endpoint<Response>) async throws -> HTTPResponse<Response> {
        let request = try makeRequest(for: endpoint)
        if let cache = configuration.cache, endpoint.cachePolicy != .disabled,
           endpoint.method == .get || endpoint.method == .head {
            return try decode(try await cachedResponse(for: request, endpoint: endpoint, cache: cache), for: endpoint)
        }
        let result = try await perform(request, endpoint: endpoint) { request in
            try await self.transport.send(request, maximumResponseSize: self.configuration.maximumResponseSize)
        }
        return try decode(result.response, for: endpoint)
    }

    /// Sends `endpoint` as an upload and decodes the response. `progress` is called as the
    /// body is sent.
    ///
    /// - Parameter file: A file to send as the body, read as it is sent instead of being
    ///   loaded into memory. When `nil`, the endpoint's own body is sent. With a file, the
    ///   `Content-Type` of the endpoint's body (if any) is still used.
    ///
    /// A failed upload is retried like any request, starting from the first byte.
    public func upload<Response>(
        _ endpoint: Endpoint<Response>,
        file: URL? = nil,
        progress: ProgressHandler? = nil
    ) async throws -> HTTPResponse<Response> {
        var request = try makeRequest(for: endpoint)
        let body: UploadBody = if let file { .file(file) } else { .data(request.httpBody ?? Data()) }
        request.httpBody = nil
        let result = try await perform(request, endpoint: endpoint) { request in
            try await self.transport.upload(request, body: body, progress: progress)
        }
        return try decode(result.response, for: endpoint)
    }

    /// Downloads the body of `endpoint` to `destination`, replacing any file there, and
    /// returns the response with the file URL. `progress` is called as the body arrives.
    ///
    /// The file at `destination` is only replaced once a response with an accepted status
    /// code has been downloaded completely.
    @discardableResult
    public func download(
        _ endpoint: Endpoint<Void>,
        to destination: URL,
        progress: ProgressHandler? = nil
    ) async throws -> HTTPResponse<URL> {
        let request = try makeRequest(for: endpoint)
        let result = try await perform(request, endpoint: endpoint, errorBody: Self.readErrorBody) { request in
            try await self.transport.download(request, progress: progress)
        }
        let file = result.response.value
        do {
            let manager = FileManager.default
            try manager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            if manager.fileExists(atPath: destination.path) {
                _ = try manager.replaceItemAt(destination, withItemAt: file)
            } else {
                try manager.moveItem(at: file, to: destination)
            }
        } catch {
            try? FileManager.default.removeItem(at: file)
            throw NetworkError.transport(URLError(.cannotMoveFile, userInfo: [NSUnderlyingErrorKey: error]))
        }
        return result.response.map { _ in destination }
    }

    // MARK: - Building and decoding

    func makeRequest<Response>(for endpoint: Endpoint<Response>) throws -> URLRequest {
        try URLRequestBuilder.makeRequest(
            for: endpoint,
            baseURL: configuration.baseURL,
            defaultHeaders: configuration.headers,
            encoder: configuration.encoder
        )
    }

    func decode<Response>(_ response: HTTPResponse<Data>, for endpoint: Endpoint<Response>) throws -> HTTPResponse<Response> {
        do {
            return try response.map { try endpoint.decode($0, configuration.decoder) }
        } catch {
            throw NetworkError.decodingFailed(error, response)
        }
    }

    /// Reads at most 64 KB of a downloaded error response, then deletes the file.
    private static func readErrorBody(_ file: URL) -> Data {
        defer { try? FileManager.default.removeItem(at: file) }
        guard let handle = try? FileHandle(forReadingFrom: file) else { return Data() }
        defer { try? handle.close() }
        return (try? handle.read(upToCount: 64 * 1024)) ?? Data()
    }
}
