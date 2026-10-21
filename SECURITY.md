# Security policy

## Supported versions

Security fixes are made for the latest release. Version 1.0.0 is a different, unmaintained code
base that did not build, and does not receive fixes.

## What counts as a vulnerability

The package sits between an app and servers it does not control: it reads responses, headers,
event streams and WebSocket messages, and it holds credentials (bearer tokens, API keys,
cookies) on the app's behalf. Please report privately anything that makes it:

- send a credential somewhere it should not go: a bearer token to a host outside
  `BearerTokenAuthenticator`'s allowed hosts, a credential header or a body across a redirect
  to another origin that `RedirectPolicy` should not have followed or should have stripped, or
  one user's cached response to another;
- accept a server that `PublicKeyPinning` should reject, or accept an invalid certificate
  because a key is pinned;
- write a secret that `Redactor` documents that it hides into `NetworkLogger` output or
  `curlCommand()` (the cases that the Redacting Sensitive Data article lists under "What it
  does not find" are known limits);
- let input change a request's structure: a header line injected through a header value, a
  multipart part or header injected through a field or file name, or path segments and query
  items injected through a `PathSegment`;
- crash (a trap, an integer overflow, an out-of-range index) on anything a server sends,
  such as a `Retry-After` or `retry:` value, instead of throwing or clamping;
- allocate memory or wait without bound because of what a server sends, beyond the limits
  `maximumResponseSize`, `maximumEventSize`, `maximumMessageSize` and the stream buffer limits
  document;
- write outside the directory given to `DiskResponseCache`.

## Reporting a vulnerability

Please report vulnerabilities privately, not in a public issue, pull request or discussion.

1. **Preferred:** open the repository's **Security** tab and choose
   **Report a vulnerability** ([how private reporting works](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)).
2. **Or** email [muhittincamdali@gmail.com](mailto:muhittincamdali@gmail.com) with
   "Security" in the subject.

Include the version (tag or commit), the platform and Xcode version, the request and response
(or a small project) that trigger the problem, and what happens.

## What happens next

You get an answer within a week. Confirmed problems are fixed in a release, with a test that
reproduces them and a note in the changelog; you are credited unless you ask not to be.
