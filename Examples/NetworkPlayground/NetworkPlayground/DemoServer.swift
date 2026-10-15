import Foundation
import NetworkingArchitecture
import NetworkingArchitectureTesting

/// A pretend backend that runs inside the app on a MockTransport, so every screen works
/// offline and behaves the same way on every run.
///
/// - `GET users`: eight users, after 400 ms.
/// - `GET flaky?run=N`: 503 twice for each run, then 200.
/// - `GET account`: 200 for the current access token, 401 for any other.
/// - `POST oauth/token`: issues the next access token.
/// - `GET prices/stream`: eight server-sent price events, half a second apart.
/// - `POST login`: answers with a token and a session cookie, for the log screen.
actor DemoServer {
    static let baseURL = URL(string: "https://api.example.com/v1")!

    static let users: [User] = [
        "Ada Lovelace", "Alan Turing", "Grace Hopper", "Katherine Johnson",
        "Edsger Dijkstra", "Barbara Liskov", "Donald Knuth", "Margaret Hamilton"
    ].enumerated().map { User(id: $0.offset + 1, name: $0.element) }

    private var flakyCalls: [String: Int] = [:]
    private(set) var currentToken = "token-1"
    private(set) var refreshCount = 0

    /// A transport that answers every request from this server.
    nonisolated func transport() -> MockTransport {
        MockTransport { request in try await self.answer(request) }
    }

    private func answer(_ request: URLRequest) async throws -> MockResponse {
        let path = request.url?.path ?? ""
        let method = request.httpMethod ?? "GET"
        switch (method, path) {
        case ("GET", "/v1/users"):
            return try .json(Self.users, headers: ["ETag": "\"users-v1\""]).delayed(by: .milliseconds(400))
        case ("GET", "/v1/flaky"):
            let run = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
                .queryItems?.first { $0.name == "run" }?.value ?? ""
            flakyCalls[run, default: 0] += 1
            let response: MockResponse = flakyCalls[run, default: 0] <= 2
                ? .status(503)
                : try .json(["message": "Recovered"])
            return response.delayed(by: .milliseconds(300))
        case ("GET", "/v1/account"):
            let authorized = request.value(forHTTPHeaderField: "Authorization") == "Bearer \(currentToken)"
            let response: MockResponse = authorized
                ? try .json(["name": "Ada Lovelace", "plan": "Pro"])
                : .status(401)
            return response.delayed(by: .milliseconds(250))
        case ("POST", "/v1/oauth/token"):
            refreshCount += 1
            currentToken = "token-\(refreshCount + 1)"
            return try .json(["access_token": currentToken, "refresh_token": "refresh-\(refreshCount)"])
                .delayed(by: .milliseconds(500))
        case ("GET", "/v1/prices/stream"):
            guard request.value(forHTTPHeaderField: "Last-Event-ID") == nil else { return .status(204) }
            return .text(Self.priceStream, headers: ["Content-Type": "text/event-stream"], chunks: 8, chunkDelay: .milliseconds(500))
        case ("POST", "/v1/login"):
            let jwt = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZGEifQ.c2lnbmF0dXJlLWZvci1kZW1v"
            return try .json(
                ["access_token": jwt, "user": "ada", "expires_in": "3600"],
                headers: ["Set-Cookie": "session=8f2a91c4; HttpOnly; Secure"]
            ).delayed(by: .milliseconds(200))
        default:
            return .status(404)
        }
    }

    /// Eight price events of about the same length, so they split evenly into eight chunks.
    private static let priceStream: String = [
        ("AAPL", "231.50"), ("MSFT", "512.25"), ("NVDA", "187.10"), ("AAPL", "231.95"),
        ("TSLA", "402.80"), ("MSFT", "511.70"), ("NVDA", "188.40"), ("AAPL", "232.30")
    ].enumerated().map { index, quote in
        "id: \(index + 1)\nevent: price\ndata: {\"symbol\":\"\(quote.0)\",\"price\":\(quote.1)}\n\n"
    }.joined()
}
