import NetworkingArchitecture
import SwiftUI

/// Calls an endpoint that fails twice with 503 and shows every attempt, wait and response as
/// a NetworkEventMonitor sees them.
struct RetryScreen: View {
    let autorun: Bool

    private struct Entry: Identifiable {
        let id: Int
        let systemImage: String
        let text: String
        let color: Color
    }

    @State private var entries: [Entry] = []
    @State private var isRunning = false
    @State private var run = 0
    private let collector = LineCollector()
    private let server = DemoServer()

    var body: some View {
        List {
            Section {
                Button(isRunning ? "Calling…" : "Call the flaky endpoint", systemImage: "play.fill") {
                    Task { await call() }
                }
                .disabled(isRunning)
            } footer: {
                Text("RetryPolicy: 3 attempts, 500 ms base delay doubling each time, no jitter.")
            }
            Section("Timeline") {
                ForEach(entries) { entry in
                    TimelineRow(systemImage: entry.systemImage, text: entry.text, color: entry.color)
                }
            }
        }
        .task {
            if autorun { await call() }
        }
    }

    private func call() async {
        isRunning = true
        run += 1
        entries = []
        let collector = collector
        var configuration = NetworkClient.Configuration()
        configuration.retryPolicy = RetryPolicy(maximumAttempts: 3, baseDelay: .milliseconds(500), jitter: 0)
        configuration.monitors = [ClosureEventMonitor { event, context in
            switch event {
            case .willSend(let request):
                collector.append("send|\(request.httpMethod ?? "GET") \(request.url?.path ?? "") — attempt \(context.attempt)")
            case .didReceive(_, let response, let duration):
                collector.append("receive|\(response.statusCode) \(statusText(response.statusCode)) after \(duration.roundedMilliseconds) ms")
            case .didFail(_, let error, _):
                collector.append("fail|\(error.localizedDescription)")
            case .willRetry(_, let delay, _):
                collector.append("wait|Waiting \(delay.roundedMilliseconds) ms before the next attempt")
            }
        }]
        let client = NetworkClient(baseURL: DemoServer.baseURL, configuration: configuration, transport: server.transport())
        let endpoint = Endpoint<[String: String]>.get("flaky", query: [URLQueryItem(name: "run", value: String(run))])

        // Show the timeline as it happens.
        let poller = Task {
            while !Task.isCancelled {
                append(collector.drain())
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
        do {
            let response = try await client.response(for: endpoint)
            poller.cancel()
            append(collector.drain())
            entries.append(Entry(id: entries.count, systemImage: "checkmark.circle.fill",
                                 text: "\(response.value["message"] ?? "Done") after \(response.attempts) attempts", color: .green))
        } catch {
            poller.cancel()
            append(collector.drain())
            entries.append(Entry(id: entries.count, systemImage: "xmark.octagon.fill", text: error.localizedDescription, color: .red))
        }
        isRunning = false
    }

    private func append(_ lines: [String]) {
        for line in lines {
            let parts = line.split(separator: "|", maxSplits: 1).map(String.init)
            let (image, color): (String, Color) = switch parts[0] {
            case "send": ("arrow.up.circle", .blue)
            case "receive": (parts[1].hasPrefix("2") ? "arrow.down.circle.fill" : "exclamationmark.triangle", parts[1].hasPrefix("2") ? .green : .orange)
            case "wait": ("hourglass", .secondary)
            default: ("xmark.circle", .red)
            }
            entries.append(Entry(id: entries.count, systemImage: image, text: parts[1], color: color))
        }
    }
}

/// "OK" for 200 (where Foundation says "no error"), Foundation's phrase for other codes.
private func statusText(_ code: Int) -> String {
    code == 200 ? "OK" : HTTPURLResponse.localizedString(forStatusCode: code).capitalized
}
