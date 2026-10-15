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

    /// Sends `endpoint` as an upload and decodes the response.
    ///
    /// A failed upload is retried like any request, starting from the first byte.
    ///
    /// - Parameters:
    ///   - endpoint: The request to send; its body is uploaded unless you pass `file`.
    ///   - file: A file to send as the body, read as it is sent instead of being loaded into
    ///     memory. With a file, the `Content-Type` of the endpoint's body (if any) is still
    ///     used.
    ///   - progress: Called as the body is sent.
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
    /// returns the response with the file URL.
    ///
    /// The file at `destination` is only replaced once a response with an accepted status
    /// code has been downloaded completely.
    ///
    /// When the connection drops and the server supports resuming, the retry continues from
    /// where the download stopped instead of starting again. When the download fails for
    /// good, ``NetworkError/resumeData`` holds the data to continue it later with
    /// `resumingFrom`. A resumed attempt sends the request as it was first sent, without
    /// running the interceptors again.
    ///
    /// - Parameters:
    ///   - endpoint: The request to send.
    ///   - destination: Where to put the file. Missing folders are created.
    ///   - resumeData: The ``NetworkError/resumeData`` of an earlier, interrupted download of
    ///     the same endpoint.
    ///   - progress: Called as the body arrives.
    @discardableResult
    public func download(
        _ endpoint: Endpoint<Void>,
        to destination: URL,
        resumingFrom resumeData: Data? = nil,
        progress: ProgressHandler? = nil
    ) async throws -> HTTPResponse<URL> {
        let request = try makeRequest(for: endpoint)
        let resume = Locked(resumeData)
        let result = try await perform(request, endpoint: endpoint, errorBody: Self.readErrorBody) { request in
            do {
                if let data = resume.withLock({ $0 }) {
                    return try await self.transport.download(resumingFrom: data, progress: progress)
                }
                return try await self.transport.download(request, progress: progress)
            } catch let error as URLError {
                // The next attempt continues from here, or starts again when there is nothing to resume.
                resume.withLock { $0 = error.downloadTaskResumeData }
                throw error
            }
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

    /// The `URLRequest` the client builds for `endpoint`, before the interceptors adapt it.
    /// Useful for debugging, for example with ``Foundation/URLRequest/curlCommand(redactor:)``.
    public func urlRequest<Response>(for endpoint: Endpoint<Response>) throws -> URLRequest {
        try makeRequest(for: endpoint)
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
