import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

@Suite("URL-encoded forms")
struct URLEncodedFormTests {
    @Test func encodesWithWHATWGRules() {
        var form = URLEncodedForm()
        form.append("name", "Ada Lovelace")
        form.append("expr", "1+1=2 & more")
        form.append("path", "/a/b?c")
        form.append("keep", "*-._")
        form.append("unicode", "çağ")
        #expect(form.encodedString ==
            "name=Ada+Lovelace&expr=1%2B1%3D2+%26+more&path=%2Fa%2Fb%3Fc&keep=*-._&unicode=%C3%A7a%C4%9F")
    }

    @Test func dictionariesAreSortedByName() {
        let form = URLEncodedForm(["b": "2", "a": "1", "c": "3"])
        #expect(form.encodedString == "a=1&b=2&c=3")
    }

    @Test func repeatedNamesAreKept() {
        let form: URLEncodedForm = ["tag": "a", "tag": "b"]
        #expect(form.encodedString == "tag=a&tag=b")
        #expect(form["tag"] == "a")
    }

    @Test func decodingReversesEncoding() {
        let original: URLEncodedForm = ["q": "c++ & swift", "empty": "", "ünï": "çödé"]
        let decoded = URLEncodedForm(decoding: original.encodedString)
        #expect(decoded == original)
    }

    @Test func malformedPercentSequencesAreKept() {
        let decoded = URLEncodedForm(decoding: "a=%ZZ&b=%E2%82&flag")
        #expect(decoded["a"] == "%ZZ")
        #expect(decoded["b"] == "%E2%82")
        #expect(decoded["flag"] == "")
    }

    @Test func formBodySetsTheContentType() async throws {
        let transport = MockTransport()
        transport.register(.post, "token", .status(204))
        let client = NetworkClient(baseURL: URL(string: "https://auth.example.com")!, transport: transport)
        try await client.send(Endpoint<Void>.post("token", body: .form(["grant_type": "password"])))
        let request = try #require(transport.requests.first)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
        #expect(request.httpBody == Data("grant_type=password".utf8))
    }
}

@Suite("Multipart form data")
struct MultipartFormDataTests {
    /// Splits an encoded body into its parts' header blocks and bodies. As in RFC 2046, a
    /// delimiter only counts at the start of a line.
    private func parts(of body: Data, boundary: String) -> [(headers: String, body: Data)] {
        let text = "\r\n" + String(decoding: body, as: UTF8.self)
        let sections = text.components(separatedBy: "\r\n--\(boundary)")
        return sections.dropFirst().dropLast().map { section in
            // The CRLF after the delimiter; Swift reads "\r\n" as a single Character.
            let content = String(section.dropFirst())
            let split = content.components(separatedBy: "\r\n\r\n")
            return (split[0], Data(split.dropFirst().joined(separator: "\r\n\r\n").utf8))
        }
    }

    @Test func encodesFieldsAndFiles() throws {
        var form = try MultipartFormData(boundary: "XYZ")
        form.append("Holiday", name: "title")
        form.append(Data("PNGDATA".utf8), name: "photo", fileName: "a.png", mimeType: "image/png")
        let expected = "--XYZ\r\n"
            + "Content-Disposition: form-data; name=\"title\"\r\n\r\nHoliday\r\n"
            + "--XYZ\r\n"
            + "Content-Disposition: form-data; name=\"photo\"; filename=\"a.png\"\r\n"
            + "Content-Type: image/png\r\n\r\nPNGDATA\r\n"
            + "--XYZ--\r\n"
        #expect(String(decoding: form.encoded(), as: UTF8.self) == expected)
        #expect(form.contentType == "multipart/form-data; boundary=XYZ")
        #expect(form.count == 2)
    }

    @Test func namesCannotInjectHeadersOrParts() {
        var form = MultipartFormData()
        form.append("x", name: "a\"\r\nContent-Type: text/html\r\n\r\n--\(form.boundary)")
        form.append(Data(), name: "f", fileName: "evil\".sh\r\nX-Injected: 1", mimeType: "text/plain\r\nX-Injected: 2")
        let parsed = parts(of: form.encoded(), boundary: form.boundary)
        #expect(parsed.count == 2)
        #expect(parsed[0].headers == #"Content-Disposition: form-data; name="a%22%0D%0AContent-Type: text/html%0D%0A%0D%0A--\#(form.boundary)""#)
        #expect(!parsed[1].headers.contains("X-Injected: 1\r\n"))
        #expect(parsed[1].headers.hasSuffix("Content-Type: application/octet-stream"))
        #expect(parsed[1].headers.split(separator: "\r\n").count == 2)
    }

    @Test("Boundaries outside RFC 2046 are rejected", arguments: [
        "", String(repeating: "a", count: 71), "ends with space ", "semi;colon", "quote\"", "new\nline"
    ])
    func rejectsInvalidBoundaries(boundary: String) {
        #expect(throws: MultipartFormData.InvalidBoundary.self) {
            try MultipartFormData(boundary: boundary)
        }
    }

    @Test func boundariesWithSpecialCharactersAreQuoted() throws {
        let form = try MultipartFormData(boundary: "a b/c")
        #expect(form.contentType == "multipart/form-data; boundary=\"a b/c\"")
    }

    @Test func fileTypeIsDerivedFromTheExtension() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        try Data("{}".utf8).write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }
        var form = MultipartFormData()
        try form.append(contentsOf: file, name: "doc")
        let parsed = parts(of: form.encoded(), boundary: form.boundary)
        #expect(parsed[0].headers.contains("filename=\"\(file.lastPathComponent)\""))
        #expect(parsed[0].headers.contains("Content-Type: application/json"))
        #expect(parsed[0].body == Data("{}".utf8))
    }

    @Test func randomBoundariesDiffer() {
        #expect(MultipartFormData().boundary != MultipartFormData().boundary)
    }

    @Test func uploadsThroughURLSessionUnchanged() async throws {
        var form = MultipartFormData()
        form.append("caption", name: "text")
        form.append(Data((0..<1_000).map { UInt8($0 % 256) }), name: "blob", fileName: "b.bin")
        let expected = form.encoded()
        let received = EventLog()
        let server = try await LocalHTTPServer { request in
            received.append(request.header("Content-Type") ?? "")
            return .body(Data(#"{"id":\#(request.body == expected ? 1 : 0),"name":"ok"}"#.utf8))
        }
        let client = NetworkClient(
            baseURL: server.url(""),
            transport: URLSessionTransport(session: URLSession(configuration: .ephemeral))
        )
        let user = try await client.upload(Endpoint<User>.post("upload", body: .multipart(form))).value
        #expect(user.id == 1)
        #expect(received.all == [form.contentType])
    }
}
