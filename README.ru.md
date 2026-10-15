<!-- i18n-source: README.md@ce4eaf1718e4211f5d9cd662c3a78c661abb0a4c status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-ru-light.svg" alt="Networking Architecture: Типизированные эндпоинты, повторы, обновление токенов, кэш и стриминг на URLSession, без зависимостей."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="Последняя версия: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

Сетевой слой для приложений на iOS 16+, macOS 13+, tvOS 16+, watchOS 9+ и visionOS 1+, построенный на `URLSession` и не имеющий зависимостей. Каждый вызов вашего API вы описываете один раз как типизированный `Endpoint` и отправляете через `NetworkClient`; повторные попытки, обновление токена, кеширование, логирование и стриминг настраиваются в клиенте, и вам не приходится писать код вокруг каждого запроса.

## Основные возможности

- **Типизированные endpoint'ы** — `Endpoint<User>.get("users/42")` декодирует JSON в `User`;
  `Endpoint<Data>` возвращает тело как есть, а `Endpoint<Void>` его игнорирует. Поддерживаются
  тела в формате JSON, формы и multipart, а `PathSegment` защищает пользовательский ввод в путях.
- **Сбои обрабатываются в одном месте** — `RetryPolicy` с экспоненциальной задержкой
  (exponential backoff), jitter и `Retry-After`, `CircuitBreaker`, обращение к кешу без сети,
  загрузки, которые продолжаются с места обрыва соединения, и единый тип `NetworkError`, который
  отличает устройство без сети от ответа 404 и от модели, больше не совпадающей с JSON.
- **Правильное обновление токена** — `BearerTokenAuthenticator` обновляет токен один раз для всех
  запросов, получивших 401, повторяет каждый из них по одному разу и отправляет токен только
  вашим хостам.
- **Стриминг** — server-sent events, разбираемые по правилам стандарта HTML, и WebSocket, который
  переподключается с нарастающей задержкой и поддерживает соединение пингами.
- **Безопасность по умолчанию** — public key pinning, удаление заголовков с учётными данными при
  редиректах на другой origin, скрытие секретов в логах и в выводе `curl`, а также ограничения на
  размер ответа, число буферизуемых сообщений и время ожидания.
- **Удобство тестирования** — `MockTransport` отвечает на запросы заранее заготовленными ответами;
  собственные 229 тестов пакета на Swift Testing запускаются на macOS, а 228 из них — ещё и на
  симуляторе iPhone, включая тесты с локальным HTTP-, TLS- и WebSocket-сервером.

### Что входит в пакет

| Область | API |
| --- | --- |
| Запросы | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| Ответы | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| Отказоустойчивость | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| Аутентификация | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| Кеширование | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| Стриминг | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| Безопасность | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| Наблюдаемость | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| Тестирование | `MockTransport`, `MockResponse` (в библиотеке `NetworkingArchitectureTesting`) |

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Вставьте его в поле поиска в правом верхнем углу окна. Оставьте для **Dependency Rule** значение
**Up to Next Major Version** начиная с `2.0.0` и нажмите **Add Package**. В следующем окне
выберите target вашего приложения рядом с **NetworkingArchitecture** и снова нажмите **Add Package**.

**2. Импортируйте модуль**

```swift
import NetworkingArchitecture
```

**3. Отправьте запрос**

Опишите ответ как тип `Decodable` и отправьте endpoint. Этот код загружает пост из JSONPlaceholder —
бесплатного тестового API:

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

Покажите `FirstPostView()` в своём `ContentView` и запустите приложение: как только ответ будет
декодирован, появится заголовок поста 1, и вам не придётся писать собственный код для URL или JSON.

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

Используйте версию 2.0.0 или новее: версия 1.0.0 не собиралась, а 2.0.0 заменяет её API.

## Использование

Все примеры ниже скопированы из
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift): этот файл
компилирует демонстрационное приложение, а тестовый target компилирует и запускает его с
заготовленными ответами.

### Опишите свой API один раз

Каждый endpoint знает свой метод, путь, тело и тип ответа. Значение от пользователя проходит через
`PathSegment`, поэтому имя вроде `ada?admin=1` остаётся одним сегментом пути.

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

### Настройте клиент

Один клиент на API хранит базовый URL и всё, что относится ко всем его запросам: аутентификатор,
circuit breaker, логгер, кеш и политику повторных попыток.

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

### Обработайте сбои

Любой сбой — это `NetworkError`, поэтому `catch` может отличить устройство без сети от отсутствующего
ресурса.

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

### Кешируйте ответы

Если в конфигурации задан кеш, каждый endpoint выбирает свою `CachePolicy`. Ответ сообщает, откуда он
получен.

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### Загрузка на сервер с прогрессом

`upload` отправляет тело endpoint'а — здесь это multipart-форма — и сообщает, сколько уже отправлено.
Имена полей и файлов экранируются, поэтому они не могут добавить собственные заголовки.

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

### Стриминг server-sent events

`events(_:)` выдаёт каждое событие по мере поступления и переподключается с `Last-Event-ID`, когда
соединение обрывается.

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

### Выполнение операций GraphQL

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

### Тестирование слоя API

`MockTransport` проигрывает сценарные ответы; в этом примере он один раз отвечает 503, а затем
успешно, поэтому повторная попытка клиента становится частью теста.

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## Демонстрационное приложение

[`Examples/NetworkPlayground`](Examples/) — приложение для iOS и macOS, которое отправляет настоящие
запросы через `NetworkClient` на вымышленный бэкенд, работающий внутри самого приложения, поэтому
каждый экран работает без сети. Слева направо: сервер, который дважды отвечает ошибкой, прежде чем
ответить успешно; четыре запроса, делящие одно обновление токена; лента цен на server-sent events и
экран входа, где пароль, API-ключ, токен и cookie никогда не попадают в лог.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="Экран повторных попыток: два ответа 503, паузы 500 и 1000 мс, затем 200 OK после 3 попыток"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="Экран обновления токена: четыре запроса получили ответ 200 после 2 попыток каждый, при этом обновление токена вызвано один раз"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="Экран server-sent events: восемь обновлений цен и статус «The server ended the stream after 8 events»"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="Экран скрытых логов: строки лога и команда curl, в которой пароль, API-ключ, токен и cookie отображаются как redacted"></picture>
</p>

Скриншоты снимаются с работающего приложения скриптом
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh).

## Документация

[Документация DocC](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)
охватывает каждый публичный тип и включает следующие статьи:

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

Swift 6.2 или новее (Xcode 26 или новее). Пакет собирается в языковом режиме Swift 6. На watchOS
система разрешает WebSocket-соединения только приложениям с активной аудиосессией.

## Участие в разработке

Сообщения об ошибках и pull request'ы приветствуются; в [CONTRIBUTING.md](CONTRIBUTING.md) описано,
как собирать пакет, запускать тесты и заново создавать скриншоты. О проблеме безопасности
сообщайте конфиденциально, как описано в [SECURITY.md](SECURITY.md).

## Лицензия

MIT. Подробнее — в файле [LICENSE](LICENSE).
