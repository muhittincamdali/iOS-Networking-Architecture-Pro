# Getting Started

Add the package, describe your API as endpoints, and send them with one client.

## Overview

This article walks from an empty project to a client that decodes responses, sends bodies and
reports errors you can act on.

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git`, and add the
**NetworkingArchitecture** library to your app target. Add **NetworkingArchitectureTesting**
to your test target if you want `MockTransport`.

In a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git", from: "2.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "NetworkingArchitecture", package: "iOS-Networking-Architecture-Pro")
    ])
]
```

### Describe your API

An ``Endpoint`` describes one request and the type its response decodes to. Collect them in
one place, so the rest of the app never builds URLs by hand:

```swift
enum API {
    static func users(page: Int) -> Endpoint<[User]> {
        .get("users", query: [URLQueryItem(name: "page", value: String(page))])
    }

    static func createUser(_ user: NewUser) -> Endpoint<User> {
        .post("users", body: .json(user))
    }

    static func deleteUser(id: Int) -> Endpoint<Void> {
        .delete("users/\(id)")
    }
}
```

The type parameter decides how the body is read: a `Decodable` type is decoded from JSON,
`Data` is returned unchanged and `Void` ignores the body. Paths are appended to the client's
base URL; wrap values that come from the user in ``PathSegment`` so they cannot add segments
or a query.

### Send requests

```swift
let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!)

let users = try await client.send(API.users(page: 1))
let created = try await client.send(API.createUser(NewUser(name: "Ada")))
try await client.send(API.deleteUser(id: created.id))
```

``NetworkClient/send(_:)`` returns the decoded value. ``NetworkClient/response(for:)``
returns an ``HTTPResponse`` with the status code, the headers, how many attempts the request
took and whether it came from the cache.

A client holds no mutable state: create one per API and share it.

### Configure the client

``NetworkClient/Configuration`` holds what applies to every request:

```swift
var configuration = NetworkClient.Configuration()
configuration.headers["X-Client-Version"] = "2.0"
configuration.decoder.keyDecodingStrategy = .convertFromSnakeCase
configuration.monitors = [NetworkLogger()]

let client = NetworkClient(baseURL: apiURL, configuration: configuration)
```

The defaults retry idempotent requests twice after timeouts and `5xx` answers, read at most
50 MB of a response into memory, and ask for JSON.

### Handle errors

Every failure is a ``NetworkError``:

```swift
do {
    let users = try await client.send(API.users(page: 1))
    show(users)
} catch let error as NetworkError where error.isConnectivityProblem {
    showOfflineBanner()
} catch NetworkError.unacceptableStatusCode(404, _) {
    showEmptyState()
} catch {
    showAlert(error.localizedDescription)
}
```

``NetworkError/unacceptableStatusCode(_:_:)`` and ``NetworkError/decodingFailed(_:_:)``
carry the response, so you can read an error body your server sends.

### Upload and download

``NetworkClient/upload(_:file:progress:)`` sends an endpoint's body, or a file read as it is
sent, and reports progress. ``NetworkClient/download(_:to:resumingFrom:progress:)`` writes
the body to a file and only replaces the destination once the download has succeeded. When
the connection drops, the retry continues where the download stopped, and
``NetworkError/resumeData`` lets you continue a failed download later:

```swift
var form = MultipartFormData()
form.append(jpeg, name: "photo", fileName: "beach.jpg", mimeType: "image/jpeg")

let photo = try await client.upload(Endpoint<Photo>.post("photos", body: .multipart(form))) { progress in
    print(progress.fractionCompleted ?? 0)
}
```

## See Also

- <doc:HandlingFailures>
- <doc:AuthenticatingRequests>
- <doc:TestingYourAPILayer>
