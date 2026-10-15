import Foundation

/// Sends requests for a ``NetworkClient``.
///
/// ``URLSessionTransport`` is the transport for apps. Tests use `MockTransport` from the
/// `NetworkingArchitectureTesting` library, and you can write your own to route requests
/// elsewhere. Only ``send(_:maximumResponseSize:)`` is required: the other methods have
/// default implementations built on it, which load the whole body before returning.
public protocol HTTPTransport: Sendable {
    /// Sends `request` and returns the complete body and the response.
    ///
    /// - Parameters:
    ///   - request: The request to send.
    ///   - maximumResponseSize: When not `nil`, stop reading and throw
    ///     ``NetworkError/responseTooLarge(limit:)`` once the body exceeds this many bytes.
    func send(_ request: URLRequest, maximumResponseSize: Int?) async throws -> (Data, HTTPURLResponse)

    /// Sends `request` and returns the response as soon as its headers arrive, with the body
    /// as a stream of chunks.
    ///
    /// The consumer may read the stream more slowly than the body arrives. An implementation
    /// should then stop reading instead of buffering without limit, as
    /// ``URLSessionTransport`` does (see ``URLSessionTransport/streamBufferLimit``).
    func stream(_ request: URLRequest) async throws -> (HTTPURLResponse, AsyncThrowingStream<Data, any Error>)

    /// Downloads the body of `request` into a temporary file that the caller then owns.
    func download(_ request: URLRequest, progress: ProgressHandler?) async throws -> (URL, HTTPURLResponse)

    /// Continues an interrupted download from the resume data of its error
    /// (`URLError.downloadTaskResumeData`) into a temporary file that the caller then owns.
    /// The default implementation throws ``NetworkError/invalidRequest(_:)``.
    func download(resumingFrom resumeData: Data, progress: ProgressHandler?) async throws -> (URL, HTTPURLResponse)

    /// Sends `request` with `body` as its body, reporting how much of it has been sent, and
    /// returns the complete response body.
    ///
    /// - Parameters:
    ///   - request: The request to send, without a body.
    ///   - body: The bytes or the file to send as the body.
    ///   - maximumResponseSize: When not `nil`, stop reading the response and throw
    ///     ``NetworkError/responseTooLarge(limit:)`` once its body exceeds this many bytes.
    ///   - progress: Called as the body is sent.
    func upload(
        _ request: URLRequest,
        body: UploadBody,
        maximumResponseSize: Int?,
        progress: ProgressHandler?
    ) async throws -> (Data, HTTPURLResponse)
}

/// The data to upload: bytes in memory or a file read by the transport as it sends.
public enum UploadBody: Sendable {
    case data(Data)
    case file(URL)

    var byteCount: Int64? {
        switch self {
        case .data(let data):
            Int64(data.count)
        case .file(let url):
            (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init)
        }
    }
}

/// How much of an upload or download has been transferred.
public struct TransferProgress: Sendable, Hashable {
    /// Bytes transferred so far.
    public let completedBytes: Int64

    /// The total size, if the server or the file reported it.
    public let totalBytes: Int64?

    /// Creates a progress value. Negative counts are treated as zero.
    public init(completedBytes: Int64, totalBytes: Int64?) {
        self.completedBytes = max(0, completedBytes)
        self.totalBytes = totalBytes.flatMap { $0 >= 0 ? $0 : nil }
    }

    /// The share transferred from 0 to 1, or `nil` when the total size is unknown.
    public var fractionCompleted: Double? {
        guard let totalBytes else { return nil }
        guard totalBytes > 0 else { return 1 }
        return min(1, Double(completedBytes) / Double(totalBytes))
    }
}

/// Receives progress updates during an upload or download. It is called on a background
/// queue; hop to the main actor before updating the UI.
public typealias ProgressHandler = @Sendable (TransferProgress) -> Void

extension HTTPTransport {
    public func stream(_ request: URLRequest) async throws -> (HTTPURLResponse, AsyncThrowingStream<Data, any Error>) {
        let (data, response) = try await send(request, maximumResponseSize: nil)
        let stream = AsyncThrowingStream<Data, any Error> { continuation in
            if !data.isEmpty {
                continuation.yield(data)
            }
            continuation.finish()
        }
        return (response, stream)
    }

    public func download(_ request: URLRequest, progress: ProgressHandler?) async throws -> (URL, HTTPURLResponse) {
        let (data, response) = try await send(request, maximumResponseSize: nil)
        let file = FileManager.default.temporaryDirectory
            .appendingPathComponent("download-\(UUID().uuidString)")
        try data.write(to: file)
        let size = Int64(data.count)
        progress?(TransferProgress(completedBytes: size, totalBytes: size))
        return (file, response)
    }

    public func download(resumingFrom resumeData: Data, progress: ProgressHandler?) async throws -> (URL, HTTPURLResponse) {
        throw NetworkError.invalidRequest("this transport cannot resume downloads")
    }

    public func upload(
        _ request: URLRequest,
        body: UploadBody,
        maximumResponseSize: Int?,
        progress: ProgressHandler?
    ) async throws -> (Data, HTTPURLResponse) {
        var request = request
        switch body {
        case .data(let data):
            request.httpBody = data
        case .file(let url):
            request.httpBody = try Data(contentsOf: url)
        }
        let result = try await send(request, maximumResponseSize: maximumResponseSize)
        let size = Int64(request.httpBody?.count ?? 0)
        progress?(TransferProgress(completedBytes: size, totalBytes: size))
        return result
    }
}
