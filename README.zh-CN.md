<!-- i18n-source: README.md@1e81d980b108d49ca5f54d545a62a31a34190fe3 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-zh-CN-light.svg" alt="Networking Architecture: 基于 URLSession：类型化端点、重试、令牌刷新、缓存和流式传输，无依赖。"></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="最新版本: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

一个面向 iOS 16+、macOS 13+、tvOS 16+、watchOS 9+ 和 visionOS 1+ 应用的网络层，基于 `URLSession` 构建，不依赖任何第三方库。你只需把 API 的每个调用描述一次，写成带类型的 `Endpoint`，再用 `NetworkClient` 发送；重试、token 刷新、缓存、日志和流式传输都是这个 client 的配置项，不必再围绕每个请求自己编写代码。

## 亮点

- **带类型的 endpoint**：`Endpoint<User>.get("users/42")` 会把 JSON 解码为 `User`；
  `Endpoint<Data>` 返回原始响应体，`Endpoint<Void>` 则忽略响应体。支持 JSON、表单和
  multipart 请求体，并提供 `PathSegment` 来安全处理路径中的用户输入。
- **失败只需处理一次**：带指数退避（exponential backoff）、jitter 和 `Retry-After` 的
  `RetryPolicy`，`CircuitBreaker`，离线时回退到缓存，从连接中断处继续的下载，以及统一的
  `NetworkError` 类型，可以区分设备离线、404，以及模型与 JSON 不再匹配的情况。
- **正确的 token 刷新**：`BearerTokenAuthenticator` 会为所有收到 401 的请求只刷新一次，
  并把这些请求各重试一次，而且只会把 token 发给你指定的主机。
- **流式传输**：按 HTML 标准规则解析的 server-sent events，以及带退避重连、
  并通过 ping 保持连接的 WebSocket。
- **默认安全**：公钥固定（public key pinning）、跨源重定向时丢弃凭据请求头、
  在日志和 `curl` 输出中隐去敏感信息，并对响应大小、缓冲消息数量和等待时间设置上限。
- **易于测试**：`MockTransport` 用预设的响应来应答请求；本软件包自带的 194 个
  Swift Testing 测试都在 macOS 上运行，其中 193 个也在 iPhone 模拟器上运行，
  包括针对本地 HTTP、TLS 和 WebSocket 服务器的测试。

### 包含的内容

| 领域 | API |
| --- | --- |
| 请求 | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| 响应 | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| 容错 | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| 身份验证 | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| 缓存 | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| 流式传输 | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| 安全 | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| 可观测性 | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| 测试 | `MockTransport`、`MockResponse`（位于 `NetworkingArchitectureTesting` 库中） |

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

把它粘贴到窗口右上角的搜索框中。将 **Dependency Rule** 保持为从 `2.0.0` 开始的
**Up to Next Major Version**，然后点击 **Add Package**。在下一个窗口中，
在 **NetworkingArchitecture** 旁边选择你的 App target，再次点击 **Add Package**。

**2. 导入模块**

```swift
import NetworkingArchitecture
```

**3. 发送请求**

把响应描述为一个 `Decodable` 类型，然后发送 endpoint。下面的代码从免费的测试 API
JSONPlaceholder 加载一篇帖子：

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

在 `ContentView` 中显示 `FirstPostView()` 并运行 App：响应解码完成后，
第 1 篇帖子的标题就会出现，你不需要自己编写任何 URL 或 JSON 代码。

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

或者将其添加到 `Package.swift` 的 `dependencies` 中：

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

请使用 2.0.0 或更高版本：1.0.0 版本无法编译，2.0.0 替换了它的 API。

## 使用方法

下面的每个示例都复制自
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift)，
示例 App 会编译这个文件，测试 target 也会编译它，并用预设的响应来运行。

### 一次性描述你的 API

每个 endpoint 都知道自己的方法、路径、请求体和响应类型。来自用户的值要通过
`PathSegment` 传入，因此像 `ada?admin=1` 这样的名字仍然只是一个路径段。

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

### 配置 client

每个 API 对应一个 client，它保存 base URL 以及适用于所有请求的设置：
authenticator、circuit breaker、日志记录器、缓存和重试策略。

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

### 处理失败

每个失败都是一个 `NetworkError`，所以 `catch` 可以区分设备离线和资源不存在。

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

### 缓存响应

配置中有缓存时，endpoint 可以选择自己的 `CachePolicy`。响应会说明它来自哪里。

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### 带进度的上传

`upload` 会发送 endpoint 的请求体（这里是 multipart 表单），并报告已发送了多少。
字段名和文件名会被转义，因此它们无法添加自己的请求头。

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

### 接收 server-sent events 流

`events(_:)` 会在每个事件到达时立即产出它，并在连接断开时使用 `Last-Event-ID` 重新连接。

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

### 执行 GraphQL 操作

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

### 测试你的 API 层

`MockTransport` 会按脚本返回预设的响应；下面这个例子先以 503 失败一次，再成功，
因此 client 的重试也成为测试的一部分。

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## 示例 App

[`Examples/NetworkPlayground`](Examples/) 是一个 iOS 和 macOS App，它通过 `NetworkClient`
把真实的请求发送到运行在 App 内部的模拟后端，因此每个页面离线时也能工作。
从左到右依次是：先失败两次才应答的服务器，共用一次 token 刷新的四个请求，
通过 server-sent events 推送的价格流，以及密码、API key、token 和 cookie 都不会进入日志的登录页。

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="重试页面：两次 503 响应，等待 500 毫秒和 1000 毫秒，第 3 次尝试后返回 200 OK"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="token 刷新页面：四个请求各在 2 次尝试后得到 200 响应，只发生了一次刷新调用"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="Server-sent events 页面：八次价格更新，状态为 “The server ended the stream after 8 events”"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="日志脱敏页面：日志行和一条 curl 命令，其中密码、API key、token 和 cookie 都显示为 redacted"></picture>
</p>

这些截图由
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) 从正在运行的 App 中截取。

## 文档

[DocC 文档](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)
涵盖每个公开类型，并包含以下文章：

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

需要 Swift 6.2 或更高版本（Xcode 26 或更高版本）。该软件包使用 Swift 6 语言模式构建。
在 watchOS 上，系统只允许有活动音频会话的 App 建立 WebSocket 连接。

## 参与贡献

欢迎提交 bug 报告和 pull request；[CONTRIBUTING.md](CONTRIBUTING.md) 说明了如何构建、测试以及重新生成截图。
如需私下报告安全问题，请参阅 [SECURITY.md](SECURITY.md)。

## 许可证

MIT。详见 [LICENSE](LICENSE)。
