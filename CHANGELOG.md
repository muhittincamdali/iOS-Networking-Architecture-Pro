# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-15

A rebuilt package. The 1.0.0 release did not build: `iOS-Networking-Architecture-Pro.swift`
had syntax errors and `MainFramework.swift` imported UIKit in a package that also targets
macOS. The sources that followed it depended on four Apple packages, one of which
(swift-async-algorithms 1.1.1) does not compile with Swift 6.4, and several of their APIs
were stubs. This release replaces them with a dependency-free networking layer. Code from two
of the author's packages that are being archived, SwiftNetwork and SwiftCache, was rewritten
for this package rather than copied.

### Added

- Requests: `NetworkClient` and `Endpoint<Response>` with JSON, `Data` and `Void` responses;
  `RequestBody` with JSON, text, data, `URLEncodedForm` (also built from `Encodable` values)
  and `MultipartFormData` bodies; `HTTPHeaders`, `HTTPMethod` and `PathSegment`;
  `urlRequest(for:)`, `upload(_:file:progress:)` and `download(_:to:resumingFrom:progress:)`,
  which continues an interrupted download instead of starting again. Form and multipart
  bodies are based on SwiftNetwork's.
- Transport: `HTTPTransport` and `URLSessionTransport`, which streams bodies (pausing the
  transfer while a slow reader catches up), reports upload and download progress and stops
  reading a body over `Configuration.maximumResponseSize`.
- Failures: `NetworkError`, `RetryPolicy` with exponential backoff, jitter and `Retry-After`,
  and `CircuitBreaker` (based on SwiftNetwork's).
- Authentication: `BearerTokenAuthenticator` with single-flight refresh, one retry per
  request and an allow-list of hosts.
- Caching: `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `LRUCache`,
  `MemoryResponseCache`, `DiskResponseCache` and `HybridResponseCache`, based on SwiftCache's
  LRU, disk and hybrid caches.
- Streaming: server-sent events with `events(_:options:)` and `ServerSentEventParser`, and
  `WebSocketConnection` with reconnection and pings (based on SwiftNetwork's WebSocket
  client).
- GraphQL: `GraphQLOperation`, `GraphQLResponse`, `GraphQLError` and `graphQL(_:path:)`.
- Security: `PublicKeyPinning` and `PinningSessionDelegate` with OpenSSL-compatible pins
  (based on SwiftNetwork's), `RedirectPolicy`, and `Redactor`.
- Observability: `NetworkLogger`, `NetworkEventMonitor`, `ClosureEventMonitor` and
  `URLRequest.curlCommand(redactor:)`; `NetworkMonitor` for connectivity.
- Testing: the `NetworkingArchitectureTesting` library with `MockTransport` and
  `MockResponse`, based on SwiftNetwork's mocks.
- DocC catalog with six articles, the NetworkPlayground example app for iOS and macOS,
  screenshots taken from it, and `.spi.yml`.

### Changed

- The package requires Swift 6.2 tools, builds in the Swift 6 language mode, supports iOS 16,
  macOS 13, tvOS 16, watchOS 9 and visionOS 1, and has no dependencies.

### Removed

- The 1.x API (`NetworkManager`, `APIRequest`, `CacheManager`) and the sources that followed
  it, including `ZeroCopyDecoder`, which returned an empty stream, an `OfflineQueue` that was
  never used, and upload and download methods that ignored their progress closures.
- The `NetworkingREST`, `NetworkingGraphQL`, `NetworkingWebSocket`, `NetworkingSSE`,
  `NetworkingGRPC` and `NetworkingArchitectureFull` products. The gRPC module had no gRPC
  implementation behind it; everything else is in `NetworkingArchitecture`.
- The CocoaPods podspec and the documentation written for the 1.x API.

### Security

- Values that come from a server or from settings cannot crash the app: `Retry-After`
  numbers too large for `Int`, server-sent `retry:` values and retry delays from
  interceptors are clamped before any wait, since `Task.sleep(for:)` traps on durations near
  `Int64.max` seconds; NaN, infinite and negative backoff settings are handled. An event
  stream waits at least `minimumRetry` (1 second by default) between connections, so a
  server that sends `retry: 0` cannot make the client reconnect in a tight loop.
- Memory is bounded: response bodies by `maximumResponseSize`, one server-sent event by
  `maximumEventSize`, one WebSocket message by `maximumMessageSize`, unread events and
  messages by `maximumBufferedEvents` and `maximumBufferedMessages`, and the caches by their
  byte and count limits. A request is sent at most 10 times whatever an interceptor asks for.
- Credentials stay where they belong: the bearer token is only sent to allowed hosts and
  only over `https` or `wss`, `RedirectPolicy.followSafely` (the default) removes credential
  headers on cross-origin redirects and refuses https-to-http redirects, and cache keys
  include a hash of the credential headers (`Authorization`, `Cookie`, API keys) so two
  users of one client never share a cached response.
- Input cannot change the structure of a request: header names and values with line breaks
  are rejected, multipart field and file names are escaped, `PathSegment` keeps user input
  in one path segment, and query values encode `+`.
- Logs and `curl` output pass through `Redactor`, which matches credential names in any
  case, separator or percent-encoding (including zero-width and full-width characters),
  hides bearer tokens and JSON Web Tokens by their value, also reads values that are
  themselves URLs or forms (a `redirect` query value or a JSON string holding
  `https://x/cb?access_token=…`) however deeply they are nested or encoded, and does not
  print bodies it cannot parse.
- Pinning failures surface as `URLError.serverCertificateUntrusted` instead of a
  cancellation, system certificate validation always runs before the pins are checked, and
  a host name with a trailing dot (`api.example.com.`) gets the same pins as without it.

## [1.0.0] - 2026-02-02

First release. It could not be built: one source file had syntax errors and another imported
UIKit in a package that also targets macOS.

[Unreleased]: https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases/tag/v1.0.0
