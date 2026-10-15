import Foundation

/// An `application/x-www-form-urlencoded` body, as sent by HTML forms and OAuth token
/// endpoints.
///
/// ```swift
/// let form: URLEncodedForm = ["grant_type": "refresh_token", "refresh_token": token]
/// let endpoint = Endpoint<TokenResponse>.post("oauth/token", body: .form(form))
/// ```
///
/// Fields keep the order they were added in. Names and values are encoded with the
/// WHATWG URL Standard rules: letters, digits and `*-._` stay as they are, a space becomes
/// `+`, and every other byte of the UTF-8 encoding becomes `%XX`.
public struct URLEncodedForm: Sendable, Hashable, ExpressibleByDictionaryLiteral {
    /// One name and value.
    public struct Field: Sendable, Hashable {
        public var name: String
        public var value: String

        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }

    /// The fields in order.
    public private(set) var fields: [Field] = []

    /// Creates an empty form.
    public init() {}

    /// Creates a form from fields in order. Names may repeat.
    public init(_ fields: [Field]) {
        self.fields = fields
    }

    /// Creates a form from a dictionary, with the fields sorted by name so the body is the
    /// same every time.
    public init(_ dictionary: [String: String]) {
        self.fields = dictionary.sorted { $0.key < $1.key }.map { Field(name: $0.key, value: $0.value) }
    }

    public init(dictionaryLiteral elements: (String, String)...) {
        self.fields = elements.map { Field(name: $0.0, value: $0.1) }
    }

    /// Adds a field at the end. Names may repeat, as in `tag=a&tag=b`.
    public mutating func append(_ name: String, _ value: String) {
        fields.append(Field(name: name, value: value))
    }

    /// The value of the first field named `name`.
    public subscript(name: String) -> String? {
        fields.first { $0.name == name }?.value
    }

    /// The encoded body, such as `name=Ada+Lovelace&lang=en`.
    public var encodedString: String {
        fields.map { Self.encode($0.name) + "=" + Self.encode($0.value) }.joined(separator: "&")
    }

    /// The encoded body as UTF-8 bytes.
    public func encoded() -> Data {
        Data(encodedString.utf8)
    }

    /// Reads an encoded body. A `+` is read as a space; a malformed `%` sequence is kept as
    /// it is.
    public init(decoding text: String) {
        self.fields = text.split(separator: "&", omittingEmptySubsequences: true).map { pair in
            let parts = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            let name = Self.decode(parts[0])
            let value = parts.count > 1 ? Self.decode(parts[1]) : ""
            return Field(name: name, value: value)
        }
    }

    private static let unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-._ "
    )

    static func encode(_ text: String) -> String {
        let encoded = text.addingPercentEncoding(withAllowedCharacters: unreserved) ?? ""
        return encoded.replacingOccurrences(of: " ", with: "+")
    }

    private static func decode(_ text: Substring) -> String {
        let spaced = text.replacingOccurrences(of: "+", with: " ")
        return spaced.removingPercentEncoding ?? spaced
    }
}

extension RequestBody {
    /// An `application/x-www-form-urlencoded` body.
    public static func form(_ form: URLEncodedForm) -> RequestBody {
        let data = form.encoded()
        return RequestBody(contentType: "application/x-www-form-urlencoded") { _ in data }
    }
}
