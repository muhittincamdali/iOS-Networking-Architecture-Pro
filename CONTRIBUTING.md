# Contributing

Thanks for taking the time to improve Networking Architecture.

## Reporting bugs

Open an issue with:

- the endpoint, client configuration and interceptors involved (with secrets removed;
  `request.curlCommand()` prints a redacted copy of a request),
- what you expected and what happened, with the `NetworkError` you got,
- the server's response if it matters (status, headers, body),
- platform and OS version (simulator or device) and Xcode version.

## Pull requests

1. Fork the repository and branch from `master`.
2. Keep each pull request focused on one change.
3. Run the tests on macOS and on an iOS simulator:

    ```sh
    swift test --no-parallel
    swift test -c release --no-parallel --filter Redaction
    xcodebuild test -scheme NetworkingArchitecture-Package \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
    ```

   The tests start HTTP, TLS and WebSocket servers on 127.0.0.1; nothing goes to the internet.
   They run one at a time (the shared `NetworkingArchitecture-Package` scheme turns off
   parallel testing): the redaction test corpus keeps every core busy for minutes in a debug
   build, and the tests with a timeout fail when they wait behind it. The release run checks
   the redaction time and memory limits in an optimized build.
4. Add or update a test for every behaviour you change in `Tests/NetworkingArchitectureTests`.
   Use `MockTransport` for client logic and the local servers in `Tests/.../Support` when the
   behaviour depends on `URLSession` itself (streaming, redirects, TLS, WebSockets).
5. Anything that comes from a server or a setting (status codes, headers such as
   `Retry-After`, event fields, sizes, durations) may be missing, malformed, negative or huge.
   Clamp or reject it before it reaches arithmetic, a `Duration` or `Task.sleep`, and add a
   test with the extreme value. New buffers need a limit.
6. If you change a README code sample, change the copy in
   `Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift` as well. That file is what
   gets compiled: by the example app, and by `swift test` through the symlink
   `Tests/NetworkingArchitectureTests/ReadmeExamples.swift`, where `ReadmeSamplesTests` also
   runs it. Build the app with:

    ```sh
    cd Examples/NetworkPlayground
    xcodebuild build -scheme NetworkPlayground -destination 'generic/platform=iOS Simulator'
    ```

7. If a change affects what the example app shows, regenerate the screenshots with
   `scripts/capture-example-screens.sh`.
8. `README.md` has translations (`README.<language>.md`). Each one records the version of
   `README.md` it follows, and CI fails while a translation is behind. If you change `README.md`
   and cannot update the translations, say so in the pull request and they will be updated
   before it is merged.

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- The package builds in the Swift 6 language mode and has no dependencies; new code should
  not add warnings or dependencies.
- Document public API with DocC comments (`///`); the documentation builds with
  `--warnings-as-errors`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).
