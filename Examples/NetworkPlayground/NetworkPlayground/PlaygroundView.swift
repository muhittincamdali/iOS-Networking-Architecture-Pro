import SwiftUI

/// Lists the demos. Each one sends real requests through a NetworkClient to the in-app
/// DemoServer.
struct PlaygroundView: View {
    enum Screen: String, CaseIterable, Identifiable {
        case users, retries, auth, prices, logs

        var id: Self { self }

        var title: String {
            switch self {
            case .users: "Typed endpoints and caching"
            case .retries: "Retries with backoff"
            case .auth: "Token refresh"
            case .prices: "Server-sent events"
            case .logs: "Redacted logs"
            }
        }

        var subtitle: String {
            switch self {
            case .users: "Decode a list, then answer from the cache"
            case .retries: "A server that fails twice before it answers"
            case .auth: "Four requests with an expired token, one refresh"
            case .prices: "A live price feed, event by event"
            case .logs: "Tokens, passwords and cookies kept out of the log"
            }
        }

        var systemImage: String {
            switch self {
            case .users: "person.2"
            case .retries: "arrow.clockwise"
            case .auth: "key"
            case .prices: "dot.radiowaves.left.and.right"
            case .logs: "text.alignleft"
            }
        }

        @MainActor @ViewBuilder
        func view(autorun: Bool) -> some View {
            switch self {
            case .users: UsersScreen()
            case .retries: RetryScreen(autorun: autorun)
            case .auth: AuthScreen(autorun: autorun)
            case .prices: PricesScreen(autorun: autorun)
            case .logs: LogScreen(autorun: autorun)
            }
        }
    }

    @State private var path: [Screen]
    private let launchedScreen: Screen?

    init(initialScreen: Screen? = nil) {
        _path = State(initialValue: initialScreen.map { [$0] } ?? [])
        launchedScreen = initialScreen
    }

    var body: some View {
        NavigationStack(path: $path) {
            List(Screen.allCases) { screen in
                NavigationLink(value: screen) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(screen.title)
                            Text(screen.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: screen.systemImage).foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Network Playground")
            .navigationDestination(for: Screen.self) { screen in
                screen.view(autorun: screen == launchedScreen)
                    .navigationTitle(screen.title)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
            }
        }
        .tint(.blue)
    }
}

/// One line of a demo's timeline.
struct TimelineRow: View {
    let systemImage: String
    let text: String
    var color: Color = .blue

    var body: some View {
        Label {
            Text(text).font(.callout.monospacedDigit())
        } icon: {
            Image(systemName: systemImage).foregroundStyle(color)
        }
    }
}

/// Collects lines from a NetworkEventMonitor, which may run on any task.
final class LineCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var lines: [String] = []

    func append(_ line: String) {
        lock.lock()
        lines.append(line)
        lock.unlock()
    }

    func drain() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        let drained = lines
        lines.removeAll()
        return drained
    }
}

extension Duration {
    /// Milliseconds rounded to the nearest 50, so timelines read the same on every run.
    var roundedMilliseconds: Int {
        let (seconds, attoseconds) = components
        let milliseconds = Double(seconds) * 1_000 + Double(attoseconds) / 1e15
        guard milliseconds.isFinite, milliseconds >= 0, milliseconds < 1e12 else { return 0 }
        return Int((milliseconds / 50).rounded()) * 50
    }
}
