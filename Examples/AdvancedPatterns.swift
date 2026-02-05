// AdvancedPatterns.swift
// iOS-Networking-Architecture-Pro
//
// Advanced usage patterns for production applications.

import Foundation
import NetworkingArchitecture
import NetworkingREST
import NetworkingGraphQL
import NetworkingWebSocket

// MARK: - Type-Safe Endpoints

/// User API endpoints
enum UserAPI {
    struct GetUser: Endpoint {
        let id: Int
        
        var baseURL: URL { URL(string: "https://api.example.com")! }
        var path: String { "/users/\(id)" }
        var method: HTTPMethod { .get }
        var cachePolicy: CachePolicy { .shortLived }
        var requiresAuthentication: Bool { true }
    }
    
    struct ListUsers: Endpoint {
        let page: Int
        let limit: Int
        
        var baseURL: URL { URL(string: "https://api.example.com")! }
        var path: String { "/users" }
        var method: HTTPMethod { .get }
        var queryParameters: [String: Any]? {
            ["page": page, "limit": limit]
        }
    }
    
    struct CreateUser: Endpoint {
        let user: CreateUserDTO
        
        var baseURL: URL { URL(string: "https://api.example.com")! }
        var path: String { "/users" }
        var method: HTTPMethod { .post }
        var body: RequestBody? { .json(user) }
        var requiresAuthentication: Bool { true }
    }
    
    struct UpdateUser: Endpoint {
        let id: Int
        let updates: UpdateUserDTO
        
        var baseURL: URL { URL(string: "https://api.example.com")! }
        var path: String { "/users/\(id)" }
        var method: HTTPMethod { .patch }
        var body: RequestBody? { .json(updates) }
        var requiresAuthentication: Bool { true }
    }
    
    struct DeleteUser: Endpoint {
        let id: Int
        
        var baseURL: URL { URL(string: "https://api.example.com")! }
        var path: String { "/users/\(id)" }
        var method: HTTPMethod { .delete }
        var requiresAuthentication: Bool { true }
    }
}

// MARK: - DTOs

struct CreateUserDTO: Codable, Sendable {
    let name: String
    let email: String
    let role: String
}

struct UpdateUserDTO: Codable, Sendable {
    let name: String?
    let email: String?
}

struct UserDTO: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String
    let createdAt: Date
}

// MARK: - Repository Example

actor UserRepository {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func getUser(id: Int) async throws -> UserDTO {
        let request = Request<UserDTO>(endpoint: UserAPI.GetUser(id: id))
        return try await client.execute(request).data
    }
    
    func listUsers(page: Int = 1, limit: Int = 20) async throws -> [UserDTO] {
        let request = Request<[UserDTO]>(endpoint: UserAPI.ListUsers(page: page, limit: limit))
        return try await client.execute(request).data
    }
    
    func createUser(_ dto: CreateUserDTO) async throws -> UserDTO {
        let request = Request<UserDTO>(endpoint: UserAPI.CreateUser(user: dto))
        return try await client.execute(request).data
    }
    
    func updateUser(id: Int, updates: UpdateUserDTO) async throws -> UserDTO {
        let request = Request<UserDTO>(endpoint: UserAPI.UpdateUser(id: id, updates: updates))
        return try await client.execute(request).data
    }
    
    func deleteUser(id: Int) async throws {
        let request = Request<EmptyResponse>(endpoint: UserAPI.DeleteUser(id: id))
        _ = try await client.execute(request)
    }
}

// MARK: - Service Layer Example

actor UserService {
    private let repository: UserRepository
    private let cache: InMemoryCache
    
    init(repository: UserRepository) {
        self.repository = repository
        self.cache = InMemoryCache(maxSize: 5 * 1024 * 1024)
    }
    
    func getUser(id: Int, forceRefresh: Bool = false) async throws -> UserDTO {
        let cacheKey = CacheKey(url: URL(string: "user://\(id)")!)
        
        // Check cache
        if !forceRefresh, let cached = try await cache.get(cacheKey) {
            return try JSONDecoder().decode(UserDTO.self, from: cached)
        }
        
        // Fetch from network
        let user = try await repository.getUser(id: id)
        
        // Cache result
        let data = try JSONEncoder().encode(user)
        try await cache.set(data, for: cacheKey, ttl: 300) // 5 min TTL
        
        return user
    }
    
    func createUser(name: String, email: String, role: String = "user") async throws -> UserDTO {
        let dto = CreateUserDTO(name: name, email: email, role: role)
        return try await repository.createUser(dto)
    }
}

// MARK: - Interceptor Chain Example

struct AppInterceptorChain {
    static func build(
        apiVersion: String,
        appVersion: String,
        deviceId: String
    ) -> [any Interceptor] {
        [
            // Add common headers
            HeaderInterceptor(headers: [
                "X-API-Version": apiVersion,
                "X-App-Version": appVersion,
                "X-Device-ID": deviceId,
                "Accept-Language": Locale.current.language.languageCode?.identifier ?? "en"
            ]),
            
            // Add request ID for tracing
            RequestIdInterceptor(),
            
            // Enable compression
            CompressionInterceptor(),
            
            // Logging (disable body in production)
            LoggingInterceptor(
                logLevel: .info,
                logBody: false,
                logHeaders: false
            )
        ]
    }
}

// MARK: - OAuth2 Flow Example

actor AuthManager {
    private var oauth: OAuth2Authenticator?
    
    func configure(
        clientId: String,
        authorizeURL: URL,
        tokenURL: URL,
        redirectURL: URL
    ) {
        oauth = OAuth2Authenticator(configuration: .init(
            clientId: clientId,
            authorizeURL: authorizeURL,
            tokenURL: tokenURL,
            redirectURL: redirectURL,
            scope: "read write"
        ))
    }
    
    func getAuthorizationURL() async -> URL? {
        await oauth?.authorizationURL(state: UUID().uuidString)
    }
    
    func handleCallback(code: String) async throws {
        // Exchange code for tokens
        // oauth?.exchangeCodeForTokens(code: code)
    }
    
    var isAuthenticated: Bool {
        get async {
            await oauth?.isValid ?? false
        }
    }
    
    func logout() async {
        await oauth?.logout()
    }
}

// MARK: - GraphQL Usage Example

struct GetUserQuery: GraphQLQuery {
    typealias Response = UserQueryResponse
    
    let userId: Int
    
    var queryString: String {
        """
        query GetUser($id: ID!) {
            user(id: $id) {
                id
                name
                email
                posts {
                    id
                    title
                }
            }
        }
        """
    }
    
    var variables: [String: Any]? {
        ["id": userId]
    }
    
    var operationName: String? { "GetUser" }
}

struct UserQueryResponse: Decodable {
    let user: GraphQLUser
}

struct GraphQLUser: Decodable {
    let id: String
    let name: String
    let email: String
    let posts: [GraphQLPost]
}

struct GraphQLPost: Decodable {
    let id: String
    let title: String
}

// MARK: - WebSocket Chat Example

actor ChatManager {
    private var client: WebSocketClient?
    private var messageHandlerId: UUID?
    
    func connect(to url: URL) async throws {
        client = WebSocketClient(
            url: url,
            configuration: .init(
                pingInterval: 30,
                autoReconnect: true,
                maxReconnectAttempts: 5
            )
        )
        
        try await client?.connect()
        
        // Handle incoming messages
        messageHandlerId = await client?.onMessage { [weak self] message in
            Task {
                await self?.handleMessage(message)
            }
        }
    }
    
    func send(_ text: String) async throws {
        try await client?.send(text)
    }
    
    func sendTyping() async throws {
        let typing = ChatEvent(type: "typing", data: nil)
        try await client?.send(typing)
    }
    
    func disconnect() async {
        if let id = messageHandlerId {
            await client?.removeMessageHandler(id: id)
        }
        client?.disconnect()
    }
    
    private func handleMessage(_ message: WebSocketMessage) {
        switch message {
        case .text(let text):
            print("Received: \(text)")
        case .data(let data):
            print("Received \(data.count) bytes")
        }
    }
}

struct ChatEvent: Codable {
    let type: String
    let data: String?
}
