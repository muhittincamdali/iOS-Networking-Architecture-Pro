import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// Secrets inside a value that is itself a URL or a form, such as an OAuth `redirect` URL.
@Suite("Redaction of embedded URLs and forms")
struct EmbeddedRedactionTests {
    private let redactor = Redactor.default
    private let nestedRedirect = "https%3A%2F%2Fx.example%2Fcb%3Faccess_token%3DSECRET4"

    @Test func aQueryValueHoldingAURLWithATokenIsHidden() throws {
        let url = try #require(URL(string: "https://api.example.com/a?redirect=\(nestedRedirect)&state=1"))
        #expect(redactor.redact(url) == "https://api.example.com/a?redirect=<redacted>&state=1")
    }

    @Test("Nesting and encoding depth do not hide the token", arguments: [
        "https://x.example/cb?access_token=S",
        "https://x.example/cb#access_token=S",
        "https://x.example/cb;jsessionid=S",
        "https://x.example/a?next=https%3A%2F%2Fy.example%2Fcb%3Ftoken%3DS",
        "access_token=S&scope=read",
        "https://ada:S@x.example/",
        "https://x.example/cb?note=Bearer%20S",
        String(repeating: "https://x.example/a?next=", count: 3) + "https://x.example/cb?token=S"
    ])
    func embeddedSecretsAreFound(value: String) {
        var encoded = value
        for _ in 0..<7 {
            #expect(redactor.containsSecret(encoded), "missed: \(encoded)")
            encoded = encoded.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? encoded
        }
    }

    @Test("Embedded URLs and forms without secrets are kept", arguments: [
        "https://x.example/cb?page=2", "https%3A%2F%2Fx.example%2Fcb%3Fpage%3D2", "a=1&b=2",
        "mailto:ada@example.com", "text/html;q=0.9", "50% off", "ada@example.com"
    ])
    func harmlessValuesAreKept(value: String) {
        #expect(!redactor.containsSecret(value))
    }

    @Test func aJSONStringHoldingAURLWithATokenIsHidden() {
        let body = Data(#"{"next":"https://x.example/cb?access_token=SECRET1","page":"https://x.example/cb?page=2"}"#.utf8)
        let text = redactor.redact(body: body, contentType: "application/json")
        #expect(text == #"{"next":"<redacted>","page":"https://x.example/cb?page=2"}"#)
    }

    @Test func aFormValueHoldingAURLWithATokenIsHidden() {
        let body = Data("next=\(nestedRedirect)&page=2".utf8)
        let text = redactor.redact(body: body, contentType: "application/x-www-form-urlencoded")
        #expect(text == "next=<redacted>&page=2")
    }

    @Test func aHeaderHoldingAURLWithATokenIsHidden() {
        let redacted = redactor.redact(["Location": "https://x.example/cb#access_token=S", "Accept": "text/html;q=0.9"] as HTTPHeaders)
        #expect(redacted["Location"] == "<redacted>")
        #expect(redacted["Accept"] == "text/html;q=0.9")
    }

    @Test func curlCommandsHideTheEmbeddedToken() throws {
        var request = URLRequest(url: try #require(URL(string: "https://api.example.com/a?redirect=\(nestedRedirect)&state=1")))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(#"{"next":"https://x.example/cb?access_token=SECRET1"}"#.utf8)
        let command = request.curlCommand()
        #expect(!command.contains("SECRET"), "leaked: \(command)")
        #expect(command.contains("redirect=<redacted>&state=1"))
    }

    @Test func logsHideTheEmbeddedToken() async throws {
        let lines = EventLog()
        let logger = NetworkLogger(detail: .bodies) { line, _ in lines.append(line) }
        let transport = MockTransport()
        transport.register(.get, "a", MockResponse(
            headers: ["Content-Type": "application/json"],
            body: Data(#"{"next":"https://x.example/cb?access_token=SECRET1"}"#.utf8)
        ))
        let client = NetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            configuration: .init(monitors: [logger]),
            transport: transport
        )
        _ = try await client.send(Endpoint<Data>.get("a?redirect=\(nestedRedirect)&state=1"))
        let log = lines.all.joined(separator: "\n")
        #expect(!log.contains("SECRET"), "leaked:\n\(log)")
        #expect(log.contains("redirect=<redacted>&state=1"))
    }
}
