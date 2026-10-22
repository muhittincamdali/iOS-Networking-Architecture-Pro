import Foundation

/// The body of a request and its content type.
///
/// ```swift
/// .json(NewUser(name: "Ada"))          // application/json, encoded with the client's encoder
/// .data(png, contentType: "image/png")
/// .text("hello")                        // text/plain; charset=utf-8
/// ```
///
/// Form and multipart bodies are built with ``URLEncodedForm`` and ``MultipartFormData``.
public struct RequestBody: Sendable {
    /// The `Content-Type` header sent with the body, unless the endpoint sets its own.
    public let contentType: String?

    private let encode: @Sendable (JSONEncoder) throws -> Data

    /// Creates a body from a closure that produces the bytes. The closure receives the
    /// client's JSON encoder.
    public init(contentType: String?, encode: @escaping @Sendable (JSONEncoder) throws -> Data) {
        self.contentType = contentType
        self.encode = encode
    }

    /// Encodes `value` as JSON with the client's encoder, or with `encoder` if you pass one.
    public static func json<Value: Encodable & Sendable>(_ value: Value, encoder: JSONEncoder? = nil) -> RequestBody {
        RequestBody(contentType: "application/json") { clientEncoder in
            try (encoder ?? clientEncoder).encode(value)
        }
    }

    /// Sends `data` unchanged.
    public static func data(_ data: Data, contentType: String = "application/octet-stream") -> RequestBody {
        RequestBody(contentType: contentType) { _ in data }
    }

    /// Sends `text` encoded as UTF-8.
    public static func text(_ text: String, contentType: String = "text/plain; charset=utf-8") -> RequestBody {
        RequestBody(contentType: contentType) { _ in Data(text.utf8) }
    }

    /// Produces the bytes of the body.
    func data(using encoder: JSONEncoder) throws -> Data {
        try encode(encoder)
    }
}
