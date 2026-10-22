# Examples

## NetworkPlayground

A small iOS and macOS app that sends real requests through `NetworkClient` to a pretend
backend running inside the app (`DemoServer`, built on `MockTransport`), so every screen
works offline and behaves the same way on every run:

- **Typed endpoints and caching**: loads a list of users with `cacheFirst`; reloading
  within 30 seconds answers from the memory cache without a request.
- **Retries with backoff**: calls an endpoint that answers 503 twice, and shows each
  attempt, response and wait as a `NetworkEventMonitor` reports them.
- **Token refresh**: sends four requests at once with an expired token; all four get a 401,
  `BearerTokenAuthenticator` refreshes once, and each request is retried with the new token.
- **Server-sent events**: opens a price feed and shows each event as it arrives.
- **Redacted logs**: signs in with a password and an API key, and shows what
  `NetworkLogger` writes and what `curlCommand()` prints.

It uses the package from this checkout (a local package reference to `../..`), so it always
shows the current code.

Run it:

1. Open `Examples/NetworkPlayground/NetworkPlayground.xcodeproj` in Xcode 26 or later.
2. Choose the **NetworkPlayground** scheme and an iPhone simulator or **My Mac** as the run
   destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/NetworkPlayground
xcodebuild build -scheme NetworkPlayground -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme NetworkPlayground -destination 'platform=macOS'
```

To open one screen and run its demo directly, pass its name as a launch argument, for
example `-screen retries` (the names are the cases of `PlaygroundView.Screen`).
[`scripts/capture-example-screens.sh`](../scripts/capture-example-screens.sh) takes the
README screenshots that way.

The README samples live in
[`NetworkPlayground/ReadmeSamples.swift`](NetworkPlayground/NetworkPlayground/ReadmeSamples.swift).
The README copies its code from that file, the app compiles it, and the package's test target
compiles and runs it through the symlink
`Tests/NetworkingArchitectureTests/ReadmeExamples.swift`.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](NetworkPlayground/project.yml) and committed, so you only need XcodeGen after
editing `project.yml`.
