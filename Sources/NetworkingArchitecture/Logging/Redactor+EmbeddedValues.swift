import Foundation

extension Redactor {
    /// How many times a value nested in another value (a URL in a query value, which holds
    /// another URL, …) is opened before a value that still holds fields is hidden unread.
    private static let maximumNesting = 4

    /// Whether `value` is a secret or carries one: a credential, a URL with a user name or
    /// password, JSON with a sensitive key, or text with `name=value` fields (a URL query,
    /// fragment or path parameter, or a form) in which a name is sensitive or a value carries
    /// a secret in turn.
    ///
    /// The fields are found by splitting the decoded text at `?`, `#`, `&` and `;` rather than
    /// by a URL parser, so text that no parser accepts is still read, and a value keeps its
    /// spaces (`note=Bearer abc` is a credential). A `+` in a field value is read as a space,
    /// as in a query or form, so `note=Bearer+abc` is a credential too.
    func containsSecret(_ value: String) -> Bool {
        containsSecret(value, nesting: 0)
    }

    private func containsSecret(_ value: String, nesting: Int) -> Bool {
        let decoded = Self.fullyDecoded(value)
        if looksLikeCredential(decoded) || Self.hasUserInfo(decoded) {
            return true
        }
        if Self.startsLikeJSON(decoded), let verdict = embeddedJSONContainsSecret(decoded, nesting: nesting) {
            return verdict
        }
        let fields = Self.embeddedFields(in: decoded)
        // Text still percent-encoded after `fullyDecoded` gave up is opened one level further.
        let stillEncoded = decoded.removingPercentEncoding.map { $0 != decoded } ?? false
        guard nesting < Self.maximumNesting else {
            return stillEncoded || !fields.isEmpty
        }
        if stillEncoded, containsSecret(decoded, nesting: nesting + 1) {
            return true
        }
        return fields.contains { field in
            isSensitive(field.name) || containsSecret(Self.plusAsSpace(field.value), nesting: nesting + 1)
        }
    }

    /// The text with every `+` read as a space, as in a URL query or form value.
    static func plusAsSpace(_ text: String) -> String {
        text.replacingOccurrences(of: "+", with: " ")
    }

    /// Whether JSON text held in a value, such as `{"access_token":"…"}` in a query value, a
    /// header or a JSON string, has a sensitive key or a value that carries a secret; `nil`
    /// when the text is not JSON. Text longer than ``maximumParsedBodySize``, or JSON at the
    /// nesting limit, counts as a secret without being read.
    private func embeddedJSONContainsSecret(_ text: String, nesting: Int) -> Bool? {
        let data = Data(text.utf8)
        guard data.count <= maximumParsedBodySize, nesting < Self.maximumNesting else { return true }
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return jsonContainsSecret(object, nesting: nesting + 1, depth: 0)
    }

    private func jsonContainsSecret(_ value: Any, nesting: Int, depth: Int) -> Bool {
        guard depth < Self.maximumDepth else { return true }
        switch value {
        case let dictionary as [String: Any]:
            return dictionary.contains { key, nested in
                isSensitive(key) || jsonContainsSecret(nested, nesting: nesting, depth: depth + 1)
            }
        case let array as [Any]:
            return array.contains { jsonContainsSecret($0, nesting: nesting, depth: depth + 1) }
        case let string as String:
            return containsSecret(string, nesting: nesting)
        default:
            return false
        }
    }

    private static func startsLikeJSON(_ text: String) -> Bool {
        let first = text.first { !$0.isWhitespace }
        return first == "{" || first == "["
    }

    /// The `name=value` pairs in text such as `https://x/cb;a=1?b=2#c=3` or `b=2&c=3`.
    private static func embeddedFields(in text: String) -> [(name: String, value: String)] {
        text.split { "?#&;".contains($0) }.compactMap { piece -> (name: String, value: String)? in
            let parts = piece.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { return nil }
            return (String(parts[0]), String(parts[1]))
        }
    }

    /// Whether the text holds a URL with a user name or password, as in `https://ada:pw@host`.
    private static func hasUserInfo(_ text: String) -> Bool {
        var remaining = Substring(text)
        while let separator = remaining.range(of: "://") {
            let authority = remaining[separator.upperBound...].prefix { !"/?#".contains($0) && !$0.isWhitespace }
            if authority.contains("@") {
                return true
            }
            remaining = remaining[separator.upperBound...]
        }
        return false
    }
}
