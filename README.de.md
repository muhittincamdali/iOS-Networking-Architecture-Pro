<!-- i18n-source: README.md@ce4eaf1718e4211f5d9cd662c3a78c661abb0a4c status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-de-light.svg" alt="Networking Architecture: Typisierte Endpunkte, Wiederholungen, Token-Erneuerung, Caching und Streaming auf URLSession, ohne Abhängigkeiten."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

Eine Netzwerkschicht für Apps auf iOS 16+, macOS 13+, tvOS 16+, watchOS 9+ und visionOS 1+, gebaut auf `URLSession` und ohne Abhängigkeiten. Du beschreibst jeden Aufruf deiner API einmal als typisierten `Endpoint` und sendest ihn mit einem `NetworkClient`; Wiederholungen, Token-Erneuerung, Caching, Logging und Streaming sind Einstellungen dieses Clients, statt Code, den du um jede einzelne Anfrage herum schreibst.

## Highlights

- **Typisierte Endpoints** — `Endpoint<User>.get("users/42")` dekodiert JSON in einen `User`;
  `Endpoint<Data>` liefert den Body unverändert und `Endpoint<Void>` ignoriert ihn. Unterstützt
  JSON-, Formular- und Multipart-Bodies sowie `PathSegment` für Benutzereingaben in Pfaden.
- **Fehler an einer Stelle behandelt** — eine `RetryPolicy` mit exponentiellem Backoff
  (exponential backoff), Jitter und `Retry-After`, ein `CircuitBreaker`, Cache-Fallbacks im
  Offline-Betrieb, Downloads, die dort weitermachen, wo die Verbindung abgebrochen ist, und ein
  einziger `NetworkError`-Typ, der ein Gerät ohne Verbindung von einem 404 oder von einem Modell
  unterscheidet, das nicht mehr zum JSON passt.
- **Token-Erneuerung richtig gemacht** — `BearerTokenAuthenticator` erneuert das Token einmal für
  alle Anfragen, die ein 401 erhalten haben, wiederholt jede davon einmal und sendet das Token nur
  an deine Hosts.
- **Streaming** — Server-sent Events, geparst nach den Regeln des HTML-Standards, und ein
  WebSocket, der sich mit Backoff neu verbindet und sich mit Pings am Leben hält.
- **Standardmäßig sicher** — Public-Key-Pinning, Header mit Zugangsdaten werden bei
  Weiterleitungen auf einen anderen Ursprung entfernt, Geheimnisse werden in Logs und in der
  `curl`-Ausgabe geschwärzt, und es gibt Grenzen für Antwortgröße, gepufferte Nachrichten und
  Wartezeiten.
- **Testbar** — `MockTransport` beantwortet Anfragen mit vorbereiteten Antworten; die 229
  Swift-Testing-Tests des Pakets laufen auf macOS, 228 davon auch in einem iPhone-Simulator,
  darunter Tests gegen einen lokalen HTTP-, TLS- und WebSocket-Server.

### Was enthalten ist

| Bereich | API |
| --- | --- |
| Anfragen | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| Antworten | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| Ausfallsicherheit | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| Authentifizierung | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| Caching | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| Streaming | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| Sicherheit | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| Beobachtbarkeit | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| Tests | `MockTransport`, `MockResponse` (in der Bibliothek `NetworkingArchitectureTesting`) |

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Füge sie in das Suchfeld oben rechts im Fenster ein. Lass **Dependency Rule** auf
**Up to Next Major Version** ab `2.0.0` stehen und klicke auf **Add Package**. Wähle im nächsten
Fenster neben **NetworkingArchitecture** das Target deiner App aus und klicke erneut auf
**Add Package**.

**2. Modul importieren**

```swift
import NetworkingArchitecture
```

**3. Anfrage senden**

Beschreibe die Antwort als `Decodable`-Typ und sende einen Endpoint. Dieser Code lädt einen Beitrag
von JSONPlaceholder, einer kostenlosen Test-API:

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

Zeige `FirstPostView()` in deiner `ContentView` an und starte die App: Der Titel von Beitrag 1
erscheint, sobald die Antwort dekodiert ist, ganz ohne eigenen Code für URLs oder JSON.

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Oder füge es zu den `dependencies` in deiner `Package.swift` hinzu:

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

Verwende Version 2.0.0 oder neuer: Die Version 1.0.0 ließ sich nicht bauen, und 2.0.0 ersetzt deren API.

## Verwendung

Jedes der folgenden Beispiele ist aus
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift) kopiert.
Die Beispiel-App kompiliert diese Datei, und das Test-Target kompiliert sie und führt sie gegen
vorbereitete Antworten aus.

### Beschreibe deine API einmal

Jeder Endpoint kennt seine Methode, seinen Pfad, seinen Body und seinen Antworttyp. Ein Wert vom
Benutzer läuft über `PathSegment`, sodass ein Name wie `ada?admin=1` ein einziges Pfadsegment bleibt.

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

### Einen Client konfigurieren

Ein Client pro API enthält die Basis-URL und alles, was für sämtliche Anfragen gilt: den
Authenticator, den Circuit Breaker, den Logger, den Cache und die Retry-Richtlinie.

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

### Fehler behandeln

Jeder Fehler ist ein `NetworkError`, daher kann ein `catch` ein Gerät ohne Verbindung von einer
nicht vorhandenen Ressource unterscheiden.

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

### Antworten cachen

Ist in der Konfiguration ein Cache eingetragen, wählt jeder Endpoint seine eigene `CachePolicy`. Die
Antwort verrät, woher sie stammt.

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### Hochladen mit Fortschritt

`upload` sendet den Body des Endpoints, hier ein Multipart-Formular, und meldet, wie viel bereits
gesendet wurde. Feld- und Dateinamen werden maskiert, sodass sie keine eigenen Header einschleusen
können.

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

### Server-sent Events streamen

`events(_:)` liefert jedes Event, sobald es eintrifft, und verbindet sich mit `Last-Event-ID` neu,
wenn die Verbindung abbricht.

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

### GraphQL-Operationen ausführen

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

### Deine API-Schicht testen

`MockTransport` spielt vorbereitete Antworten ab; dieses Beispiel scheitert einmal mit 503 und hat
danach Erfolg, sodass der Retry des Clients Teil des Tests ist.

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## Beispiel-App

[`Examples/NetworkPlayground`](Examples/) ist eine iOS- und macOS-App, die echte Anfragen über
`NetworkClient` an ein vorgetäuschtes Backend schickt, das in der App selbst läuft; deshalb
funktioniert jeder Bildschirm offline. Von links nach rechts: ein Server, der zweimal scheitert,
bevor er antwortet, vier Anfragen, die sich eine einzige Token-Erneuerung teilen, ein Preis-Feed
über Server-sent Events und eine Anmeldung, bei der Passwort, API-Schlüssel, Token und Cookie nie im
Log landen.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="Bildschirm für Wiederholungen: zwei 503-Antworten, Wartezeiten von 500 und 1000 ms, dann 200 OK nach 3 Versuchen"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="Bildschirm für Token-Erneuerung: vier Anfragen, jeweils nach 2 Versuchen mit 200 beantwortet, bei nur einem Erneuerungsaufruf"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="Bildschirm für Server-sent Events: acht Preisaktualisierungen und der Status „The server ended the stream after 8 events“"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="Bildschirm für geschwärzte Logs: Logzeilen und ein curl-Befehl, in dem Passwort, API-Schlüssel, Token und Cookie als redacted erscheinen"></picture>
</p>

Die Screenshots werden von
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) in der laufenden App
aufgenommen.

## Dokumentation

Die [DocC-Dokumentation](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)
deckt jeden öffentlichen Typ ab und enthält diese Artikel:

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## Voraussetzungen

| Plattform | Mindestversion |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

Swift 6.2 oder neuer (Xcode 26 oder neuer). Das Paket wird im Swift-6-Sprachmodus gebaut. Auf
watchOS erlaubt das System WebSocket-Verbindungen nur für Apps mit einer aktiven Audiositzung.

## Mitwirken

Fehlerberichte und Pull Requests sind willkommen; [CONTRIBUTING.md](CONTRIBUTING.md) erklärt, wie
du das Paket baust, testest und die Screenshots neu erzeugst. Eine Sicherheitslücke meldest du
vertraulich, wie in [SECURITY.md](SECURITY.md) beschrieben.

## Lizenz

MIT. Siehe [LICENSE](LICENSE).
