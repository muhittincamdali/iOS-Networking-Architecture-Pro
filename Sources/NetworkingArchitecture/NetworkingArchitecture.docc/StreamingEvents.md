# Streaming Events

Read server-sent events and WebSocket messages as async sequences that reconnect on their
own.

## Overview

Both streams are `AsyncThrowingStream`s: iterate them in a task, and stop iterating (or
cancel the task) to close the connection. Both keep a bounded buffer: when your loop falls
behind by more than 1000 items, the stream ends with ``NetworkError/bufferOverflow(limit:)``
instead of using more and more memory.

### Server-sent events

``NetworkClient/events(_:options:)`` opens a `text/event-stream` response and yields each
``ServerSentEvent`` as soon as it is complete:

```swift
struct PriceUpdate: Decodable, Sendable {
    let symbol: String
    let price: Double
}

for try await event in client.events(.get("prices/stream")) where event.type == "price" {
    let update = try event.decode(PriceUpdate.self)
    prices[update.symbol] = update.price
}
```

The request goes through the client's interceptors, so authentication applies. When the
connection drops or the server ends the response, the client waits for the server's `retry:`
time (or ``EventStreamOptions/defaultRetry``) and reconnects with a `Last-Event-ID` header, as
browsers do. A `204 No Content` answer ends the stream; a `4xx` answer or a response that is
not an event stream fails it.

The parser follows the HTML standard: lines may end in CRLF, LF or CR, even split across
chunks; comments are skipped; and an event larger than
``EventStreamOptions/maximumEventSize`` fails the stream instead of growing without bound.
Use ``ServerSentEventParser`` directly to parse events from another source.

### WebSockets

``NetworkClient/webSocket(_:session:options:)`` creates a ``WebSocketConnection`` for an
endpoint, with `http` and `https` turned into `ws` and `wss`:

```swift
let socket = try client.webSocket(.get("live"))

Task {
    for try await message in await socket.messages() {
        if case .text(let text) = message {
            handle(text)
        }
    }
}

try await socket.send(.text(#"{"subscribe":"prices"}"#))
```

``WebSocketConnection/send(_:)`` waits while the connection opens. A ping every 25 seconds
detects a dead connection. When the connection drops, it reconnects with backoff, building
the request again so an authenticator adds a fresh token; a close with code 1000 or 1008
from the server ends the stream instead. ``WebSocketConnection/close(code:)`` closes it for
good.

On watchOS, the system only allows WebSocket connections for apps with an active audio
session.

## See Also

- ``ServerSentEvent``
- ``EventStreamOptions``
- ``WebSocketConnection``
