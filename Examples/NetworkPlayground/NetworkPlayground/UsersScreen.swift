import NetworkingArchitecture
import SwiftUI

/// Loads `API.users(page:)` with a cache-first policy: the first load goes to the server, the
/// next ones within 30 seconds come from the memory cache.
struct UsersScreen: View {
    @State private var users: [User] = []
    @State private var status = "Loading…"
    @State private var client = NetworkClient(
        baseURL: DemoServer.baseURL,
        configuration: .init(cache: MemoryResponseCache()),
        transport: DemoServer().transport()
    )

    var body: some View {
        List {
            Section {
                Label(status, systemImage: "info.circle").foregroundStyle(.secondary)
            }
            Section("Users") {
                ForEach(users) { user in
                    LabeledContent(user.name, value: "#\(user.id)")
                }
            }
        }
        .toolbar {
            Button("Reload", systemImage: "arrow.clockwise") {
                Task { await load() }
            }
        }
        .task { await load() }
    }

    private func load() async {
        status = "Loading…"
        let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(30)))
        do {
            let response = try await client.response(for: endpoint)
            users = response.value
            status = switch response.source {
            case .cache: "From the cache: no request was sent"
            default: "From the server in \(response.attempts) attempt\(response.attempts == 1 ? "" : "s")"
            }
        } catch {
            status = error.localizedDescription
        }
    }
}
