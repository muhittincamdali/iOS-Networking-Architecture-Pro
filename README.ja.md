<!-- i18n-source: README.md@c671cc6ff7a608f863ac18c7f83a709081eeffec status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ja-light.svg" alt="Networking Architecture: URLSession 上の型付きエンドポイント、リトライ、トークン更新、キャッシュ、ストリーミング。依存関係なし。"></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="最新バージョン: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

iOS 16+、macOS 13+、tvOS 16+、watchOS 9+、visionOS 1+ のアプリ向けのネットワーク層です。`URLSession` を土台にしており、依存パッケージはありません。API の各呼び出しを型付きの `Endpoint` として一度だけ記述し、`NetworkClient` で送信します。リトライ、token のリフレッシュ、キャッシュ、ロギング、ストリーミングは、リクエストごとに自分で書くコードではなく、クライアントの設定として扱えます。

## 主な特長

- **型付きの endpoint** — `Endpoint<User>.get("users/42")` は JSON を `User` にデコードします。
  `Endpoint<Data>` は本文をそのまま返し、`Endpoint<Void>` は本文を無視します。JSON、フォーム、
  multipart の本文に対応し、パス内のユーザー入力には `PathSegment` を使います。
- **障害対応を一か所に集約** — 指数バックオフ（exponential backoff）、jitter、`Retry-After` に
  対応した `RetryPolicy`、`CircuitBreaker`、オフライン時のキャッシュへのフォールバック、
  接続が切れた位置から再開するダウンロード、そしてオフラインの端末と 404、
  JSON に合わなくなったモデルを区別できる単一の `NetworkError` 型を備えています。
- **正しい token リフレッシュ** — `BearerTokenAuthenticator` は、401 を受け取ったすべてのリクエストに対して
  リフレッシュを一度だけ行い、それぞれのリクエストを一度ずつ再試行し、
  token は指定したホストにしか送りません。
- **ストリーミング** — HTML 標準の規則どおりに解析する server-sent events と、
  バックオフを挟んで再接続し、ping で接続を維持する WebSocket。
- **デフォルトで安全** — 公開鍵ピンニング（public key pinning）、別オリジンへのリダイレクトを
  たどらずに返す動作、redactor が理解できる部分だけを表示するログと `curl` 出力、
  レスポンスサイズ・バッファするメッセージ数・待ち時間の上限。
- **テストしやすい** — `MockTransport` が用意したレスポンスでリクエストに応答します。
  パッケージ自体の 932 個の Swift Testing テストは macOS で実行され、そのうち 927 個は
  iPhone シミュレータでも実行されます。ローカルの HTTP、TLS、WebSocket サーバーに対するテストも含まれます。

### 含まれるもの

| 分野 | API |
| --- | --- |
| リクエスト | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| レスポンス | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| 耐障害性 | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| 認証 | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| キャッシュ | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| ストリーミング | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| セキュリティ | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| 可観測性 | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| テスト | `MockTransport`、`MockResponse`（`NetworkingArchitectureTesting` ライブラリに含まれます） |

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

ウィンドウ右上の検索フィールドに貼り付けてください。**Dependency Rule** は `2.0.0` からの
**Up to Next Major Version** のままにして、**Add Package** をクリックします。次のウィンドウで
**NetworkingArchitecture** の横からアプリの target を選び、もう一度 **Add Package** をクリックします。

**2. モジュールをインポートする**

```swift
import NetworkingArchitecture
```

**3. リクエストを送る**

レスポンスを `Decodable` な型として記述し、endpoint を送信します。次のコードは、無料のテスト用 API である
JSONPlaceholder から投稿を 1 件読み込みます。

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

`ContentView` で `FirstPostView()` を表示してアプリを実行してください。レスポンスがデコードされると
1 番目の投稿のタイトルが表示されます。URL や JSON を扱うコードを自分で書く必要はありません。

## インストール

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

または `Package.swift` の `dependencies` に追加します。

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

2.0.0 以降を使用してください。1.0.0 はビルドできず、2.0.0 でその API を置き換えました。

## 使い方

以下のサンプルはすべて
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift) からコピーしたものです。
このファイルはサンプルアプリがコンパイルし、テスト target もコンパイルして用意したレスポンスに対して実行します。

### API を一度だけ記述する

各 endpoint は、自身のメソッド、パス、本文、レスポンスの型を持っています。ユーザーから受け取った値は
`PathSegment` を通すので、`ada?admin=1` のような名前でも 1 つのパスセグメントのままです。

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

### クライアントを設定する

API ごとに 1 つのクライアントが、ベース URL と、すべてのリクエストに適用される設定を保持します。
authenticator、circuit breaker、ロガー、キャッシュ、リトライポリシーです。

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

### 失敗を処理する

どの失敗も `NetworkError` なので、`catch` でオフラインの端末と存在しないリソースを区別できます。

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

### 秘密情報をログに残さない

`NetworkLogger` と `URLRequest.curlCommand()` は、すべてのリクエストとレスポンスを
`Redactor` に通します。`Redactor` は完全には理解できないものをすべて隠します。

- **記録されるもの:** メソッド、ステータス、所要時間とサイズ、ヘッダー名、許可リストにある
  ヘッダーの値（デフォルトでは `Accept`, `Accept-Encoding`, `Accept-Language`, `Cache-Control`, `Content-Encoding`,
  `Content-Length`, `Content-Type`, `ETag`, `User-Agent`）、URL の
  スキーム・ホスト・パス・クエリパラメータ名、そしてマスク後の JSON・フォーム・multipart・
  `text/plain` のボディ。
- **決して記録されないもの:** URL のユーザー情報とフラグメント、許可リストにないクエリの値
  （デフォルトではすべて）、その他すべてのヘッダーの値（`Authorization`、`Cookie`、
  `X-API-Key`、名前に `token`・`key`・`auth` を含むものは許可リストにあっても隠されます）、
  `password`・`token`・`api_key` などの秘密の名前の下にある値全体、識別子に見えるパスの
  セグメント（`:id` と書かれます）、multipart ボディのファイル部分、エラーの説明。
- **プレーンな ASCII ではないキー**（キリル文字の `а` を使った `pаssword`、`pass\u200Bword`、
  `şifre`）の値は、デフォルトで隠されます。そのような名前を持つフィールドの隣の値も隠され、
  `{"name":"Ayşe","id":42}` は `{"name":"Ayşe","id":"[REDACTED]"}` として記録されます。
- **値として書かれたラベル**は、文として書かれていても隣の値を隠します。
  `{"question":"What's your PIN?","answer":"1234"}` と `{"title":"PIN (4 digits)","value":"1234"}`
  は、回答と値を隠して記録されます。
- **その他のフィールドの値**と自由テキストからは、JWT、`Bearer` 資格情報、32 文字以上の 16 進数
  または Base64 の文字列、カード番号、IBAN、メールアドレスを探します。JSON の数値は、それが表す
  10 進数として読まれます。Jackson や Gson が `double` を書き出す形の
  `{"amount":4.111111111111111E15}` は `{"amount":"[REDACTED]"}` として記録されます。
- **解析できないボディ**（XML、HTML、Content-Type がない・不明、壊れた JSON、256 KiB 超）は
  記録されず、`[body omitted: 512 bytes, application/xml]` のような注記に置き換えられます。
- **自由テキスト**（残されたヘッダーの値、`text/plain` のボディ、JSON やフォームの文字列）は、
  最初のトリガーから末尾まで隠されます。トリガーは `allowedTextKeys` にないキー、秘密の名前、
  エスケープ、マークアップ、閉じない引用符です。`login password=hunter2 status=200` は
  `login password=[REDACTED]` として記録されます。

```swift
func makeLoggingClient() -> NetworkClient {
    let redactor = Redactor(
        additionalSecretNames: ["license_number"],
        allowedHeaders: Redactor.defaultAllowedHeaders + ["X-Request-ID"],
        allowedQueryParameters: ["page"]
    )
    var configuration = NetworkClient.Configuration()
    configuration.monitors = [NetworkLogger(detail: .bodies, redactor: redactor)]
    return NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, configuration: configuration)
}
```

マスクは安全網であり、保証ではありません。誤ってログに書かれた秘密情報のために作られています。
構造化された入力はパーサーで読み、パーサーが完全には理解できないものはすべて隠します。自由テキストは
ベストエフォートです。`=` や `:` なしで書かれ、2 文字以上を似た文字に置き換えた秘密の名前
（`pɑsswoʀd hunter2`）、ラベルのない秘密（`login -p hunter2`）、パスのセグメントにある短い秘密
（`/reset/abc123`）、テキストや JSON 文字列の中に指数付きで書かれたカード番号
（`"4111111111111111e0"`）、秘密の単語の後に自分の値を持つ文の隣の値
（`{"error":"Error: PIN expired","answer":"1234"}`）は、必ず見つかるとは限りません。そもそもログに書くリクエストに秘密情報を
入れないでください。redactor の以前の開発版が見逃した秘密はすべてテストとして残しています。
すべてのルールは
[Redacting Sensitive Data](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/redactingsensitivedata)
の記事にあります。

変装した文字を読むルールは 1 つです。ASCII の単語の中にある、ASCII の形を持たない 1 つの文字・
結合文字・数字は、任意の 1 文字としても、何もないものとしても読みます。そのため
`tͦken hunter2`、`passw〇rd hunter2`、`piꞏn 1234` は見つかります。残りを追いかけるための
似た文字の表は持ちません。どんな表も完全にはならないからです。構造化ログを使ってください。
フィールドを分け、秘密情報はメッセージに入れないでください。

このモデルにはさらに 2 つの制限があります。**コストの上限:** 1 つの入力に入れ子になったすべての
ドキュメント（文字列内の JSON、テキスト内の URL）は、合わせて入力の長さの最大 4 倍までしか
読み取りません。この予算を超えると、次のドキュメントを含む文字列は丸ごと隠します。自由テキストの
**複数行のレイアウト**に特別な処理は要りません。独立した行にある property list の `<key>`、
複数行にわたる JSON、テキストとして書かれた multipart ボディは、最初のトリガーからテキストの
終わりまで隠すため、値はどこに書かれていても隠れます。

### レスポンスをキャッシュする

設定にキャッシュがあれば、endpoint ごとに `CachePolicy` を選べます。レスポンスは、どこから来たかを示します。

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### 進捗付きでアップロードする

`upload` は endpoint の本文（ここでは multipart フォーム）を送信し、どれだけ送ったかを通知します。
フィールド名とファイル名はエスケープされるため、独自のヘッダーを追加することはできません。

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

### server-sent events をストリーミングする

`events(_:)` はイベントが届くたびに順に返し、接続が切れると `Last-Event-ID` を付けて再接続します。

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

### GraphQL オペレーションを実行する

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

### API 層をテストする

`MockTransport` は用意した応答を順に返します。この例では 1 回目は 503 で失敗し、その後成功するので、
クライアントのリトライもテストに含まれます。

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## サンプルアプリ

[`Examples/NetworkPlayground`](Examples/) は iOS と macOS のアプリで、`NetworkClient` を通じて実際のリクエストを
アプリ内で動く疑似バックエンドに送ります。そのため、どの画面もオフラインで動作します。左から順に、
2 回失敗してから応答するサーバー、1 回の token リフレッシュを共有する 4 つのリクエスト、
server-sent events による価格フィード、パスワード、API key、token、cookie がログに一切出ないサインインです。

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="リトライ画面：503 の応答が 2 回、500 ms と 1000 ms の待機を挟み、3 回目の試行で 200 OK"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="token リフレッシュ画面：4 つのリクエストがそれぞれ 2 回目の試行で 200 を返し、リフレッシュの呼び出しは 1 回だけ"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="server-sent events 画面：8 件の価格更新と、「The server ended the stream after 8 events」 というステータス"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="マスクされたログの画面：ログの行と、パスワード、API key、token、cookie が redacted と表示される curl コマンド"></picture>
</p>

スクリーンショットは、実行中のアプリから
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) で撮影しています。

## ドキュメント

[DocC ドキュメント](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)は、
すべての公開型を網羅しており、次の記事があります。

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Redacting Sensitive Data](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/redactingsensitivedata)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

Swift 6.2 以降（Xcode 26 以降）。このパッケージは Swift 6 言語モードでビルドされます。
watchOS では、アクティブなオーディオセッションを持つアプリにのみ、システムが WebSocket 接続を許可します。

## コントリビューション

バグ報告と pull request を歓迎します。ビルド、テスト、スクリーンショットの再生成の手順は
[CONTRIBUTING.md](CONTRIBUTING.md) をご覧ください。セキュリティ上の問題を非公開で報告する場合は
[SECURITY.md](SECURITY.md) を参照してください。

## ライセンス

MIT。詳細は [LICENSE](LICENSE) を参照してください。
