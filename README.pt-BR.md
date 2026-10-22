<!-- i18n-source: README.md@77b23d7d87811b8f5b9b998152b5d0904585341a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/banner-pt-BR-light.svg" alt="Networking Architecture: Endpoints tipados, novas tentativas, renovação de token, cache e streaming sobre URLSession, sem dependências."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-version-light.svg" alt="Versão mais recente: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Networking-Architecture-Pro/master/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

Uma camada de rede para apps no iOS 16+, macOS 13+, tvOS 16+, watchOS 9+ e visionOS 1+, construída sobre o `URLSession` e sem dependências. Você descreve cada chamada da sua API uma única vez como um `Endpoint` tipado e a envia com um `NetworkClient`; novas tentativas, renovação de token, cache, logs e streaming são configurações desse cliente, em vez de código que você escreve em volta de cada requisição.

## Destaques

- **Endpoints tipados** — `Endpoint<User>.get("users/42")` decodifica o JSON em um `User`;
  `Endpoint<Data>` devolve o corpo como está e `Endpoint<Void>` o ignora. Suporta corpos JSON,
  de formulário e multipart, e `PathSegment` para dados do usuário nos caminhos.
- **Falhas tratadas em um só lugar** — uma `RetryPolicy` com espera exponencial
  (exponential backoff), jitter e `Retry-After`, um `CircuitBreaker`, alternativas vindas do cache
  quando não há conexão, downloads que continuam de onde a conexão caiu e um único tipo
  `NetworkError` que distingue um dispositivo sem conexão de um 404 ou de um modelo que não
  corresponde mais ao JSON.
- **Renovação de token bem feita** — o `BearerTokenAuthenticator` renova o token uma única vez para
  todas as requisições que receberam um 401, tenta cada uma delas de novo uma vez e só envia o
  token para os seus hosts.
- **Streaming** — server-sent events interpretados pelas regras do padrão HTML e um WebSocket que
  se reconecta com espera progressiva e se mantém ativo com pings.
- **Seguro por padrão** — public key pinning, redirecionamentos para outra origem
  devolvidos em vez de seguidos, logs e saída do `curl` que mostram só o que o redactor entende, e limites para
  o tamanho das respostas, as mensagens em buffer e os tempos de espera.
- **Fácil de testar** — o `MockTransport` responde às requisições com respostas prontas; os 936
  testes de Swift Testing do próprio pacote rodam no macOS e 931 deles também em um simulador de
  iPhone, incluindo testes contra um servidor local HTTP, TLS e WebSocket.

### O que está incluído

| Área | API |
| --- | --- |
| Requisições | `NetworkClient`, `Endpoint`, `RequestBody` (`json`, `form`, `multipart`), `PathSegment`, `HTTPHeaders` |
| Respostas | `HTTPResponse`, `NetworkError`, `upload(_:file:progress:)`, `download(_:to:resumingFrom:progress:)` |
| Resiliência | `RetryPolicy`, `CircuitBreaker`, `NetworkMonitor` |
| Autenticação | `BearerTokenAuthenticator`, `BearerToken`, `RequestInterceptor` |
| Cache | `CachePolicy` (`cacheFirst`, `networkFirst`, `revalidate`), `MemoryResponseCache`, `DiskResponseCache`, `HybridResponseCache` |
| Streaming | `events(_:options:)`, `ServerSentEventParser`, `WebSocketConnection` |
| GraphQL | `GraphQLOperation`, `graphQL(_:path:)`, `GraphQLResponse` |
| Segurança | `PublicKeyPinning`, `RedirectPolicy`, `Redactor` |
| Observabilidade | `NetworkLogger`, `NetworkEventMonitor`, `URLRequest.curlCommand()` |
| Testes | `MockTransport`, `MockResponse` (na biblioteca `NetworkingArchitectureTesting`) |

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Cole-a no campo de busca no canto superior direito da janela. Deixe **Dependency Rule** em
**Up to Next Major Version** a partir de `2.0.0` e clique em **Add Package**. Na janela seguinte,
escolha o target do seu app ao lado de **NetworkingArchitecture** e clique em **Add Package** de novo.

**2. Importe o módulo**

```swift
import NetworkingArchitecture
```

**3. Envie uma requisição**

Descreva a resposta como um tipo `Decodable` e envie um endpoint. Este código carrega uma postagem do
JSONPlaceholder, uma API de teste gratuita:

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

Mostre `FirstPostView()` na sua `ContentView` e execute o app: o título da postagem 1 aparece assim
que a resposta é decodificada, sem nenhum código seu para URL ou JSON.

## Instalação

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git
```

Ou adicione-o às `dependencies` do seu `Package.swift`:

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

Use a versão 2.0.0 ou posterior: a versão 1.0.0 não compilava, e a 2.0.0 substitui a API dela.

## Uso

Todos os exemplos abaixo foram copiados de
[`ReadmeSamples.swift`](Examples/NetworkPlayground/NetworkPlayground/ReadmeSamples.swift), que o app de
exemplo compila e que o target de testes compila e executa com respostas prontas.

### Descreva sua API uma vez

Cada endpoint conhece seu método, seu caminho, seu corpo e o tipo da resposta. Um valor vindo do usuário
passa pelo `PathSegment`, de modo que um nome como `ada?admin=1` continua sendo um único segmento do
caminho.

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

### Configure um cliente

Um cliente por API guarda a URL base e tudo que vale para todas as suas requisições: o autenticador, o
circuit breaker, o logger, o cache e a política de novas tentativas.

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

### Trate as falhas

Toda falha é um `NetworkError`, então um `catch` consegue distinguir um dispositivo sem conexão de um
recurso inexistente.

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

### Mantenha segredos fora dos logs

`NetworkLogger` e `URLRequest.curlCommand()` passam cada requisição e cada resposta por um
`Redactor`, que oculta tudo o que não entende por completo.

- **Registrado:** método, status, duração e tamanho, nomes dos cabeçalhos, os valores dos
  cabeçalhos da lista permitida (por padrão `Accept`, `Accept-Encoding`, `Accept-Language`, `Cache-Control`, `Content-Encoding`,
  `Content-Length`, `Content-Type`, `ETag`, `User-Agent`),
  o esquema, o host, o caminho e os nomes dos parâmetros de consulta da URL, e corpos
  JSON, de formulário, multipart e `text/plain` depois de ocultar o que é sensível.
- **Nunca registrado:** informações de usuário e fragmentos de URLs, valores de consulta que não
  estão na lista permitida (nenhum, por padrão), os valores de todos os outros cabeçalhos
  (`Authorization`, `Cookie`, `X-API-Key` e nomes com `token`, `key` ou `auth`, mesmo quando
  permitidos), valores inteiros sob nomes secretos como `password`, `token` ou `api_key`,
  segmentos de caminho que parecem identificadores (escritos como `:id`), um host de URL que
  nomeia um segredo junto com sua porta, seu caminho e sua query (`myapp://pin/4831` é
  registrado como `myapp://[REDACTED]`), partes de arquivo de corpos multipart e descrições de
  erro.
- **Chaves que não são ASCII simples** (`pаssword` com um `а` cirílico, `pass\u200Bword`,
  `şifre`) têm seus valores ocultados por padrão. O mesmo vale para os valores ao lado de um
  campo que contém um nome assim: `{"name":"Ayşe","id":42}` é registrado como `{"name":"Ayşe","id":"[REDACTED]"}`.
- **Rótulos escritos como valores** ocultam o valor ao lado, também quando são frases:
  `{"question":"What's your PIN?","answer":"1234"}` e
  `{"title":"PIN (4 digits)","value":"1234"}` são registrados com a resposta e o valor ocultos.
- **Valores de outros campos** e texto livre são examinados em busca de JWTs, credenciais
  `Bearer`, strings hexadecimais ou Base64 de 32 caracteres ou mais, números de cartão, IBANs e
  endereços de e-mail. Um número JSON é lido como o decimal que representa:
  `{"amount":4.111111111111111E15}`, como Jackson e Gson escrevem um `double`, é registrado como
  `{"amount":"[REDACTED]"}`.
- **Corpos que não podem ser analisados** (XML, HTML, tipo de conteúdo ausente ou desconhecido,
  JSON malformado, mais de 256 KiB) ficam de fora com uma nota como
  `[body omitted: 512 bytes, application/xml]`.
- **Texto livre** (valores de cabeçalhos mantidos, corpos `text/plain`, strings em JSON e
  formulários) é ocultado do primeiro gatilho até o fim: uma chave que não está em
  `allowedTextKeys`, um nome secreto, um escape, marcação ou uma aspa que não fecha.
  `login password=hunter2 status=200` é registrado como `login password=[REDACTED]`.

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

Ocultar dados é uma rede de segurança, não uma garantia. Foi feito para segredos registrados por
acidente: a entrada estruturada é analisada, e tudo o que o analisador não entende por completo é
ocultado; o texto livre é tratado da melhor forma possível. Um nome secreto escrito sem `=` ou
`:` e disfarçado com duas ou mais letras parecidas (`pɑsswoʀd hunter2`), um segredo sem rótulo
(`login -p hunter2`), um segredo curto em um segmento de caminho (`/reset/abc123`), um número
de cartão escrito com expoente em texto ou em uma string JSON (`"4111111111111111e0"`) e o
valor ao lado de uma frase que traz o próprio valor depois de uma palavra secreta
(`{"error":"Error: PIN expired","answer":"1234"}`) não têm garantia de ser encontrados. Mantenha segredos fora das requisições que você registra desde o
início. Cada segredo que versões de desenvolvimento anteriores do redactor deixaram passar está
guardado como teste; o artigo
[Redacting Sensitive Data](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/redactingsensitivedata)
lista todas as regras.

Uma regra lê letras disfarçadas: uma única letra, marca ou número sem forma ASCII dentro de uma
palavra ASCII conta como qualquer letra ou como nenhuma, então `tͦken hunter2`,
`passw〇rd hunter2` e `piꞏn 1234` são encontrados. Nenhuma tabela de letras parecidas é mantida
para perseguir o resto, porque nenhuma fica completa. Prefira logs estruturados: campos
separados, e segredos fora das mensagens.

Mais dois limites fazem parte desse modelo. **Limite de custo:** todos os documentos aninhados
em uma entrada (JSON dentro de uma string, uma URL em um texto) leem juntos no máximo quatro vezes
o tamanho da entrada; passado esse orçamento, a string que contém o próximo documento é ocultada
inteira. **Layouts de várias linhas** em texto livre não precisam de nada especial: um `<key>` de
property list em sua própria linha, um JSON espalhado por várias linhas e um corpo multipart
escrito como texto são ocultados do primeiro gatilho até o fim do texto, então o valor fica
oculto onde quer que esteja.

### Guarde respostas em cache

Com um cache na configuração, cada endpoint escolhe sua `CachePolicy`. A resposta informa de onde veio.

```swift
func cachedUsers(with client: NetworkClient) async throws -> HTTPResponse<[User]> {
    let endpoint = API.users(page: 1).with(\.cachePolicy, .cacheFirst(maxAge: .seconds(300)))
    let response = try await client.response(for: endpoint)
    print(response.source) // .network the first time, .cache for the next five minutes
    return response
}
```

### Envie arquivos com progresso

O `upload` envia o corpo do endpoint, aqui um formulário multipart, e informa quanto já foi enviado. Os
nomes de campos e de arquivos são escapados, então não conseguem acrescentar cabeçalhos próprios.

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

### Receba server-sent events em streaming

O `events(_:)` entrega cada evento assim que ele chega e se reconecta com o `Last-Event-ID` quando a
conexão cai.

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

### Execute operações GraphQL

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

### Teste sua camada de API

O `MockTransport` reproduz respostas roteirizadas; esta falha uma vez com 503 e depois funciona, de modo
que a nova tentativa do cliente faz parte do teste.

```swift
func makeTestClient() throws -> (NetworkClient, MockTransport) {
    let transport = MockTransport()
    transport.register(.get, "users", .status(503), try .json([User(id: 1, name: "Ada")]))
    let client = NetworkClient(baseURL: URL(string: "https://api.example.com/v1")!, transport: transport)
    return (client, transport)
}
```

## App de exemplo

O [`Examples/NetworkPlayground`](Examples/) é um app para iOS e macOS que envia requisições reais pelo
`NetworkClient` para um backend de mentira que roda dentro do próprio app, então todas as telas funcionam
sem conexão. Da esquerda para a direita: um servidor que falha duas vezes antes de responder, quatro
requisições que compartilham uma única renovação de token, um feed de preços com server-sent events e um
login cuja senha, chave de API, token e cookie nunca chegam ao log.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-retries-dark.png"><img src="docs/images/example-retries-light.png" width="200" alt="Tela de novas tentativas: duas respostas 503, esperas de 500 e 1000 ms e depois 200 OK na 3ª tentativa"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-auth-dark.png"><img src="docs/images/example-auth-light.png" width="200" alt="Tela de renovação de token: quatro requisições respondidas com 200 após 2 tentativas cada, com uma única chamada de renovação"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-prices-dark.png"><img src="docs/images/example-prices-light.png" width="200" alt="Tela de server-sent events: oito atualizações de preço e o status 'The server ended the stream after 8 events'"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-logs-dark.png"><img src="docs/images/example-logs-light.png" width="200" alt="Tela de logs ocultados: linhas de log e um comando curl em que a senha, a chave de API, o token e o cookie aparecem como redacted"></picture>
</p>

As capturas de tela são feitas a partir do app em execução pelo
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh).

## Documentação

A [documentação do DocC](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/)
cobre todos os tipos públicos, com estes artigos:

- [Getting Started](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/gettingstarted)
- [Handling Failures](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/handlingfailures)
- [Authenticating Requests](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/authenticatingrequests)
- [Streaming Events](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/streamingevents)
- [Securing Traffic](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/securingtraffic)
- [Redacting Sensitive Data](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/redactingsensitivedata)
- [Testing Your API Layer](https://muhittincamdali.github.io/iOS-Networking-Architecture-Pro/documentation/networkingarchitecture/testingyourapilayer)

## Requisitos

| Plataforma | Versão mínima |
| --- | --- |
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| visionOS | 1.0 |

Swift 6.2 ou posterior (Xcode 26 ou posterior). O pacote é compilado no modo de linguagem Swift 6. No
watchOS, o sistema só permite conexões WebSocket para apps com uma sessão de áudio ativa.

## Como contribuir

Relatos de bugs e pull requests são bem-vindos; o [CONTRIBUTING.md](CONTRIBUTING.md) explica como
compilar, testar e gerar as capturas de tela de novo. Para relatar uma falha de segurança de forma
privada, veja o [SECURITY.md](SECURITY.md).

## Licença

MIT. Veja [LICENSE](LICENSE).
