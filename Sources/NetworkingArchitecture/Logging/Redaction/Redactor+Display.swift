import Foundation

/// The redacted text that ``NetworkLogger`` and `URLRequest.curlCommand(redactor:)` write.
extension Redactor {
    /// The text written for a request's URL: ``redact(url:)``, or `<no URL>`.
    func displayText(of url: URL?) -> String {
        guard let url else { return "<no URL>" }
        return redact(url: url)
    }

    /// The text written for a body: the redacted body as UTF-8, a note such as
    /// `[body omitted: 512 bytes, application/xml]`, or an empty string when there is no body.
    func displayText(ofBody body: Data?, contentType: String?) -> String {
        guard let body, !body.isEmpty else { return "" }
        let redacted = redact(body: body, contentType: contentType).body
        // Only a disabled redactor returns bytes it did not write; they may not be UTF-8.
        return BodyText.utf8(redacted, dropsByteOrderMark: true) ?? "[\(body.count) bytes of binary body not shown]"
    }
}
