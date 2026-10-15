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
removes on such a redirect every header whose name or value a ``Redactor`` would hide (such
as `X-API-Key`, `Cookie` or `X-Upstream: Bearer …`), and refuses redirects from `https` to
`http`. ``RedirectPolicy/doNotFollow``
returns every redirect to you instead.

``BearerTokenAuthenticator`` adds its token only to the hosts you list, so an absolute URL
to another server never receives it.

### Keep secrets out of logs

``NetworkLogger`` and `URLRequest.curlCommand(redactor:)` pass everything through a
``Redactor``. It hides header, query, JSON and form values whose names look like credentials
(`password`, `access_token`, `Access-Token`, `ACCESS%5FTOKEN`, `apiKey`, …), any value that
starts with an HTTP authentication scheme (`Bearer …`, `Token …`, `Negotiate …`, …, and
`Bearer+…` in a query, where `+` is a space) or is a JSON Web Token, and the user and
password of a URL. A value that is itself a URL or a form is read too, however it is nested
or encoded, so a `redirect` query value or a JSON string holding
`https://x/cb?access_token=…` is hidden. Bodies it cannot parse, such as XML, are summarised
by size only.

Path parameters such as `;jsessionid=…` are treated like query fields. Redaction is a safety
net, not a guarantee: a secret that is a whole path segment (`/reset/8f2a…`) or sits under an
unusual name is not recognised. Add your own names:

```swift
var redactor = Redactor()
redactor.sensitiveNames.insert("customerReference")
configuration.monitors = [NetworkLogger(detail: .headers, redactor: redactor)]
```

Names are compared after lower-casing them and removing everything but letters and digits,
so `customerReference` also covers `customer_reference` and `Customer-Reference`.

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
- ``PathSegment``
