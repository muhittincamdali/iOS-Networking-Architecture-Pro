import Foundation
import Network

/// A snapshot of the device's network connection.
public struct NetworkPath: Sendable, Hashable {
    /// A kind of network interface.
    public enum Interface: String, Sendable, Hashable, CaseIterable {
        case wifi, cellular, wiredEthernet, loopback, other
    }

    /// Whether the system considers the network usable.
    public let isConnected: Bool

    /// Whether the connection is costly, such as cellular data or a personal hotspot.
    public let isExpensive: Bool

    /// Whether the user enabled Low Data Mode for the connection.
    public let isConstrained: Bool

    /// The interfaces the connection uses.
    public let interfaces: Set<Interface>

    /// Creates a path, for example to test code that reacts to connectivity.
    public init(isConnected: Bool, isExpensive: Bool = false, isConstrained: Bool = false, interfaces: Set<Interface> = []) {
        self.isConnected = isConnected
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.interfaces = interfaces
    }

    init(_ path: NWPath) {
        var interfaces = Set<Interface>()
        for type in [NWInterface.InterfaceType.wifi, .cellular, .wiredEthernet, .loopback, .other]
            where path.usesInterfaceType(type) {
            switch type {
            case .wifi: interfaces.insert(.wifi)
            case .cellular: interfaces.insert(.cellular)
            case .wiredEthernet: interfaces.insert(.wiredEthernet)
            case .loopback: interfaces.insert(.loopback)
            default: interfaces.insert(.other)
            }
        }
        self.init(
            isConnected: path.status == .satisfied,
            isExpensive: path.isExpensive,
            isConstrained: path.isConstrained,
            interfaces: interfaces
        )
    }
}

/// Reports the device's connectivity with `NWPathMonitor`.
///
/// ```swift
/// for await path in NetworkMonitor.paths() {
///     isOffline = !path.isConnected
/// }
/// ```
///
/// Use it to show an offline banner or to pause work, not to decide whether to send a request:
/// a path can be satisfied while a server is unreachable, and the reverse. Let requests fail
/// and look at ``NetworkError/isConnectivityProblem`` instead.
public enum NetworkMonitor {
    /// The connection as it changes, starting with the current one. Each call starts its own
    /// monitor, which stops when the iteration ends.
    public static func paths() -> AsyncStream<NetworkPath> {
        paths { report in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in report(NetworkPath(path)) }
            monitor.start(queue: DispatchQueue(label: "NetworkingArchitecture.NetworkMonitor"))
            return { monitor.cancel() }
        }
    }

    /// The current connection.
    public static func currentPath() async -> NetworkPath {
        for await path in paths() {
            return path
        }
        return NetworkPath(isConnected: false)
    }

    /// Returns once the device has a usable connection, or throws `CancellationError` when
    /// the task is cancelled first.
    public static func waitUntilConnected() async throws {
        try await waitUntilConnected(in: paths())
    }

    /// The paths a source reports. `start` begins observing, passes each path to the closure
    /// it receives, and returns the closure that stops observing, which runs when the
    /// iteration ends. Tests supply a source of their own.
    static func paths(
        from start: (_ report: @escaping @Sendable (NetworkPath) -> Void) -> @Sendable () -> Void
    ) -> AsyncStream<NetworkPath> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let stop = start { continuation.yield($0) }
            continuation.onTermination = { _ in stop() }
        }
    }

    static func waitUntilConnected(in paths: AsyncStream<NetworkPath>) async throws {
        for await path in paths where path.isConnected {
            return
        }
        throw CancellationError()
    }
}
