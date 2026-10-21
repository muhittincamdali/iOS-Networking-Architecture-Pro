import Foundation
import Testing
@testable import NetworkingArchitecture

extension RedactionTimeLimitTests {
    // The seventeenth review of the library this corpus was written for: a text of a million
    // different characters outside ASCII, about four megabytes, took 1.46 s and 70.5 MiB with a
    // reading kept for each character.
    @Test("redacting a text of a million different characters takes less than a second a megabyte")
    func logMessageOfDifferentCharacters() {
        let message = DistinctScalarShapes.logMessage()
        let megabytes = Double(message.utf8.count) / 1_000_000
        var fastest = Duration.seconds(1_000)
        for _ in 0..<3 where fastest >= Self.limit * megabytes {
            fastest = min(fastest, onThread(stackSize: RedactionStackTests.threadStack) {
                let start = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)
                _ = Redactor.default.redact(text: message)
                return Duration.nanoseconds(Int64(clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID) - start))
            })
        }
        #expect(fastest < Self.limit * megabytes, "\(fastest) for \(megabytes) MB")
    }
}
