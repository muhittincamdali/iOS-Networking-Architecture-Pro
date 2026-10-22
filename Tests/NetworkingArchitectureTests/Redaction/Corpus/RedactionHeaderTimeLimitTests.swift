import Foundation
import Testing
@testable import NetworkingArchitecture

/// What a 512 KiB thread did with a response of many header fields.
private struct HeaderRun: Sendable {
    let seconds: Double
    let fieldCount: Int
    let redactedCount: Int
    let accept: String?
    let logLines: Int
}

/// The review found headers read and redacted in time that grew with the square of their number:
/// every field was added by looking through the fields before it, so 20,000 response header
/// fields (658 KB) took 6.6 s to redact and 6.5 s more to read from the `HTTPURLResponse`. A
/// hostile server can send that many; URLSession accepts them. ``HTTPHeaders`` now finds a field
/// by an index of its case-folded name.
@Suite("Redaction corpus: header time limit", .serialized, .enabled(if: isOptimized, "time limits are checked in a release build: swift test -c release"))
struct RedactionHeaderTimeLimitTests {
    /// Reading the header fields of a response, redacting them and writing the logger's lines.
    private static func run(_ response: HTTPURLResponse) -> HeaderRun {
        onThread(stackSize: RedactionStackTests.threadStack) {
            let start = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)
            let headers = HTTPHeaders(response)
            let redacted = Redactor.default.redact(headers: headers)
            let logger = NetworkLogger(detail: .headers, redactor: .default) { _, _ in }
            let request = URLRequest(url: URL(string: "https://api.example.com/a")!)
            let line = logger.format(.didReceive(request, HTTPResponse(value: Data(), statusCode: 200, headers: headers), duration: .zero),
                                     context: RequestContext(retryPolicy: .none)) ?? ""
            let nanoseconds = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID) - start
            return HeaderRun(seconds: Double(nanoseconds) / 1e9, fieldCount: headers.count, redactedCount: redacted.count,
                             accept: redacted["accept"], logLines: line.split(separator: "\n").count)
        }
    }

    @Test("reading, redacting and logging many response header fields takes a 512 KiB thread less than a second per megabyte",
          arguments: [10_000, 20_000, 32_000])
    func manyFields(count: Int) {
        var fields: [String: String] = ["Accept": "application/json"]
        for i in 0..<count { fields["X-H\(i)"] = "value \(i) status=200" }
        let response = HTTPURLResponse(url: URL(string: "https://api.example.com/a")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: fields)!
        let megabytes = Double(fields.reduce(0) { $0 + $1.key.utf8.count + $1.value.utf8.count + 4 }) / 1e6
        var run = Self.run(response)
        for _ in 0..<2 where run.seconds >= megabytes {
            run = Self.run(response)
        }
        #expect(run.fieldCount == count + 1 && run.redactedCount == count + 1 && run.logLines == count + 2)
        #expect(run.accept == "application/json")
        #expect(run.seconds < megabytes, "\(count) fields, \(megabytes) MB: \(run.seconds) s")
    }
}

/// ``HTTPHeaders`` finds, replaces and removes fields by name, in any case, with the index.
@Suite("HTTP headers: lookup by name")
struct HTTPHeadersLookupTests {
    @Test("a field is found, replaced and removed in any case, and the fields after a removed one are still found")
    func lookup() {
        var headers: HTTPHeaders = ["Accept": "a", "X-One": "1", "X-Two": "2"]
        headers["accept"] = "b"
        #expect(headers.fields.map(\.name) == ["accept", "X-One", "X-Two"] && headers["ACCEPT"] == "b")
        headers["x-one"] = nil
        #expect(headers.count == 2 && headers["X-ONE"] == nil && headers["x-two"] == "2")
        headers["X-Three"] = "3"
        #expect(headers.fields.map(\.name) == ["accept", "X-Two", "X-Three"] && headers["x-three"] == "3")
        #expect(headers == ["X-TWO": "2", "ACCEPT": "b", "x-three": "3"])
    }
}
