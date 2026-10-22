# ``NetworkingArchitecture``

Typed endpoints, retries, token refresh, caching, streaming and certificate pinning on top of
URLSession, without dependencies.

## Overview

NetworkingArchitecture is a networking layer for apps on iOS 16, macOS 13, tvOS 16, watchOS 9
and visionOS 1 and later. You describe each call of your API once as an ``Endpoint`` and send
it with a ``NetworkClient``:

```swift
struct User: Decodable, Sendable {
    let id: Int
    let name: String
}

let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!)
let user = try await client.send(Endpoint<User>.get("users/42"))
```

Around that core the package covers what most apps end up writing by hand:

- **Failures**: a ``RetryPolicy`` with exponential backoff that honours `Retry-After`, a
  ``CircuitBreaker``, and one ``NetworkError`` type that tells an offline device from a
  server error.
- **Authentication**: ``BearerTokenAuthenticator`` refreshes an expired token once for all
  waiting requests, and only sends it to your hosts.
- **Caching**: ``CachePolicy`` with memory, disk and hybrid ``ResponseCache``s, including
  `ETag` revalidation.
- **Streaming**: server-sent events with ``NetworkClient/events(_:options:)`` and a
  reconnecting ``WebSocketConnection``.
- **Security**: ``PublicKeyPinning``, a ``RedirectPolicy`` that by default does not follow
  redirects to another origin, a ``Redactor`` that keeps secrets out of logs by hiding what it does not understand, and ``PathSegment``
  for user input in paths.
- **Testing**: the `NetworkingArchitectureTesting` library's `MockTransport` answers
  requests from canned responses, so your API layer can be tested without a server.

## Topics

### Essentials

- <doc:GettingStarted>
- ``NetworkClient``
- ``Endpoint``
- ``NetworkError``
- ``HTTPResponse``

### Requests

- ``HTTPMethod``
- ``HTTPHeaders``
- ``RequestBody``
- ``URLEncodedForm``
- ``MultipartFormData``
- ``PathSegment``
- ``UploadBody``
- ``TransferProgress``
- ``ProgressHandler``

### Retries and resilience

- <doc:HandlingFailures>
- ``RetryPolicy``
- ``RetryDecision``
- ``RetryReason``
- ``CircuitBreaker``
- ``NetworkMonitor``
- ``NetworkPath``

### Authentication

- <doc:AuthenticatingRequests>
- ``BearerTokenAuthenticator``
- ``BearerToken``

### Caching

- ``CachePolicy``
- ``ResponseCache``
- ``CachedResponse``
- ``MemoryResponseCache``
- ``DiskResponseCache``
- ``HybridResponseCache``
- ``ResponseSource``
- ``LRUCache``

### Streaming

- <doc:StreamingEvents>
- ``ServerSentEvent``
- ``ServerSentEventParser``
- ``EventStreamOptions``
- ``WebSocketConnection``

### GraphQL

- ``GraphQLOperation``
- ``GraphQLResponse``
- ``GraphQLError``
- ``GraphQLFailure``

### Security and logging

- <doc:SecuringTraffic>
- <doc:RedactingSensitiveData>
- ``PublicKeyPinning``
- ``PinningSessionDelegate``
- ``RedirectPolicy``
- ``Redactor``
- ``RedactionOutcome``
- ``NetworkLogger``

### Extending the client

- <doc:TestingYourAPILayer>
- ``RequestInterceptor``
- ``RequestContext``
- ``AttemptOutcome``
- ``NetworkEventMonitor``
- ``NetworkEvent``
- ``ClosureEventMonitor``
- ``HTTPTransport``
- ``URLSessionTransport``
