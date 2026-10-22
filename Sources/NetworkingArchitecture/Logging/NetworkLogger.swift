import Foundation
import os

/// Logs the requests of a ``NetworkClient`` with secrets removed.
///
/// ```swift
/// var configuration = NetworkClient.Configuration()
/// configuration.monitors = [NetworkLogger(detail: .headers)]
/// ```
///
/// Every line passes through a ``Redactor`` first, which keeps only what it understands: the
/// values of allowlisted headers, parsed bodies with secret values hidden, and URLs without
/// user info, fragments or query values that are not allowlisted (see
/// <doc:RedactingSensitiveData>). Errors are written by their kind and code, never by their
/// description. Redaction is a safety net, not a guarantee. By default the lines go to the unified logging system (`os.Logger`, visible
/// in Xcode and Console) under the subsystem `NetworkingArchitecture`; pass `output` to send
/// them elsewhere. Because the text is already redacted it is logged as public, so Console
/// shows it outside the debugger too.
public struct NetworkLogger: NetworkEventMonitor {
    /// How much of each request and response is logged.
    public enum Detail: Int, Sendable, Comparable {
        /// Method, URL, status code, duration and size.
        case basic
        /// Also the header fields.
        case headers
        /// Also the bodies, as far as the redactor can show them.
        case bodies

        public static func < (lhs: Detail, rhs: Detail) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    /// How much is logged.
    public let detail: Detail

    /// Removes secrets before anything is written.
    public let redactor: Redactor

    private let output: @Sendable (String, OSLogType) -> Void

    /// Creates a logger that writes to the unified logging system.
    public init(detail: Detail = .basic, redactor: Redactor = .default, category: String = "network") {
        let logger = Logger(subsystem: "NetworkingArchitecture", category: category)
        self.init(detail: detail, redactor: redactor) { line, type in
            logger.log(level: type, "\(line, privacy: .public)")
        }
    }

    /// Creates a logger that passes every line to `output`, for example to print it or send
    /// it to your own logging system.
    public init(
        detail: Detail = .basic,
        redactor: Redactor = .default,
        output: @escaping @Sendable (String, OSLogType) -> Void
    ) {
        self.detail = detail
        self.redactor = redactor
        self.output = output
    }

    public func handle(_ event: NetworkEvent, context: RequestContext) {
        guard let line = format(event, context: context) else { return }
        output(line, Self.logType(for: event))
    }

    /// The text logged for `event`.
    public func format(_ event: NetworkEvent, context: RequestContext) -> String? {
        let id = String(context.id.uuidString.prefix(8))
        switch event {
        case .willSend(let request):
            var line = "→ [\(id)] \(request.httpMethod ?? "GET") \(redactor.displayText(of: request.url))"
            if context.attempt > 1 { line += " (attempt \(context.attempt))" }
            return line + details(headers: request.allHTTPHeaderFields.map { HTTPHeaders($0) }, body: request.httpBody,
                                  contentType: request.value(forHTTPHeaderField: "Content-Type"))
        case .didReceive(let request, let response, let duration):
            let line = "← [\(id)] \(response.statusCode) \(request.httpMethod ?? "GET") \(redactor.displayText(of: request.url))"
                + " (\(Self.milliseconds(duration)) ms, \(response.value.count) bytes)"
            return line + details(headers: response.headers, body: response.value, contentType: response.headers["Content-Type"])
        case .didFail(let request, let error, let duration):
            return "✕ [\(id)] \(request.httpMethod ?? "GET") \(redactor.displayText(of: request.url))"
                + " failed after \(Self.milliseconds(duration)) ms: \(Self.summary(of: error))"
        case .willRetry(_, let delay, let reason):
            return "↻ [\(id)] retrying in \(Self.milliseconds(delay)) ms (\(reason.rawValue))"
        }
    }

    private func details(headers: HTTPHeaders?, body: Data?, contentType: String?) -> String {
        var text = ""
        if detail >= .headers, let headers {
            for field in redactor.redact(headers: headers) {
                text += "\n    \(field.name): \(field.value)"
            }
        }
        if detail >= .bodies {
            let shown = redactor.displayText(ofBody: body, contentType: contentType)
            if !shown.isEmpty { text += "\n    \(shown)" }
        }
        return text
    }

    /// A description of the error that does not repeat URLs or response bodies.
    static func summary(of error: NetworkError) -> String {
        switch error {
        case .invalidRequest: "invalid request"
        case .encodingFailed: "the body could not be encoded"
        case .transport(let error): "URLError \(error.code.rawValue)"
        case .unacceptableStatusCode(let code, _): "status \(code)"
        case .decodingFailed(let error, _): "decoding failed (\(type(of: error)))"
        case .responseTooLarge(let limit): "response larger than \(limit) bytes"
        case .circuitOpen: "circuit open"
        case .authenticationFailed: "authentication failed"
        case .invalidResponse: "invalid response"
        case .bufferOverflow(let limit): "more than \(limit) items waiting to be read"
        case .cancelled: "cancelled"
        }
    }

    private static func milliseconds(_ duration: Duration) -> Int {
        let value = duration.timeInterval * 1_000
        guard value.isFinite else { return 0 }
        return Int(max(0, min(value, Double(Int32.max))).rounded())
    }

    private static func logType(for event: NetworkEvent) -> OSLogType {
        switch event {
        case .didFail: .error
        case .didReceive(_, let response, _) where response.statusCode >= 400: .error
        default: .debug
        }
    }
}
