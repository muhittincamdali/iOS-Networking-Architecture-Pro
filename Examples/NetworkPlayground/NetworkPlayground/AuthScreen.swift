import NetworkingArchitecture
import SwiftUI

/// Sends four requests at once with an expired token. Each gets a 401, the authenticator
/// refreshes the token once for all of them, and each request is retried with the new token.
struct AuthScreen: View {
    let autorun: Bool

    private struct Outcome: Identifiable {
        let id: Int
        let text: String
        let succeeded: Bool
    }

    private struct TokenResponse: Decodable, Sendable {
        let accessToken: String
        let refreshToken: String
    }

    @State private var outcomes: [Outcome] = []
    @State private var refreshCount = 0
    @State private var token = "token-0 (expired)"
    @State private var isRunning = false

    var body: some View {
        List {
            Section {
                Button(isRunning ? "Sending…" : "Send 4 requests at once", systemImage: "paperplane.fill") {
                    Task { await sendRequests() }
                }
                .disabled(isRunning)
                LabeledContent("Access token", value: token)
                LabeledContent("Refresh calls", value: "\(refreshCount)")
            } footer: {
                Text("BearerTokenAuthenticator lets the first 401 start the refresh; the other requests wait for it.")
            }
            Section("Requests") {
                ForEach(outcomes) { outcome in
                    TimelineRow(
                        systemImage: outcome.succeeded ? "checkmark.circle.fill" : "xmark.octagon.fill",
                        text: outcome.text,
                        color: outcome.succeeded ? .green : .red
                    )
                }
            }
        }
        .task {
            if autorun { await sendRequests() }
        }
    }

    private func sendRequests() async {
        isRunning = true
        outcomes = []
        let server = DemoServer()
        let transport = server.transport()

        // The refresh call goes through its own client, without the authenticator.
        let refreshConfiguration = NetworkClient.Configuration()
        refreshConfiguration.decoder.keyDecodingStrategy = .convertFromSnakeCase
        let refreshClient = NetworkClient(baseURL: DemoServer.baseURL, configuration: refreshConfiguration, transport: transport)

        let authenticator = BearerTokenAuthenticator(
            token: BearerToken(accessToken: "token-0", refreshToken: "refresh-0"),
            allowedHosts: ["api.example.com"]
        ) { expired in
            let fresh = try await refreshClient.send(Endpoint<TokenResponse>.post(
                "oauth/token", body: .form(["grant_type": "refresh_token", "refresh_token": expired.refreshToken ?? ""])
            ))
            return BearerToken(accessToken: fresh.accessToken, refreshToken: fresh.refreshToken)
        }
        let client = NetworkClient(
            baseURL: DemoServer.baseURL,
            configuration: .init(interceptors: [authenticator]),
            transport: transport
        )

        let results = await withTaskGroup(of: (Int, String, Bool).self) { group in
            for index in 1...4 {
                group.addTask {
                    do {
                        let response = try await client.response(for: Endpoint<[String: String]>.get("account"))
                        return (index, "Request \(index): \(response.statusCode) after \(response.attempts) attempts", true)
                    } catch {
                        return (index, "Request \(index): \(error.localizedDescription)", false)
                    }
                }
            }
            var collected: [(Int, String, Bool)] = []
            for await result in group { collected.append(result) }
            return collected.sorted { $0.0 < $1.0 }
        }
        outcomes = results.map { Outcome(id: $0.0, text: $0.1, succeeded: $0.2) }
        refreshCount = await server.refreshCount
        token = await authenticator.currentToken?.accessToken ?? "none"
        isRunning = false
    }
}
