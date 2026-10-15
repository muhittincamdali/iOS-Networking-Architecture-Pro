import Foundation

/// One event of a `text/event-stream` response.
public struct ServerSentEvent: Sendable, Hashable {
    /// The event type from the `event:` field; `"message"` when the server sent none.
    public var type: String

    /// The `data:` lines of the event, joined with line feeds.
    public var data: String

    /// The last event ID the server sent (with an `id:` field in this or an earlier event),
    /// or an empty string.
    public var id: String

    /// Creates an event, for example to test code that handles events.
    public init(type: String = "message", data: String, id: String = "") {
        self.type = type
        self.data = data
        self.id = id
    }

    /// Decodes ``data`` as JSON.
    public func decode<Value: Decodable>(_ type: Value.Type, decoder: JSONDecoder = JSONDecoder()) throws -> Value {
        try decoder.decode(type, from: Data(data.utf8))
    }
}

/// Reads server-sent events from bytes as they arrive, following the WHATWG HTML standard's
/// event stream interpretation.
///
/// Feed it chunks in order; a chunk may end anywhere, even between the `\r` and `\n` of a
/// line break. Lines may end with CRLF, LF or CR, a leading byte order mark is skipped,
/// comments (`:`) are ignored, `retry:` only accepts digits, and an `id:` containing NUL is
/// ignored.
///
/// ```swift
/// var parser = ServerSentEventParser()
/// for event in try parser.parse(Data("data: hello\n\n".utf8)) {
///     print(event.data) // "hello"
/// }
/// ```
public struct ServerSentEventParser: Sendable {
    /// The error thrown when an event or line exceeds ``maximumEventSize``.
    public struct EventTooLarge: Error, Sendable, Equatable {
        /// The limit that was exceeded, in bytes.
        public let limit: Int
    }

    /// The largest event (or single line) kept in memory, in bytes. A server that sends more
    /// without a blank line makes ``parse(_:)`` throw ``EventTooLarge`` instead of growing
    /// memory without bound.
    public let maximumEventSize: Int

    /// The ID of the last event, sent as `Last-Event-ID` when reconnecting.
    public private(set) var lastEventID = ""

    /// The reconnection delay the server asked for with `retry:`, if any.
    public private(set) var reconnectionTime: Duration?

    private var line: [UInt8] = []
    private var data = ""
    private var dataBytes = 0
    private var eventType = ""
    private var skippedBOM = false
    private var lastByteWasCR = false

    /// Creates a parser.
    public init(maximumEventSize: Int = 1_048_576) {
        self.maximumEventSize = max(1, maximumEventSize)
    }

    /// Consumes `bytes` and returns the events they complete.
    public mutating func parse(_ bytes: some Sequence<UInt8>) throws -> [ServerSentEvent] {
        var events: [ServerSentEvent] = []
        for byte in bytes {
            if !skippedBOM {
                if try handleBOM(byte) { continue }
            }
            switch byte {
            case UInt8(ascii: "\n") where lastByteWasCR:
                // The LF of a CRLF whose CR already ended the line.
                lastByteWasCR = false
            case UInt8(ascii: "\n"), UInt8(ascii: "\r"):
                lastByteWasCR = byte == UInt8(ascii: "\r")
                if let event = try endLine() { events.append(event) }
            default:
                lastByteWasCR = false
                guard line.count + dataBytes < maximumEventSize else {
                    throw EventTooLarge(limit: maximumEventSize)
                }
                line.append(byte)
            }
        }
        return events
    }

    /// Returns `true` when `byte` belongs to a leading byte order mark (EF BB BF).
    private mutating func handleBOM(_ byte: UInt8) throws -> Bool {
        let bom: [UInt8] = [0xEF, 0xBB, 0xBF]
        if line.count < bom.count, byte == bom[line.count], line == Array(bom.prefix(line.count)) {
            line.append(byte)
            if line.count == bom.count {
                line.removeAll()
                skippedBOM = true
            }
            return true
        }
        // Not a BOM: whatever was buffered is ordinary content.
        skippedBOM = true
        return false
    }

    private mutating func endLine() throws -> ServerSentEvent? {
        defer { line.removeAll(keepingCapacity: true) }
        if line.isEmpty {
            return dispatch()
        }
        if line.first == UInt8(ascii: ":") {
            return nil
        }
        let text = String(decoding: line, as: UTF8.self)
        let field: Substring
        var value: Substring
        if let colon = text.firstIndex(of: ":") {
            field = text[..<colon]
            value = text[text.index(after: colon)...]
            if value.first == " " { value = value.dropFirst() }
        } else {
            field = text[...]
            value = ""
        }
        switch field {
        case "event":
            eventType = String(value)
        case "data":
            data += value + "\n"
            dataBytes += value.utf8.count + 1
        case "id" where !value.contains("\0"):
            lastEventID = String(value)
        case "retry":
            if !value.isEmpty, value.unicodeScalars.allSatisfy({ ("0"..."9").contains($0) }),
               let milliseconds = Int(value) {
                reconnectionTime = .milliseconds(milliseconds)
            }
        default:
            break
        }
        return nil
    }

    /// A parser for a new connection: the same limit, last event ID and retry time, with
    /// any partly received event discarded.
    func restarted() -> ServerSentEventParser {
        var parser = ServerSentEventParser(maximumEventSize: maximumEventSize)
        parser.lastEventID = lastEventID
        parser.reconnectionTime = reconnectionTime
        return parser
    }

    private mutating func dispatch() -> ServerSentEvent? {
        defer {
            data = ""
            dataBytes = 0
            eventType = ""
        }
        guard !data.isEmpty else { return nil }
        return ServerSentEvent(
            type: eventType.isEmpty ? "message" : eventType,
            data: String(data.dropLast()),
            id: lastEventID
        )
    }
}
