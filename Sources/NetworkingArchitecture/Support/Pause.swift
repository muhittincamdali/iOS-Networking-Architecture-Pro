/// Waits for a duration that may come from a server, an interceptor or a setting.
///
/// `Task.sleep(for:)` traps ("Not enough bits to represent the passed value") for durations
/// near `Int64.max` seconds, and a `Retry-After`, `retry:` field or custom retry decision can
/// ask for one. Every wait in the package goes through here and is clamped to 0...24 hours.
package enum Pause {
    /// The longest single wait.
    package static let longest: Duration = .seconds(86_400)

    /// `duration` limited to 0...``longest``.
    package static func clamped(_ duration: Duration) -> Duration {
        min(max(duration, .zero), longest)
    }

    /// Sleeps for `duration`, clamped; throws `CancellationError` when the task is cancelled.
    package static func sleep(for duration: Duration) async throws {
        try await Task.sleep(for: clamped(duration))
    }
}
