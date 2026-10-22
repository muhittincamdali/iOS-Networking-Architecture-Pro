import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// Every secret that an earlier, name-based version of ``Redactor`` let through, kept as a test.
///
/// Each was fixed once with a rule of its own: a value holding a URL or a form, a `+` read as a
/// space, JSON inside a value, `;jsessionid` path parameters, percent-encoded path segments,
/// more authentication schemes and more names. The current rules hide them without such rules:
/// query values and headers are kept only when allowlisted, an allowlisted value is free text
/// that is cut at its first trigger, and a path segment that looks like a token becomes `:id`.
/// Each value is checked in every place the library writes it, with its query parameter or header
/// allowlisted, which is the most an app can show.
@Suite("Redaction: earlier bypasses")
struct EarlierBypassTests {
    static let secret = "SECRET4"

    /// `value` as each output writes it: a query value and a header value that the app allows, a
    /// JSON string, a form value and a plain-text body under a key that is not secret, a log line
    /// and a `curl` command.
    static func outputs(of value: String) throws -> [(place: String, text: String)] {
        let redactor = Redactor(allowedHeaders: Redactor.defaultAllowedHeaders + ["X-Note"], allowedQueryParameters: ["note"])
        let query = try #require(URL(string: "https://api.example.com/a?note=" + formEncoded(value)))
        let json = try JSONSerialization.data(withJSONObject: ["note": value])
        let form = Data(("note=" + formEncoded(value)).utf8)
        var request = URLRequest(url: query)
        request.httpMethod = "POST"
        request.setValue(value, forHTTPHeaderField: "X-Note")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        func text(_ body: Data, _ type: String) -> String {
            String(decoding: redactor.redact(body: body, contentType: type).body, as: UTF8.self)
        }
        return [
            ("query", redactor.redact(url: query)),
            ("header", redactor.redact(headers: ["X-Note": value])["X-Note"] ?? ""),
            ("JSON", text(json, "application/json")),
            ("form", text(form, "application/x-www-form-urlencoded")),
            ("text/plain", text(Data(value.utf8), "text/plain")),
            ("free text", redactor.redact(text: "note: " + value)),
            ("log and curl", LoggedOutput.request(request, redactor: redactor)),
        ]
    }

    static func formEncoded(_ text: String) -> String {
        text.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? text
    }

    static func expectHidden(_ value: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
        for (place, text) in try outputs(of: value) {
            #expect(!text.contains(secret), "\(place): \(value) -> \(text)", sourceLocation: sourceLocation)
        }
    }

    // fix(logging): hide values that carry a secret inside a URL or form. An OAuth redirect held a
    // token one URL down; the same value was then encoded up to seven times.
    @Test("A URL or form inside a value, encoded up to seven times", arguments: [
        "https://x.example/cb?access_token=\(secret)",
        "https://x.example/cb#access_token=\(secret)",
        "https://x.example/cb;jsessionid=\(secret)",
        "https://x.example/a?next=https%3A%2F%2Fy.example%2Fcb%3Ftoken%3D\(secret)",
        "access_token=\(secret)&scope=read",
        "https://ada:\(secret)@x.example/",
        "https://x.example/cb?note=Bearer%20\(secret)",
        String(repeating: "https://x.example/a?next=", count: 3) + "https://x.example/cb?token=\(secret)",
    ])
    func embeddedURLsAndForms(value: String) throws {
        var encoded = value
        for _ in 0..<7 {
            try Self.expectHidden(encoded)
            encoded = Self.formEncoded(encoded)
        }
    }

    @Test func anOAuthRedirectInTheRequestURL() throws {
        let url = try #require(URL(string: "https://api.example.com/a?redirect=https%3A%2F%2Fx.example%2Fcb%3Faccess_token%3D\(Self.secret)&state=1"))
        #expect(Redactor.default.redact(url: url) == "https://api.example.com/a?redirect=\(Redactor.replacement)&state=\(Redactor.replacement)")
        let allowing = Redactor(allowedQueryParameters: ["redirect", "state"])
        #expect(allowing.redact(url: url) == "https://api.example.com/a?redirect=\(Redactor.replacement)&state=1")
    }

    // fix(logging): read a plus in a query value as a space.
    @Test("A plus that a form decodes to a space", arguments: [
        "Bearer+\(secret)", "Bearer \(secret)",
        "https://x.example/cb?note=Bearer%2B\(secret)",
    ])
    func plusAsSpace(value: String) throws {
        try Self.expectHidden(value)
        let url = try #require(URL(string: "https://api.example.com/a?note=Bearer+\(Self.secret)&page=2"))
        #expect(!Redactor(allowedQueryParameters: ["note", "page"]).redact(url: url).contains(Self.secret))
    }

    // fix(logging): hide values that hold JSON with a sensitive key.
    @Test("JSON with a secret key inside a value", arguments: [
        #"{"access_token":"\#(secret)"}"#, #"[{"a":"{\"pin\":\"\#(secret)\"}"}]"#, #"{"token":"\#(secret)"}"#,
    ])
    func embeddedJSON(value: String) throws {
        try Self.expectHidden(value)
        try Self.expectHidden(Self.formEncoded(value))
    }

    @Test func jsonInsideAJSONString() {
        let body = Data(#"{"data":"{\"access_token\":\"SECRET4\"}","list":"[{\"a\":\"{\\\"pin\\\":1}\"}]","page":"{\"n\":2}"}"#.utf8)
        let text = String(decoding: Redactor.default.redact(body: body, contentType: "application/json").body, as: UTF8.self)
        #expect(!text.contains(Self.secret), "\(text)")
        #expect(!text.contains(#"\"pin\":1"#), "\(text)")
        // JSON in a string is free text again: a key that is not an allowed text key hides the rest
        // from its opening quote.
        #expect(text.hasSuffix(#""page":"{[REDACTED]"}"#), "\(text)")
    }

    // fix(logging): hide sensitive path parameters such as ;jsessionid, and the lost follow-up that
    // hid percent-encoded path segments. A path with a `;`, raw or encoded, now keeps only the
    // scheme, host and port.
    @Test("Path parameters and encoded path segments", arguments: [
        "https://api.example.com/cart;jsessionid=\(secret)/items",
        "https://api.example.com/cart;jsessionid=\(secret);v=2/items;Session%5FId=\(secret)?x=1",
        "https://api.example.com/cart%3Bjsessionid%3D\(secret)/items",
        "https://api.example.com/proxy/https%3A%2F%2Fx%2Fcb%3Faccess_token%3D\(secret)/items",
        "https://api.example.com/proxy/https%253A%252F%252Fx%252Fcb%253Ftoken%253D\(secret);v=1/items",
    ])
    func pathParametersAndEncodedSegments(text: String) throws {
        let url = try #require(URL(string: text))
        let redacted = Redactor.default.redact(url: url)
        #expect(!redacted.contains(Self.secret), "\(redacted)")
        let logged = LoggedOutput.request(URLRequest(url: url))
        #expect(!logged.contains(Self.secret), "\(logged)")
    }

    // The documentation of the name-based rules said a secret that is a whole path segment was not
    // recognised. A segment that looks like a token is now written as `:id`.
    @Test func aTokenThatIsAWholePathSegment() throws {
        let url = try #require(URL(string: "https://api.example.com/reset/8f2a9c41d07b4e6f8a3b5c2d1e0f9a8b/confirm"))
        #expect(Redactor.default.redact(url: url) == "https://api.example.com/reset/:id/confirm")
    }

    // fix(logging): redact more API key names and tab-separated credential schemes, and recognise
    // more HTTP authentication schemes in values.
    @Test("Credential schemes after any white space", arguments: [
        "Bearer\t\(secret)", "bearer  \(secret)", "Basic\u{00A0}\(secret)", " Digest username=\"\(secret)\"", "BEARER\n\(secret)",
        "Token \(secret)", "token token=\"\(secret)\"", "Negotiate \(secret)", "NTLM \(secret)", "DPoP \(secret)",
        "SSWS \(secret)", "SharedAccessSignature sr=x&sig=\(secret)", "AWS4-HMAC-SHA256 Credential=\(secret)",
        "OAuth oauth_token=\(secret)",
    ])
    func credentialSchemes(value: String) throws {
        try Self.expectHidden(value)
        #expect(RedirectPolicy.followSafely.request(redirecting: Self.original, to: Self.redirect(["X-Upstream": value]))?
            .value(forHTTPHeaderField: "X-Upstream") == nil)
    }

    @Test("API key headers", arguments: [
        "X-API-Key", "X-Auth-Key", "Ocp-Apim-Subscription-Key", "x-functions-key", "Subscription-Key", "Authorization",
        "Proxy-Authorization", "Cookie", "Set-Cookie", "X-Auth-Token", "X-Session",
    ])
    func apiKeyHeaders(name: String) {
        let listed = Redactor(allowedHeaders: [name])
        #expect(listed.redact(headers: [name: Self.secret])[name] == Redactor.replacement)
        #expect(RedirectPolicy.followSafely.request(redirecting: Self.original, to: Self.redirect([name: "v"]))?
            .value(forHTTPHeaderField: name) == nil)
    }

    @Test func anAzureSharedAccessSignature() throws {
        let url = try #require(URL(string: "https://account.blob.core.windows.net/c/b.txt?sv=2024-11-04&se=2026-10-16&sp=r&sig=c2VjcmV0JTJGc2ln"))
        let allowing = Redactor(allowedQueryParameters: ["sv", "se", "sp", "sig"])
        #expect(allowing.redact(url: url) == "https://account.blob.core.windows.net/c/b.txt?sv=2024-11-04&se=2026-10-16&sp=r&sig=\(Redactor.replacement)")
    }

    // fix(logging): normalise names added to a Redactor after it is created. Added names are now
    // folded once, when the redactor is created.
    @Test func anAddedNameInAnotherSpelling() {
        let custom = Redactor(additionalSecretNames: ["customerReference"])
        let body = Data(#"{"customer_reference":"SECRET4","CUSTOMER-REFERENCE":"SECRET4"}"#.utf8)
        let text = String(decoding: custom.redact(body: body, contentType: "application/json").body, as: UTF8.self)
        #expect(!text.contains(Self.secret), "\(text)")
    }

    @Test func logsAndCurlHideTheEmbeddedToken() async throws {
        let lines = EventLog()
        let logger = NetworkLogger(detail: .bodies) { line, _ in lines.append(line) }
        let transport = MockTransport()
        transport.register(.get, "a", MockResponse(
            headers: ["Content-Type": "application/json", "Location": "https://x.example/cb#access_token=\(Self.secret)"],
            body: Data(#"{"next":"https://x.example/cb?access_token=SECRET4"}"#.utf8)
        ))
        let client = NetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            configuration: .init(monitors: [logger]),
            transport: transport
        )
        let endpoint = Endpoint<Data>.get("a?redirect=https%3A%2F%2Fx.example%2Fcb%3Faccess_token%3D\(Self.secret)&state=1")
        _ = try await client.send(endpoint)
        let log = lines.all.joined(separator: "\n")
        #expect(!log.contains(Self.secret), "leaked:\n\(log)")
        #expect(log.contains("redirect=\(Redactor.replacement)&state=\(Redactor.replacement)"))
        let command = try client.urlRequest(for: endpoint).curlCommand()
        #expect(!command.contains(Self.secret), "leaked: \(command)")
    }

    private static let original = URLRequest(url: URL(string: "https://api.example.com/a")!)

    private static func redirect(_ headers: [String: String]) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://cdn.example.net/b")!)
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }
}
