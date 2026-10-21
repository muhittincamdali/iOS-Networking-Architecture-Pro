import Foundation
@testable import NetworkingArchitecture

/// What this library writes for a request or a response: the lines of
/// ``NetworkLogger`` at ``NetworkLogger/Detail/bodies`` and the `curl` command. The shared
/// redaction test corpus checks them where it checked the network inspector of the library it
/// was written for.
enum LoggedOutput {
    /// The lines the logger writes before `request` is sent, and its `curl` command.
    static func request(_ request: URLRequest, redactor: Redactor = .default) -> String {
        let logger = NetworkLogger(detail: .bodies, redactor: redactor) { _, _ in }
        let line = logger.format(.willSend(request), context: RequestContext(retryPolicy: .none)) ?? ""
        return line + "\n" + request.curlCommand(redactor: redactor)
    }

    /// The body as the logger writes it for a response with this body and content type: the text
    /// after the indented `Content-Type` line.
    static func responseBody(_ body: Data, contentType: String, redactor: Redactor = .default) -> String {
        let request = URLRequest(url: URL(string: "https://api.example.com/a")!)
        let response = HTTPResponse(value: body, statusCode: 200, headers: ["Content-Type": contentType])
        let logger = NetworkLogger(detail: .bodies, redactor: redactor) { _, _ in }
        let line = logger.format(.didReceive(request, response, duration: .zero), context: RequestContext(retryPolicy: .none)) ?? ""
        // The status line, the header line, then the body, each after a line feed and four spaces.
        return line.components(separatedBy: "\n    ").dropFirst(2).joined(separator: "\n    ")
    }

    /// A plain-text response body as the logger writes it.
    static func plainTextBody(_ text: String, redactor: Redactor = .default) -> String {
        responseBody(Data(text.utf8), contentType: "text/plain; charset=utf-8", redactor: redactor)
    }
}
