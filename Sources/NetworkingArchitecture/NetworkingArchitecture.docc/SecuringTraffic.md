# Securing Traffic

Pin your server's keys, keep credentials on their origin, keep secrets out of logs, and keep
user input out of the structure of your URLs.

## Overview

The package's defaults are chosen so that a request does not leak more than it has to. This
article explains each safeguard and the settings that change it.

### Pin public keys

``PublicKeyPinning`` accepts a server only when its certificate chain contains one of the keys
you pinned. A pin is the Base64 SHA-256 hash of a certificate's SubjectPublicKeyInfo, the same
value OpenSSL prints:

```sh
openssl s_client -connect api.example.com:443 -servername api.example.com </dev/null \
  | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary | base64
```

```swift
let pinning = PublicKeyPinning(pins: [
    "api.example.com": ["<current key pin>", "<backup key pin>"]
])
let client = NetworkClient(baseURL: apiURL, transport: URLSessionTransport(pinning: pinning))
```

The system's certificate validation always runs first; a pin never makes an invalid
certificate acceptable. Pin a backup key as well (or your CA's intermediate), so renewing a
certificate does not lock your app out. A rejected server fails the request with
``NetworkError/transport(_:)`` and the code `URLError.serverCertificateUntrusted`.

### Keep credentials on their origin

`URLSession` drops `Authorization` when a redirect leads to another origin but forwards every
other header. With the default ``RedirectPolicy/followSafely``, ``URLSessionTransport`` also
removes on such a redirect every header that carries a credential: a name that a ``Redactor``
always hides (such as `X-API-Key`, `Cookie` or any name with `token`, `key` or `auth`), and a
value that starts with an authentication scheme (`X-Upstream: Bearer …`) or that the free-text
rule would cut (a URL with a query, a `key=value` pair, an escape). It also refuses redirects
from `https` to `http`. ``RedirectPolicy/doNotFollow``
returns every redirect to you instead.

``BearerTokenAuthenticator`` adds its token only to the hosts you list, so an absolute URL
to another server never receives it.

### Keep secrets out of logs

``NetworkLogger`` and `URLRequest.curlCommand(redactor:)` pass everything through a
``Redactor``, which hides what it does not fully understand. Header values are kept only for a
short allowlist (`Accept`, `Content-Type`, `User-Agent`, …), and never for `Authorization`,
`Cookie` or a name with `token`, `key` or `auth`. A URL loses its user info and fragment, its
query values unless you allow the parameter, and path segments that look like identifiers. JSON,
form and multipart bodies are parsed, and the whole value under a secret key, or under any key that
is not plain ASCII, is hidden. Bodies that cannot be parsed, such as XML, are left out with a
note. Kept text is cut at its first sign of a secret.

```swift
let redactor = Redactor(additionalSecretNames: ["customerReference"], allowedQueryParameters: ["page"])
configuration.monitors = [NetworkLogger(detail: .headers, redactor: redactor)]
```

Redaction is a safety net, not a guarantee: keep secrets out of what you log in the first place.
<doc:RedactingSensitiveData> lists what is logged, what never is, and what the rules do not find.

### Keep user input in its place

A value interpolated into a path can change the request: `"x?role=admin"` adds a query and
`".."` climbs a level. Wrap such values in ``PathSegment``:

```swift
Endpoint<Profile>.get("users/\(PathSegment(username))/profile")
```

Header names and values with line breaks are rejected with
``NetworkError/invalidRequest(_:)``, and multipart field and file names are escaped, so input
cannot add headers or parts of its own.

### Bound what a server can make you hold

A response body is read into memory up to
``NetworkClient/Configuration/maximumResponseSize`` (50 MB by default) and fails with
``NetworkError/responseTooLarge(limit:)`` beyond it; downloads go to disk instead. Event
streams limit the size of one event, WebSockets the size of one message, and both the number
of items waiting to be read. Delays from `Retry-After`, `retry:` or an interceptor are
clamped, so a server cannot make a request wait for years.

## See Also

- ``PublicKeyPinning``
- ``RedirectPolicy``
- ``Redactor``
- <doc:RedactingSensitiveData>
- ``PathSegment``
