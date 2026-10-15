import Foundation
import Testing
@testable import NetworkingArchitecture

/// These tests send real requests through `URLSession` to a server on 127.0.0.1.
@Suite("URLSession transport", .serialized, .timeLimit(.minutes(1)))
struct URLSessionTransportTests {
    private func client(_ server: LocalHTTPServer, maximumResponseSize: Int? = nil) -> NetworkClient {
        NetworkClient(
            baseURL: server.url("/api"),
            configuration: .init(retryPolicy: .none, maximumResponseSize: maximumResponseSize),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral))
        )
    }

    @Test func sendsTheRequestAndDecodesTheResponse() async throws {
        let server = try await LocalHTTPServer { request in
            let echo = #"{"id":1,"name":"\#(request.method) \#(request.path) \#(request.header("X-Test") ?? "")"}"#
            return .body(Data(echo.utf8), headers: ["Content-Type": "application/json"])
        }
        let user = try await client(server).send(Endpoint<User>.get("users", headers: ["X-Test": "yes"]))
        #expect(user == User(id: 1, name: "GET /api/users yes"))
    }

    @Test func postsTheBody() async throws {
        let server = try await LocalHTTPServer { request in
            .body(request.body, headers: ["Content-Type": request.header("Content-Type") ?? ""])
        }
        let user = try await client(server).send(Endpoint<User>.post("users", body: .json(User(id: 5, name: "Grace"))))
        #expect(user == User(id: 5, name: "Grace"))
    }

    @Test func rejectsADeclaredLengthOverTheLimitBeforeReadingIt() async throws {
        let server = try await LocalHTTPServer { _ in .body(Data(count: 512 * 1024)) }
        let error = await #expect(throws: NetworkError.self) {
            try await client(server, maximumResponseSize: 64 * 1024).send(Endpoint<Data>.get("big"))
        }
        guard case .responseTooLarge(65_536)? = error else {
            Issue.record("Expected responseTooLarge, got \(String(describing: error))")
            return
        }
    }

    @Test func stopsReadingAnUndeclaredBodyAtTheLimit() async throws {
        let chunk = Data(count: 16 * 1024)
        let server = try await LocalHTTPServer { _ in
            LocalHTTPServer.Response(chunks: Array(repeating: chunk, count: 32), omitsContentLength: true)
        }
        let error = await #expect(throws: NetworkError.self) {
            try await client(server, maximumResponseSize: 64 * 1024).send(Endpoint<Data>.get("stream"))
        }
        guard case .responseTooLarge? = error else {
            Issue.record("Expected responseTooLarge, got \(String(describing: error))")
            return
        }
    }

    @Test func streamsChunksBeforeTheBodyEnds() async throws {
        let server = try await LocalHTTPServer { _ in
            LocalHTTPServer.Response(
                chunks: [Data("first".utf8), Data("second".utf8)],
                chunkDelay: .milliseconds(300),
                omitsContentLength: true
            )
        }
        let transport = URLSessionTransport(session: URLSession(configuration: .ephemeral))
        let (response, stream) = try await transport.stream(URLRequest(url: server.url("/events")))
        #expect(response.statusCode == 200)
        var received = Data()
        var firstArrival: ContinuousClock.Instant?
        let start = ContinuousClock.now
        for try await chunk in stream {
            if firstArrival == nil { firstArrival = .now }
            received.append(chunk)
        }
        #expect(String(decoding: received, as: UTF8.self) == "firstsecond")
        let firstDelay = try #require(firstArrival) - start
        #expect(firstDelay < .milliseconds(250))
    }

    /// A server that answers with `count` chunks of 64 KB.
    private func largeBodyServer(chunks count: Int) async throws -> LocalHTTPServer {
        try await LocalHTTPServer { _ in
            LocalHTTPServer.Response(chunks: Array(repeating: Data(repeating: 7, count: 64 * 1024), count: count))
        }
    }

    /// Waits until the session's only task is in `state`, for at most 20 seconds.
    private func waitForTask(in session: URLSession, toBe state: URLSessionTask.State) async throws -> Bool {
        let deadline = ContinuousClock.now.advanced(by: .seconds(20))
        while ContinuousClock.now < deadline {
            if await session.allTasks.first?.state == state { return true }
            try await Task.sleep(for: .milliseconds(20))
        }
        return false
    }

    @Test func aSlowStreamConsumerPausesTheTransferWithoutLosingData() async throws {
        let server = try await largeBodyServer(chunks: 16)
        let session = URLSession(configuration: .ephemeral)
        let transport = URLSessionTransport(session: session, streamBufferLimit: 128 * 1024)
        let (_, stream) = try await transport.stream(URLRequest(url: server.url("/large")))

        #expect(try await waitForTask(in: session, toBe: .suspended), "The transfer was not paused")
        var received = 0
        for try await chunk in stream {
            #expect(chunk.allSatisfy { $0 == 7 })
            received += chunk.count
        }
        #expect(received == 16 * 64 * 1024)
    }

    @Test func droppingAStreamCancelsItsTask() async throws {
        let server = try await largeBodyServer(chunks: 16)
        let session = URLSession(configuration: .ephemeral)
        let transport = URLSessionTransport(session: session, streamBufferLimit: 64 * 1024)
        do {
            let (response, _) = try await transport.stream(URLRequest(url: server.url("/large")))
            #expect(response.statusCode == 200)
        }
        let deadline = ContinuousClock.now.advanced(by: .seconds(20))
        while await !session.allTasks.isEmpty {
            guard ContinuousClock.now < deadline else {
                Issue.record("The task of a dropped stream kept running")
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
    }

    @Test func cancellingAStreamReaderCancelsTheTransfer() async throws {
        let server = try await largeBodyServer(chunks: 16)
        let session = URLSession(configuration: .ephemeral)
        let transport = URLSessionTransport(session: session, streamBufferLimit: 64 * 1024)
        // The stream lives only in the reader, as in an app's task that reads a body.
        let reader = Task {
            let (_, stream) = try await transport.stream(URLRequest(url: server.url("/large")))
            for try await _ in stream {
                try await Task.sleep(for: .seconds(1))
            }
        }
        #expect(try await waitForTask(in: session, toBe: .suspended), "The transfer was not paused")
        let task = try #require(await session.allTasks.first)
        reader.cancel()
        // A cancelled reader sees the end of the stream or an error, like with any AsyncStream.
        _ = await reader.result
        let deadline = ContinuousClock.now.advanced(by: .seconds(20))
        while task.state != .completed, ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(task.state == .completed)
        #expect((task.error as? URLError)?.code == .cancelled)
    }

    @Test func downloadsToAFileAndReportsProgress() async throws {
        let payload = Data((0..<300_000).map { UInt8($0 % 251) })
        let server = try await LocalHTTPServer { _ in .body(payload) }
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).bin")
        defer { try? FileManager.default.removeItem(at: destination) }
        let progress = EventLog()
        let response = try await client(server).download(.get("file"), to: destination) { update in
            progress.append(String(update.fractionCompleted ?? -1))
        }
        #expect(response.statusCode == 200)
        #expect(try Data(contentsOf: destination) == payload)
        #expect(progress.all.last == "1.0")
    }

    /// A server that cuts the first response in half and answers range requests, the way a
    /// file server behind a flaky connection does.
    private func resumableServer(_ payload: Data, ranges: Locked<[String]>) async throws -> LocalHTTPServer {
        try await LocalHTTPServer { request in
            let validators = ["ETag": "\"file-v1\"", "Accept-Ranges": "bytes", "Last-Modified": "Wed, 21 Oct 2015 07:28:00 GMT"]
            guard let range = request.header("Range"), range.hasPrefix("bytes="),
                  let start = Int(range.dropFirst(6).prefix { $0 != "-" }) else {
                ranges.withLock { $0.append("none") }
                // Declare the whole file but send only the first half, then close. The pause before
                // the close lets URLSession take in the half first; without it, a busy machine
                // sometimes saw the close first and its resume data started at byte 0.
                return LocalHTTPServer.Response(
                    headers: validators,
                    chunks: [payload.prefix(payload.count / 2), Data()],
                    chunkDelay: .milliseconds(300),
                    declaredLength: payload.count
                )
            }
            ranges.withLock { $0.append(range) }
            var headers = validators
            headers["Content-Range"] = "bytes \(start)-\(payload.count - 1)/\(payload.count)"
            return LocalHTTPServer.Response(status: 206, headers: headers, chunks: [payload.suffix(from: start)])
        }
    }

    @Test func aDroppedDownloadIsResumedByTheRetry() async throws {
        let payload = Data((0..<400_000).map { UInt8($0 % 253) })
        let ranges = Locked<[String]>([])
        let server = try await resumableServer(payload, ranges: ranges)
        let client = NetworkClient(
            baseURL: server.url(""),
            configuration: .init(retryPolicy: RetryPolicy(baseDelay: .zero, jitter: 0)),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral))
        )
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).bin")
        defer { try? FileManager.default.removeItem(at: destination) }
        let response = try await client.download(.get("file"), to: destination)
        #expect(response.statusCode == 206)
        #expect(response.attempts == 2)
        #expect(try Data(contentsOf: destination) == payload)
        #expect(ranges.withLock { $0 } == ["none", "bytes=200000-"])
    }

    @Test func anInterruptedDownloadCanBeResumedLater() async throws {
        let payload = Data((0..<300_000).map { UInt8($0 % 241) })
        let ranges = Locked<[String]>([])
        let server = try await resumableServer(payload, ranges: ranges)
        let client = NetworkClient(
            baseURL: server.url(""),
            configuration: .init(retryPolicy: .none),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral))
        )
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).bin")
        defer { try? FileManager.default.removeItem(at: destination) }
        let error = await #expect(throws: NetworkError.self) {
            try await client.download(.get("file"), to: destination)
        }
        #expect(!FileManager.default.fileExists(atPath: destination.path))
        let resumeData = try #require(error?.resumeData)

        try await client.download(.get("file"), to: destination, resumingFrom: resumeData)
        #expect(try Data(contentsOf: destination) == payload)
        #expect(ranges.withLock { $0 } == ["none", "bytes=150000-"])
    }

    @Test func uploadsAFileAndReportsProgress() async throws {
        let payload = Data(repeating: 7, count: 200_000)
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).bin")
        try payload.write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }
        let server = try await LocalHTTPServer { request in
            .body(Data(#"{"id":\#(request.body.count),"name":"received"}"#.utf8))
        }
        let progress = EventLog()
        let response = try await client(server).upload(Endpoint<User>.post("upload"), file: file) { update in
            progress.append(String(update.completedBytes))
        }
        #expect(response.value.id == payload.count)
        #expect(progress.all.last == String(payload.count))
    }

    @Test func uploadResponsesOverTheLimitFail() async throws {
        let server = try await LocalHTTPServer { _ in .body(Data(count: 512 * 1024)) }
        let error = await #expect(throws: NetworkError.self) {
            try await client(server, maximumResponseSize: 64 * 1024).upload(
                Endpoint<Data>.post("upload", body: .data(Data("abc".utf8), contentType: "text/plain"))
            )
        }
        guard case .responseTooLarge(65_536)? = error else {
            Issue.record("Expected responseTooLarge, got \(String(describing: error))")
            return
        }
    }

    @Test func undeclaredUploadResponsesStopAtTheLimit() async throws {
        let chunk = Data(count: 16 * 1024)
        let server = try await LocalHTTPServer { _ in
            LocalHTTPServer.Response(chunks: Array(repeating: chunk, count: 32), omitsContentLength: true)
        }
        let error = await #expect(throws: NetworkError.self) {
            try await client(server, maximumResponseSize: 64 * 1024).upload(
                Endpoint<Data>.post("upload", body: .data(Data("abc".utf8), contentType: "text/plain"))
            )
        }
        guard case .responseTooLarge? = error else {
            Issue.record("Expected responseTooLarge, got \(String(describing: error))")
            return
        }
    }

    @Test func cancellationStopsAPendingRequest() async throws {
        let server = try await LocalHTTPServer { _ in
            LocalHTTPServer.Response(chunks: [Data("a".utf8), Data("b".utf8)], chunkDelay: .seconds(10))
        }
        let client = client(server)
        let task = Task { try await client.send(Endpoint<Data>.get("slow")) }
        try await Task.sleep(for: .milliseconds(200))
        task.cancel()
        let result = await task.result
        guard case .failure(NetworkError.cancelled) = result else {
            Issue.record("Expected cancelled, got \(result)")
            return
        }
    }

    @Test func unreachableHostIsAConnectivityProblem() async throws {
        // Port 9 (discard) is closed on the test machines, so the connection is refused.
        let client = NetworkClient(
            baseURL: URL(string: "http://127.0.0.1:9")!,
            configuration: .init(retryPolicy: .none),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral))
        )
        let error = await #expect(throws: NetworkError.self) {
            try await client.send(Endpoint<Data>.get("x"))
        }
        #expect(error?.isConnectivityProblem == true)
    }
}
