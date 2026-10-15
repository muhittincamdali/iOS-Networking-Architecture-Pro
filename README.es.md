<!-- i18n-source: README.md@c31287351d0f60344dae9e674a055185223d09f4 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-es-light.svg" alt="Networking Architecture: Endpoints tipados, reintentos, renovación de tokens, caché y streaming sobre URLSession, sin dependencias."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="Última versión: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

Una capa de red para apps en iOS 16+, macOS 13+, tvOS 16+, watchOS 9+ y visionOS 1+, construida sobre `URLSession` y sin dependencias. Describes cada llamada de tu API una sola vez como un `Endpoint` tipado y la envías con un `NetworkClient`; los reintentos, la renovación de tokens, el caché, el registro y el streaming son ajustes de ese cliente, en lugar de código que escribes alrededor de cada petición.

## Lo más destacado

- **Endpoints tipados** — `Endpoint<User>.get("users/42")` decodifica el JSON en un `User`;
  `Endpoint<Data>` devuelve el cuerpo tal cual y `Endpoint<Void>` lo ignora. Admite cuerpos
  JSON, de formulario y multipart, y `PathSegment` para los datos del usuario en las rutas.
- **Los fallos se gestionan una sola vez** — una `RetryPolicy` con retroceso exponencial
  (exponential backoff), jitter y `Retry-After`, un `CircuitBreaker`, alternativas desde el caché
  cuando no hay conexión, descargas que se reanudan donde se cortó la conexión y un único tipo
  `NetworkError` que distingue un dispositivo sin conexión de un 404 o de un modelo que ya no
  coincide con el JSON.
- **Renovación de tokens bien hecha** — `BearerTokenAuthenticator` renueva el token una sola vez
  para todas las peticiones que recibieron un 401, reintenta cada una de ellas una vez y solo
  envía el token a tus hosts.
- **Streaming** — server-sent events analizados con las reglas del estándar HTML y un WebSocket
  que se reconecta con retroceso y se mantiene activo con pings.
- **Seguro por defecto** — public key pinning, cabeceras de credenciales eliminadas en las
  redirecciones a otro origen, secretos ocultos en los registros y en la salida de `curl`, y
  límites para el tamaño de las respuestas, los mensajes en búfer y los tiempos de espera.
- **Fácil de probar** — `MockTransport` responde a las peticiones con respuestas predefinidas; las
  215 pruebas de Swift Testing del propio paquete se ejecutan en macOS y 214 de ellas también en
  un simulador de iPhone, incluidas pruebas contra un servidor local HTTP, TLS y WebSocket.

### Qué incluye

| Área | API |
| --- | --- |
| Peticiones | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| Respuestas | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| Resiliencia | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| Autenticación | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| Caché | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| Streaming | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| Seguridad | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| Observabilidad | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| Pruebas | `MockTransport`, `MockResponse` (en la biblioteca `NetworkingArchitectureTesting`) |

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Pégala en el campo de búsqueda de la esquina superior derecha de la ventana. Deja **Dependency Rule**
en **Up to Next Major Version** desde `2.0.0` y haz clic en **Add Package**. En la ventana siguiente,
elige el target de tu app junto a **NetworkingArchitecture** y haz clic de nuevo en **Add Package**.

**2. Importa el módulo**

```swift
import NetworkingArchitecture
```

**3. Envía una petición**

Describe la respuesta como un tipo `Decodable` y envía un endpoint. Este código carga una publicación
de JSONPlaceholder, una API de pruebas gratuita:

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

Muestra `FirstPostView()` en tu `ContentView` y ejecuta la app: el título de la publicación 1 aparece
cuando se decodifica la respuesta, sin que tengas que escribir código propio para la URL ni el JSON.

## Instalación

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

O añádelo a las `dependencies` de tu `Package.swift`:

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

Usa la versión 2.0.0 o posterior: la versión 1.0.0 no compilaba y la 2.0.0 sustituye su API.

## Uso

Todos los ejemplos siguientes están copiados de
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift), que la app
de ejemplo compila y que el target de pruebas compila y ejecuta con respuestas predefinidas.

### Describe tu API una sola vez

Cada endpoint conoce su método, su ruta, su cuerpo y el tipo de su respuesta. Un valor que proviene del
usuario pasa por `PathSegment`, de modo que un nombre como `ada?admin=1` sigue siendo un único segmento
de la ruta.

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

### Configura un cliente

Un cliente por API guarda la URL base y todo lo que se aplica a todas sus peticiones: el autenticador,
el circuit breaker, el registro, el caché y la política de reintentos.

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

### Gestiona los fallos

Todo fallo es un `NetworkError`, así que un `catch` puede distinguir un dispositivo sin conexión de un
recurso que no existe.

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

### Guarda las respuestas en caché

Si la configuración incluye un caché, cada endpoint elige su `CachePolicy`. La respuesta indica de dónde
procede.

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### Sube archivos con progreso

`upload` envía el cuerpo del endpoint, aquí un formulario multipart, e informa de cuánto se ha enviado.
Los nombres de campos y de archivos se escapan, por lo que no pueden añadir cabeceras propias.

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

### Recibe server-sent events en streaming

`events(_:)` entrega cada evento en cuanto llega y se reconecta con `Last-Event-ID` cuando se cae la
conexión.

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

### Ejecuta operaciones GraphQL

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

### Prueba tu capa de API

`MockTransport` reproduce respuestas programadas de antemano; este ejemplo falla una vez con un 503 y luego
funciona, de modo que el reintento del cliente forma parte de la prueba.

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## App de ejemplo

[`Examples/NetworkPlayground`](Examples/) es una app de iOS y macOS que envía peticiones reales a través
de `NetworkClient` a un backend simulado que se ejecuta dentro de la propia app, así que todas las
pantallas funcionan sin conexión. De izquierda a derecha: un servidor que falla dos veces antes de
responder, cuatro peticiones que comparten una misma renovación de token, un flujo de precios con
server-sent events y un inicio de sesión cuya contraseña, clave de API, token y cookie nunca llegan al
registro.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="Pantalla de reintentos: dos respuestas 503, esperas de 500 y 1000 ms y después 200 OK tras 3 intentos"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="Pantalla de renovación de token: cuatro peticiones respondidas con 200 tras 2 intentos cada una, con una sola llamada de renovación"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="Pantalla de server-sent events: ocho actualizaciones de precio y el estado 'The server ended the stream after 8 events'"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="Pantalla de registros ocultos: líneas de registro y un comando curl en el que la contraseña, la clave de API, el token y la cookie aparecen como redacted"></picture>
</p>

Las capturas de pantalla se toman de la app en ejecución con
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh).

## Documentación

La [documentación de DocC](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)
cubre todos los tipos públicos e incluye estos artículos:

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## Requisitos

| Plataforma | Versión mínima |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

Swift 6.2 o posterior (Xcode 26 o posterior). El paquete se compila en el modo de lenguaje Swift 6.
En watchOS, el sistema solo permite conexiones WebSocket a las apps con una sesión de audio activa.

## Contribuir

Los informes de errores y las pull requests son bienvenidos; [CONTRIBUTING.md](CONTRIBUTING.md) explica
cómo compilar, probar y regenerar las capturas de pantalla. Para informar de un problema de seguridad
de forma privada, consulta [SECURITY.md](SECURITY.md).

## Licencia

MIT. Consulta [LICENSE](LICENSE).
