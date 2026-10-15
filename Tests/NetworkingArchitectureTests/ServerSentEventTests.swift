import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

@Suite("Server-sent event parser")
struct ServerSentEventParserTests {
    private func parse(_ text: String, chunkSize: Int = .max) throws -> ([ServerSentEvent], ServerSentEventParser) {
        var parser = ServerSentEventParser()
        let bytes = Array(text.utf8)
        var events: [ServerSentEvent] = []
        var index = 0
        while index < bytes.count {
            let end = min(index + max(1, chunkSize), bytes.count)
            events += try parser.parse(bytes[index..<end])
            index = end
        }
        return (events, parser)
    }

    @Test("Any chunking gives the same events", arguments: [1, 2, 3, 7, .max])
    func chunkingDoesNotMatter(chunkSize: Int) throws {
        let text = "event: update\r\ndata: first\r\ndata: second\r\nid: 42\r\n\r\ndata: plain\n\n: comment\ndata:no space\r\r"
        let (events, parser) = try parse(text, chunkSize: chunkSize)
        #expect(events == [
            ServerSentEvent(type: "update", data: "first\nsecond", id: "42"),
            ServerSentEvent(data: "plain", id: "42"),
            ServerSentEvent(data: "no space", id: "42")
        ])
        #expect(parser.lastEventID == "42")
    }

    @Test func leadingByteOrderMarkIsSkippedOnce() throws {
        let (events, _) = try parse("\u{FEFF}data: a\n\n\u{FEFF}data: b\n\n")
        #expect(events.map(\.data) == ["a"])
    }

    @Test func fieldsFollowTheStandard() throws {
        let text = """
        data
        data:  two spaces
        event
        id: has\u{0}nul
        unknown: ignored
        data: x

        event: only-type


        """
        let (events, parser) = try parse(text)
        #expect(events == [ServerSentEvent(data: "\n two spaces\nx")])
        #expect(parser.lastEventID == "")
    }

    @Test("retry accepts only digits", arguments: [
        ("retry: 2500", Duration?.some(.milliseconds(2_500))),
        ("retry: 25.5", nil), ("retry: -1", nil), ("retry: ", nil), ("retry: 1e3", nil),
        ("retry: 99999999999999999999999999", nil)
    ])
    func retryField(line: String, expected: Duration?) throws {
        let (_, parser) = try parse(line + "\n\n")
        #expect(parser.reconnectionTime == expected)
    }

    @Test func eventsWithoutABlankLineAreNotDispatched() throws {
        let (events, _) = try parse("data: unfinished")
        #expect(events.isEmpty)
    }

    @Test func oversizedEventsThrowInsteadOfGrowingMemory() throws {
        var parser = ServerSentEventParser(maximumEventSize: 64)
        let line = Array("data: \(String(repeating: "x", count: 40))\n".utf8)
        _ = try parser.parse(line)
        #expect(throws: ServerSentEventParser.EventTooLarge(limit: 64)) {
            try parser.parse(line)
        }
        var lineOnly = ServerSentEventParser(maximumEventSize: 64)
        #expect(throws: ServerSentEventParser.EventTooLarge.self) {
            try lineOnly.parse(Array(repeating: UInt8(ascii: "a"), count: 1_000))
        }
    }

    @Test func decodesJSONData() throws {
        let (events, _) = try parse(#"data: {"id":3,"name":"Ada"}"# + "\n\n")
        #expect(try events.first?.decode(User.self) == User(id: 3, name: "Ada"))
    }
}

@Suite("Event streams", .timeLimit(.minutes(1)))
struct EventStreamTests {
    private let base = URL(string: "https://api.example.com")!

    private func collect(_ stream: AsyncThrowingStream<ServerSentEvent, any Error>, limit: Int = .max) async throws -> [ServerSentEvent] {
        var events: [ServerSentEvent] = []
        for try await event in stream {
            events.append(event)
            if events.count == limit { break }
        }
        return events
    }

    @Test func reconnectsWithLastEventIDUntilTheServerSends204() async throws {
        let transport = MockTransport { request in
            let headers: HTTPHeaders = ["Content-Type": "text/event-stream"]
            switch request.value(forHTTPHeaderField: "Last-Event-ID") {
            case nil: return .text("retry: 10\nid: 1\ndata: one\n\nid: 2\ndata: two\n\ndata: cut", headers: headers, chunks: 4)
            case "2": return .text("id: 3\ndata: three\n\n", headers: headers)
            default: return .status(204)
            }
        }
        let client = NetworkClient(baseURL: base, transport: transport)
        let events = try await collect(client.events(.get("stream"), options: EventStreamOptions(minimumRetry: .zero)))
        #expect(events.map(\.data) == ["one", "two", "three"])
        #expect(transport.requests.map { $0.value(forHTTPHeaderField: "Last-Event-ID") } == [nil, "2", "3"])
        #expect(transport.requests.first?.value(forHTTPHeaderField: "Accept") == "text/event-stream")
    }

    @Test func clientErrorsEndTheStreamWithoutReconnecting() async throws {
        let transport = MockTransport { _ in .status(403) }
        let client = NetworkClient(baseURL: base, transport: transport)
        let error = await #expect(throws: NetworkError.self) { try await collect(client.events(.get("stream"))) }
        #expect(error?.statusCode == 403)
        #expect(transport.requests.count == 1)
    }

    @Test func responsesThatAreNotEventStreamsFail() async throws {
        let transport = MockTransport { _ in .text("<html>") }
        let client = NetworkClient(baseURL: base, transport: transport)
        await #expect(throws: NetworkError.self) { try await collect(client.events(.get("stream"))) }
        #expect(transport.requests.count == 1)
    }

    @Test func emptyConnectionsStopAfterTheLimit() async throws {
        let transport = MockTransport { _ in .text(": keep-alive\n", headers: ["Content-Type": "text/event-stream"]) }
        let client = NetworkClient(baseURL: base, transport: transport)
        let options = EventStreamOptions(defaultRetry: .zero, minimumRetry: .zero, maximumReconnectAttempts: 3)
        let events = try await collect(client.events(.get("stream"), options: options))
        #expect(events.isEmpty)
        #expect(transport.requests.count == 4)
    }

    @Test func droppedConnectionsReconnectAndPersistentFailuresThrow() async throws {
        let transport = MockTransport { _ in .failure(.networkConnectionLost) }
        let client = NetworkClient(baseURL: base, transport: transport)
        let options = EventStreamOptions(defaultRetry: .zero, minimumRetry: .zero, maximumReconnectAttempts: 2)
        let error = await #expect(throws: NetworkError.self) { try await collect(client.events(.get("stream"), options: options)) }
        #expect(error?.isConnectivityProblem == true)
        #expect(transport.requests.count == 3)
    }

    @Test func serverRetryIsCappedByTheMaximum() async throws {
        let transport = MockTransport { request in
            request.value(forHTTPHeaderField: "Last-Event-ID") == nil
                ? .text("retry: 999999999\nid: 1\ndata: a\n\n", headers: ["Content-Type": "text/event-stream"])
                : .status(204)
        }
        let client = NetworkClient(baseURL: base, transport: transport)
        let start = ContinuousClock.now
        let events = try await collect(client.events(.get("s"), options: EventStreamOptions(maximumRetry: .milliseconds(50))))
        #expect(events.count == 1)
        #expect(ContinuousClock.now - start < .seconds(5))
    }

    @Test func aZeroServerRetryStillWaitsTheMinimum() async throws {
        let transport = MockTransport { request in
            let headers: HTTPHeaders = ["Content-Type": "text/event-stream"]
            return switch request.value(forHTTPHeaderField: "Last-Event-ID") {
            case nil: .text("retry: 0\nid: 1\ndata: a\n\n", headers: headers)
            case "1": .text("id: 2\ndata: b\n\n", headers: headers)
            default: .status(204)
            }
        }
        let client = NetworkClient(baseURL: base, transport: transport)
        let start = ContinuousClock.now
        let options = EventStreamOptions(minimumRetry: .milliseconds(300))
        let events = try await collect(client.events(.get("s"), options: options))
        #expect(events.map(\.data) == ["a", "b"])
        #expect(transport.requests.count == 3)
        // Two reconnections, each at least the minimum apart.
        #expect(ContinuousClock.now - start >= .milliseconds(600))
    }

    @Test func theMinimumRetryDefaultsToOneSecond() {
        #expect(EventStreamOptions().minimumRetry == .seconds(1))
        #expect(EventStreamOptions(minimumRetry: .seconds(-5)).minimumRetry == .zero)
    }

    @Test func aConsumerThatFallsBehindEndsTheStreamInsteadOfBufferingForever() async throws {
        let events = (1...50).map { "data: \($0)\n\n" }.joined()
        let transport = MockTransport { _ in .text(events, headers: ["Content-Type": "text/event-stream"]) }
        let client = NetworkClient(baseURL: base, transport: transport)
        let stream = client.events(.get("s"), options: EventStreamOptions(reconnects: false, maximumBufferedEvents: 5))
        // Let the producer run ahead before reading anything.
        try await Task.sleep(for: .milliseconds(200))
        var received: [String] = []
        do {
            for try await event in stream { received.append(event.data) }
            Issue.record("Expected bufferOverflow")
        } catch NetworkError.bufferOverflow(let limit) {
            #expect(limit == 5)
        }
        #expect(received == ["1", "2", "3", "4", "5"])
    }

    @Test func stoppingTheIterationClosesTheConnection() async throws {
        let server = try await LocalHTTPServer { _ in
            LocalHTTPServer.Response(
                headers: ["Content-Type": "text/event-stream"],
                chunks: (1...50).map { Data("data: \($0)\n\n".utf8) },
                chunkDelay: .milliseconds(20),
                omitsContentLength: true
            )
        }
        let client = NetworkClient(
            baseURL: server.url(""),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral))
        )
        let events = try await collect(client.events(.get("live")), limit: 3)
        #expect(events.map(\.data) == ["1", "2", "3"])
    }
}
