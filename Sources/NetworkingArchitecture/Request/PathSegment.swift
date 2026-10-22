/// A value that stays a single path segment when interpolated into an endpoint path.
///
/// Interpolating user input straight into a path lets it change the request: a name such as
/// `"x?role=admin"` adds a query, `"a/b"` adds a segment and `".."` climbs up a level.
/// Wrap such values in `PathSegment`; every character outside the RFC 3986 unreserved set is
/// percent-encoded, and `.` and `..` are encoded as well:
///
/// ```swift
/// Endpoint<Profile>.get("users/\(PathSegment(username))/profile")
/// // username "x?role=admin" -> users/x%3Frole%3Dadmin/profile
/// ```
public struct PathSegment: CustomStringConvertible, Sendable, Hashable {
    /// The value before encoding.
    public let value: String

    /// Wraps a value, such as a user name or an ID, for use as one path segment.
    public init(_ value: some CustomStringConvertible) {
        self.value = value.description
    }

    /// The percent-encoded segment.
    public var description: String {
        if value == "." || value == ".." {
            return String(repeating: "%2E", count: value.count)
        }
        var encoded = ""
        for byte in value.utf8 {
            if Self.isUnreserved(byte) {
                encoded.unicodeScalars.append(Unicode.Scalar(byte))
            } else {
                encoded += "%" + Self.hex(byte >> 4) + Self.hex(byte & 0x0F)
            }
        }
        return encoded
    }

    static func isUnreserved(_ byte: UInt8) -> Bool {
        switch byte {
        case UInt8(ascii: "A")...UInt8(ascii: "Z"), UInt8(ascii: "a")...UInt8(ascii: "z"),
             UInt8(ascii: "0")...UInt8(ascii: "9"), UInt8(ascii: "-"), UInt8(ascii: "."),
             UInt8(ascii: "_"), UInt8(ascii: "~"):
            true
        default:
            false
        }
    }

    private static func hex(_ nibble: UInt8) -> String {
        String(nibble, radix: 16, uppercase: true)
    }
}
