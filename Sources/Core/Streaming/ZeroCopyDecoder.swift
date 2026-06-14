import Foundation

/// iOS-Networking-Architecture-Pro: Zero-Copy Streaming Decoder
public struct ZeroCopyDecoder: Sendable {
    public static func decode<T: Decodable>(stream: AsyncStream<Data>) async throws -> AsyncStream<T> {
        return AsyncStream { continuation in }
    }
}
