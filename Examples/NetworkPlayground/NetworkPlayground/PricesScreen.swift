import NetworkingArchitecture
import SwiftUI

/// Reads a server-sent event stream and shows each price as it arrives.
struct PricesScreen: View {
    let autorun: Bool

    private struct Row: Identifiable {
        let id: String
        let update: PriceUpdate
    }

    @State private var rows: [Row] = []
    @State private var status = "Not connected"
    @State private var streaming: Task<Void, Never>?

    var body: some View {
        List {
            Section {
                if streaming == nil {
                    Button("Open the price stream", systemImage: "play.fill") { start() }
                } else {
                    Button("Close the stream", systemImage: "stop.fill") { stop() }
                }
                LabeledContent("Status", value: status)
            } footer: {
                Text("NetworkClient.events(_:) parses text/event-stream as it arrives and reconnects with Last-Event-ID.")
            }
            Section("Prices") {
                ForEach(rows.reversed()) { row in
                    LabeledContent(row.update.symbol) {
                        Text(row.update.price, format: .currency(code: "USD")).monospacedDigit()
                    }
                }
            }
        }
        .task {
            if autorun { start() }
        }
        .onDisappear { stop() }
    }

    private func start() {
        rows = []
        status = "Connecting…"
        let client = NetworkClient(baseURL: DemoServer.baseURL, transport: DemoServer().transport())
        streaming = Task {
            do {
                for try await event in client.events(.get("prices/stream")) where event.type == "price" {
                    let update = try event.decode(PriceUpdate.self)
                    rows.append(Row(id: event.id, update: update))
                    status = "Received \(rows.count) events"
                }
                status = "The server ended the stream after \(rows.count) events"
            } catch is CancellationError {
                status = "Closed"
            } catch NetworkError.cancelled {
                status = "Closed"
            } catch {
                status = error.localizedDescription
            }
            streaming = nil
        }
    }

    private func stop() {
        streaming?.cancel()
        streaming = nil
    }
}
