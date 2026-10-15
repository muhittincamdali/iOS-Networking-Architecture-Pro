/// An HTTP request method, such as `GET` or `POST`.
///
/// The common methods are static members; any other token can be written as a string literal:
///
/// ```swift
/// let method: HTTPMethod = "PROPFIND"
/// ```
public struct HTTPMethod: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral {
    /// The method name as it is sent on the wire, in upper case.
    public let rawValue: String

    /// Creates a method from its name. The name is upper-cased.
    public init(rawValue: String) {
        self.rawValue = rawValue.uppercased()
    }

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    public static let get = HTTPMethod(rawValue: "GET")
    public static let head = HTTPMethod(rawValue: "HEAD")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let put = HTTPMethod(rawValue: "PUT")
    public static let patch = HTTPMethod(rawValue: "PATCH")
    public static let delete = HTTPMethod(rawValue: "DELETE")
    public static let options = HTTPMethod(rawValue: "OPTIONS")

    /// Whether sending the request twice has the same effect as sending it once
    /// (RFC 9110, section 9.2.2).
    ///
    /// ``RetryPolicy`` only retries idempotent requests unless you allow otherwise, because a
    /// `POST` that timed out may already have been processed by the server.
    public var isIdempotent: Bool {
        switch rawValue {
        case "GET", "HEAD", "PUT", "DELETE", "OPTIONS", "TRACE": true
        default: false
        }
    }
}

extension HTTPMethod: CustomStringConvertible {
    public var description: String { rawValue }
}
