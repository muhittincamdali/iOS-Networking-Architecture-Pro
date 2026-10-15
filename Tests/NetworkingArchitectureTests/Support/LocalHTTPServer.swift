import Foundation
import Network
import Security

/// A minimal HTTP/1.1 server on 127.0.0.1 for testing the real `URLSession` transport.
///
/// Each connection serves one request and is closed afterwards. The handler sees the method,
/// path, headers and body, and answers with a status, headers and a body that can be sent in
/// pieces with a pause between them.
final class LocalHTTPServer: @unchecked Sendable {
    struct Request: Sendable {
        let method: String
        let path: String
        let headers: [String: String]
        let body: Data

        func header(_ name: String) -> String? {
            headers.first { $0.key.caseInsensitiveCompare(name) == .orderedSame }?.value
        }
    }

    struct Response: Sendable {
        var status: Int = 200
        var headers: [String: String] = [:]
        var chunks: [Data] = []
        var chunkDelay: Duration = .zero
        /// Leave out Content-Length so the body ends when the connection closes.
        var omitsContentLength = false

        static func body(_ data: Data, status: Int = 200, headers: [String: String] = [:]) -> Response {
            Response(status: status, headers: headers, chunks: [data])
        }
    }

    private let listener: NWListener
    private let queue = DispatchQueue(label: "LocalHTTPServer")
    private let handler: @Sendable (Request) -> Response

    /// The port the server listens on.
    let port: UInt16

    private let isSecure: Bool

    /// Starts a server; with `identity`, it speaks HTTPS with that certificate.
    init(identity: SecIdentity? = nil, handler: @escaping @Sendable (Request) -> Response) async throws {
        self.handler = handler
        let parameters: NWParameters
        if let identity, let secIdentity = sec_identity_create(identity) {
            let tls = NWProtocolTLS.Options()
            sec_protocol_options_set_local_identity(tls.securityProtocolOptions, secIdentity)
            parameters = NWParameters(tls: tls)
        } else {
            parameters = .tcp
        }
        self.isSecure = identity != nil
        let listener = try NWListener(using: parameters, on: .any)
        let queue = queue
        self.listener = listener
        self.port = try await withCheckedThrowingContinuation { continuation in
            let resumed = LockedFlag()
            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if resumed.set(), let port = listener.port?.rawValue {
                        continuation.resume(returning: port)
                    }
                case .failed(let error):
                    if resumed.set() { continuation.resume(throwing: error) }
                default:
                    break
                }
            }
            listener.newConnectionHandler = { [handler, queue] connection in
                Self.serve(connection, handler: handler, queue: queue)
            }
            listener.start(queue: queue)
        }
    }

    deinit {
        listener.cancel()
    }

    func url(_ path: String) -> URL {
        URL(string: "\(isSecure ? "https" : "http")://127.0.0.1:\(port)\(path)")!
    }

    private static func serve(
        _ connection: NWConnection,
        handler: @escaping @Sendable (Request) -> Response,
        queue: DispatchQueue
    ) {
        connection.start(queue: queue)
        receive(connection, buffer: Data()) { request in
            let response = handler(request)
            Task {
                await send(response, on: connection)
            }
        }
    }

    private static func receive(_ connection: NWConnection, buffer: Data, completion: @escaping @Sendable (Request) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1 << 16) { data, _, isComplete, error in
            var buffer = buffer
            if let data { buffer.append(data) }
            if let request = parse(buffer) {
                completion(request)
            } else if isComplete || error != nil {
                connection.cancel()
            } else {
                receive(connection, buffer: buffer, completion: completion)
            }
        }
    }

    /// Returns the request once the headers and the whole body have arrived.
    private static func parse(_ buffer: Data) -> Request? {
        guard let end = buffer.range(of: Data("\r\n\r\n".utf8)) else { return nil }
        let head = String(decoding: buffer[..<end.lowerBound], as: UTF8.self)
        var lines = head.components(separatedBy: "\r\n")
        let requestLine = lines.removeFirst().split(separator: " ")
        guard requestLine.count >= 2 else { return nil }
        var headers: [String: String] = [:]
        for line in lines {
            guard let colon = line.firstIndex(of: ":") else { continue }
            headers[String(line[..<colon])] = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        }
        let length = headers.first { $0.key.lowercased() == "content-length" }.flatMap { Int($0.value) } ?? 0
        let body = buffer[end.upperBound...]
        guard body.count >= length else { return nil }
        return Request(
            method: String(requestLine[0]),
            path: String(requestLine[1]),
            headers: headers,
            body: Data(body.prefix(length))
        )
    }

    private static func send(_ response: Response, on connection: NWConnection) async {
        var head = "HTTP/1.1 \(response.status) \(HTTPURLResponse.localizedString(forStatusCode: response.status))\r\n"
        var headers = response.headers
        headers["Connection"] = "close"
        if !response.omitsContentLength {
            headers["Content-Length"] = String(response.chunks.reduce(0) { $0 + $1.count })
        }
        for (name, value) in headers.sorted(by: { $0.key < $1.key }) {
            head += "\(name): \(value)\r\n"
        }
        head += "\r\n"
        await write(Data(head.utf8), on: connection)
        for (index, chunk) in response.chunks.enumerated() {
            if index > 0, response.chunkDelay > .zero {
                try? await Task.sleep(for: response.chunkDelay)
            }
            await write(chunk, on: connection)
        }
        connection.send(content: nil, contentContext: .finalMessage, isComplete: true, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private static func write(_ data: Data, on connection: NWConnection) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            connection.send(content: data, completion: .contentProcessed { _ in continuation.resume() })
        }
    }
}

/// A flag that can be set once, from any thread.
final class LockedFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var isSet = false

    /// Sets the flag; returns `true` only for the first call.
    func set() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard !isSet else { return false }
        isSet = true
        return true
    }
}
