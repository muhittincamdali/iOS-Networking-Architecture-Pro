@testable import NetworkingArchitecture

/// A header name and value in a list that keeps duplicates and order, as the shared redaction
/// test corpus writes headers.
struct HTTPHeader: Sendable, Hashable {
    let name: String
    let value: String
}

extension Redactor {
    /// Each header as ``Redactor/redact(headers:)`` records it, one at a time, so a list with the
    /// same name twice keeps both entries.
    func redact(headers: [HTTPHeader]) -> [HTTPHeader] {
        headers.map { header in
            let redacted = redact(headers: HTTPHeaders([header.name: header.value]))
            return HTTPHeader(name: header.name, value: redacted[header.name] ?? "")
        }
    }
}
