import Foundation

extension URLRequest {
    /// A `curl` command line that sends this request, for reproducing it in a terminal.
    ///
    /// ```swift
    /// print(request.curlCommand())
    /// // curl -X 'POST' 'https://api.example.com/login' -H 'Authorization: [REDACTED]' --data-binary '{"user":"ada"}'
    /// ```
    ///
    /// Every argument is single-quoted for POSIX shells, so a value cannot run a command when
    /// the line is pasted. With a `redactor` (the default) secrets are replaced as in the logs,
    /// which keeps the command safe to share but means it may need the real values filled in
    /// before it works; pass `nil` to get the request exactly.
    public func curlCommand(redactor: Redactor? = .default) -> String {
        var parts = ["curl"]
        let method = httpMethod ?? "GET"
        if method != "GET" {
            parts += ["-X", Self.quoted(method)]
        }
        parts.append(Self.quoted(redactor?.displayText(of: url) ?? url?.absoluteString ?? ""))

        var headers = HTTPHeaders(allHTTPHeaderFields ?? [:])
        if let redactor {
            headers = redactor.redact(headers: headers)
        }
        for field in headers {
            parts += ["-H", Self.quoted("\(field.name): \(field.value)")]
        }

        if let body = httpBody, !body.isEmpty {
            let text: String?
            if let redactor {
                text = redactor.displayText(ofBody: body, contentType: value(forHTTPHeaderField: "Content-Type"))
            } else {
                text = String(data: body, encoding: .utf8)
            }
            if let text {
                parts += ["--data-binary", Self.quoted(text)]
            } else {
                parts.append("# \(body.count) bytes of binary body not shown")
            }
        }
        return parts.joined(separator: " ")
    }

    /// Wraps `text` in single quotes, closing and reopening them around each quote inside.
    static func quoted(_ text: String) -> String {
        "'" + text.replacingOccurrences(of: "'", with: #"'\''"#) + "'"
    }
}
