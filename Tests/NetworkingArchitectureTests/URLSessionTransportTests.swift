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
                // Declare the whole file but send only the first half, then close.
                return LocalHTTPServer.Response(
                    headers: validators, chunks: [payload.prefix(payload.count / 2)], declaredLength: payload.count
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
