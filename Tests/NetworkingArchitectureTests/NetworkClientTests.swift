import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// Records events from any task, for assertions.
final class EventLog: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [String] = []

    func append(_ entry: String) {
        lock.lock()
        entries.append(entry)
        lock.unlock()
    }

    var all: [String] {
        lock.lock()
        defer { lock.unlock() }
        return entries
    }
}

extension RetryPolicy {
    /// The default policy without waiting between attempts, so tests run fast.
    static let immediate = RetryPolicy(baseDelay: .zero, jitter: 0)
}

@Suite("Network client")
struct NetworkClientTests {
    private let baseURL = URL(string: "https://api.example.com/v1")!

    private func client(
        _ transport: MockTransport,
        interceptors: [any RequestInterceptor] = [],
        monitors: [any NetworkEventMonitor] = [],
        retryPolicy: RetryPolicy = .immediate,
        maximumResponseSize: Int? = 50 * 1024 * 1024
    ) -> NetworkClient {
        NetworkClient(
            baseURL: baseURL,
            configuration: .init(
                interceptors: interceptors, monitors: monitors,
                retryPolicy: retryPolicy, maximumResponseSize: maximumResponseSize
            ),
            transport: transport
        )
    }

    @Test func decodesJSON() async throws {
        let transport = MockTransport()
        transport.register(.get, "users/1", try .json(User(id: 1, name: "Ada")))
        let user = try await client(transport).send(Endpoint<User>.get("users/1"))
        #expect(user == User(id: 1, name: "Ada"))
        #expect(transport.requests.first?.url?.absoluteString == "https://api.example.com/v1/users/1")
        #expect(transport.requests.first?.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func dataEndpointsReturnTheBodyUnchanged() async throws {
        let transport = MockTransport()
        transport.register(.get, "raw", MockResponse(body: Data([0, 1, 2, 255])))
        let data = try await client(transport).send(Endpoint<Data>.get("raw"))
        #expect(data == Data([0, 1, 2, 255]))
    }

    @Test func voidEndpointsIgnoreTheBody() async throws {
        let transport = MockTransport()
        transport.register(.delete, "users/1", .text("not json"))
        try await client(transport).send(Endpoint<Void>.delete("users/1"))
        #expect(transport.requests.first?.httpMethod == "DELETE")
    }

    @Test func unacceptableStatusCarriesTheBody() async throws {
        let transport = MockTransport()
        transport.register(.get, "users/9", MockResponse(statusCode: 404, body: Data("missing".utf8)))
        let error = await #expect(throws: NetworkError.self) {
            try await client(transport).send(Endpoint<User>.get("users/9"))
        }
        #expect(error?.statusCode == 404)
        #expect(error?.response?.value == Data("missing".utf8))
    }

    @Test func decodingFailureKeepsTheResponse() async throws {
        let transport = MockTransport()
        transport.register(.get, "users/1", .text(#"{"id":"one"}"#))
        let error = await #expect(throws: NetworkError.self) {
            try await client(transport).send(Endpoint<User>.get("users/1"))
        }
        guard case .decodingFailed(let underlying, let response)? = error else {
            Issue.record("Expected decodingFailed, got \(String(describing: error))")
            return
        }
        #expect(underlying is DecodingError)
        #expect(response.statusCode == 200)
    }

    @Test func retriesTransientFailuresAndReportsAttempts() async throws {
        let transport = MockTransport()
        transport.register(.get, "users/1", .status(503), .failure(.networkConnectionLost), try .json(User(id: 1, name: "Ada")))
        let response = try await client(transport).response(for: Endpoint<User>.get("users/1"))
        #expect(response.attempts == 3)
        #expect(transport.requests.count == 3)
    }

    @Test func givesUpAfterTheLastAttempt() async throws {
        let transport = MockTransport()
        transport.register(.get, "flaky", .status(503))
        await #expect(throws: NetworkError.self) {
            try await client(transport).send(Endpoint<Data>.get("flaky"))
        }
        #expect(transport.requests.count == RetryPolicy.immediate.maximumAttempts)
    }

    @Test func doesNotRetryPost() async throws {
        let transport = MockTransport()
        transport.register(.post, "orders", .status(503), .status(201))
        await #expect(throws: NetworkError.self) {
            try await client(transport).send(Endpoint<Void>.post("orders"))
        }
        #expect(transport.requests.count == 1)
    }

    @Test func endpointRetryPolicyOverridesTheClients() async throws {
        let transport = MockTransport()
        transport.register(.get, "x", .status(503))
        _ = try? await client(transport).send(Endpoint<Data>.get("x").with(\.retryPolicy, RetryPolicy.none))
        #expect(transport.requests.count == 1)
    }

    @Test func interceptorsAdaptEveryAttemptInOrder() async throws {
        struct Header: RequestInterceptor {
            let name: String
            func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
                var request = request
                let previous = request.value(forHTTPHeaderField: "X-Chain") ?? ""
                request.setValue(previous + name, forHTTPHeaderField: "X-Chain")
                request.setValue(String(context.attempt), forHTTPHeaderField: "X-Attempt")
                return request
            }
        }
        let transport = MockTransport()
        transport.register(.get, "x", .status(500), .status(200))
        try await client(transport, interceptors: [Header(name: "a"), Header(name: "b")]).send(Endpoint<Void>.get("x"))
        #expect(transport.requests.map { $0.value(forHTTPHeaderField: "X-Chain") } == ["ab", "ab"])
        #expect(transport.requests.map { $0.value(forHTTPHeaderField: "X-Attempt") } == ["1", "2"])
    }

    @Test func interceptorThatAlwaysRetriesIsStoppedAtTheAttemptLimit() async throws {
        struct Stubborn: RequestInterceptor {
            func retry(_ request: URLRequest, dueTo error: NetworkError, context: RequestContext) async throws -> RetryDecision {
                .retry(after: .zero, reason: "stubborn")
            }
        }
        let transport = MockTransport()
        transport.register(.post, "x", .status(400))
        await #expect(throws: NetworkError.self) {
            try await client(transport, interceptors: [Stubborn()]).send(Endpoint<Void>.post("x"))
        }
        #expect(transport.requests.count == RetryPolicy.attemptLimit)
    }

    @Test func interceptorRetriesAreCountedPerReason() async throws {
        struct CountingRetrier: RequestInterceptor {
            let log: EventLog
            func retry(_ request: URLRequest, dueTo error: NetworkError, context: RequestContext) async throws -> RetryDecision {
                log.append("\(context.retryCount(for: "custom"))")
                return context.retryCount(for: "custom") < 2 ? .retry(after: .zero, reason: "custom") : .doNotRetry
            }
        }
        let log = EventLog()
        let transport = MockTransport()
        transport.register(.post, "x", .status(409))
        _ = try? await client(transport, interceptors: [CountingRetrier(log: log)]).send(Endpoint<Void>.post("x"))
        #expect(log.all == ["0", "1", "2"])
        #expect(transport.requests.count == 3)
    }

    @Test func errorThrownByAnAdapterStopsTheRequest() async throws {
        struct Refusing: RequestInterceptor {
            struct Refused: Error {}
            func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest { throw Refused() }
        }
        let transport = MockTransport()
        await #expect(throws: Refusing.Refused.self) {
            try await client(transport, interceptors: [Refusing()]).send(Endpoint<Void>.get("x"))
        }
        #expect(transport.requests.isEmpty)
    }

    @Test func cancellingTheTaskStopsTheWaitBetweenAttempts() async throws {
        let transport = MockTransport()
        transport.register(.get, "slow", .status(503))
        let policy = RetryPolicy(maximumAttempts: 5, baseDelay: .seconds(30), jitter: 0)
        let client = client(transport, retryPolicy: policy)
        let task = Task { try await client.send(Endpoint<Void>.get("slow")) }
        try await Task.sleep(for: .milliseconds(100))
        task.cancel()
        let result = await task.result
        #expect(throws: NetworkError.self) { try result.get() }
        if case .failure(NetworkError.cancelled) = result {} else {
            Issue.record("Expected cancelled, got \(result)")
        }
        #expect(transport.requests.count == 1)
    }

    @Test func monitorsSeeEveryStep() async throws {
        let log = EventLog()
        let monitor = ClosureEventMonitor { event, context in
            switch event {
            case .willSend: log.append("send \(context.attempt)")
            case .didReceive(_, let response, _): log.append("status \(response.statusCode)")
            case .didFail(_, let error, _): log.append("fail \(error.isConnectivityProblem)")
            case .willRetry(_, _, let reason): log.append("retry \(reason.rawValue)")
            }
        }
        let transport = MockTransport()
        transport.register(.get, "x", .failure(.notConnectedToInternet), .status(204))
        try await client(transport, monitors: [monitor]).send(Endpoint<Void>.get("x"))
        #expect(log.all == ["send 1", "fail true", "retry transientFailure", "send 2", "status 204"])
    }

    @Test func bodiesOverTheLimitFail() async throws {
        let transport = MockTransport()
        transport.register(.get, "big", MockResponse(body: Data(count: 2_048)))
        let error = await #expect(throws: NetworkError.self) {
            try await client(transport, maximumResponseSize: 1_024).send(Endpoint<Data>.get("big"))
        }
        guard case .responseTooLarge(1_024)? = error else {
            Issue.record("Expected responseTooLarge, got \(String(describing: error))")
            return
        }
        #expect(transport.requests.count == 1)
    }

    @Test func uploadSendsTheEndpointBody() async throws {
        let transport = MockTransport()
        transport.register(.post, "files", try .json(User(id: 7, name: "upload")))
        let progress = EventLog()
        let response = try await client(transport).upload(
            Endpoint<User>.post("files", body: .data(Data("abc".utf8), contentType: "text/plain"))
        ) { progress.append("\($0.completedBytes)/\($0.totalBytes ?? -1)") }
        #expect(response.value.id == 7)
        #expect(transport.requests.first?.httpBody == Data("abc".utf8))
        #expect(transport.requests.first?.value(forHTTPHeaderField: "Content-Type") == "text/plain")
        #expect(progress.all == ["3/3"])
    }

    @Test func uploadResponsesOverTheLimitFail() async throws {
        let transport = MockTransport()
        transport.register(.post, "files", MockResponse(body: Data(count: 2_048)))
        let error = await #expect(throws: NetworkError.self) {
            try await client(transport, maximumResponseSize: 1_024).upload(Endpoint<Data>.post("files"))
        }
        guard case .responseTooLarge(1_024)? = error else {
            Issue.record("Expected responseTooLarge, got \(String(describing: error))")
            return
        }
    }

    @Test func downloadReplacesTheDestinationOnlyOnSuccess() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let destination = directory.appendingPathComponent("report.txt")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("old".utf8).write(to: destination)
        defer { try? FileManager.default.removeItem(at: directory) }

        let transport = MockTransport()
        transport.register(.get, "report", MockResponse(statusCode: 404, body: Data("gone".utf8)), .text("new"))
        let client = client(transport, retryPolicy: .none)

        await #expect(throws: NetworkError.self) {
            try await client.download(.get("report"), to: destination)
        }
        #expect(try String(contentsOf: destination, encoding: .utf8) == "old")

        let response = try await client.download(.get("report"), to: destination)
        #expect(response.value == destination)
        #expect(try String(contentsOf: destination, encoding: .utf8) == "new")
    }

    @Test func urlRequestShowsTheRequestBeforeInterceptors() throws {
        struct Stamp: RequestInterceptor {
            func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
                var request = request
                request.setValue("1", forHTTPHeaderField: "X-Stamped")
                return request
            }
        }
        let client = client(MockTransport(), interceptors: [Stamp()])
        let request = try client.urlRequest(for: Endpoint<Data>.get("users", query: [URLQueryItem(name: "q", value: "a+b")]))
        #expect(request.url?.absoluteString == "https://api.example.com/v1/users?q=a%2Bb")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "X-Stamped") == nil)
    }

    @Test func mapTransformsTheDecodedValue() async throws {
        let transport = MockTransport()
        transport.register(.get, "users/1", try .json(User(id: 1, name: "Ada")))
        let name = try await client(transport).send(Endpoint<User>.get("users/1").map(\.name))
        #expect(name == "Ada")
    }
}
