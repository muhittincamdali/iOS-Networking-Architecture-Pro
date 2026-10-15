import NetworkingArchitecture
import SwiftUI

/// Signs in with a password and an API key, and shows what NetworkLogger writes and what
/// curlCommand() prints: the secrets are replaced before anything is written.
struct LogScreen: View {
    let autorun: Bool

    private struct Credentials: Encodable, Sendable {
        let username: String
        let password: String
    }

    @State private var lines: [String] = []
    @State private var curl = ""

    var body: some View {
        List {
            Section {
                Button("Sign in", systemImage: "person.badge.key.fill") {
                    Task { await signIn() }
                }
            } footer: {
                Text("Sent: password \"hunter2\", X-API-Key \"k-7d1f0c\", answered with a JWT and a session cookie.")
            }
            Section("NetworkLogger(detail: .bodies)") {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line).font(.caption.monospaced()).textSelection(.enabled)
                }
            }
            if !curl.isEmpty {
                Section("request.curlCommand()") {
                    Text(curl).font(.caption.monospaced()).textSelection(.enabled)
                }
            }
        }
        .task {
            if autorun { await signIn() }
        }
    }

    private func signIn() async {
        let collector = LineCollector()
        // Drop the request ID and round the duration so the screen reads the same on every run.
        let logger = NetworkLogger(detail: .bodies) { line, _ in
            let stable = line
                .replacing(#/\[[0-9A-F]{8}\] /#, with: "")
                .replacing(#/\((\d+) ms/#) { match in "(\((Int(match.1) ?? 0) / 50 * 50) ms" }
            collector.append(stable)
        }
        let client = NetworkClient(
            baseURL: DemoServer.baseURL,
            configuration: .init(headers: ["Accept": "application/json", "X-API-Key": "k-7d1f0c"], monitors: [logger]),
            transport: DemoServer().transport()
        )
        let endpoint = Endpoint<[String: String]>.post("login", body: .json(Credentials(username: "ada", password: "hunter2")))
        _ = try? await client.send(endpoint)
        lines = collector.drain()
        if let request = try? client.urlRequest(for: endpoint) {
            curl = request.curlCommand()
        }
    }
}
