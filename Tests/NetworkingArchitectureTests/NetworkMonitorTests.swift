import Foundation
import Testing
@testable import NetworkingArchitecture

@Suite("Network monitor", .timeLimit(.minutes(1)))
struct NetworkMonitorTests {
    @Test func reportsTheCurrentPathRightAway() async {
        let start = ContinuousClock.now
        let path = await NetworkMonitor.currentPath()
        #expect(ContinuousClock.now - start < .seconds(5))
        // A connected path always names at least one interface.
        if path.isConnected {
            #expect(!path.interfaces.isEmpty)
        }
    }

    @Test func endingTheIterationStopsTheMonitor() async {
        var count = 0
        for await _ in NetworkMonitor.paths() {
            count += 1
            break
        }
        #expect(count == 1)
    }

    @Test func waitingIsCancellable() async {
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            try await NetworkMonitor.waitUntilConnected()
        }
        let result = await task.result
        // Cancelled before the first path arrived it throws; if a connected path won the
        // race it returns. It must not hang either way.
        if case .failure(let error) = result {
            #expect(error is CancellationError)
        }
    }
}
