# Testing Your API Layer

Test the code that talks to your server without a server, and extend the client with
interceptors, monitors and transports of your own.

## Overview

``NetworkClient`` sends every request through an ``HTTPTransport``. In the app that is
``URLSessionTransport``; in tests, the `MockTransport` of the `NetworkingArchitectureTesting`
library answers from canned responses, so tests run fast, offline and the same way every
time.

### Answer with canned responses

Add `NetworkingArchitectureTesting` to your test target, register an answer per method and
path, and pass the transport to the client:

```swift
import NetworkingArchitecture
import NetworkingArchitectureTesting
import Testing

@Test func retriesAfterAServerError() async throws {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))

    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    let users = try await client.send(API.users(page: 1))

    #expect(users.count == 1)
    #expect(transport.requests.count == 2)
}
```

A registered path matches the end of the request path, so `"users"` answers
`https://api.example.com/v1/users?page=1`. Several responses for one route are used in order,
and the last one repeats. `MockResponse` builds JSON, text, empty and failing answers
(`.failure(.notConnectedToInternet)`), can be delayed, and can stream its body in chunks for
event-stream tests. Requests without a route get a `404`.

`transport.requests` records every request with its headers and body, for assertions on what
your code sent. For full control, create the transport with a handler that builds each
response from the request.

### Adapt and retry requests

A ``RequestInterceptor`` can change every request before it is sent, decide whether a failed
request is sent again, and observe the outcome of each attempt:

```swift
struct RequestID: RequestInterceptor {
    func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var request = request
        request.setValue(context.id.uuidString, forHTTPHeaderField: "X-Request-ID")
        return request
    }
}
```

``RequestContext`` carries the attempt number and how often the request was retried for each
``RetryReason``, so an interceptor can limit its own retries.

### Observe requests

A ``NetworkEventMonitor`` sees every send, response, failure and retry; ``NetworkLogger`` is
one. ``ClosureEventMonitor`` forwards events to a closure, for metrics:

```swift
configuration.monitors = [ClosureEventMonitor { event, context in
    if case .didReceive(let request, let response, let duration) = event {
        metrics.record(request.url?.path, status: response.statusCode, duration: duration)
    }
}]
```

### Write a transport

Conform to ``HTTPTransport`` to send requests some other way. Only
``HTTPTransport/send(_:maximumResponseSize:)`` is required; streaming, uploads and downloads
have default implementations built on it.

## See Also

- ``HTTPTransport``
- ``RequestInterceptor``
- ``NetworkEventMonitor``
