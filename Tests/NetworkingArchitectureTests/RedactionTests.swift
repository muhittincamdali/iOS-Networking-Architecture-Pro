import Foundation
import NetworkingArchitectureTesting
import Testing
@testable import NetworkingArchitecture

/// The redaction rules as this library's types use them: header lists, request URLs and bodies.
@Suite("Redaction")
struct RedactionTests {
    private let redactor = Redactor.default
    private let jwt = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJl"
    private let hidden = Redactor.replacement

    @Test("Secret names are recognised in any spelling", arguments: [
        "password", "Password", "PASSWORD", "user_password", "newPassword", "access_token", "Access-Token",
        "accessToken", "ACCESS%5FTOKEN", "access%255Ftoken", "refresh_token", "client_secret", "X-API-Key",
        "apiKey", "Set-Cookie", "session_id", "pin", "PIN", "otp", "cvv", "pass\u{200B}word", "ｐａｓｓｗｏｒｄ",
        "p-a-s-s-w-o-r-d", "Authorization", "sig", "X-Auth-Key", "Ocp-Apim-Subscription-Key", "x-functions-key",
        "Subscription-Key", "jwt", "code", "Code",
    ])
    func recognisesSecretNames(name: String) {
        #expect(redactor.isSensitive(name: name))
    }

    @Test("Plain ASCII names that are not secret are left alone", arguments: [
        "shipping", "spinner", "name", "email_verified", "page", "author", "sort", "id", "count", "signal",
        "design", "keyboard", "subscription", "functions", "status_code", "zipcode",
    ])
    func leavesOrdinaryNames(name: String) {
        #expect(!redactor.isSensitive(name: name))
    }

    @Test("A name that is not plain ASCII is treated as secret", arguments: ["Şifre", "пароль", "pass word\u{00AD}", "a[b]", "名前"])
    func nonASCIINamesAreSecret(name: String) {
        #expect(redactor.isSensitive(name: name))
    }

    @Test func onlyAllowlistedHeadersKeepTheirValues() {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer abc", "cookie": "a=b", "X-Upstream": "Bearer hidden", "X-Trace": jwt,
            "X-Request-ID": "r-1", "Accept": "application/json", "Content-Type": "text/html; charset=utf-8",
            "User-Agent": "MyApp/1.0",
        ]
        let redacted = redactor.redact(headers: headers)
        for name in ["Authorization", "Cookie", "X-Upstream", "X-Trace", "X-Request-ID"] {
            #expect(redacted[name] == hidden, "\(name)")
        }
        #expect(redacted["Accept"] == "application/json")
        #expect(redacted["Content-Type"] == "text/html; charset=utf-8")
        #expect(redacted["User-Agent"] == "MyApp/1.0")
    }

    @Test func anAppCanAllowItsOwnHeaders() {
        let custom = Redactor(allowedHeaders: Redactor.defaultAllowedHeaders + ["X-Request-ID", "X-API-Key"])
        let redacted = custom.redact(headers: ["X-Request-ID": "r-1", "X-API-Key": "k-1"])
        #expect(redacted["X-Request-ID"] == "r-1")
        // A header that is always hidden stays hidden when it is listed.
        #expect(redacted["X-API-Key"] == hidden)
    }

    @Test func urlsLoseUserInfoFragmentQueryValuesAndIdentifiers() throws {
        let url = try #require(URL(string: "https://user:hunter2@api.example.com:8443/v1/users/12345678/items?page=2&api_key=abc123&flag#frag"))
        #expect(redactor.redact(url: url) == "https://api.example.com:8443/v1/users/:id/items?page=\(hidden)&api_key=\(hidden)&\(hidden)")
        let allowing = Redactor(allowedQueryParameters: ["page", "api_key"])
        #expect(allowing.redact(url: url) == "https://api.example.com:8443/v1/users/:id/items?page=2&api_key=\(hidden)&\(hidden)")
        #expect(Redactor(urlDetail: .hostOnly).redact(url: url) == "https://api.example.com:8443")
    }

    @Test func jsonBodiesHideEveryValueUnderASecretKey() {
        let body = Data("""
        {"user":{"name":"Ada","Password":"p1","profile":{"pass\\u0077ord":"p2"}},
         "tokens":[{"refresh_token":"r1"},{"note":"Bearer t1"}],
         "items":[1,2,{"cvv":"123"}],"id_token":null,"jwt":"\(jwt)","free":"\(jwt)"}
        """.utf8)
        let (data, outcome) = redactor.redact(body: body, contentType: "application/json; charset=utf-8")
        let text = String(decoding: data, as: UTF8.self)
        for secret in ["p1", "p2", "r1", "t1", "123", jwt] {
            #expect(!text.contains(secret), "\(secret) leaked: \(text)")
        }
        #expect(text.contains("\"name\":\"Ada\""))
        #expect(outcome == .redacted)
    }

    @Test func formBodiesHideSecretFieldsAndReadOtherValuesAsFreeText() {
        let body = Data("scope=read&username=ada&password=hunter2&refresh%5Ftoken=r".utf8)
        let text = String(decoding: redactor.redact(body: body, contentType: "application/x-www-form-urlencoded").body, as: UTF8.self)
        #expect(text == "scope=read&username=ada&password=\(hidden)&refresh%5Ftoken=\(hidden)")
        // A value that names a secret, such as `grant_type=password`, hides the field after it too.
        let named = Data("grant_type=password&username=ada&password=hunter2".utf8)
        let namedText = String(decoding: redactor.redact(body: named, contentType: "application/x-www-form-urlencoded").body, as: UTF8.self)
        #expect(namedText == "grant_type=password&username=\(hidden)&password=\(hidden)")
    }

    @Test("Bodies that are not parsed are omitted", arguments: [
        ("<login><password>hunter2</password></login>", "application/xml"),
        ("not json {", "application/json"),
        (#"{"secret":"s"}"#, nil),
    ] as [(String, String?)])
    func unparsedBodiesAreOmitted(body: String, contentType: String?) {
        let (data, outcome) = redactor.redact(body: Data(body.utf8), contentType: contentType)
        #expect(outcome == .omitted)
        #expect(String(decoding: data, as: UTF8.self) == "[body omitted: \(body.utf8.count) bytes, \(contentType.map { MediaType($0)?.essence ?? $0 } ?? "no content type")]")
    }

    @Test func bodiesOverTheLimitAreOmittedUnread() {
        let limited = Redactor(maximumBodySize: 10)
        let body = Data(#"{"password":"long secret"}"#.utf8)
        let (data, outcome) = limited.redact(body: body, contentType: "application/json")
        #expect(outcome == .omitted)
        #expect(String(decoding: data, as: UTF8.self) == "[body omitted: \(body.count) bytes, application/json]")
    }

    @Test func deeplyNestedJSONIsOmittedWithoutRecursion() {
        let depth = 400
        let body = Data((String(repeating: "[", count: depth) + #"{"token":"t"}"# + String(repeating: "]", count: depth)).utf8)
        let (data, outcome) = redactor.redact(body: body, contentType: "application/json")
        #expect(outcome == .omitted)
        #expect(!String(decoding: data, as: UTF8.self).contains("\"t\""))
    }

    @Test func addedNamesExtendTheDefaults() {
        let custom = Redactor(additionalSecretNames: ["customerReference", "Internal_ID"])
        #expect(custom.isSensitive(name: "Customer-Reference"))
        #expect(custom.isSensitive(name: "customer_reference"))
        #expect(custom.isSensitive(name: "x-internal-id"))
        #expect(custom.isSensitive(name: "password"))
        #expect(!Redactor.default.isSensitive(name: "customer_reference"))
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
