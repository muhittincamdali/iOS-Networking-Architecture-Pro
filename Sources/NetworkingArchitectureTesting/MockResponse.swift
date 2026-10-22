import Foundation
import NetworkingArchitecture

/// A canned answer for ``MockTransport``.
///
/// ```swift
/// try .json(User(id: 1, name: "Ada"))
/// .status(503, headers: ["Retry-After": "1"])
/// .failure(.notConnectedToInternet)
/// .text("data: hello\n\n", chunks: 3)          // streamed in three pieces
/// ```
public struct MockResponse: Sendable {
    /// The status code.
    public var statusCode: Int

    /// The response headers.
    public var headers: HTTPHeaders

    /// The body.
    public var body: Data

    /// How long the transport waits before answering. The wait ends early, with a
    /// cancellation error, when the request's task is cancelled.
    public var delay: Duration

    /// When not `nil`, the transport fails with this error instead of answering.
    public var error: URLError?

    /// How many pieces ``MockTransport/stream(_:)`` splits the body into.
    public var chunkCount: Int

    /// The pause between two streamed pieces.
    public var chunkDelay: Duration

    /// Creates a response. See the properties for what each value means.
    public init(
        statusCode: Int = 200,
        headers: HTTPHeaders = [:],
        body: Data = Data(),
        delay: Duration = .zero,
        error: URLError? = nil,
        chunkCount: Int = 1,
        chunkDelay: Duration = .zero
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.delay = delay
        self.error = error
        self.chunkCount = max(1, chunkCount)
        self.chunkDelay = chunkDelay
    }

    /// A response whose body is `value` encoded as JSON.
    public static func json(
        _ value: some Encodable,
        statusCode: Int = 200,
        headers: HTTPHeaders = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> MockResponse {
        var headers = headers
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json"
        }
        return MockResponse(statusCode: statusCode, headers: headers, body: try encoder.encode(value))
    }

    /// A response whose body is `text`, streamed in `chunks` pieces by
    /// ``MockTransport/stream(_:)``.
    public static func text(
        _ text: String,
        statusCode: Int = 200,
        headers: HTTPHeaders = ["Content-Type": "text/plain; charset=utf-8"],
        chunks: Int = 1,
        chunkDelay: Duration = .zero
    ) -> MockResponse {
        MockResponse(
            statusCode: statusCode, headers: headers, body: Data(text.utf8),
            chunkCount: chunks, chunkDelay: chunkDelay
        )
    }

    /// A response with an empty body.
    public static func status(_ statusCode: Int, headers: HTTPHeaders = [:]) -> MockResponse {
        MockResponse(statusCode: statusCode, headers: headers)
    }

    /// A transport failure, such as `.notConnectedToInternet`.
    public static func failure(_ code: URLError.Code) -> MockResponse {
        MockResponse(error: URLError(code))
    }

    /// The same response, answered after `delay`.
    public func delayed(by delay: Duration) -> MockResponse {
        var copy = self
        copy.delay = delay
        return copy
    }

    /// The body split into ``chunkCount`` pieces of about the same size.
    var chunks: [Data] {
        let bytes = Data(body)
        guard chunkCount > 1, bytes.count > 1 else { return bytes.isEmpty ? [] : [bytes] }
        let size = Int((Double(bytes.count) / Double(min(chunkCount, bytes.count))).rounded(.up))
        return stride(from: 0, to: bytes.count, by: size).map { start in
            bytes.subdata(in: start..<min(start + size, bytes.count))
        }
    }
}
