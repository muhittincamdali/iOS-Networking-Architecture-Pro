# 🔐 Authentication Guide

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [⚡ Quick Start](#-quick-start)
- [🔧 Configuration](#-configuration)
- [🔑 OAuth 2.0](#-oauth-20)
- [🎫 JWT Authentication](#-jwt-authentication)
- [🛡️ Security Features](#-security-features)
- [📊 Error Handling](#-error-handling)
- [📱 Examples](#-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**Authentication Guide** provides comprehensive documentation for implementing authentication functionality in iOS applications using the iOS Networking Architecture Pro framework.

### 🎯 Key Features

- **OAuth 2.0**: Complete OAuth 2.0 implementation
- **JWT Support**: JWT token handling and validation
- **Custom Authentication**: Custom authentication schemes
- **Token Management**: Automatic token refresh and management
- **Session Management**: Secure session handling
- **Multi-Factor Auth**: Multi-factor authentication support
- **Biometric Auth**: Biometric authentication integration
- **Certificate Auth**: Certificate-based authentication

---

## ⚡ Quick Start

### Basic Authentication Setup

```swift
import NetworkingArchitecturePro

// Initialize authentication manager
let authManager = AuthenticationManager()

// Configure authentication
let authConfig = AuthenticationConfiguration()
authConfig.type = .oauth
authConfig.enableBiometricAuth = true
authConfig.enableMFA = false
authConfig.sessionTimeout = 3600.0
authConfig.autoRefreshTokens = true

// Setup authentication manager
authManager.configure(authConfig)

// Authenticate user
authManager.authenticate(username: "user@company.com", password: "password") { result in
    switch result {
    case .success(let authResult):
        print("✅ Authentication successful")
        print("Access token: \(authResult.accessToken)")
        print("Refresh token: \(authResult.refreshToken)")
        print("Expires in: \(authResult.expiresIn) seconds")
    case .failure(let error):
        print("❌ Authentication failed: \(error)")
    }
}
```

### Simple Authentication Usage

```swift
// OAuth authentication
let oauthManager = OAuthManager()

// Configure OAuth
let oauthConfig = OAuthConfiguration()
oauthConfig.clientId = "your_client_id"
oauthConfig.clientSecret = "your_client_secret"
oauthConfig.redirectURI = "com.company.app://oauth/callback"
oauthConfig.scope = "read write"
oauthConfig.authorizationURL = "https://auth.company.com/oauth/authorize"
oauthConfig.tokenURL = "https://auth.company.com/oauth/token"

oauthManager.configure(oauthConfig)

// Start OAuth flow
oauthManager.startAuthorization { result in
    switch result {
    case .success(let authResult):
        print("✅ OAuth authorization successful")
        print("Access token: \(authResult.accessToken)")
    case .failure(let error):
        print("❌ OAuth authorization failed: \(error)")
    }
}
```

---

## 🔧 Configuration

### Authentication Configuration

```swift
// Configure authentication settings
let authConfig = AuthenticationConfiguration()

// Basic settings
authConfig.type = .oauth
authConfig.enableBiometricAuth = true
authConfig.enableMFA = false
authConfig.sessionTimeout = 3600.0
authConfig.autoRefreshTokens = true

// Security settings
authConfig.enableSecureStorage = true
authConfig.enableTokenEncryption = true
authConfig.enableSessionValidation = true

// Apply configuration
authManager.configure(authConfig)
```

### Advanced Configuration

```swift
// Advanced authentication configuration
let advancedConfig = AuthenticationConfiguration()

// Authentication type
advancedConfig.type = .oauth

// OAuth configuration
let oauthConfig = OAuthConfiguration()
oauthConfig.clientId = "your_client_id"
oauthConfig.clientSecret = "your_client_secret"
oauthConfig.redirectURI = "com.company.app://oauth/callback"
oauthConfig.scope = "read write admin"
oauthConfig.authorizationURL = "https://auth.company.com/oauth/authorize"
oauthConfig.tokenURL = "https://auth.company.com/oauth/token"
oauthConfig.revokeURL = "https://auth.company.com/oauth/revoke"
advancedConfig.oauthConfig = oauthConfig

// JWT configuration
let jwtConfig = JWTConfiguration()
jwtConfig.secretKey = "your_jwt_secret"
jwtConfig.algorithm = .hs256
jwtConfig.expirationTime = 3600 // 1 hour
jwtConfig.enableRefresh = true
advancedConfig.jwtConfig = jwtConfig

// Security configuration
let securityConfig = SecurityConfiguration()
securityConfig.enableEncryption = true
securityConfig.enableCertificatePinning = true
securityConfig.enableSSLPinning = true
advancedConfig.securityConfig = securityConfig

// Session settings
advancedConfig.enableBiometricAuth = true
advancedConfig.enableMFA = true
advancedConfig.sessionTimeout = 7200.0 // 2 hours
advancedConfig.autoRefreshTokens = true
advancedConfig.refreshTokenThreshold = 300.0 // 5 minutes

authManager.configure(advancedConfig)
```

---

## 🔑 OAuth 2.0

### OAuth Configuration

```swift
// Configure OAuth 2.0
let oauthConfig = OAuthConfiguration()

// Client credentials
oauthConfig.clientId = "your_client_id"
oauthConfig.clientSecret = "your_client_secret"
oauthConfig.redirectURI = "com.company.app://oauth/callback"

// OAuth endpoints
oauthConfig.authorizationURL = "https://auth.company.com/oauth/authorize"
oauthConfig.tokenURL = "https://auth.company.com/oauth/token"
oauthConfig.revokeURL = "https://auth.company.com/oauth/revoke"
oauthConfig.introspectURL = "https://auth.company.com/oauth/introspect"

// OAuth settings
oauthConfig.scope = "read write admin"
oauthConfig.responseType = "code"
oauthConfig.grantType = "authorization_code"
oauthConfig.state = "random_state_string"

// Security settings
oauthConfig.enablePKCE = true
oauthConfig.codeVerifier = "random_code_verifier"
oauthConfig.codeChallenge = "code_challenge"
oauthConfig.codeChallengeMethod = "S256"

oauthManager.configure(oauthConfig)
```

### OAuth Flow

```swift
// Start OAuth authorization flow
oauthManager.startAuthorization { result in
    switch result {
    case .success(let authResult):
        print("✅ OAuth authorization successful")
        print("Access token: \(authResult.accessToken)")
        print("Refresh token: \(authResult.refreshToken)")
        print("Expires in: \(authResult.expiresIn) seconds")
        print("Token type: \(authResult.tokenType)")
        print("Scope: \(authResult.scope)")
        
    case .failure(let error):
        print("❌ OAuth authorization failed: \(error)")
    }
}

// Complete OAuth flow with authorization code
oauthManager.completeAuthorization(with: "authorization_code") { result in
    switch result {
    case .success(let tokenResult):
        print("✅ Token exchange successful")
        print("Access token: \(tokenResult.accessToken)")
        
    case .failure(let error):
        print("❌ Token exchange failed: \(error)")
    }
}

// Refresh access token
oauthManager.refreshToken(refreshToken) { result in
    switch result {
    case .success(let tokenResult):
        print("✅ Token refresh successful")
        print("New access token: \(tokenResult.accessToken)")
        print("New refresh token: \(tokenResult.refreshToken)")
        
    case .failure(let error):
        print("❌ Token refresh failed: \(error)")
    }
}

// Revoke access token
oauthManager.revokeToken(accessToken) { result in
    switch result {
    case .success:
        print("✅ Token revoked successfully")
        
    case .failure(let error):
        print("❌ Token revocation failed: \(error)")
    }
}
```

### OAuth Token Management

```swift
// Get current access token
if let accessToken = oauthManager.getAccessToken() {
    print("Current access token: \(accessToken)")
}

// Get current refresh token
if let refreshToken = oauthManager.getRefreshToken() {
    print("Current refresh token: \(refreshToken)")
}

// Check if token is expired
if oauthManager.isTokenExpired() {
    print("⚠️ Token is expired")
    // Refresh token
    oauthManager.refreshToken(refreshToken) { result in
        // Handle refresh result
    }
}

// Get token expiration date
if let expirationDate = oauthManager.getTokenExpiration() {
    print("Token expires at: \(expirationDate)")
}

// Logout user
oauthManager.logout()
```

---

## 🎫 JWT Authentication

### JWT Configuration

```swift
// Configure JWT authentication
let jwtConfig = JWTConfiguration()

// JWT settings
jwtConfig.secretKey = "your_jwt_secret"
jwtConfig.algorithm = .hs256
jwtConfig.expirationTime = 3600 // 1 hour
jwtConfig.enableRefresh = true
jwtConfig.refreshTokenExpiration = 86400 // 24 hours

// JWT claims
jwtConfig.defaultClaims = [
    "iss": "your_app_issuer",
    "aud": "your_app_audience",
    "iat": Date().timeIntervalSince1970
]

// Security settings
jwtConfig.enableSignatureValidation = true
jwtConfig.enableExpirationValidation = true
jwtConfig.enableIssuerValidation = true
jwtConfig.enableAudienceValidation = true

jwtManager.configure(jwtConfig)
```

### JWT Token Operations

```swift
// Create JWT token
let claims = JWTClaims(
    userId: "123",
    email: "user@company.com",
    role: "user",
    permissions: ["read", "write"]
)

jwtManager.createToken(claims: claims) { result in
    switch result {
    case .success(let token):
        print("✅ JWT token created")
        print("Token: \(token)")
        
    case .failure(let error):
        print("❌ JWT token creation failed: \(error)")
    }
}

// Validate JWT token
jwtManager.validateToken(token) { result in
    switch result {
    case .success(let claims):
        print("✅ JWT token valid")
        print("User ID: \(claims.userId)")
        print("Email: \(claims.email)")
        print("Role: \(claims.role)")
        print("Permissions: \(claims.permissions)")
        
    case .failure(let error):
        print("❌ JWT token validation failed: \(error)")
    }
}

// Decode JWT token
if let claims = jwtManager.decodeToken(token) {
    print("✅ JWT token decoded")
    print("User ID: \(claims.userId)")
    print("Email: \(claims.email)")
}

// Refresh JWT token
jwtManager.refreshToken(token) { result in
    switch result {
    case .success(let newToken):
        print("✅ JWT token refreshed")
        print("New token: \(newToken)")
        
    case .failure(let error):
        print("❌ JWT token refresh failed: \(error)")
    }
}
```

### JWT Claims Management

```swift
// Create custom JWT claims
let customClaims = JWTClaims(
    userId: "123",
    email: "user@company.com",
    role: "admin",
    permissions: ["read", "write", "admin"],
    customFields: [
        "department": "engineering",
        "location": "san-francisco",
        "preferences": ["dark_mode", "notifications"]
    ]
)

// Validate JWT claims
if jwtManager.validateClaims(customClaims) {
    print("✅ JWT claims are valid")
} else {
    print("❌ JWT claims are invalid")
}

// Update JWT claims
jwtManager.updateClaims(customClaims, in: token) { result in
    switch result {
    case .success(let updatedToken):
        print("✅ JWT claims updated")
        print("Updated token: \(updatedToken)")
        
    case .failure(let error):
        print("❌ JWT claims update failed: \(error)")
    }
}
```

---

## 🛡️ Security Features

### Biometric Authentication

```swift
// Configure biometric authentication
let biometricConfig = BiometricConfiguration()
biometricConfig.enableBiometricAuth = true
biometricConfig.biometricType = .faceID // or .touchID
biometricConfig.fallbackToPasscode = true
biometricConfig.reason = "Authenticate to access the app"

authManager.configureBiometric(biometricConfig)

// Authenticate with biometrics
authManager.authenticateWithBiometrics { result in
    switch result {
    case .success:
        print("✅ Biometric authentication successful")
        // Proceed with app access
        
    case .failure(let error):
        print("❌ Biometric authentication failed: \(error)")
        // Fallback to password authentication
    }
}

// Check biometric availability
if authManager.isBiometricAvailable() {
    print("✅ Biometric authentication is available")
} else {
    print("❌ Biometric authentication is not available")
}
```

### Multi-Factor Authentication

```swift
// Configure MFA
let mfaConfig = MFAConfiguration()
mfaConfig.enableMFA = true
mfaConfig.mfaType = .totp // or .sms, .email
mfaConfig.totpSecret = "your_totp_secret"
mfaConfig.totpAlgorithm = .sha1
mfaConfig.totpDigits = 6
mfaConfig.totpPeriod = 30

authManager.configureMFA(mfaConfig)

// Authenticate with MFA
authManager.authenticateWithMFA(code: "123456") { result in
    switch result {
    case .success:
        print("✅ MFA authentication successful")
        
    case .failure(let error):
        print("❌ MFA authentication failed: \(error)")
    }
}

// Generate TOTP code
if let totpCode = authManager.generateTOTPCode() {
    print("TOTP code: \(totpCode)")
}
```

### Certificate Authentication

```swift
// Configure certificate authentication
let certConfig = CertificateConfiguration()
certConfig.enableCertificateAuth = true
certConfig.certificateType = .clientCertificate
certConfig.certificatePath = "path/to/certificate.p12"
certConfig.certificatePassword = "certificate_password"

authManager.configureCertificate(certConfig)

// Authenticate with certificate
authManager.authenticateWithCertificate { result in
    switch result {
    case .success:
        print("✅ Certificate authentication successful")
        
    case .failure(let error):
        print("❌ Certificate authentication failed: \(error)")
    }
}
```

---

## 📊 Error Handling

### Authentication Error Types

```swift
// Handle different authentication error types
authManager.authenticate(username: "user", password: "password") { result in
    switch result {
    case .success(let authResult):
        print("✅ Authentication successful")
        
    case .failure(let error):
        switch error {
        case .networkError(let reason):
            print("❌ Network error: \(reason)")
            // Handle network connectivity issues
            
        case .timeoutError(let reason):
            print("❌ Timeout error: \(reason)")
            // Handle timeout issues
            
        case .invalidCredentials(let reason):
            print("❌ Invalid credentials: \(reason)")
            // Handle invalid username/password
            
        case .tokenExpired(let reason):
            print("❌ Token expired: \(reason)")
            // Handle token expiration
            
        case .tokenInvalid(let reason):
            print("❌ Token invalid: \(reason)")
            // Handle invalid token
            
        case .tokenNotFound(let reason):
            print("❌ Token not found: \(reason)")
            // Handle missing token
            
        case .authenticationFailed(let reason):
            print("❌ Authentication failed: \(reason)")
            // Handle general authentication failure
            
        case .authorizationFailed(let reason):
            print("❌ Authorization failed: \(reason)")
            // Handle authorization issues
            
        case .biometricError(let reason):
            print("❌ Biometric error: \(reason)")
            // Handle biometric authentication issues
            
        case .mfaError(let reason):
            print("❌ MFA error: \(reason)")
            // Handle MFA issues
            
        case .securityError(let reason):
            print("❌ Security error: \(reason)")
            // Handle security issues
            
        case .configurationError(let reason):
            print("❌ Configuration error: \(reason)")
            // Handle configuration issues
            
        case .unknownError(let reason):
            print("❌ Unknown error: \(reason)")
            // Handle unknown errors
        }
    }
}
```

### Error Recovery

```swift
// Error recovery strategies
class AuthenticationErrorRecovery {
    private let authManager: AuthenticationManager
    private var errorCount = 0
    private let maxErrors = 3
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    func handleError(_ error: AuthenticationError) {
        errorCount += 1
        
        if errorCount >= maxErrors {
            print("⚠️ Too many authentication errors, stopping retry")
            return
        }
        
        switch error {
        case .networkError:
            // Retry with exponential backoff
            let delay = pow(2.0, Double(errorCount))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.retryAuthentication()
            }
            
        case .tokenExpired:
            // Refresh token and retry
            refreshToken { success in
                if success {
                    self.retryAuthentication()
                }
            }
            
        case .invalidCredentials:
            // Show login form again
            showLoginForm()
            
        case .biometricError:
            // Fallback to password authentication
            fallbackToPasswordAuth()
            
        case .mfaError:
            // Show MFA form again
            showMFAForm()
            
        default:
            // Log error and continue
            print("❌ Unhandled authentication error: \(error)")
        }
    }
    
    private func retryAuthentication() {
        // Implement retry logic
    }
    
    private func refreshToken(completion: @escaping (Bool) -> Void) {
        // Implement token refresh
        completion(true)
    }
    
    private func showLoginForm() {
        // Show login form
    }
    
    private func fallbackToPasswordAuth() {
        // Fallback to password authentication
    }
    
    private func showMFAForm() {
        // Show MFA form
    }
}
```

---

## 📱 Examples

### Authentication Manager Implementation

```swift
// Authentication manager implementation
class AuthenticationManager {
    private let oauthManager: OAuthManager
    private let jwtManager: JWTAuthenticationManager
    private let securityManager: SecurityManager
    private var currentUser: User?
    
    init() {
        self.oauthManager = OAuthManager()
        self.jwtManager = JWTAuthenticationManager()
        self.securityManager = SecurityManager()
    }
    
    // Configure authentication
    func configure(_ config: AuthenticationConfiguration) {
        if let oauthConfig = config.oauthConfig {
            oauthManager.configure(oauthConfig)
        }
        
        if let jwtConfig = config.jwtConfig {
            jwtManager.configure(jwtConfig)
        }
        
        if let securityConfig = config.securityConfig {
            securityManager.configure(securityConfig)
        }
    }
    
    // Authenticate user
    func authenticate(username: String, password: String, completion: @escaping (Result<AuthResult, AuthenticationError>) -> Void) {
        // Try OAuth first
        oauthManager.startAuthorization { result in
            switch result {
            case .success(let authResult):
                self.currentUser = User(id: authResult.userId, name: username)
                completion(.success(authResult))
                
            case .failure(let error):
                // Fallback to JWT
                self.authenticateWithJWT(username: username, password: password, completion: completion)
            }
        }
    }
    
    // JWT authentication fallback
    private func authenticateWithJWT(username: String, password: String, completion: @escaping (Result<AuthResult, AuthenticationError>) -> Void) {
        let claims = JWTClaims(
            userId: "user_\(username)",
            email: username,
            role: "user"
        )
        
        jwtManager.createToken(claims: claims) { result in
            switch result {
            case .success(let token):
                let authResult = AuthResult(
                    accessToken: token,
                    refreshToken: nil,
                    expiresIn: 3600,
                    tokenType: "Bearer",
                    scope: "read write"
                )
                self.currentUser = User(id: claims.userId, name: username)
                completion(.success(authResult))
                
            case .failure(let error):
                completion(.failure(.authenticationFailed(error.localizedDescription)))
            }
        }
    }
    
    // Check if user is authenticated
    var isAuthenticated: Bool {
        return currentUser != nil && !isTokenExpired()
    }
    
    // Get current user
    var user: User? {
        return currentUser
    }
    
    // Logout user
    func logout() {
        currentUser = nil
        oauthManager.logout()
        jwtManager.revokeToken("") { _ in }
    }
    
    // Check if token is expired
    private func isTokenExpired() -> Bool {
        return oauthManager.isTokenExpired()
    }
}

// Usage example
let authManager = AuthenticationManager()

// Configure authentication
let config = AuthenticationConfiguration()
config.type = .oauth
config.enableBiometricAuth = true
config.enableMFA = false
config.sessionTimeout = 3600.0
config.autoRefreshTokens = true

authManager.configure(config)

// Authenticate user
authManager.authenticate(username: "user@company.com", password: "password") { result in
    switch result {
    case .success(let authResult):
        print("✅ Authentication successful")
        print("Access token: \(authResult.accessToken)")
        
        if authManager.isAuthenticated {
            print("✅ User is authenticated")
            if let user = authManager.user {
                print("Current user: \(user.name)")
            }
        }
        
    case .failure(let error):
        print("❌ Authentication failed: \(error)")
    }
}

// Check authentication status
if authManager.isAuthenticated {
    print("✅ User is authenticated")
} else {
    print("❌ User is not authenticated")
}

// Logout user
authManager.logout()
print("✅ User logged out")
```

---

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import NetworkingArchitecturePro

class AuthenticationTests: XCTestCase {
    var authManager: AuthenticationManager!
    var oauthManager: OAuthManager!
    var jwtManager: JWTAuthenticationManager!
    
    override func setUp() {
        super.setUp()
        authManager = AuthenticationManager()
        oauthManager = OAuthManager()
        jwtManager = JWTAuthenticationManager()
    }
    
    override func tearDown() {
        authManager = nil
        oauthManager = nil
        jwtManager = nil
        super.tearDown()
    }
    
    func testAuthenticationConfiguration() {
        let config = AuthenticationConfiguration(
            type: .oauth,
            enableBiometricAuth: true,
            enableMFA: false,
            sessionTimeout: 3600.0,
            autoRefreshTokens: true
        )
        
        authManager.configure(config)
        
        XCTAssertEqual(authManager.configuration.type, .oauth)
        XCTAssertTrue(authManager.configuration.enableBiometricAuth)
        XCTAssertFalse(authManager.configuration.enableMFA)
        XCTAssertEqual(authManager.configuration.sessionTimeout, 3600.0)
        XCTAssertTrue(authManager.configuration.autoRefreshTokens)
    }
    
    func testOAuthConfiguration() {
        let config = OAuthConfiguration()
        config.clientId = "test_client_id"
        config.clientSecret = "test_client_secret"
        config.redirectURI = "com.test.app://oauth/callback"
        config.scope = "read write"
        config.authorizationURL = "https://auth.test.com/oauth/authorize"
        config.tokenURL = "https://auth.test.com/oauth/token"
        
        oauthManager.configure(config)
        
        XCTAssertEqual(oauthManager.configuration.clientId, "test_client_id")
        XCTAssertEqual(oauthManager.configuration.clientSecret, "test_client_secret")
        XCTAssertEqual(oauthManager.configuration.redirectURI, "com.test.app://oauth/callback")
        XCTAssertEqual(oauthManager.configuration.scope, "read write")
    }
    
    func testJWTConfiguration() {
        let config = JWTConfiguration()
        config.secretKey = "test_jwt_secret"
        config.algorithm = .hs256
        config.expirationTime = 3600
        
        jwtManager.configure(config)
        
        XCTAssertEqual(jwtManager.configuration.secretKey, "test_jwt_secret")
        XCTAssertEqual(jwtManager.configuration.algorithm, .hs256)
        XCTAssertEqual(jwtManager.configuration.expirationTime, 3600)
    }
}
```

### Integration Testing

```swift
class AuthenticationIntegrationTests: XCTestCase {
    func testOAuthFlow() {
        let expectation = XCTestExpectation(description: "OAuth flow")
        
        let oauthManager = OAuthManager()
        let config = OAuthConfiguration()
        config.clientId = "test_client_id"
        config.clientSecret = "test_client_secret"
        config.redirectURI = "com.test.app://oauth/callback"
        config.authorizationURL = "https://auth.test.com/oauth/authorize"
        config.tokenURL = "https://auth.test.com/oauth/token"
        
        oauthManager.configure(config)
        
        oauthManager.startAuthorization { result in
            switch result {
            case .success(let authResult):
                XCTAssertNotNil(authResult.accessToken)
                XCTAssertNotNil(authResult.refreshToken)
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("OAuth flow failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testJWTAuthentication() {
        let expectation = XCTestExpectation(description: "JWT authentication")
        
        let jwtManager = JWTAuthenticationManager()
        let config = JWTConfiguration()
        config.secretKey = "test_jwt_secret"
        config.algorithm = .hs256
        config.expirationTime = 3600
        
        jwtManager.configure(config)
        
        let claims = JWTClaims(
            userId: "123",
            email: "test@company.com",
            role: "user"
        )
        
        jwtManager.createToken(claims: claims) { result in
            switch result {
            case .success(let token):
                XCTAssertNotNil(token)
                
                // Validate the created token
                jwtManager.validateToken(token) { validationResult in
                    switch validationResult {
                    case .success(let validatedClaims):
                        XCTAssertEqual(validatedClaims.userId, "123")
                        XCTAssertEqual(validatedClaims.email, "test@company.com")
                        XCTAssertEqual(validatedClaims.role, "user")
                        expectation.fulfill()
                        
                    case .failure(let error):
                        XCTFail("JWT validation failed: \(error)")
                    }
                }
                
            case .failure(let error):
                XCTFail("JWT creation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

---

## 📞 Support

For additional support and questions about Authentication:

- **Documentation**: [Authentication API Reference](AuthenticationAPI.md)
- **Examples**: [Authentication Examples](../Examples/AuthenticationExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this guide helped you!**
