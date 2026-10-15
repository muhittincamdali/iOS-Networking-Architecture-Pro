<!-- i18n-source: README.md@1e81d980b108d49ca5f54d545a62a31a34190fe3 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-fr-light.svg" alt="Networking Architecture: Endpoints typés, relances, renouvellement de jeton, cache et streaming sur URLSession, sans dépendance."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="Dernière version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

Une couche réseau pour les apps sur iOS 16+, macOS 13+, tvOS 16+, watchOS 9+ et visionOS 1+, construite sur `URLSession` et sans dépendance. Vous décrivez chaque appel de votre API une seule fois sous la forme d’un `Endpoint` typé et vous l’envoyez avec un `NetworkClient` ; les nouvelles tentatives, le renouvellement du token, le cache, la journalisation et le streaming sont des réglages de ce client, et non du code que vous écrivez autour de chaque requête.

## Points forts

- **Endpoints typés** — `Endpoint<User>.get("users/42")` décode le JSON en `User` ;
  `Endpoint<Data>` renvoie le corps tel quel et `Endpoint<Void>` l’ignore. Prise en charge des
  corps JSON, de formulaire et multipart, et de `PathSegment` pour les saisies de l’utilisateur
  dans les chemins.
- **Les échecs sont gérés au même endroit** — une `RetryPolicy` avec attente exponentielle
  (exponential backoff), jitter et `Retry-After`, un `CircuitBreaker`, un repli sur le cache hors
  connexion, des téléchargements qui reprennent là où la connexion s’est interrompue, et un seul
  type `NetworkError` qui distingue un appareil hors connexion d’une erreur 404 ou d’un modèle qui
  ne correspond plus au JSON.
- **Un renouvellement de token bien fait** — `BearerTokenAuthenticator` renouvelle le token une
  seule fois pour toutes les requêtes qui ont reçu un 401, relance chacune d’elles une fois et
  n’envoie le token qu’à vos hôtes.
- **Streaming** — des server-sent events analysés selon les règles du standard HTML, et un
  WebSocket qui se reconnecte avec une attente progressive et reste actif grâce à des pings.
- **Sûr par défaut** — épinglage de clé publique (public key pinning), en-têtes d’identifiants
  supprimés lors des redirections vers une autre origine, secrets masqués dans les journaux et
  dans la sortie de `curl`, et limites sur la taille des réponses, les messages mis en tampon et
  les délais d’attente.
- **Testable** — `MockTransport` répond aux requêtes avec des réponses préparées ; les 194 tests
  Swift Testing du paquet s’exécutent sur macOS, dont 193 aussi sur un simulateur d’iPhone, y
  compris des tests contre un serveur local HTTP, TLS et WebSocket.

### Ce qui est inclus

| Domaine | API |
| --- | --- |
| Requêtes | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| Réponses | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| Résilience | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| Authentification | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| Cache | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| Streaming | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| Sécurité | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| Observabilité | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| Tests | `MockTransport`, `MockResponse` (dans la bibliothèque `NetworkingArchitectureTesting`) |

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Collez-la dans le champ de recherche en haut à droite de la fenêtre. Laissez **Dependency Rule** sur
**Up to Next Major Version** à partir de `2.0.0`, puis cliquez sur **Add Package**. Dans la fenêtre
suivante, choisissez la cible de votre app en face de **NetworkingArchitecture** et cliquez de
nouveau sur **Add Package**.

**2. Importer le module**

```swift
import NetworkingArchitecture
```

**3. Envoyer une requête**

Décrivez la réponse sous la forme d’un type `Decodable` et envoyez un endpoint. Ce code charge un
article depuis JSONPlaceholder, une API de test gratuite :

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

Affichez `FirstPostView()` dans votre `ContentView` et lancez l’app : le titre de l’article 1
apparaît une fois la réponse décodée, sans aucun code d’URL ni de JSON de votre part.

## Installation

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Ou ajoutez-le aux `dependencies` de votre `Package.swift` :

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

Utilisez la version 2.0.0 ou une version ultérieure : la version 1.0.0 ne compilait pas, et la 2.0.0 remplace son API.

## Utilisation

Chaque exemple ci-dessous est copié depuis
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift), que l’app
d’exemple compile et que la cible de tests compile et exécute avec des réponses préparées.

### Décrire votre API une seule fois

Chaque endpoint connaît sa méthode, son chemin, son corps et le type de sa réponse. Une valeur
fournie par l’utilisateur passe par `PathSegment`, si bien qu’un nom comme `ada?admin=1` reste un seul
segment de chemin.

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

### Configurer un client

Un client par API conserve l’URL de base et tout ce qui s’applique à l’ensemble de ses requêtes :
l’authentificateur, le circuit breaker, le logger, le cache et la politique de nouvelles tentatives.

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

### Gérer les échecs

Chaque échec est un `NetworkError` ; un `catch` peut donc distinguer un appareil hors connexion d’une
ressource introuvable.

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

### Mettre les réponses en cache

Lorsque la configuration contient un cache, chaque endpoint choisit sa `CachePolicy`. La réponse
indique d’où elle provient.

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### Envoyer des fichiers avec suivi de la progression

`upload` envoie le corps de l’endpoint, ici un formulaire multipart, et indique la quantité déjà
envoyée. Les noms de champs et de fichiers sont échappés : ils ne peuvent donc pas ajouter d’en-têtes
de leur cru.

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

### Recevoir des server-sent events en continu

`events(_:)` produit chaque événement dès qu’il arrive et se reconnecte avec `Last-Event-ID` lorsque la
connexion est coupée.

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

### Exécuter des opérations GraphQL

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

### Tester votre couche API

`MockTransport` joue des réponses scénarisées ; celle-ci échoue une fois avec un 503, puis réussit :
la nouvelle tentative du client fait donc partie du test.

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## App d’exemple

[`Examples/NetworkPlayground`](Examples/) est une app iOS et macOS qui envoie de vraies requêtes via
`NetworkClient` à un faux backend exécuté dans l’app elle-même ; chaque écran fonctionne donc hors
connexion. De gauche à droite : un serveur qui échoue deux fois avant de répondre, quatre requêtes
qui partagent un seul renouvellement de token, un flux de prix en server-sent events, et une
connexion dont le mot de passe, la clé d’API, le token et le cookie n’atteignent jamais le journal.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="Écran des nouvelles tentatives : deux réponses 503, des attentes de 500 et 1000 ms, puis 200 OK au bout de 3 tentatives"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="Écran de renouvellement du token : quatre requêtes ayant reçu un 200 après 2 tentatives chacune, avec un seul appel de renouvellement"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="Écran des server-sent events : huit mises à jour de prix et le statut « The server ended the stream after 8 events »"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="Écran des journaux masqués : des lignes de journal et une commande curl où le mot de passe, la clé d’API, le token et le cookie apparaissent comme redacted"></picture>
</p>

Les captures d’écran sont prises dans l’app en cours d’exécution par
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh).

## Documentation

La [documentation DocC](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)
couvre chaque type public, avec ces articles :

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## Prérequis

| Plateforme | Version minimale |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

Swift 6.2 ou version ultérieure (Xcode 26 ou version ultérieure). Le paquet se compile en mode de
langage Swift 6. Sur watchOS, le système n’autorise les connexions WebSocket que pour les apps
disposant d’une session audio active.

## Contribuer

Les rapports de bogues et les pull requests sont les bienvenus ; [CONTRIBUTING.md](CONTRIBUTING.md)
explique comment compiler, tester et régénérer les captures d’écran. Pour signaler une faille de
sécurité en privé, consultez [SECURITY.md](SECURITY.md).

## Licence

MIT. Voir [LICENSE](LICENSE).
