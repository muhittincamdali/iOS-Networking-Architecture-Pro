// Authenticator.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Protocol for authentication handlers
public protocol Authenticator: Sendable {
    /// Authenticate a request
    func authenticate(request: URLRequest) async throws -> URLRequest
    
    /// Refresh authentication (e.g., token refresh)
    func refresh() async throws
    
    /// Check if authentication is valid
    var isValid: Bool { get async }
    
    /// Clear authentication data
    func logout() async
}

// MARK: - Bearer Token Authenticator

/// Bearer token authentication
public actor BearerTokenAuthenticator: Authenticator {
    private var token: String?
    private var refreshToken: String?
    private var tokenExpiration: Date?
    private let refreshHandler: (@Sendable () async throws -> TokenResponse)?
    
    public init(
        token: String? = nil,
        refreshToken: String? = nil,
        tokenExpiration: Date? = nil,
        refreshHandler: (@Sendable () async throws -> TokenResponse)? = nil
    ) {
        self.token = token
        self.refreshToken = refreshToken
        self.tokenExpiration = tokenExpiration
        self.refreshHandler = refreshHandler
    }
    
    public func authenticate(request: URLRequest) async throws -> URLRequest {
        // Check if token needs refresh
        if let expiration = tokenExpiration, expiration < Date() {
            try await refresh()
        }
        
        guard let token = token else {
            throw NetworkError.authenticationRequired
        }
        
        var mutableRequest = request
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
    
    public func refresh() async throws {
        guard let handler = refreshHandler else {
            throw NetworkError.tokenRefreshFailed(reason: "No refresh handler configured")
        }
        
        let response = try await handler()
        self.token = response.accessToken
        self.refreshToken = response.refreshToken ?? self.refreshToken
        self.tokenExpiration = response.expiresAt
    }
    
    public var isValid: Bool {
        guard token != nil else { return false }
        if let expiration = tokenExpiration {
            return expiration > Date()
        }
        return true
    }
    
    public func logout() async {
        token = nil
        refreshToken = nil
        tokenExpiration = nil
    }
    
    /// Update tokens
    public func setTokens(accessToken: String, refreshToken: String? = nil, expiresAt: Date? = nil) {
        self.token = accessToken
        self.refreshToken = refreshToken ?? self.refreshToken
        self.tokenExpiration = expiresAt
    }
}

// MARK: - Token Response

/// Response from token refresh
public struct TokenResponse: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String?
    public let expiresIn: Int?
    public let tokenType: String?
    
    public var expiresAt: Date? {
        expiresIn.map { Date().addingTimeInterval(TimeInterval($0)) }
    }
    
    public init(
        accessToken: String,
        refreshToken: String? = nil,
        expiresIn: Int? = nil,
        tokenType: String? = "Bearer"
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

// MARK: - API Key Authenticator

/// API key authentication
public struct APIKeyAuthenticator: Authenticator {
    private let apiKey: String
    private let headerName: String
    private let prefix: String?
    
    public init(apiKey: String, headerName: String = "X-API-Key", prefix: String? = nil) {
        self.apiKey = apiKey
        self.headerName = headerName
        self.prefix = prefix
    }
    
    public func authenticate(request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request
        let value = prefix.map { "\($0) \(apiKey)" } ?? apiKey
        mutableRequest.setValue(value, forHTTPHeaderField: headerName)
        return mutableRequest
    }
    
    public func refresh() async throws {
        // API keys typically don't refresh
    }
    
    public var isValid: Bool {
        !apiKey.isEmpty
    }
    
    public func logout() async {
        // API keys are typically static
    }
}

// MARK: - Basic Auth Authenticator

/// HTTP Basic authentication
public struct BasicAuthAuthenticator: Authenticator {
    private let username: String
    private let password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    public func authenticate(request: URLRequest) async throws -> URLRequest {
        let credentials = "\(username):\(password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            throw NetworkError.encodingFailed(reason: "Failed to encode credentials")
        }
        
        let base64Credentials = credentialsData.base64EncodedString()
        
        var mutableRequest = request
        mutableRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
    
    public func refresh() async throws {
        // Basic auth doesn't refresh
    }
    
    public var isValid: Bool {
        !username.isEmpty
    }
    
    public func logout() async {
        // Basic auth is stateless
    }
}

// MARK: - OAuth2 Authenticator

/// OAuth 2.0 authentication
public actor OAuth2Authenticator: Authenticator {
    public struct Configuration: Sendable {
        public let clientId: String
        public let clientSecret: String?
        public let authorizeURL: URL
        public let tokenURL: URL
        public let redirectURL: URL
        public let scope: String?
        
        public init(
            clientId: String,
            clientSecret: String? = nil,
            authorizeURL: URL,
            tokenURL: URL,
            redirectURL: URL,
            scope: String? = nil
        ) {
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.authorizeURL = authorizeURL
            self.tokenURL = tokenURL
            self.redirectURL = redirectURL
            self.scope = scope
        }
    }
    
    private let config: Configuration
    private var accessToken: String?
    private var refreshToken: String?
    private var tokenExpiration: Date?
    
    public init(configuration: Configuration) {
        self.config = configuration
    }
    
    public func authenticate(request: URLRequest) async throws -> URLRequest {
        if let expiration = tokenExpiration, expiration < Date() {
            try await refresh()
        }
        
        guard let token = accessToken else {
            throw NetworkError.authenticationRequired
        }
        
        var mutableRequest = request
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
    
    public func refresh() async throws {
        guard let refreshToken = refreshToken else {
            throw NetworkError.tokenRefreshFailed(reason: "No refresh token available")
        }
        
        var request = URLRequest(url: config.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var body = "grant_type=refresh_token&refresh_token=\(refreshToken)&client_id=\(config.clientId)"
        if let secret = config.clientSecret {
            body += "&client_secret=\(secret)"
        }
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.tokenRefreshFailed(reason: "Token refresh request failed")
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.accessToken = tokenResponse.accessToken
        self.refreshToken = tokenResponse.refreshToken ?? self.refreshToken
        self.tokenExpiration = tokenResponse.expiresAt
    }
    
    public var isValid: Bool {
        guard accessToken != nil else { return false }
        if let expiration = tokenExpiration {
            return expiration > Date()
        }
        return true
    }
    
    public func logout() async {
        accessToken = nil
        refreshToken = nil
        tokenExpiration = nil
    }
    
    /// Set tokens from OAuth callback
    public func setTokens(from response: TokenResponse) {
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
        self.tokenExpiration = response.expiresAt
    }
    
    /// Generate authorization URL
    public func authorizationURL(state: String? = nil, codeChallenge: String? = nil) -> URL {
        var components = URLComponents(url: config.authorizeURL, resolvingAgainstBaseURL: true)!
        var queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "redirect_uri", value: config.redirectURL.absoluteString)
        ]
        
        if let scope = config.scope {
            queryItems.append(URLQueryItem(name: "scope", value: scope))
        }
        
        if let state = state {
            queryItems.append(URLQueryItem(name: "state", value: state))
        }
        
        if let challenge = codeChallenge {
            queryItems.append(URLQueryItem(name: "code_challenge", value: challenge))
            queryItems.append(URLQueryItem(name: "code_challenge_method", value: "S256"))
        }
        
        components.queryItems = queryItems
        return components.url!
    }
}

// MARK: - Composite Authenticator

/// Combines multiple authentication methods
public struct CompositeAuthenticator: Authenticator {
    private let authenticators: [any Authenticator]
    
    public init(_ authenticators: any Authenticator...) {
        self.authenticators = authenticators
    }
    
    public func authenticate(request: URLRequest) async throws -> URLRequest {
        var currentRequest = request
        for authenticator in authenticators {
            currentRequest = try await authenticator.authenticate(request: currentRequest)
        }
        return currentRequest
    }
    
    public func refresh() async throws {
        for authenticator in authenticators {
            try await authenticator.refresh()
        }
    }
    
    public var isValid: Bool {
        get async {
            for authenticator in authenticators {
                if await !authenticator.isValid {
                    return false
                }
            }
            return true
        }
    }
    
    public func logout() async {
        for authenticator in authenticators {
            await authenticator.logout()
        }
    }
}
