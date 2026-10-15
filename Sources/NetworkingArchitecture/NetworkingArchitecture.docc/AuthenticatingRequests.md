# Authenticating Requests

Attach a bearer token to your requests and refresh it once, however many requests notice
that it expired.

## Overview

``BearerTokenAuthenticator`` is a ``RequestInterceptor``. It adds
`Authorization: Bearer <token>` to requests for the hosts you list, refreshes the token with
a closure you provide, and retries the requests that failed with `401 Unauthorized`.

### Set up the authenticator

Give it the saved token, the hosts that may receive it, and the refresh call. Send the
refresh through a client *without* the authenticator, so a failing refresh does not try to
refresh itself:

```swift
struct TokenResponse: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

let authClient = NetworkClient(baseURL: authURL, configuration: snakeCaseConfiguration)

let authenticator = BearerTokenAuthenticator(
    token: keychain.loadToken(),
    allowedHosts: ["api.example.com", "*.cdn.example.com"],
    onTokenChange: { token in keychain.save(token) }
) { expired in
    let form: URLEncodedForm = ["grant_type": "refresh_token", "refresh_token": expired.refreshToken ?? ""]
    let response = try await authClient.send(Endpoint<TokenResponse>.post("oauth/token", body: .form(form)))
    return BearerToken(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: Date().addingTimeInterval(TimeInterval(response.expiresIn))
    )
}

var configuration = NetworkClient.Configuration()
configuration.interceptors = [authenticator]
let client = NetworkClient(baseURL: apiURL, configuration: configuration)
```

### What happens on a 401

When several requests fail with `401` together, the first one starts the refresh and the
others wait for its result, so your token endpoint is called once. Each request is then sent
again with the new token. A request is retried at most once after a refresh: if the server
still answers `401`, that answer is thrown instead of refreshing again.

A token whose ``BearerToken/expiresAt`` falls within the leeway (30 seconds by default) is
refreshed before the request is sent, which saves the round trip of a `401`.

### Only to your hosts

The token is only added to requests whose host is in `allowedHosts`. `"*.example.com"`
matches `api.example.com` and `example.com`, but not `evil-example.com`. An absolute URL in
an endpoint, for example a download link taken from a response, never receives the token
unless its host is listed.

### Signing in and out

Call ``BearerTokenAuthenticator/setToken(_:)`` after signing in, and with `nil` when signing
out. If a refresh is still running when you sign out, its result is discarded and the
waiting requests fail with ``NetworkError/authenticationFailed(_:)``.

When the refresh itself fails, for example because the refresh token was revoked, requests
fail with ``NetworkError/authenticationFailed(_:)`` with the refresh error inside. That is
the place to show the sign-in screen:

```swift
do {
    try await client.send(API.profile)
} catch NetworkError.authenticationFailed {
    await authenticator.setToken(nil)
    showSignIn()
}
```

### Other schemes

For an API key or a custom scheme, write a small interceptor:

```swift
struct APIKey: RequestInterceptor {
    let key: String

    func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var request = request
        request.setValue(key, forHTTPHeaderField: "X-API-Key")
        return request
    }
}
```

``URLSessionTransport`` removes credential headers such as `X-API-Key` when a redirect leads
to another origin; see <doc:SecuringTraffic>.

## See Also

- ``BearerTokenAuthenticator``
- ``RequestInterceptor``
