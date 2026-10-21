import Foundation

extension Redactor {
    /// The URL as a display string, with its credentials, query values and identifiers hidden.
    ///
    /// The URL is read with `URLComponents`:
    ///
    /// - The user name and password (`user:password@`) and the fragment (`#…`) are never written.
    /// - **Host:** the host is a key of the URL. It is written only when it is a name of ASCII
    ///   letters, digits and `-` in labels separated by `.`, an IPv4 address or an IPv6 address in
    ///   brackets, and the value detectors find nothing in it (a card number, a run of 32 hex
    ///   digits, a token). Any other host — one with `=`, `;`, `%`, `_` or letters outside ASCII,
    ///   such as `password=hunter2` in `myapp://password=hunter2` — is written as `[REDACTED]`
    ///   after the scheme, with nothing after it. A host that names a secret, by the key rule or as
    ///   a word, is written with the scheme and port only, as the path after it is its value: with
    ///   a scheme of the app's own `URLComponents` reads the first part after `//` as the host, so
    ///   `myapp://pin/4831` has the host `pin` and is written as `myapp://pin`. A host such as
    ///   `auth.example.com` names `auth` and hides its whole path too, which over-hides on purpose.
    /// - **Query:** a parameter keeps its value only when its name, decoded, is plain ASCII and on
    ///   ``allowedQueryParameters``, which is empty by default; any other value is `[REDACTED]`,
    ///   and so is a parameter without `=` that is not on the list. A name that is not plain
    ///   ASCII, or holds a card number, an address or a token, is `[REDACTED]` as well, and a
    ///   parameter that names a secret in its value (`?label=Password&value=…`) hides the others.
    ///   A query that servers could split into fields differently is written as `?[REDACTED]`, as
    ///   ``redact(body:contentType:isComplete:)`` describes for forms: one with a `;`, a `%` that
    ///   does not start an escape, or a name spelled two ways.
    /// - **Path:** a segment that looks like an identifier or a secret becomes `:id`: a UUID, a
    ///   number of six or more digits, a token of 16 or more letters and digits, a run of 32 or more
    ///   hex or Base64 characters, a JSON Web Token, anything the value detectors find, and text
    ///   the free-text rule would change. The segment after one that names a secret, or is not a
    ///   plain-ASCII name of ASCII letters, digits, `_`, `-`, `.` and spaces, is a value too and
    ///   becomes `:id` whatever it looks like (`/pin/4831`, `/token/…/info`, `/şifre/…`,
    ///   `/p%0Ain/…`, `/a,b/…`).
    /// - **A path that servers resolve differently** — with a dot segment (`/pin/./4831`,
    ///   `/token/x/../…`), a `;` anywhere (`/a;pin/4831`, `/cart;jsessionid=…`), or an escaped
    ///   `.`, `/`, `\`, `;` or `%` (`%2E`, `%2F`, `%5C`, `%3B`, `%25`, in either case) — is not
    ///   written: only the scheme, host and port are, as which segment follows a secret name
    ///   depends on the server (RFC 3986 §5.2.4). Parameters after a `;` are not read at all.
    /// - A path of more than ``maximumPathSegments`` segments, or a query of more than
    ///   ``maximumQueryParameters`` parameters, is not read: only the scheme, host and port are
    ///   written. So is every URL with ``URLDetail/hostOnly``.
    ///
    /// A URL that `URLComponents` cannot parse, or that has no scheme or no host, is written as
    /// ``unparsedURL``.
    ///
    /// ```swift
    /// Redactor.default.redact(url: URL(string: "https://bob:pw@example.com/users/12345678/reset?code=x#y")!)
    /// // https://example.com/users/:id/reset?code=[REDACTED]
    /// ```
    public func redact(url: URL) -> String {
        guard isEnabled else { return url.absoluteString }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return Self.unparsedURL }
        let length = url.absoluteString.unicodeScalars.count
        return redacted(components, nesting: .document(length: length), compatibility: CompatibilityText(length: length))
    }

    /// A URL written in text, recorded as ``redact(url:)`` records it. `nesting` is the URL's own:
    /// its query values and path segments are read as text inside it; `compatibility` is the
    /// readings table of the text.
    func redactedURL(_ text: String, nesting: Nesting, compatibility: CompatibilityText) -> String {
        guard let components = URLComponents(string: text) else { return Self.unparsedURL }
        return redacted(components, nesting: nesting, compatibility: compatibility)
    }

    /// The URL; one readings table serves its host, every path segment and every parameter.
    private func redacted(_ components: URLComponents, nesting: Nesting, compatibility: CompatibilityText) -> String {
        guard let scheme = components.scheme, let host = components.percentEncodedHost else { return Self.unparsedURL }
        guard showsHost(host, compatibility: compatibility) else { return scheme + "://" + Self.replacement }
        var result = scheme + "://" + host
        if let port = components.port { result += ":\(port)" }
        let path = components.percentEncodedPath
        guard urlDetail == .full, !Self.exceedsLimits(components), !Self.resolvesDifferently(path: path) else { return result }
        if Self.hostNamesSecret(host, compatibility: compatibility) { return result }
        result += redacted(path: path, nesting: nesting, compatibility: compatibility)
        if let query = components.percentEncodedQuery, !Self.isStrictForm(query) { return result + "?" + Self.replacement }
        if let items = components.percentEncodedQueryItems {
            // `?label=Password&value=…`: a parameter that names a secret hides the others.
            let field = { (item: URLQueryItem) in Self.namingField(name: Self.formDecoded(item.name) ?? "", value: item.value.flatMap(Self.formDecoded)) }
            let naming = NamingFields(items.lazy.map(field), compatibility: compatibility)
            let parameters = items.indices.map { index in
                redacted(
                    parameter: items[index].name, value: items[index].value, hidesValue: naming.hidesValue(at: index, of: field(items[index])),
                    nesting: nesting, compatibility: compatibility)
            }
            result += "?" + parameters.joined(separator: "&")
        }
        return result
    }

    /// Whether a host is written: empty, as in `file:///…`, or an address, in which the value
    /// detectors find nothing.
    func showsHost(_ host: String, compatibility: CompatibilityText) -> Bool {
        guard !host.isEmpty else { return true }
        let bytes = Array(host.utf8)
        guard Self.isHostName(bytes) || Self.isIPv4Address(bytes) || Self.isIPv6Literal(bytes) else { return false }
        return detectorSpans(in: NormalizedText(Array(host.unicodeScalars), compatibility: compatibility)).isEmpty
    }

    /// Whether a host names a secret, by the key rule (``FieldName/hidesValue(_:)``) or as a word
    /// that makes the path segment after it a value (``FreeTextScanner/mentionsSecret(_:compatibility:)``).
    /// In `myapp://pin/4831` `URLComponents` reads `pin` as the host, so the path after it is
    /// the value a segment `pin` would label: only the scheme, host and port are written. An
    /// IPv4 or IPv6 address names nothing.
    static func hostNamesSecret(_ host: String, compatibility: CompatibilityText) -> Bool {
        let bytes = Array(host.utf8)
        guard !bytes.isEmpty, !isIPv4Address(bytes), !isIPv6Literal(bytes) else { return false }
        return FieldName.hidesValue(host.unicodeScalars) || FreeTextScanner.mentionsSecret(Array(host.unicodeScalars), compatibility: compatibility)
    }

    /// The longest host name, in bytes, and the longest label in it.
    private static let longestHostName = 253
    private static let longestLabel = 63

    /// Whether a host is a name of labels of ASCII letters, digits and `-` that neither starts nor
    /// ends a label, separated by `.`, with an optional `.` at the end.
    static func isHostName(_ bytes: [UInt8]) -> Bool {
        guard bytes.count <= longestHostName else { return false }
        var labels = bytes.split(separator: UInt8(ascii: "."), omittingEmptySubsequences: false)
        if labels.count > 1, labels.last?.isEmpty == true { labels.removeLast() }
        return labels.allSatisfy { label in
            guard let first = label.first, let last = label.last, label.count <= longestLabel else { return false }
            return first != UInt8(ascii: "-") && last != UInt8(ascii: "-")
                && label.allSatisfy { ASCII.isAlphanumeric($0) || $0 == UInt8(ascii: "-") }
        }
    }

    /// Whether a host is four decimal numbers from 0 to 255 separated by `.`.
    static func isIPv4Address(_ bytes: [UInt8]) -> Bool {
        let parts = bytes.split(separator: UInt8(ascii: "."), omittingEmptySubsequences: false)
        return parts.count == 4 && parts.allSatisfy { part in
            (1...3).contains(part.count) && part.allSatisfy(ASCII.isDigit) && Int(String(decoding: part, as: UTF8.self)).map { $0 <= 255 } == true
        }
    }

    /// Whether a host is an IPv6 address in brackets: hex digits, `:` and the `.` of an IPv4 tail,
    /// without a zone (`%25en0`).
    static func isIPv6Literal(_ bytes: [UInt8]) -> Bool {
        guard bytes.count > 2, bytes.first == UInt8(ascii: "["), bytes.last == UInt8(ascii: "]") else { return false }
        let inside = bytes.dropFirst().dropLast()
        return inside.contains(UInt8(ascii: ":")) && inside.allSatisfy { byte in
            ASCII.isDigit(byte) || (UInt8(ascii: "a")...UInt8(ascii: "f")).contains(byte | 0x20) || byte == UInt8(ascii: ":") || byte == UInt8(ascii: ".")
        }
    }

    /// Whether the path has more than ``maximumPathSegments`` segments, or the query more than
    /// ``maximumQueryParameters`` parameters. Each segment and parameter is read on its own, so
    /// the count bounds the work a URL can ask for; real URLs stay far below both.
    static func exceedsLimits(_ components: URLComponents) -> Bool {
        if components.percentEncodedPath.utf8.count(where: { $0 == UInt8(ascii: "/") }) > maximumPathSegments { return true }
        guard let query = components.percentEncodedQuery else { return false }
        return query.utf8.count(where: { $0 == UInt8(ascii: "&") }) >= maximumQueryParameters
    }

    /// Whether servers could resolve the path to other segments than it is written with: it has a
    /// dot segment (`.`, `..`), a `;`, or a `.`, `/`, `\`, `;` or `%` written as an escape (`%2E`,
    /// `%2F`, `%5C`, `%3B`, `%25`, in either case). Servers remove dot segments and decode escapes
    /// before routing, and one that decodes twice reads `%25` as another escape; a `;` in a
    /// segment starts parameters for a Java servlet but is part of the segment for Express, Go,
    /// Rails, Django and ASP.NET Core (`/a;pin/4831` is `a` and the parameter `pin`, or the segment
    /// `a;pin`). Which segment follows the one that names a secret then depends on the server
    /// (`/pin/./4831`, `/token/x/../…`, `/a;pin/4831`), so no segment of such a path is written.
    static func resolvesDifferently(path: String) -> Bool {
        let bytes = Array(path.utf8)
        if bytes.contains(UInt8(ascii: ";")) { return true }
        for (i, byte) in bytes.enumerated() where byte == UInt8(ascii: "%") && i + 2 < bytes.count {
            let escape = [bytes[i + 1], bytes[i + 2] | 0x20]
            if Self.ambiguousEscapes.contains(escape) { return true }
        }
        return bytes.split(separator: UInt8(ascii: "/"), omittingEmptySubsequences: false).contains { segment in
            segment.elementsEqual(".".utf8) || segment.elementsEqual("..".utf8)
        }
    }

    /// The escapes of `.`, `/`, `\`, `;` and `%`, the hex letter in lowercase.
    private static let ambiguousEscapes: Set<[UInt8]> = [Array("2e".utf8), Array("2f".utf8), Array("5c".utf8), Array("3b".utf8), Array("25".utf8)]

    /// The path segment by segment. A segment after one that names a secret, cannot be read or is
    /// not a plain-ASCII name (`/pin/4831`, `/password-reset/…`, `/token/…/info`, `/şifre/…`,
    /// `/p%0Ain/…`, `/a,b/…`) is a value, so it becomes `:id` whatever it looks like. A segment that comes
    /// again is not read again. The path has no `;` (see ``resolvesDifferently(path:)``).
    private func redacted(path: String, nesting: Nesting, compatibility: CompatibilityText) -> String {
        var readings: [Substring: PathSegmentReading] = [:]
        var segments: [String] = []
        var followsLabel = false
        for segment in path.split(separator: "/", omittingEmptySubsequences: false) {
            guard !segment.isEmpty else {
                segments.append("")
                continue
            }
            let reading = readings[segment] ?? read(pathSegment: segment, nesting: nesting, compatibility: compatibility)
            readings[segment] = reading
            segments.append(followsLabel || reading.hides ? Self.identifierPlaceholder : String(segment))
            followsLabel = reading.isLabel
        }
        return segments.joined(separator: "/")
    }

    /// What a path segment is, from one reading of it.
    private struct PathSegmentReading {
        /// It looks like an identifier or holds a secret, so it becomes `:id`.
        let hides: Bool
        /// It has a word that names a secret or cannot be read, or it is not a plain-ASCII name
        /// (see ``PlainName``), so the segment after it is a value.
        let isLabel: Bool
    }

    /// Reads a path segment once: it is decoded and scanned a single time, and the free-text rule,
    /// every value detector and the word reading all run on that scan. A segment that does not
    /// decode is both. A segment is a label by the one rule for names (see
    /// ``WrittenName/nameNamesSecret(_:byKeyRule:compatibility:)``), as a name held by a field
    /// is: unless it is a plain-ASCII name — ASCII letters and digits, `_`, `-`, `.` and spaces —
    /// that names no secret, the segment after it becomes `:id`, since a letter outside ASCII, a
    /// control character or other punctuation may disguise a secret name. `:id`, which the
    /// redactor writes for a segment, is not a label, so a path that is already redacted reads
    /// the same again.
    private func read(pathSegment segment: Substring, nesting: Nesting, compatibility: CompatibilityText) -> PathSegmentReading {
        guard let decoded = segment.removingPercentEncoding else { return PathSegmentReading(hides: true, isLabel: true) }
        let scalars = Array(decoded.unicodeScalars)
        guard !scalars.isEmpty else { return PathSegmentReading(hides: false, isLabel: false) }
        let isIdentifier = UUID(uuidString: decoded) != nil || Self.isIdentifierShaped(scalars)
        guard !Self.isQuietWord(scalars) else { return PathSegmentReading(hides: isIdentifier, isLabel: false) }
        let text = NormalizedText(scalars, compatibility: compatibility)
        let holdsSecret = !textSpans(in: scalars, text: text, compatibility: compatibility, nesting: nesting, detectsInRegions: true).isEmpty
        let isLabel = decoded != Self.identifierPlaceholder
            && (FreeTextScanner.mentionsSecret(scalars, text: text, compatibility: compatibility)
                || WrittenName.nameNamesSecret(scalars, byKeyRule: true, compatibility: compatibility))
        return PathSegmentReading(hides: isIdentifier || holdsSecret, isLabel: isLabel)
    }

    /// `name=value` from a query, both percent-encoded. The value is kept only when the name is
    /// allowed and no other parameter names a secret (`hidesValue`). An empty field, as between
    /// `&&`, stays empty.
    private func redacted(
        parameter rawName: String, value rawValue: String?, hidesValue: Bool, nesting: Nesting, compatibility: CompatibilityText
    ) -> String {
        if rawName.isEmpty, rawValue == nil { return "" }
        let name = Self.formDecoded(rawName)
        let shownName = name.map { PlainName($0.unicodeScalars) != nil && redactedName($0, nesting: nesting, compatibility: compatibility) == $0 } == true
            ? rawName : Self.replacement
        let allowed = name.flatMap { FieldName.allowableFold($0.unicodeScalars) }.map(allowedQueryParameters.contains) ?? false
        guard let rawValue else { return allowed ? shownName : Self.replacement }
        guard !rawValue.isEmpty else { return shownName + "=" }
        guard allowed, !hidesValue, let value = Self.formDecoded(rawValue) else { return shownName + "=" + Self.replacement }
        let redactedValue = redact(value, nesting: nesting, compatibility: compatibility)
        return shownName + "=" + (redactedValue == value ? rawValue : Self.formEncoded(redactedValue))
    }

    /// Path segments of letters and digits at least this long are treated as tokens.
    static let mixedTokenLength = 16

    /// Whether a decoded path segment is a number of six or more digits or a token of 16 or more
    /// letters, digits, `-` and `_` with both letters and digits.
    private static func isIdentifierShaped(_ scalars: [Unicode.Scalar]) -> Bool {
        guard scalars.allSatisfy(\.isASCII) else { return false }
        let bytes = scalars.map { UInt8($0.value) }
        if bytes.count >= 6, bytes.allSatisfy(ASCII.isDigit) { return true }
        let isToken = bytes.allSatisfy { ASCII.isAlphanumeric($0) || $0 == UInt8(ascii: "-") || $0 == UInt8(ascii: "_") }
        return isToken && bytes.count >= mixedTokenLength && bytes.contains(where: ASCII.isLetter) && bytes.contains(where: ASCII.isDigit)
    }
}
