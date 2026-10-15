import Foundation
import UniformTypeIdentifiers

/// A `multipart/form-data` body (RFC 7578) for uploading files together with form fields.
///
/// ```swift
/// var form = MultipartFormData()
/// form.append("Holiday", name: "title")
/// form.append(jpegData, name: "photo", fileName: "beach.jpg", mimeType: "image/jpeg")
///
/// let endpoint = Endpoint<Photo>.post("photos", body: .multipart(form))
/// let photo = try await client.upload(endpoint) { progress in
///     print(progress.fractionCompleted ?? 0)
/// }
/// ```
///
/// Field names and file names are escaped the way browsers do it: a line break becomes
/// `%0D`/`%0A` and a quote becomes `%22`, so a name cannot end its header line early or
/// add headers of its own.
public struct MultipartFormData: Sendable {
    /// The string that separates the parts.
    public let boundary: String

    private var parts: [Part] = []

    private struct Part: Sendable {
        let headers: String
        let body: Data
    }

    /// The error thrown for a boundary that RFC 2046 does not allow.
    public struct InvalidBoundary: Error, Sendable, Equatable {
        public let boundary: String
    }

    /// Creates an empty body with a random boundary.
    public init() {
        self.boundary = "Boundary-" + UUID().uuidString
    }

    /// Creates an empty body with your own boundary.
    ///
    /// - Throws: ``InvalidBoundary`` unless the boundary has 1 to 70 characters from the set
    ///   RFC 2046 allows and does not end with a space.
    public init(boundary: String) throws {
        guard Self.isValid(boundary) else { throw InvalidBoundary(boundary: boundary) }
        self.boundary = boundary
    }

    /// The `Content-Type` header value, including the boundary.
    public var contentType: String {
        // A boundary with characters outside the HTTP token set (such as a space, "/" or
        // ":") must be quoted in the header parameter.
        let token = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'+_-.")
        let needsQuotes = !boundary.unicodeScalars.allSatisfy { token.contains($0) }
        return "multipart/form-data; boundary=" + (needsQuotes ? "\"\(boundary)\"" : boundary)
    }

    /// The number of parts.
    public var count: Int { parts.count }

    /// Adds a text field.
    public mutating func append(_ value: String, name: String) {
        let headers = "Content-Disposition: form-data; name=\"\(Self.escape(name))\"\r\n"
        parts.append(Part(headers: headers, body: Data(value.utf8)))
    }

    /// Adds a file from memory.
    ///
    /// - Parameters:
    ///   - fileName: The file name the server sees. `nil` sends the data as a field without
    ///     a file name.
    ///   - mimeType: The part's `Content-Type`. A value with a line break is replaced with
    ///     `application/octet-stream`.
    public mutating func append(
        _ data: Data,
        name: String,
        fileName: String? = nil,
        mimeType: String = "application/octet-stream"
    ) {
        var headers = "Content-Disposition: form-data; name=\"\(Self.escape(name))\""
        if let fileName {
            headers += "; filename=\"\(Self.escape(fileName))\""
        }
        headers += "\r\nContent-Type: \(Self.safeMIMEType(mimeType))\r\n"
        parts.append(Part(headers: headers, body: data))
    }

    /// Adds the contents of a file. The MIME type is derived from the file extension when you
    /// do not pass one.
    public mutating func append(
        contentsOf fileURL: URL,
        name: String,
        fileName: String? = nil,
        mimeType: String? = nil
    ) throws {
        let data = try Data(contentsOf: fileURL)
        let type = mimeType
            ?? UTType(filenameExtension: fileURL.pathExtension)?.preferredMIMEType
            ?? "application/octet-stream"
        append(data, name: name, fileName: fileName ?? fileURL.lastPathComponent, mimeType: type)
    }

    /// The encoded body.
    public func encoded() -> Data {
        var body = Data()
        for part in parts {
            body.append(Data("--\(boundary)\r\n\(part.headers)\r\n".utf8))
            body.append(part.body)
            body.append(Data("\r\n".utf8))
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }

    /// Escapes a name the way the HTML standard's form submission does.
    static func escape(_ text: String) -> String {
        var result = ""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "\r": result += "%0D"
            case "\n": result += "%0A"
            case "\"": result += "%22"
            default: result.unicodeScalars.append(scalar)
            }
        }
        return result
    }

    private static func safeMIMEType(_ type: String) -> String {
        let unsafe = type.isEmpty || type.unicodeScalars.contains { $0 == "\r" || $0 == "\n" || $0 == "\0" }
        return unsafe ? "application/octet-stream" : type
    }

    /// RFC 2046, section 5.1.1: 1 to 70 characters from `bchars`, not ending with a space.
    private static func isValid(_ boundary: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'()+_,-./:=? ")
        return (1...70).contains(boundary.unicodeScalars.count)
            && boundary.unicodeScalars.allSatisfy { allowed.contains($0) }
            && !boundary.hasSuffix(" ")
    }
}

extension RequestBody {
    /// A `multipart/form-data` body.
    public static func multipart(_ form: MultipartFormData) -> RequestBody {
        let data = form.encoded()
        return RequestBody(contentType: form.contentType) { _ in data }
    }
}
