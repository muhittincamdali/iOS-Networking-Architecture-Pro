import Foundation

/// An ``HTTPTransport`` that sends requests with a `URLSession`.
///
/// Each request gets its own task delegate, so the transport can stop reading a body that
/// grows past ``NetworkClient/Configuration/maximumResponseSize``, hand out a streamed body
/// chunk by chunk, and report upload and download progress, while the session's own
/// delegate (for example a ``PinningSessionDelegate``) still answers authentication
/// challenges. Redirects follow a ``RedirectPolicy``.
public struct URLSessionTransport: HTTPTransport {
    /// The session the requests are sent with.
    public let session: URLSession

    /// How redirects are handled.
    public let redirectPolicy: RedirectPolicy

    /// How many bytes of a streamed body may wait for a slow consumer. When they are
    /// reached, the transport stops reading from the network until half of them have been
    /// read, so memory stays bounded and nothing is dropped.
    public let streamBufferLimit: Int

    /// Creates a transport that sends requests with `session`.
    ///
    /// - Parameters:
    ///   - session: The session the requests are sent with.
    ///   - redirectPolicy: How redirects are handled.
    ///   - streamBufferLimit: How many bytes of a streamed body may wait for the consumer,
    ///     at least 1. The default is 1 MB.
    public init(
        session: URLSession = .shared,
        redirectPolicy: RedirectPolicy = .followSafely,
        streamBufferLimit: Int = 1024 * 1024
    ) {
        self.session = session
        self.redirectPolicy = redirectPolicy
        self.streamBufferLimit = max(1, streamBufferLimit)
    }

    public func send(_ request: URLRequest, maximumResponseSize: Int?) async throws -> (Data, HTTPURLResponse) {
        let delegate = BufferingTaskDelegate(limit: maximumResponseSize, progress: nil, redirectPolicy: redirectPolicy)
        return try await delegate.run(session.dataTask(with: request))
    }

    public func upload(
        _ request: URLRequest,
        body: UploadBody,
        maximumResponseSize: Int?,
        progress: ProgressHandler?
    ) async throws -> (Data, HTTPURLResponse) {
        let delegate = BufferingTaskDelegate(limit: maximumResponseSize, progress: progress, redirectPolicy: redirectPolicy)
        let task = switch body {
        case .data(let data): session.uploadTask(with: request, from: data)
        case .file(let url): session.uploadTask(with: request, fromFile: url)
        }
        return try await delegate.run(task)
    }

    public func stream(_ request: URLRequest) async throws -> (HTTPURLResponse, AsyncThrowingStream<Data, any Error>) {
        let delegate = StreamingTaskDelegate(bufferLimit: streamBufferLimit, redirectPolicy: redirectPolicy)
        return try await delegate.run(session.dataTask(with: request))
    }

    public func download(_ request: URLRequest, progress: ProgressHandler?) async throws -> (URL, HTTPURLResponse) {
        let delegate = DownloadTaskDelegate(progress: progress, redirectPolicy: redirectPolicy)
        return try await delegate.run(session.downloadTask(with: request))
    }

    public func download(resumingFrom resumeData: Data, progress: ProgressHandler?) async throws -> (URL, HTTPURLResponse) {
        let delegate = DownloadTaskDelegate(progress: progress, redirectPolicy: redirectPolicy)
        return try await delegate.run(session.downloadTask(withResumeData: resumeData))
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

/// Applies the redirect policy; the task delegates below inherit from it.
private class RedirectingTaskDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    let redirectPolicy: RedirectPolicy

    init(redirectPolicy: RedirectPolicy) {
        self.redirectPolicy = redirectPolicy
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(redirectPolicy.request(redirecting: task.currentRequest, to: request))
    }
}

/// Collects a body in memory, up to an optional limit.
private final class BufferingTaskDelegate: RedirectingTaskDelegate, URLSessionDataDelegate, @unchecked Sendable {
    private struct State {
        var continuation: CheckedContinuation<(Data, HTTPURLResponse), any Error>?
        var data = Data()
        var failure: (any Error)?
        var reportedBytes: Int64 = 0
        /// The body bytes of the last request the task sent, from its metrics.
        var measuredBodyBytes: Int64 = 0
    }

    private let limit: Int?
    private let progress: ProgressHandler?
    private let state = Locked(State())

    init(limit: Int?, progress: ProgressHandler?, redirectPolicy: RedirectPolicy) {
        self.limit = limit.map { max(0, $0) }
        self.progress = progress
        super.init(redirectPolicy: redirectPolicy)
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
        state.withLock { $0.reportedBytes = totalBytesSent }
        progress?(TransferProgress(completedBytes: totalBytesSent, totalBytes: totalBytesExpectedToSend))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        if let last = metrics.transactionMetrics.last {
            state.withLock { $0.measuredBodyBytes = last.countOfRequestBodyBytesSent }
        }
        // A task delegate that implements this method keeps it from the session's delegate.
        (session.delegate as? URLSessionTaskDelegate)?.urlSession?(session, task: task, didFinishCollecting: metrics)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let error = completionError(error, session: session, task: task)
        let (continuation, data, failure, reported, measured) = state.withLock { state in
            defer { state.continuation = nil }
            return (state.continuation, state.data, state.failure ?? error, state.reportedBytes, state.measuredBodyBytes)
        }
        if let failure {
            continuation?.resume(throwing: failure)
            return
        }
        // URLSession does not always deliver a last didSendBodyData once the response has
        // arrived, and when the whole upload finishes quickly it can deliver none and still
        // read 0 in countOfBytesSent. The task metrics, which arrive before this call, count
        // the body that was sent; report the finished upload so progress ends at that size.
        let sent = max(task.countOfBytesSent, measured)
        if let progress, sent > reported {
            progress(TransferProgress(completedBytes: sent, totalBytes: sent))
        }
        continuation?.resume(with: Result { (data, try httpResponse(task.response)) })
    }
}

/// Hands out a body chunk by chunk as it arrives.
///
/// The stream is pulled: each `next()` takes the oldest waiting chunk. When `bufferLimit`
/// bytes are waiting because the consumer is slower than the network, the task is suspended,
/// and it is resumed once no more than half of them are left, so memory stays bounded and no
/// chunk is dropped.
///
/// The body is meant for one reader. Calls to `next()` that wait at the same time, from
/// several iterators of the stream, are queued and served in order, so none of them is left
/// waiting; each chunk goes to one of them.
private final class StreamingTaskDelegate: RedirectingTaskDelegate, URLSessionDataDelegate, @unchecked Sendable {
    typealias Output = (HTTPURLResponse, AsyncThrowingStream<Data, any Error>)

    private struct State {
        var headers: CheckedContinuation<Output, any Error>?
        var task: URLSessionDataTask?
        var chunks: [Data] = []
        var bufferedBytes = 0
        var isSuspended = false
        /// Calls to `next()` waiting for a chunk, oldest first; only non-empty while `chunks`
        /// is empty.
        var waiters: [CheckedContinuation<Data?, any Error>] = []
        var isComplete = false
        var failure: (any Error)?
    }

    private let bufferLimit: Int
    private let state = Locked(State())

    init(bufferLimit: Int, redirectPolicy: RedirectPolicy) {
        self.bufferLimit = max(1, bufferLimit)
        super.init(redirectPolicy: redirectPolicy)
    }

    func run(_ task: URLSessionDataTask) async throws -> Output {
        task.delegate = self
        state.withLock { $0.task = task }
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
        // Cancels the task once the stream and its iterators are gone, so a consumer that
        // stops reading does not leave the task suspended or downloading.
        let lifetime = TaskLifetime(dataTask)
        let stream = AsyncThrowingStream<Data, any Error> { [self, lifetime] in
            _ = lifetime
            return try await next()
        }
        let headers = state.withLock { state in
            defer { state.headers = nil }
            return state.headers
        }
        completionHandler(.allow)
        headers?.resume(returning: (response, stream))
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let waiter = state.withLock { state -> CheckedContinuation<Data?, any Error>? in
            if !state.waiters.isEmpty {
                return state.waiters.removeFirst()
            }
            state.chunks.append(data)
            state.bufferedBytes += data.count
            if !state.isSuspended, state.bufferedBytes >= bufferLimit {
                // Suspended and resumed under the lock, so the two cannot overtake each other.
                state.isSuspended = true
                dataTask.suspend()
            }
            return nil
        }
        waiter?.resume(returning: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let error = completionError(error, session: session, task: task)
        let (headers, waiters) = state.withLock { state in
            defer {
                state.headers = nil
                state.waiters = []
                state.task = nil
            }
            state.isComplete = true
            // Waiting calls to next() take the error now; otherwise it follows the buffered chunks.
            state.failure = state.waiters.isEmpty ? error : nil
            return (state.headers, state.waiters)
        }
        headers?.resume(throwing: error ?? NetworkError.invalidResponse)
        for waiter in waiters {
            if let error {
                waiter.resume(throwing: error)
            } else {
                waiter.resume(returning: nil)
            }
        }
    }

    /// The next chunk, or `nil` at the end of the body.
    private func next() async throws -> Data? {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, any Error>) in
                let result = state.withLock { state -> Result<Data?, any Error>? in
                    if !state.chunks.isEmpty {
                        let chunk = state.chunks.removeFirst()
                        state.bufferedBytes -= chunk.count
                        if state.isSuspended, state.bufferedBytes <= bufferLimit / 2 {
                            state.isSuspended = false
                            state.task?.resume()
                        }
                        return .success(chunk)
                    }
                    guard !state.isComplete else {
                        defer { state.failure = nil }
                        return state.failure.map { .failure($0) } ?? .success(nil)
                    }
                    state.waiters.append(continuation)
                    return nil
                }
                if let result {
                    continuation.resume(with: result)
                }
            }
        } onCancel: {
            state.withLock { $0.task }?.cancel()
        }
    }
}

/// Cancels a task when it is released.
private final class TaskLifetime: Sendable {
    private let task: URLSessionTask

    init(_ task: URLSessionTask) {
        self.task = task
    }

    deinit {
        task.cancel()
    }
}

/// Writes a body to a temporary file and reports progress.
private final class DownloadTaskDelegate: RedirectingTaskDelegate, URLSessionDownloadDelegate, @unchecked Sendable {
    private struct State {
        var continuation: CheckedContinuation<(URL, HTTPURLResponse), any Error>?
        var file: URL?
        var failure: (any Error)?
    }

    private let progress: ProgressHandler?
    private let state = Locked(State())

    init(progress: ProgressHandler?, redirectPolicy: RedirectPolicy) {
        self.progress = progress
        super.init(redirectPolicy: redirectPolicy)
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

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) {
        progress?(TransferProgress(completedBytes: fileOffset, totalBytes: expectedTotalBytes))
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
