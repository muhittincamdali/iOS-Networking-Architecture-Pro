import SwiftUI
import Combine

/// A state-driven network observer for SwiftUI views.
///
/// Use this object to manage the state of a single network request
/// with automatic loading and error handling.
@MainActor
public final class NetworkState<T: Decodable & Sendable>: ObservableObject {
    
    public enum Status {
        case idle
        case loading
        case success(T)
        case error(Error)
    }
    
    @Published public private(set) var status: Status = .idle
    
    public var data: T? {
        if case .success(let value) = status { return value }
        return nil
    }
    
    public var isLoading: Bool {
        if case .loading = status { return true }
        return false
    }
    
    public var error: Error? {
        if case .error(let err) = status { return err }
        return nil
    }
    
    public init() {}
    
    /// Executes a network request and updates the state.
    public func execute(_ task: @escaping () async throws -> T) {
        status = .loading
        
        Task {
            do {
                let result = try await task()
                status = .success(result)
            } catch {
                status = .error(error)
            }
        }
    }
    
    public func reset() {
        status = .idle
    }
}

public extension View {
    /// Visual signature for network-loading views
    func networkLoading(isActive: Bool) -> some View {
        self.overlay {
            if isActive {
                ZStack {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView()
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }
}
