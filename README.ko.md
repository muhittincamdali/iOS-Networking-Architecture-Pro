<!-- i18n-source: README.md@ce4eaf1718e4211f5d9cd662c3a78c661abb0a4c status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ko-light.svg" alt="Networking Architecture: URLSession 기반 타입 엔드포인트, 재시도, 토큰 갱신, 캐싱, 스트리밍. 의존성 없음."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="최신 버전: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+ 앱을 위한 네트워킹 레이어로, `URLSession` 위에 만들어졌고 의존성이 없습니다. API의 각 호출을 타입이 있는 `Endpoint`로 한 번만 정의하고 `NetworkClient`로 전송하면 됩니다. 재시도, token 갱신, 캐싱, 로깅, 스트리밍은 요청마다 직접 코드를 작성하는 대신 클라이언트의 설정으로 처리합니다.

## 주요 기능

- **타입이 있는 endpoint** — `Endpoint<User>.get("users/42")`는 JSON을 `User`로 디코딩합니다.
  `Endpoint<Data>`는 응답 본문을 그대로 반환하고, `Endpoint<Void>`는 본문을 무시합니다. JSON, 폼,
  multipart 본문을 지원하며, 경로에 들어가는 사용자 입력에는 `PathSegment`를 사용합니다.
- **실패를 한 곳에서 처리** — 지수 백오프(exponential backoff), jitter, `Retry-After`를 지원하는
  `RetryPolicy`, `CircuitBreaker`, 오프라인일 때의 캐시 폴백, 연결이 끊어진 지점부터 이어받는
  다운로드, 그리고 오프라인 기기와 404, 더 이상 JSON과 맞지 않는 모델을 구분해 주는
  단일 `NetworkError` 타입을 제공합니다.
- **올바른 token 갱신** — `BearerTokenAuthenticator`는 401을 받은 모든 요청에 대해 한 번만 갱신하고,
  각 요청을 한 번씩 다시 시도하며, token은 지정한 호스트에만 보냅니다.
- **스트리밍** — HTML 표준의 규칙에 따라 파싱하는 server-sent events와, 백오프를 두고
  다시 연결하며 ping으로 연결을 유지하는 WebSocket.
- **기본적으로 안전** — 공개 키 고정(public key pinning), 다른 출처로의 리디렉션 시 인증 헤더 제거,
  로그와 `curl` 출력에서 비밀 값 마스킹, 응답 크기·버퍼링되는 메시지 수·대기 시간에 대한 제한.
- **테스트하기 쉬움** — `MockTransport`가 미리 준비한 응답으로 요청에 답합니다. 패키지 자체의
  229개 Swift Testing 테스트가 macOS에서 실행되며, 그중 228개는 iPhone 시뮬레이터에서도 실행됩니다.
  로컬 HTTP, TLS, WebSocket 서버를 대상으로 한 테스트도 포함됩니다.

### 포함된 기능

| 영역 | API |
| --- | --- |
| 요청 | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| 응답 | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| 복원력 | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| 인증 | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| 캐싱 | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| 스트리밍 | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| 보안 | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| 관측 가능성 | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| 테스트 | `MockTransport`, `MockResponse` (`NetworkingArchitectureTesting` 라이브러리에 포함) |

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

창 오른쪽 위의 검색 필드에 붙여 넣으세요. **Dependency Rule**은 `2.0.0`부터인
**Up to Next Major Version**으로 둔 채 **Add Package**를 클릭합니다. 다음 창에서
**NetworkingArchitecture** 옆에 앱 target을 선택하고 **Add Package**를 다시 클릭하세요.

**2. 모듈 가져오기**

```swift
import NetworkingArchitecture
```

**3. 요청 보내기**

응답을 `Decodable` 타입으로 정의하고 endpoint를 전송하세요. 다음 코드는 무료 테스트용 API인
JSONPlaceholder에서 게시물 하나를 불러옵니다.

```swift
struct Post: Decodable, Sendable {
    let id: Int
    let title: String
}

func loadFirstPost() async throws -> Post {
    let client = NetworkClient(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
    return try await client.send(Endpoint<Post>.get("posts/1"))
}

struct FirstPostView: View {
    @State private var title = "Loading…"

    var body: some View {
        Text(title)
            .padding()
            .task {
                do {
                    title = try await loadFirstPost().title
                } catch {
                    title = error.localizedDescription
                }
            }
    }
}
```

`ContentView`에 `FirstPostView()`를 표시하고 앱을 실행하세요. 응답이 디코딩되면
1번 게시물의 제목이 나타나며, URL이나 JSON을 다루는 코드를 직접 작성할 필요가 없습니다.

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

또는 `Package.swift`의 `dependencies`에 추가하세요.

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "NetworkingArchitecture", package: "iOS-Networking-Architecture-Pro")
    ]),
    .testTarget(name: "YourAppTests", dependencies: [
        .product(name: "NetworkingArchitectureTesting", package: "iOS-Networking-Architecture-Pro")
    ])
]
```

2.0.0 이상을 사용하세요. 1.0.0 릴리스는 빌드되지 않았고, 2.0.0은 그 API를 대체합니다.

## 사용법

아래 예제는 모두
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift)에서 복사한 것입니다.
이 파일은 예제 앱이 컴파일하고, 테스트 target도 컴파일해서 미리 준비한 응답으로 실행합니다.

### API를 한 번만 정의하기

각 endpoint는 자신의 메서드, 경로, 본문, 응답 타입을 알고 있습니다. 사용자에게서 받은 값은
`PathSegment`를 거치므로 `ada?admin=1` 같은 이름도 하나의 경로 세그먼트로 유지됩니다.

```swift
struct User: Codable, Sendable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct NewUser: Encodable, Sendable {
    let name: String
}

enum API {
    static func users(page: Int) -> Endpoint<[User]> {
        .get("users", query: [URLQueryItem(name: "page", value: String(page))])
    }

    static func user(named name: String) -> Endpoint<User> {
        .get("users/by-name/\(PathSegment(name))")
    }

    static func createUser(_ user: NewUser) -> Endpoint<User> {
        .post("users", body: .json(user))
    }

    static func deleteUser(id: Int) -> Endpoint<Void> {
        .delete("users/\(id)")
    }
}
```

### 클라이언트 설정하기

API마다 클라이언트 하나가 기본 URL과 모든 요청에 적용되는 설정을 갖습니다.
authenticator, circuit breaker, 로거, 캐시, 재시도 정책입니다.

```swift
func makeClient(savedToken: BearerToken?, refresh: @escaping BearerTokenAuthenticator.Refresh) -> NetworkClient {
    let authenticator = BearerTokenAuthenticator(
        token: savedToken,
        allowedHosts: ["api.example.com"],
        refresh: refresh
    )

    var configuration = NetworkClient.Configuration()
    configuration.decoder.keyDecodingStrategy = .convertFromSnakeCase
    configuration.interceptors = [authenticator, CircuitBreaker()]
    configuration.monitors = [NetworkLogger(detail: .headers)]
    configuration.cache = HybridResponseCache()
    configuration.retryPolicy.maximumAttempts = 4

    return NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, configuration: configuration)
}
```

### 실패 처리하기

모든 실패는 `NetworkError`이므로, `catch`에서 오프라인 기기와 존재하지 않는 리소스를 구분할 수 있습니다.

```swift
enum LoadState: Equatable {
    case loaded([User])
    case offline
    case notFound
    case failed(String)
}

func loadUsers(with client: NetworkClient) async -> LoadState {
    do {
        return .loaded(try await client.send(API.users(page: 1)))
    } catch let error as NetworkError where error.isConnectivityProblem {
        return .offline
    } catch NetworkError.unacceptableStatusCode(404, _) {
        return .notFound
    } catch {
        return .failed(error.localizedDescription)
    }
}
```

### 응답 캐싱하기

구성에 캐시가 있으면 endpoint가 `CachePolicy`를 선택합니다. 응답은 어디에서 왔는지 알려 줍니다.

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### 진행률과 함께 업로드하기

`upload`는 endpoint의 본문(여기서는 multipart 폼)을 전송하고 얼마나 보냈는지 알려 줍니다.
필드 이름과 파일 이름은 이스케이프되므로 자체 헤더를 추가할 수 없습니다.

```swift
struct Photo: Decodable, Sendable {
    let id: Int
}

func uploadPhoto(_ jpeg: Data, with client: NetworkClient) async throws -> Photo {
    var form = MultipartFormData()
    form.append("Holiday", name: "title")
    form.append(jpeg, name: "photo", fileName: "beach.jpg", mimeType: "image/jpeg")

    let response = try await client.upload(Endpoint<Photo>.post("photos", body: .multipart(form))) { progress in
        print("Sent \(Int((progress.fractionCompleted ?? 0) * 100)) %")
    }
    return response.value
}
```

### server-sent events 스트리밍하기

`events(_:)`는 이벤트가 도착하는 대로 하나씩 전달하고, 연결이 끊어지면 `Last-Event-ID`로 다시 연결합니다.

```swift
struct PriceUpdate: Decodable, Sendable {
    let symbol: String
    let price: Double
}

func watchPrices(with client: NetworkClient) async throws -> [PriceUpdate] {
    var updates: [PriceUpdate] = []
    for try await event in client.events(.get("prices/stream")) where event.type == "price" {
        updates.append(try event.decode(PriceUpdate.self))
    }
    return updates
}
```

### GraphQL 작업 실행하기

```swift
struct ViewerData: Decodable, Sendable {
    struct Viewer: Decodable, Sendable { let login: String }
    let viewer: Viewer
}

func viewerLogin(with client: NetworkClient) async throws -> String {
    let operation = GraphQLOperation<ViewerData>("query { viewer { login } }")
    return try await client.graphQL(operation).viewer.login
}
```

### API 레이어 테스트하기

`MockTransport`는 미리 정해 둔 응답을 차례로 돌려줍니다. 이 예제는 한 번 503으로 실패한 뒤 성공하므로
클라이언트의 재시도도 테스트에 포함됩니다.

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## 예제 앱

[`Examples/NetworkPlayground`](Examples/)는 iOS와 macOS 앱으로, `NetworkClient`를 통해 실제 요청을
앱 안에서 실행되는 가상 백엔드로 보냅니다. 그래서 모든 화면이 오프라인에서도 동작합니다.
왼쪽부터 순서대로, 두 번 실패한 뒤에 응답하는 서버, 하나의 token 갱신을 공유하는 네 개의 요청,
server-sent events로 받는 가격 피드, 그리고 비밀번호, API key, token, 쿠키가 로그에 전혀 남지 않는 로그인 화면입니다.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="재시도 화면: 503 응답 두 번, 500ms와 1000ms 대기, 3번째 시도에서 200 OK"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="token 갱신 화면: 네 개의 요청이 각각 2번째 시도에서 200 응답을 받았고, 갱신 호출은 한 번뿐"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="server-sent events 화면: 가격 업데이트 8건과 'The server ended the stream after 8 events' 상태"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="마스킹된 로그 화면: 로그 줄과, 비밀번호, API key, token, 쿠키가 redacted로 표시되는 curl 명령"></picture>
</p>

스크린샷은 실행 중인 앱에서
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh)로 촬영합니다.

## 문서

[DocC 문서](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)는
모든 공개 타입을 다루며, 다음 글이 포함되어 있습니다.

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## 요구 사항

| 플랫폼 | 최소 버전 |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

Swift 6.2 이상(Xcode 26 이상). 이 패키지는 Swift 6 언어 모드로 빌드됩니다.
watchOS에서는 활성 오디오 세션이 있는 앱에서만 시스템이 WebSocket 연결을 허용합니다.

## 기여하기

버그 보고와 pull request를 환영합니다. 빌드, 테스트, 스크린샷 재생성 방법은
[CONTRIBUTING.md](CONTRIBUTING.md)에 설명되어 있습니다. 보안 문제를 비공개로 제보하려면
[SECURITY.md](SECURITY.md)를 참고하세요.

## 라이선스

MIT. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
