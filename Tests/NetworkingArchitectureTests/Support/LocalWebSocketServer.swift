import Foundation
import Network
@testable import NetworkingArchitecture

/// A WebSocket echo server on 127.0.0.1 for testing ``WebSocketConnection`` against a real
/// socket.
///
/// It echoes every text and binary message. The text `"close"` makes it close the connection
/// with code 1000, and `"drop"` makes it cut the connection without a close frame.
final class LocalWebSocketServer: @unchecked Sendable {
    private let listener: NWListener
    private let queue = DispatchQueue(label: "LocalWebSocketServer")
    private let state = Locked((connections: 0, authorizations: [String?]()))

    /// The port the server listens on.
    let port: UInt16

    /// How many connections were accepted.
    var connectionCount: Int { state.withLock { $0.connections } }

    /// The Authorization header of each handshake, in order.
    var authorizations: [String?] { state.withLock { $0.authorizations } }

    init() async throws {
        let options = NWProtocolWebSocket.Options()
        options.autoReplyPing = true
        let queue = queue
        let state = state
        options.setClientRequestHandler(queue) { _, headers in
            let authorization = headers.first { $0.name.caseInsensitiveCompare("Authorization") == .orderedSame }?.value
            state.withLock { $0.authorizations.append(authorization) }
            return NWProtocolWebSocket.Response(status: .accept, subprotocol: nil)
        }
        let parameters = NWParameters.tcp
        parameters.defaultProtocolStack.applicationProtocols.insert(options, at: 0)
        let listener = try NWListener(using: parameters, on: .any)
        self.listener = listener
        self.port = try await withCheckedThrowingContinuation { continuation in
            let resumed = LockedFlag()
            listener.stateUpdateHandler = { update in
                switch update {
                case .ready:
                    if resumed.set(), let port = listener.port?.rawValue { continuation.resume(returning: port) }
                case .failed(let error):
                    if resumed.set() { continuation.resume(throwing: error) }
                default:
                    break
                }
            }
            listener.newConnectionHandler = { connection in
                state.withLock { $0.connections += 1 }
                connection.start(queue: queue)
                Self.receive(on: connection)
            }
            listener.start(queue: queue)
        }
    }

    deinit {
        listener.cancel()
    }

    var url: URL { URL(string: "ws://127.0.0.1:\(port)/socket")! }

    private static func receive(on connection: NWConnection) {
        connection.receiveMessage { content, context, _, error in
            guard error == nil, let context,
                  let metadata = context.protocolMetadata(definition: NWProtocolWebSocket.definition) as? NWProtocolWebSocket.Metadata else {
                connection.cancel()
                return
            }
            switch metadata.opcode {
            case .text where content == Data("close".utf8):
                let close = NWProtocolWebSocket.Metadata(opcode: .close)
                close.closeCode = .protocolCode(.normalClosure)
                let closeContext = NWConnection.ContentContext(identifier: "close", metadata: [close])
                connection.send(content: nil, contentContext: closeContext, isComplete: true, completion: .contentProcessed { _ in
                    connection.cancel()
                })
                return
            case .text where content == Data("drop".utf8):
                connection.forceCancel()
                return
            case .text, .binary:
                let echo = NWProtocolWebSocket.Metadata(opcode: metadata.opcode)
                let echoContext = NWConnection.ContentContext(identifier: "echo", metadata: [echo])
                connection.send(content: content, contentContext: echoContext, isComplete: true, completion: .idempotent)
            default:
                break
            }
            receive(on: connection)
        }
    }
}
