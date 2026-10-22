import Foundation

/// HTTP header fields, looked up without regard to case.
///
/// Header names are case-insensitive in HTTP, so `headers["content-type"]` and
/// `headers["Content-Type"]` read the same field. Setting a field replaces any field with the
/// same name in another case.
///
/// ```swift
/// var headers: HTTPHeaders = ["Accept": "application/json"]
/// headers["X-Request-ID"] = UUID().uuidString
/// ```
public struct HTTPHeaders: Hashable, Sendable, Sequence, ExpressibleByDictionaryLiteral {
    /// The fields in the order they were added, with the names as they were written.
    public private(set) var fields: [(name: String, value: String)] = []

    /// The index in ``fields`` of the field with each name, by ``lookupKey(_:)``. A field is found
    /// and replaced without reading the others, so headers of many fields, such as a response
    /// from a hostile server, are read and redacted in time linear in their number.
    private var indexes: [String: Int] = [:]

    /// Creates an empty set of headers.
    public init() {}

    /// Creates headers from a dictionary.
    public init(_ dictionary: [String: String]) {
        for (name, value) in dictionary.sorted(by: { $0.key < $1.key }) {
            self[name] = value
        }
    }

    public init(dictionaryLiteral elements: (String, String)...) {
        for (name, value) in elements {
            self[name] = value
        }
    }

    /// The value of the field with this name, compared without regard to case.
    /// Setting `nil` removes the field.
    public subscript(name: String) -> String? {
        get {
            indexes[Self.lookupKey(name)].map { fields[$0].value }
        }
        set {
            let key = Self.lookupKey(name)
            switch (indexes[key], newValue) {
            case (let index?, let value?):
                fields[index] = (name, value)
            case (let index?, nil):
                fields.remove(at: index)
                indexes[key] = nil
                for later in index..<fields.count { indexes[Self.lookupKey(fields[later].name)] = later }
            case (nil, let value?):
                indexes[key] = fields.count
                fields.append((name, value))
            case (nil, nil):
                break
            }
        }
    }

    /// The key a name is looked up by: the name case-folded, so names that differ only in case
    /// are one field. Header names are ASCII tokens, which are only lowercased.
    private static func lookupKey(_ name: String) -> String {
        name.utf8.allSatisfy { $0 < 0x80 } ? name.lowercased() : name.folding(options: .caseInsensitive, locale: nil)
    }

    /// The number of fields.
    public var count: Int { fields.count }

    /// The fields as a dictionary keyed by the names as they were written.
    public var dictionary: [String: String] {
        Dictionary(fields.map { ($0.name, $0.value) }, uniquingKeysWith: { _, last in last })
    }

    /// Adds every field of `other`, replacing fields with the same name.
    public mutating func merge(_ other: HTTPHeaders) {
        for field in other.fields {
            self[field.name] = field.value
        }
    }

    public func makeIterator() -> some IteratorProtocol<(name: String, value: String)> {
        fields.makeIterator()
    }

    public static func == (lhs: HTTPHeaders, rhs: HTTPHeaders) -> Bool {
        lhs.normalized.elementsEqual(rhs.normalized) { $0.name == $1.name && $0.value == $1.value }
    }

    public func hash(into hasher: inout Hasher) {
        for field in normalized {
            hasher.combine(field.name)
            hasher.combine(field.value)
        }
    }

    private var normalized: [(name: String, value: String)] {
        fields.map { (Self.lookupKey($0.name), $0.value) }.sorted { $0.name < $1.name }
    }

    /// Reads the header fields of a response.
    init(_ response: HTTPURLResponse) {
        for case let (name as String, value as String) in response.allHeaderFields {
            self[name] = value
        }
    }

    /// The first header name or value that contains a line break or a NUL character,
    /// which would let a value inject extra header lines.
    var firstUnsafeField: String? {
        for field in fields where !Self.isSafe(field.name) || !Self.isSafe(field.value) || field.name.isEmpty {
            return field.name
        }
        return nil
    }

    private static func isSafe(_ text: String) -> Bool {
        !text.unicodeScalars.contains { $0 == "\r" || $0 == "\n" || $0 == "\0" }
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        fields.map { "\($0.name): \($0.value)" }.joined(separator: "\n")
    }
}

extension HTTPHeaders: Codable {
    private struct Field: Codable {
        let name: String
        let value: String
    }

    public init(from decoder: any Decoder) throws {
        let fields = try decoder.singleValueContainer().decode([Field].self)
        for field in fields {
            self[field.name] = field.value
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fields.map { Field(name: $0.name, value: $0.value) })
    }
}
