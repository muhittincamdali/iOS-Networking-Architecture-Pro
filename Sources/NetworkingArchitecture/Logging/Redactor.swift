import Foundation

/// Removes secrets from URLs, headers and bodies before they are logged.
///
/// A name is compared after lower-casing it and dropping everything but letters and digits,
/// so `access_token`, `Access-Token`, `accessToken` and `ACCESS%5FTOKEN` are the same name.
/// A name is sensitive when it equals one of ``sensitiveNames`` or contains one of
/// ``sensitiveNameFragments``. Values are also hidden wherever they appear when they look
/// like credentials: `Bearer …` and `Basic …` values and JSON Web Tokens.
///
/// Bodies are shown only when they can be parsed: JSON (every nested sensitive key is
/// hidden) and URL-encoded forms. Other bodies, such as XML or plain text, are summarised
/// by size, because a secret in free text cannot be found reliably.
///
/// Redaction is a safety net for logs, not a guarantee: a secret in a URL path segment
/// (`/reset/8f2a…`) or under an unusual name is not recognised. Add your own names to
/// ``sensitiveNames`` and ``sensitiveNameFragments``.
public struct Redactor: Sendable {
    /// Exact names whose values are hidden. Names are normalised when you set them, so
    /// inserting `"customerReference"` also covers `customer_reference`.
    public var sensitiveNames: Set<String> {
        get { normalizedNames }
        set { normalizedNames = Set(newValue.map(Self.normalize)) }
    }

    /// Parts of names whose values are hidden, such as `token` in `refresh_token`. They are
    /// normalised when you set them.
    public var sensitiveNameFragments: [String] {
        get { normalizedFragments }
        set { normalizedFragments = newValue.map(Self.normalize).filter { !$0.isEmpty } }
    }

    private var normalizedNames: Set<String> = []
    private var normalizedFragments: [String] = []

    /// The text that replaces a hidden value.
    public var replacement: String

    /// The longest body text shown, in characters; longer bodies are cut.
    public var maximumBodyLength: Int

    /// Bodies larger than this many bytes are summarised without being parsed.
    public var maximumParsedBodySize: Int

    /// Creates a redactor. The defaults cover common credential and personal-data names.
    public init(
        sensitiveNames: Set<String> = Redactor.defaultNames,
        sensitiveNameFragments: [String] = Redactor.defaultFragments,
        replacement: String = "<redacted>",
        maximumBodyLength: Int = 4_096,
        maximumParsedBodySize: Int = 1_048_576
    ) {
        self.normalizedNames = Set(sensitiveNames.map(Self.normalize))
        self.normalizedFragments = sensitiveNameFragments.map(Self.normalize).filter { !$0.isEmpty }
        self.replacement = replacement
        self.maximumBodyLength = max(0, maximumBodyLength)
        self.maximumParsedBodySize = max(0, maximumParsedBodySize)
    }

    /// The default redactor.
    public static let `default` = Redactor()

    /// Short names that are only sensitive as a whole word (`pin`, but not `shipping`).
    public static let defaultNames: Set<String> = [
        "pin", "otp", "cvv", "cvc", "ssn", "iban", "auth", "code", "sid", "jwt", "pass", "pwd", "key"
    ]

    /// Fragments that make any name containing them sensitive.
    public static let defaultFragments: [String] = [
        "password", "passwd", "passphrase", "secret", "token", "apikey", "accesskey", "privatekey",
        "authorization", "credential", "cookie", "session", "signature", "creditcard", "cardnumber",
        "securitycode", "clientsecret"
    ]

    /// Whether values under `name` are hidden.
    public func isSensitive(_ name: String) -> Bool {
        let normalized = Self.normalize(Self.fullyDecoded(name))
        return normalizedNames.contains(normalized) || normalizedFragments.contains { normalized.contains($0) }
    }

    /// The headers with sensitive values replaced.
    public func redact(_ headers: HTTPHeaders) -> HTTPHeaders {
        var result = HTTPHeaders()
        for field in headers {
            result[field.name] = isSensitive(field.name) || looksLikeCredential(field.value) ? replacement : field.value
        }
        return result
    }

    /// The URL as text with the user name, password, fragment and sensitive query values
    /// replaced.
    public func redact(_ url: URL?) -> String {
        guard let url else { return "<no URL>" }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return replacement }
        // Assembled by hand: URLComponents traps when a percent-encoded part is set to text
        // with characters such as "<", which the replacement may contain.
        var text = components.scheme.map { "\($0)://" } ?? ""
        if components.percentEncodedUser != nil || components.percentEncodedPassword != nil {
            text += replacement + "@"
        }
        text += components.percentEncodedHost ?? ""
        if let port = components.port {
            text += ":\(port)"
        }
        text += components.percentEncodedPath
        if let items = components.percentEncodedQueryItems {
            text += "?" + items.map { item in
                let hide = isSensitive(item.name) || looksLikeCredential(Self.fullyDecoded(item.value ?? ""))
                guard let value = item.value else { return item.name }
                return item.name + "=" + (hide ? replacement : value)
            }.joined(separator: "&")
        }
        if let fragment = components.percentEncodedFragment, !fragment.isEmpty {
            text += "#" + replacement
        }
        return text
    }

    /// The body as loggable text: parsed and redacted JSON or form data, or a size summary.
    public func redact(body: Data?, contentType: String?) -> String {
        guard let body, !body.isEmpty else { return "" }
        guard body.count <= maximumParsedBodySize else { return "<\(body.count) bytes, not shown>" }
        let type = contentType?.lowercased() ?? ""
        if type.contains("json") || (type.isEmpty && Self.startsLikeJSON(body)),
           let object = try? JSONSerialization.jsonObject(with: body, options: [.fragmentsAllowed]) {
            let redacted = redactJSON(object, depth: 0)
            if let data = try? JSONSerialization.data(withJSONObject: redacted, options: [.sortedKeys, .fragmentsAllowed, .withoutEscapingSlashes]) {
                return truncate(String(decoding: data, as: UTF8.self))
            }
        }
        if type.contains("x-www-form-urlencoded"), let text = String(data: body, encoding: .utf8) {
            let form = URLEncodedForm(decoding: text)
            let redacted = URLEncodedForm(form.fields.map { field in
                isSensitive(field.name) || looksLikeCredential(field.value)
                    ? URLEncodedForm.Field(name: field.name, value: replacement) : field
            })
            return truncate(redacted.encodedString.replacingOccurrences(of: URLEncodedForm.encode(replacement), with: replacement))
        }
        return "<\(body.count) bytes\(type.isEmpty ? "" : " of \(type)"), not shown>"
    }

    // MARK: - Helpers

    private static let maximumDepth = 64

    private func redactJSON(_ value: Any, depth: Int) -> Any {
        guard depth < Self.maximumDepth else { return replacement }
        switch value {
        case let dictionary as [String: Any]:
            var result: [String: Any] = [:]
            for (key, nested) in dictionary {
                result[key] = isSensitive(key) ? replacement : redactJSON(nested, depth: depth + 1)
            }
            return result
        case let array as [Any]:
            return array.map { redactJSON($0, depth: depth + 1) }
        case let string as String:
            return looksLikeCredential(string) ? replacement : string
        default:
            return value
        }
    }

    /// `Bearer …`, `Basic …` and JSON Web Tokens (`eyJ….….…`).
    func looksLikeCredential(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        let lowercased = trimmed.lowercased()
        if lowercased.hasPrefix("bearer ") || lowercased.hasPrefix("basic ") || lowercased.hasPrefix("digest ") {
            return true
        }
        let segments = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        return trimmed.hasPrefix("eyJ") && segments.count == 3 && segments.allSatisfy { segment in
            !segment.isEmpty && segment.unicodeScalars.allSatisfy { Self.base64URL.contains($0) }
        }
    }

    private static let base64URL = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=")

    private func truncate(_ text: String) -> String {
        guard text.count > maximumBodyLength else { return text }
        return String(text.prefix(maximumBodyLength)) + "… (\(text.count - maximumBodyLength) more characters)"
    }

    private static func startsLikeJSON(_ data: Data) -> Bool {
        guard let first = data.first(where: { !($0 == 0x20 || $0 == 0x0A || $0 == 0x0D || $0 == 0x09) }) else { return false }
        return first == UInt8(ascii: "{") || first == UInt8(ascii: "[")
    }

    /// Maps compatibility characters, lower-cases, and keeps only letters and digits, which
    /// also drops zero-width and other invisible characters.
    static func normalize(_ name: String) -> String {
        // Compatibility mapping turns full-width and other look-alike forms into plain letters.
        String(name.precomposedStringWithCompatibilityMapping.lowercased().unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }.map(Character.init))
    }

    /// Removes percent-encoding, repeatedly, so `%255F` cannot hide an underscore.
    static func fullyDecoded(_ text: String) -> String {
        var current = text
        for _ in 0..<4 {
            guard let decoded = current.removingPercentEncoding, decoded != current else { break }
            current = decoded
        }
        return current
    }
}
