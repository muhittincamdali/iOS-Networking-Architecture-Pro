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
  (based on SwiftNetwork's), `RedirectPolicy`, and `Redactor` with `RedactionOutcome`.
- Observability: `NetworkLogger`, `NetworkEventMonitor`, `ClosureEventMonitor` and
  `URLRequest.curlCommand(redactor:)`; `NetworkMonitor` for connectivity.
- Testing: the `NetworkingArchitectureTesting` library with `MockTransport` and
  `MockResponse`, based on SwiftNetwork's mocks.
- DocC catalog with seven articles, the NetworkPlayground example app for iOS and macOS,
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
  only over `https` or `wss`. `RedirectPolicy.followSameOrigin` (the default) follows a
  redirect only when it keeps the scheme, host and port of the request it answers, and
  returns any other redirect to the caller; `RedirectPolicy.followSafely` follows redirects to
  other origins without the body and without credential headers (names that `Redactor` always
  hides, and values that start with an authentication scheme or that its free-text rule would
  cut). Both refuse https-to-http redirects and a `Location` with a user name or password.
  Cache keys include a hash of the same credential headers so two users of one client never
  share a cached response.
- Input cannot change the structure of a request: header names and values with line breaks
  are rejected, multipart field and file names are escaped, `PathSegment` keeps user input
  in one path segment, and query values encode `+`.
- Logs and `curl` output pass through `Redactor`, which hides what it does not fully
  understand. Header values are kept only for an allowlist (`Accept`, `Content-Type`,
  `User-Agent`, …; never `Authorization`, `Cookie` or a name with `token`, `key` or
  `auth`), query values only for parameters the app allows (none by default); URLs lose their
  user info and fragment, path segments that look like identifiers become `:id`, and a path
  with a dot segment or a `;` keeps only the scheme and host. JSON, form and multipart bodies
  are parsed: the whole value under a secret name, or under a key that is not plain ASCII, is
  hidden, and a body that cannot be parsed, has an unknown content type or is larger than
  256 KiB is left out with a note. Free text (kept header values, `text/plain` bodies,
  strings in JSON and forms) is hidden from its first trigger to its end. A field that holds a
  name (`name`, `label`, `type`, `id`, …) that names a secret or is not plain ASCII hides the
  values beside it, a Turkish `name` of a record included. Depth, nesting, reading and time
  are bounded. The design, the rules and their test corpus are those of iOSSecurityTools 2.1.0
  (one function classifies every name; separate readers for names, free text and JSON; one
  cumulative depth and reading budget; shared static tables), with this package's header
  allowlist and secret-name extensions (`sig`, `jwt`, `code`). The secrets that the rules used
  during development missed — values holding URLs, forms or JSON, `+` read as a space,
  `;jsessionid`, percent-encoded path segments, a value after a bracket that does not close,
  `&#` before a value, an address before a vertical tab — are kept as tests, with the review
  probes of iOSSecurityTools, iOSDevelopmentTools and this package. Redaction is a safety net,
  not a guarantee: a secret name in free text disguised with look-alike letters and no
  separator, a secret with no label and a short secret in a path segment are not guaranteed to
  be found.
- Pinning failures surface as `URLError.serverCertificateUntrusted` instead of a
  cancellation, system certificate validation always runs before the pins are checked, and
  a host name with a trailing dot (`api.example.com.`) gets the same pins as without it.

## [1.0.0] - 2026-02-02

First release. It could not be built: one source file had syntax errors and another imported
UIKit in a package that also targets macOS.

[Unreleased]: https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases/tag/v1.0.0
