import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

@Suite("Redaction")
struct RedactionTests {
    private let redactor = Redactor.default
    private let jwt = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJl"

    @Test("Sensitive names are recognised in any spelling", arguments: [
        "password", "Password", "PASSWORD", "user_password", "newPassword", "access_token", "Access-Token",
        "accessToken", "ACCESS%5FTOKEN", "access%255Ftoken", "refresh_token", "client_secret", "X-API-Key",
        "apiKey", "Set-Cookie", "session_id", "pin", "PIN", "otp", "cvv", "pass\u{200B}word", "ｐａｓｓｗｏｒｄ",
        "p-a-s-s-w-o-r-d", "Authorization", "sig", "X-Auth-Key", "Ocp-Apim-Subscription-Key", "x-functions-key",
        "Subscription-Key"
    ])
    func recognisesSensitiveNames(name: String) {
        #expect(redactor.isSensitive(name))
    }

    @Test("Ordinary names are left alone", arguments: [
        "shipping", "spinner", "name", "email_verified", "page", "author", "sort", "id", "count", "signal",
        "design", "keyboard", "subscription", "functions"
    ])
    func leavesOrdinaryNames(name: String) {
        #expect(!redactor.isSensitive(name))
    }

    @Test func headersAreRedactedByNameAndByValue() {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer abc", "cookie": "a=b", "X-Upstream": "Bearer hidden",
            "X-Trace": jwt, "Accept": "application/json"
        ]
        let redacted = redactor.redact(headers)
        #expect(redacted["Authorization"] == "<redacted>")
        #expect(redacted["Cookie"] == "<redacted>")
        #expect(redacted["X-Upstream"] == "<redacted>")
        #expect(redacted["X-Trace"] == "<redacted>")
        #expect(redacted["Accept"] == "application/json")
    }

    @Test("Credential values are found after any whitespace", arguments: [
        "Bearer\tabc", "bearer  abc", "Basic\u{00A0}dXNlcjpwYXNz", " Digest username=\"a\"", "BEARER\nabc",
        "Token SECRET", "token token=\"abc\"", "Negotiate YIIG", "NTLM TlRMTVNTUAAB", "DPoP eyJ0",
        "SSWS 00abc", "SharedAccessSignature sr=x&sig=y", "AWS4-HMAC-SHA256 Credential=AKIA/x", "OAuth oauth_token=x"
    ])
    func credentialValuesAfterAnyWhitespace(value: String) {
        let redacted = redactor.redact(["X-Upstream": value] as HTTPHeaders)
        #expect(redacted["X-Upstream"] == "<redacted>")
    }

    @Test func ordinaryValuesThatStartWithASchemeNameAreKept() {
        let redacted = redactor.redact(["X-Note": "Bearer", "X-Kind": "basic-plan", "X-Mode": "token-only"] as HTTPHeaders)
        #expect(redacted["X-Note"] == "Bearer")
        #expect(redacted["X-Kind"] == "basic-plan")
        #expect(redacted["X-Mode"] == "token-only")
    }

    @Test func azureSharedAccessSignatureIsRedacted() throws {
        let url = try #require(URL(string: "https://account.blob.core.windows.net/c/b.txt?sv=2024-11-04&se=2026-10-16&sp=r&sig=c2VjcmV0JTJGc2ln"))
        let text = redactor.redact(url)
        #expect(text == "https://account.blob.core.windows.net/c/b.txt?sv=2024-11-04&se=2026-10-16&sp=r&sig=<redacted>")
    }

    @Test func urlQueryCredentialsAndUserInfoAreRedacted() throws {
        let url = try #require(URL(string: "https://user:hunter2@api.example.com:8443/v1/items?page=2&api_key=abc123&ACCESS%5FTOKEN=xyz&q=\(jwt)&flag#frag"))
        let text = redactor.redact(url)
        #expect(text == "https://<redacted>@api.example.com:8443/v1/items?page=2&api_key=<redacted>&ACCESS%5FTOKEN=<redacted>&q=<redacted>&flag#<redacted>")
        #expect(!text.contains("hunter2") && !text.contains("abc123") && !text.contains("xyz"))
    }

    @Test func sensitivePathParametersAreRedacted() throws {
        let url = try #require(URL(string: "https://api.example.com/cart;jsessionid=SECRET5;v=2/items;Session%5FId=S6?x=1"))
        let text = redactor.redact(url)
        #expect(text == "https://api.example.com/cart;jsessionid=<redacted>;v=2/items;Session%5FId=<redacted>?x=1")
        let plain = try #require(URL(string: "https://api.example.com/a;v=2/b;"))
        #expect(redactor.redact(plain) == "https://api.example.com/a;v=2/b;")
    }

    @Test func nestedJSONKeysAndTokenValuesAreRedacted() {
        let body = Data("""
        {"user":{"name":"Ada","Password":"p1","profile":{"pass\\u0077ord":"p2"}},
         "tokens":[{"refresh_token":"r1"},{"note":"Bearer t1"}],
         "items":[1,2,{"cvv":"123"}],"id_token":null,"jwt":"\(jwt)","free":"\(jwt)"}
        """.utf8)
        let text = redactor.redact(body: body, contentType: "application/json; charset=utf-8")
        for secret in ["p1", "p2", "r1", "t1", "123", jwt] {
            #expect(!text.contains(secret), "\(secret) leaked: \(text)")
        }
        #expect(text.contains("\"name\":\"Ada\""))
    }

    @Test func jsonIsDetectedWithoutAContentType() {
        let text = redactor.redact(body: Data(#"  {"secret":"s"}"#.utf8), contentType: nil)
        #expect(text == #"{"secret":"<redacted>"}"#)
    }

    @Test func formBodiesAreRedacted() {
        let body = Data("grant_type=password&username=ada&password=hunter2&refresh%5Ftoken=r".utf8)
        let text = redactor.redact(body: body, contentType: "application/x-www-form-urlencoded")
        #expect(text == "grant_type=password&username=ada&password=<redacted>&refresh_token=<redacted>")
    }

    @Test func unstructuredBodiesAreSummarised() {
        let xml = Data("<login><password>hunter2</password></login>".utf8)
        let text = redactor.redact(body: xml, contentType: "application/xml")
        #expect(text == "<\(xml.count) bytes of application/xml, not shown>")
        #expect(redactor.redact(body: Data("not json {".utf8), contentType: "application/json").hasSuffix("not shown>"))
    }

    @Test func largeBodiesAreNotParsed() {
        var limited = Redactor()
        limited.maximumParsedBodySize = 10
        let body = Data(#"{"password":"long secret"}"#.utf8)
        #expect(limited.redact(body: body, contentType: "application/json") == "<\(body.count) bytes, not shown>")
    }

    @Test func longBodiesAreCut() {
        var limited = Redactor()
        limited.maximumBodyLength = 10
        let text = limited.redact(body: Data(#"["aaaaaaaaaaaaaaaaaaaa"]"#.utf8), contentType: "application/json")
        #expect(text == #"["aaaaaaaa… (14 more characters)"#)
    }

    @Test func deeplyNestedJSONDoesNotRecurseWithoutLimit() {
        let depth = 400
        let body = Data((String(repeating: "[", count: depth) + #"{"token":"t"}"# + String(repeating: "]", count: depth)).utf8)
        let text = redactor.redact(body: body, contentType: "application/json")
        #expect(!text.contains("\"t\""))
    }

    @Test func customNamesExtendTheDefaults() {
        var custom = Redactor()
        custom.sensitiveNames.insert("customerReference")
        custom.sensitiveNameFragments.append("Internal_ID")
        #expect(custom.isSensitive("Customer-Reference"))
        #expect(custom.isSensitive("customer_reference"))
        #expect(custom.isSensitive("x-internal-id-v2"))
    }
}

@Suite("Network logger")
struct NetworkLoggerTests {
    @Test func logsRequestsWithoutSecrets() async throws {
        let lines = EventLog()
        let logger = NetworkLogger(detail: .bodies) { line, _ in lines.append(line) }
        let transport = MockTransport()
        transport.register(.post, "login", MockResponse(
            headers: ["Content-Type": "application/json", "Set-Cookie": "session=s3cr3t"],
            body: Data(#"{"access_token":"tok-123","user":"ada"}"#.utf8)
        ))
        let client = NetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            configuration: .init(headers: ["Authorization": "Bearer abc"], monitors: [logger]),
            transport: transport
        )
        struct Login: Encodable, Sendable { let user: String; let password: String }
        _ = try await client.send(Endpoint<Data>.post("login?api_key=k-999", body: .json(Login(user: "ada", password: "hunter2"))))
        let log = lines.all.joined(separator: "\n")
        for secret in ["abc", "hunter2", "tok-123", "s3cr3t", "k-999"] {
            #expect(!log.contains(secret), "\(secret) leaked:\n\(log)")
        }
        #expect(log.contains("→ ["))
        #expect(log.contains("← ["))
        #expect(log.contains("\"user\":\"ada\""))
    }

    @Test func basicDetailHasOneLinePerEvent() async throws {
        let lines = EventLog()
        let logger = NetworkLogger { line, _ in lines.append(line) }
        let transport = MockTransport()
        transport.register(.get, "x", .status(503), .status(200))
        let client = NetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            configuration: .init(monitors: [logger], retryPolicy: .immediate),
            transport: transport
        )
        try await client.send(Endpoint<Void>.get("x"))
        // send, 503, retry, send again, 200
        #expect(lines.all.count == 5)
        #expect(lines.all.allSatisfy { !$0.contains("\n") })
        #expect(lines.all[1].contains("← [") && lines.all[1].contains(" 503 GET "))
        #expect(lines.all[2].contains("retrying in 0 ms (transientFailure)"))
        #expect(lines.all[3].hasSuffix("(attempt 2)"))
    }

    @Test func failureSummariesDoNotRepeatTheErrorText() {
        let error = NetworkError.transport(URLError(.notConnectedToInternet, userInfo: [
            NSURLErrorFailingURLStringErrorKey: "https://api.example.com/?token=secret"
        ]))
        #expect(NetworkLogger.summary(of: error) == "URLError -1009")
    }
}
