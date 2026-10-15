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

    /// `GET`: read a resource.
    public static let get = HTTPMethod(rawValue: "GET")
    /// `HEAD`: like `GET`, without the body.
    public static let head = HTTPMethod(rawValue: "HEAD")
    /// `POST`: create a resource or run an action.
    public static let post = HTTPMethod(rawValue: "POST")
    /// `PUT`: replace a resource.
    public static let put = HTTPMethod(rawValue: "PUT")
    /// `PATCH`: change part of a resource.
    public static let patch = HTTPMethod(rawValue: "PATCH")
    /// `DELETE`: remove a resource.
    public static let delete = HTTPMethod(rawValue: "DELETE")
    /// `OPTIONS`: ask what a resource supports.
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
