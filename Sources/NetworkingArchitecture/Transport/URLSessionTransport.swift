import Foundation

/// An ``HTTPTransport`` that sends requests with a `URLSession`.
///
/// Each request gets its own task delegate, so the transport can stop reading a body that
/// grows past ``NetworkClient/Configuration/maximumResponseSize``, hand out a streamed body
/// chunk by chunk, and report upload and download progress, while the session's own
/// delegate (for example a ``PinningSessionDelegate``) still answers authentication
/// challenges.
public struct URLSessionTransport: HTTPTransport {
    /// The session the requests are sent with.
    public let session: URLSession

    /// Creates a transport that sends requests with `session`.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest, maximumResponseSize: Int?) async throws -> (Data, HTTPURLResponse) {
        let delegate = BufferingTaskDelegate(limit: maximumResponseSize, progress: nil)
        return try await delegate.run(session.dataTask(with: request))
    }

    public func upload(
        _ request: URLRequest,
        body: UploadBody,
        progress: ProgressHandler?
    ) async throws -> (Data, HTTPURLResponse) {
        let delegate = BufferingTaskDelegate(limit: nil, progress: progress)
        let task = switch body {
        case .data(let data): session.uploadTask(with: request, from: data)
        case .file(let url): session.uploadTask(with: request, fromFile: url)
        }
        return try await delegate.run(task)
    }

    public func stream(_ request: URLRequest) async throws -> (HTTPURLResponse, AsyncThrowingStream<Data, any Error>) {
        let delegate = StreamingTaskDelegate()
        return try await delegate.run(session.dataTask(with: request))
    }

    public func download(_ request: URLRequest, progress: ProgressHandler?) async throws -> (URL, HTTPURLResponse) {
        let delegate = DownloadTaskDelegate(progress: progress)
        return try await delegate.run(session.downloadTask(with: request))
    }
}

/// Runs a task until it completes, cancelling it when the calling task is cancelled.
private func runTask<Result: Sendable>(
    _ task: URLSessionTask,
    start: (CheckedContinuation<Result, any Error>) -> Void
) async throws -> Result {
    try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            start(continuation)
            task.resume()
        }
    } onCancel: {
        task.cancel()
    }
}

/// Replaces the `cancelled` error of a task whose server ``PinningSessionDelegate`` rejected
/// with `serverCertificateUntrusted`, so a pinning failure is not mistaken for a cancellation.
private func completionError(_ error: (any Error)?, session: URLSession, task: URLSessionTask) -> (any Error)? {
    guard let pinning = session.delegate as? PinningSessionDelegate,
          let reason = pinning.takeRejection(for: task) else {
        return error
    }
    return URLError(.serverCertificateUntrusted, userInfo: [NSLocalizedDescriptionKey: "The server was rejected by certificate pinning (\(reason))."])
}

private func httpResponse(_ response: URLResponse?) throws -> HTTPURLResponse {
    guard let response = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
    return response
}

/// Collects a body in memory, up to an optional limit.
private final class BufferingTaskDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private struct State {
        var continuation: CheckedContinuation<(Data, HTTPURLResponse), any Error>?
        var data = Data()
        var failure: (any Error)?
    }

    private let limit: Int?
    private let progress: ProgressHandler?
    private let state = Locked(State())

    init(limit: Int?, progress: ProgressHandler?) {
        self.limit = limit.map { max(0, $0) }
        self.progress = progress
    }

    func run(_ task: URLSessionTask) async throws -> (Data, HTTPURLResponse) {
        task.delegate = self
        return try await runTask(task) { continuation in
            state.withLock { $0.continuation = continuation }
        }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void
    ) {
        if let limit, response.expectedContentLength > Int64(limit) {
            state.withLock { $0.failure = NetworkError.responseTooLarge(limit: limit) }
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let exceeded = state.withLock { state -> Bool in
            state.data.append(data)
            guard let limit, state.data.count > limit else { return false }
            state.failure = NetworkError.responseTooLarge(limit: limit)
            state.data = Data()
            return true
        }
        if exceeded {
            dataTask.cancel()
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        progress?(TransferProgress(completedBytes: totalBytesSent, totalBytes: totalBytesExpectedToSend))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let error = completionError(error, session: session, task: task)
        let (continuation, data, failure) = state.withLock { state in
            defer { state.continuation = nil }
            return (state.continuation, state.data, state.failure ?? error)
        }
        if let failure {
            continuation?.resume(throwing: failure)
            return
        }
        continuation?.resume(with: Result { (data, try httpResponse(task.response)) })
    }
}

/// Hands out a body chunk by chunk as it arrives.
private final class StreamingTaskDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    typealias Output = (HTTPURLResponse, AsyncThrowingStream<Data, any Error>)

    private struct State {
        var headers: CheckedContinuation<Output, any Error>?
        var body: AsyncThrowingStream<Data, any Error>.Continuation?
    }

    private let state = Locked(State())

    func run(_ task: URLSessionDataTask) async throws -> Output {
        task.delegate = self
        return try await runTask(task) { continuation in
            state.withLock { $0.headers = continuation }
        }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void
    ) {
        guard let response = response as? HTTPURLResponse else {
            completionHandler(.cancel)
            return
        }
        let (stream, continuation) = AsyncThrowingStream<Data, any Error>.makeStream()
        continuation.onTermination = { termination in
            if case .cancelled = termination {
                dataTask.cancel()
            }
        }
        let headers = state.withLock { state in
            defer { state.headers = nil }
            state.body = continuation
            return state.headers
        }
        completionHandler(.allow)
        headers?.resume(returning: (response, stream))
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        _ = state.withLock { $0.body }?.yield(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let error = completionError(error, session: session, task: task)
        let (headers, body) = state.withLock { state in
            defer {
                state.headers = nil
                state.body = nil
            }
            return (state.headers, state.body)
        }
        headers?.resume(throwing: error ?? NetworkError.invalidResponse)
        body?.finish(throwing: error)
    }
}

/// Writes a body to a temporary file and reports progress.
private final class DownloadTaskDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    private struct State {
        var continuation: CheckedContinuation<(URL, HTTPURLResponse), any Error>?
        var file: URL?
        var failure: (any Error)?
    }

    private let progress: ProgressHandler?
    private let state = Locked(State())

    init(progress: ProgressHandler?) {
        self.progress = progress
    }

    func run(_ task: URLSessionDownloadTask) async throws -> (URL, HTTPURLResponse) {
        task.delegate = self
        return try await runTask(task) { continuation in
            state.withLock { $0.continuation = continuation }
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        progress?(TransferProgress(completedBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // The system deletes `location` when this method returns, so move it now.
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("download-\(UUID().uuidString)")
        do {
            try FileManager.default.moveItem(at: location, to: file)
            state.withLock { $0.file = file }
        } catch {
            state.withLock { $0.failure = error }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let error = completionError(error, session: session, task: task)
        let (continuation, file, failure) = state.withLock { state in
            defer { state.continuation = nil }
            return (state.continuation, state.file, state.failure ?? error)
        }
        if let failure {
            if let file {
                try? FileManager.default.removeItem(at: file)
            }
            continuation?.resume(throwing: failure)
            return
        }
        continuation?.resume(with: Result {
            guard let file else { throw NetworkError.invalidResponse }
            return (file, try httpResponse(task.response))
        })
    }
}
