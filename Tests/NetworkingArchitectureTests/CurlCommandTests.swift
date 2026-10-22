import Foundation
import Testing
@testable import NetworkingArchitecture

@Suite("curl commands")
struct CurlCommandTests {
    private func request() -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.example.com/login?token=t-1&page=2")!)
        request.httpMethod = "POST"
        request.setValue("Bearer secret", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(#"{"user":"ada","password":"it's"}"#.utf8)
        return request
    }

    @Test func redactsByDefault() {
        let command = request().curlCommand()
        #expect(command.hasPrefix("curl -X 'POST' 'https://api.example.com/login?token=[REDACTED]&page=[REDACTED]'"))
        #expect(command.contains("-H 'Authorization: [REDACTED]'"))
        #expect(command.contains("-H 'Content-Type: application/json'"))
        #expect(command.contains(#"--data-binary '{"user":"ada","password":"[REDACTED]"}'"#))
        #expect(!command.contains("secret") && !command.contains("t-1"))
    }

    @Test func quotesSingleQuotes() {
        #expect(URLRequest.quoted("it's") == #"'it'\''s'"#)
        #expect(request().curlCommand(redactor: nil).contains(#""password":"it'\''s""#))
    }

    @Test func binaryBodiesAreNotPrinted() {
        var request = URLRequest(url: URL(string: "https://api.example.com/upload")!)
        request.httpMethod = "PUT"
        request.httpBody = Data([0xFF, 0xFE, 0x00])
        #expect(request.curlCommand(redactor: nil).hasSuffix("# 3 bytes of binary body not shown"))
    }

    #if os(macOS)
    @Test func theCommandRunsInAShellAndSendsTheSameRequest() async throws {
        let received = Locked<LocalHTTPServer.Request?>(nil)
        let server = try await LocalHTTPServer { request in
            received.withLock { $0 = request }
            return .body(Data("ok".utf8))
        }
        var request = URLRequest(url: server.url("/echo?q=a%20b"))
        request.httpMethod = "PATCH"
        request.setValue("value with 'quotes' and $(echo injected)", forHTTPHeaderField: "X-Note")
        request.httpBody = Data("body; rm -rf / 'quoted'".utf8)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", request.curlCommand(redactor: nil) + " --silent --output /dev/null"]
        try process.run()
        process.waitUntilExit()
        #expect(process.terminationStatus == 0)

        let seen = try #require(received.withLock { $0 })
        #expect(seen.method == "PATCH")
        #expect(seen.path == "/echo?q=a%20b")
        #expect(seen.header("X-Note") == "value with 'quotes' and $(echo injected)")
        #expect(seen.body == Data("body; rm -rf / 'quoted'".utf8))
    }
    #endif
}
