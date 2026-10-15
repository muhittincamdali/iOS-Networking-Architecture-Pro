# Handling Failures

Retry what a retry can fix, stop calling a service that is down, and fall back to cached
responses when the device is offline.

## Overview

Networks fail in different ways, and each needs a different answer. The client separates
them: a ``RetryPolicy`` handles brief failures, a ``CircuitBreaker`` handles a service that
stays down, and a ``CachePolicy`` lets a screen show the last known data.

### Retry brief failures

The client's ``NetworkClient/Configuration/retryPolicy`` applies to every endpoint that does
not set its own. The default sends an idempotent request (`GET`, `HEAD`, `PUT`, `DELETE`,
`OPTIONS`) up to three times after a timeout, a lost connection or a `408`, `429`, `500`,
`502`, `503` or `504` answer, waiting 0.5 s and then 1 s with 20 % jitter:

```swift
var policy = RetryPolicy.default
policy.maximumAttempts = 5
policy.baseDelay = .seconds(1)

let report = API.report(id: 7).with(\.retryPolicy, policy)
```

A `Retry-After` header, in seconds or as an HTTP date, replaces the computed delay. When
it asks for longer than ``RetryPolicy/maximumRetryAfter`` (60 s by default), the request
fails instead of hanging. `POST` and `PATCH` are not retried unless you set
``RetryPolicy/retriesNonIdempotentRequests``, because the server may already have acted on
a request whose answer was lost.

Whatever a policy or an interceptor asks for, a request is sent at most
``RetryPolicy/attemptLimit`` (10) times, and no single wait is longer than a day.

### Stop calling a service that is down

When a backend is down, every request waits for its timeout and adds to the load that keeps
it down. A ``CircuitBreaker`` opens after a number of consecutive failures and fails requests
at once with ``NetworkError/circuitOpen(retryAfter:)``; after a pause it lets one request
through to test the service:

```swift
configuration.interceptors = [CircuitBreaker(failureThreshold: 5, resetTimeout: .seconds(30))]
```

A `4xx` answer counts as a success here: the server is up and answered.

### Fall back to the cache

Give the client a ``ResponseCache`` and choose a policy per endpoint:

```swift
configuration.cache = HybridResponseCache()

let feed = API.feed.with(\.cachePolicy, .networkFirst(maxStale: .seconds(86_400)))
let response = try await client.response(for: feed)
if response.source == .staleCache {
    showBanner("You are offline; this is the feed from earlier.")
}
```

- ``CachePolicy/cacheFirst(maxAge:)`` answers from a fresh stored response without a request.
- ``CachePolicy/networkFirst(maxStale:)`` returns a stored response when the device is offline
  or the server answers `5xx`.
- ``CachePolicy/revalidate`` sends `If-None-Match` and `If-Modified-Since` and uses the stored
  body when the server answers `304 Not Modified`.

Only `GET` and `HEAD` responses with a `2xx` status and without `Cache-Control: no-store` are
stored. Cache keys include a hash of the credential headers (`Authorization`, `Cookie`,
`X-API-Key` and every other name ``Redactor`` hides), so two users of one client never see
each other's responses. Cookies that `URLSession` adds from its cookie storage are not part of
the request when the key is made, so an app that signs in with such cookies should call
``ResponseCache/removeAll()`` when the user signs out.

### Watch connectivity

``NetworkMonitor`` reports changes of the device's connection, for an offline banner:

```swift
for await path in NetworkMonitor.paths() {
    isOffline = !path.isConnected
}
```

Do not use it to decide whether to send a request; send it and check
``NetworkError/isConnectivityProblem`` when it fails.

## See Also

- ``RetryPolicy``
- ``CircuitBreaker``
- ``CachePolicy``
