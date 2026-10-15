import Foundation
import Testing
@testable import NetworkingArchitecture

@Suite("Network monitor", .timeLimit(.minutes(1)))
struct NetworkMonitorTests {
    /// A path source that reports the paths a test sends and counts how often it was stopped.
    private final class FakePathSource: Sendable {
        private let report = Locked<(@Sendable (NetworkPath) -> Void)?>(nil)
        private let stopCount = Locked(0)

        var stops: Int { stopCount.withLock { $0 } }

        func paths() -> AsyncStream<NetworkPath> {
            NetworkMonitor.paths { report in
                self.report.withLock { $0 = report }
                return { self.stopCount.withLock { $0 += 1 } }
            }
        }

        func send(_ path: NetworkPath) {
            report.withLock { $0 }?(path)
        }
    }

    private let offline = NetworkPath(isConnected: false)
    private let wifi = NetworkPath(isConnected: true, interfaces: [.wifi])

    @Test func reportsTheCurrentPathRightAway() async {
        let start = ContinuousClock.now
        let path = await NetworkMonitor.currentPath()
        #expect(ContinuousClock.now - start < .seconds(5))
        // A connected path always names at least one interface.
        if path.isConnected {
            #expect(!path.interfaces.isEmpty)
        }
    }

    @Test func endingTheIterationStopsTheSource() async {
        let source = FakePathSource()
        var received: [NetworkPath] = []
        do {
            let paths = source.paths()
            source.send(wifi)
            for await path in paths {
                received.append(path)
                #expect(source.stops == 0)
                break
            }
        }
        #expect(received == [wifi])
        #expect(source.stops == 1)
    }

    @Test func waitingReturnsOnceAPathIsConnected() async throws {
        let source = FakePathSource()
        let paths = source.paths()
        let task = Task { try await NetworkMonitor.waitUntilConnected(in: paths) }
        source.send(offline)
        source.send(wifi)
        try await task.value
    }

    @Test func waitingWithoutAConnectionThrowsWhenCancelled() async {
        let source = FakePathSource()
        let paths = source.paths()
        source.send(offline)
        let task = Task { try await NetworkMonitor.waitUntilConnected(in: paths) }
        task.cancel()
        let result = await task.result
        guard case .failure(let error) = result else {
            Issue.record("Expected CancellationError, but waiting returned while offline")
            return
        }
        #expect(error is CancellationError)
    }
}
