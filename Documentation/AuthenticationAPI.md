# 🔐 Authentication API Reference

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [📦 OAuthManager](#-oauthmanager)
- [🔑 JWTAuthenticationManager](#-jwtauthenticationmanager)
- [🛡️ SecurityManager](#-securitymanager)
- [⚙️ AuthenticationConfiguration](#-authenticationconfiguration)
- [❌ AuthenticationError](#-authenticationerror)
- [📱 Usage Examples](#-usage-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**Authentication API Reference** provides comprehensive documentation for all authentication-related classes, protocols, and utilities in the iOS Networking Architecture Pro framework.

### 🎯 Key Components

- **OAuthManager**: OAuth 2.0 authentication implementation
- **JWTAuthenticationManager**: JWT token handling and validation
- **SecurityManager**: Security features and encryption
- **AuthenticationConfiguration**: Authentication configuration options
- **AuthenticationError**: Error types and handling

---

## 📦 OAuthManager

### Class Definition

```swift
public class OAuthManager {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: OAuthConfiguration
    
    /// Current access token
    public private(set) var accessToken: String?
    
    /// Current refresh token
    public private(set) var refreshToken: String?
    
    /// Token expiration date
    public private(set) var tokenExpiration: Date?
    
    /// Whether user is authenticated
    public var isAuthenticated: Bool { accessToken != nil }
    
    // MARK: - Event Handlers
    
    /// Called when authentication succeeds
    public var onAuthenticationSuccess: ((OAuthResult) -> Void)?
    
    /// Called when authentication fails
    public var onAuthenticationFailure: ((AuthenticationError) -> Void)?
    
    /// Called when token is refreshed
    public var onTokenRefresh: ((OAuthResult) -> Void)?
    
    /// Called when token expires
    public var onTokenExpiration: (() -> Void)?
}
```

### Initialization

```swift
// Create OAuth manager
let oauthManager = OAuthManager()

// Create with configuration
let config = OAuthConfiguration()
config.clientId = "your_client_id"
config.clientSecret = "your_client_secret"
let oauthManager = OAuthManager(configuration: config)
```

### Configuration Methods

```swift
// Configure OAuth manager
func configure(_ configuration: OAuthConfiguration)

// Update configuration
func updateConfiguration(_ configuration: OAuthConfiguration)

// Reset configuration to defaults
func resetConfiguration()
```

### Authentication Methods

```swift
// Start OAuth flow
func startAuthorization(completion: @escaping (Result<OAuthResult, AuthenticationError>) -> Void)

// Complete OAuth flow
func completeAuthorization(with code: String, completion: @escaping (Result<OAuthResult, AuthenticationError>) -> Void)

// Refresh access token
func refreshToken(_ refreshToken: String, completion: @escaping (Result<OAuthResult, AuthenticationError>) -> Void)

// Revoke access token
func revokeToken(_ token: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void)

// Logout user
func logout()
```

### Token Management

```swift
// Get current access token
func getAccessToken() -> String?

// Get current refresh token
func getRefreshToken() -> String?

// Check if token is expired
func isTokenExpired() -> Bool

// Get token expiration date
func getTokenExpiration() -> Date?

// Set access token
func setAccessToken(_ token: String, expiration: Date?)

// Set refresh token
func setRefreshToken(_ token: String)
```

---

## 🔑 JWTAuthenticationManager

### Class Definition

```swift
public class JWTAuthenticationManager {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: JWTConfiguration
    
    /// JWT secret key
    public private(set) var secretKey: String
    
    /// JWT algorithm
    public private(set) var algorithm: JWTAlgorithm
    
    /// Whether JWT is enabled
    public var isEnabled: Bool
    
    // MARK: - Event Handlers
    
    /// Called when JWT token is created
    public var onTokenCreated: ((String) -> Void)?
    
    /// Called when JWT token is validated
    public var onTokenValidated: ((JWTClaims) -> Void)?
    
    /// Called when JWT token is invalid
    public var onTokenInvalid: ((AuthenticationError) -> Void)?
}
```

### Initialization

```swift
// Create JWT manager
let jwtManager = JWTAuthenticationManager()

// Create with configuration
let config = JWTConfiguration()
config.secretKey = "your_jwt_secret"
config.algorithm = .hs256
let jwtManager = JWTAuthenticationManager(configuration: config)
```

### Configuration Methods

```swift
// Configure JWT manager
func configure(_ configuration: JWTConfiguration)

// Update configuration
func updateConfiguration(_ configuration: JWTConfiguration)

// Reset configuration to defaults
func resetConfiguration()
```

### Token Methods

```swift
// Create JWT token
func createToken(claims: JWTClaims, completion: @escaping (Result<String, AuthenticationError>) -> Void)

// Validate JWT token
func validateToken(_ token: String, completion: @escaping (Result<JWTClaims, AuthenticationError>) -> Void)

// Decode JWT token
func decodeToken(_ token: String) -> JWTClaims?

// Refresh JWT token
func refreshToken(_ token: String, completion: @escaping (Result<String, AuthenticationError>) -> Void)

// Revoke JWT token
func revokeToken(_ token: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void)
```

### Claims Management

```swift
// Create JWT claims
func createClaims(userId: String, email: String, role: String) -> JWTClaims

// Validate JWT claims
func validateClaims(_ claims: JWTClaims) -> Bool

// Get claims from token
func getClaims(from token: String) -> JWTClaims?

// Update claims
func updateClaims(_ claims: JWTClaims, in token: String) -> String?
```

---

## 🛡️ SecurityManager

### Class Definition

```swift
public class SecurityManager {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: SecurityConfiguration
    
    /// Encryption key
    public private(set) var encryptionKey: Data?
    
    /// Certificate pinning enabled
    public var certificatePinningEnabled: Bool
    
    /// SSL pinning enabled
    public var sslPinningEnabled: Bool
    
    // MARK: - Event Handlers
    
    /// Called when security check passes
    public var onSecurityCheckPassed: (() -> Void)?
    
    /// Called when security check fails
    public var onSecurityCheckFailed: ((SecurityError) -> Void)?
}
```

### Initialization

```swift
// Create security manager
let securityManager = SecurityManager()

// Create with configuration
let config = SecurityConfiguration()
config.enableCertificatePinning = true
config.enableSSLPinning = true
let securityManager = SecurityManager(configuration: config)
```

### Configuration Methods

```swift
// Configure security manager
func configure(_ configuration: SecurityConfiguration)

// Update configuration
func updateConfiguration(_ configuration: SecurityConfiguration)

// Reset configuration to defaults
func resetConfiguration()
```

### Security Methods

```swift
// Encrypt data
func encrypt(_ data: Data, completion: @escaping (Result<Data, SecurityError>) -> Void)

// Decrypt data
func decrypt(_ data: Data, completion: @escaping (Result<Data, SecurityError>) -> Void)

// Hash data
func hash(_ data: Data, algorithm: HashAlgorithm, completion: @escaping (Result<Data, SecurityError>) -> Void)

// Verify hash
func verifyHash(_ data: Data, hash: Data, algorithm: HashAlgorithm, completion: @escaping (Result<Bool, SecurityError>) -> Void)

// Generate secure random data
func generateSecureRandomData(length: Int) -> Data?

// Validate certificate
func validateCertificate(_ certificate: SecCertificate) -> Bool

// Validate SSL certificate
func validateSSLCertificate(for url: URL) -> Bool
```

---

## ⚙️ AuthenticationConfiguration

### Structure Definition

```swift
public struct AuthenticationConfiguration {
    /// Authentication type
    public var type: AuthenticationType
    
    /// OAuth configuration
    public var oauthConfig: OAuthConfiguration?
    
    /// JWT configuration
    public var jwtConfig: JWTConfiguration?
    
    /// Security configuration
    public var securityConfig: SecurityConfiguration?
    
    /// Enable biometric authentication
    public var enableBiometricAuth: Bool
    
    /// Enable multi-factor authentication
    public var enableMFA: Bool
    
    /// Session timeout
    public var sessionTimeout: TimeInterval
    
    /// Auto refresh tokens
    public var autoRefreshTokens: Bool
}
```

### Authentication Types

```swift
public enum AuthenticationType {
    case oauth
    case jwt
    case custom
    case biometric
    case certificate
}
```

### Default Configuration

```swift
public extension AuthenticationConfiguration {
    /// Default configuration
    static let `default` = AuthenticationConfiguration(
        type: .oauth,
        oauthConfig: nil,
        jwtConfig: nil,
        securityConfig: nil,
        enableBiometricAuth: false,
        enableMFA: false,
        sessionTimeout: 3600.0,
        autoRefreshTokens: true
    )
}
```

---

## ❌ AuthenticationError

### Error Types

```swift
public enum AuthenticationError: Error, LocalizedError {
    /// Network error
    case networkError(String)
    
    /// Timeout error
    case timeoutError(String)
    
    /// Invalid credentials
    case invalidCredentials(String)
    
    /// Token expired
    case tokenExpired(String)
    
    /// Token invalid
    case tokenInvalid(String)
    
    /// Token not found
    case tokenNotFound(String)
    
    /// Authentication failed
    case authenticationFailed(String)
    
    /// Authorization failed
    case authorizationFailed(String)
    
    /// Biometric error
    case biometricError(String)
    
    /// MFA error
    case mfaError(String)
    
    /// Security error
    case securityError(String)
    
    /// Configuration error
    case configurationError(String)
    
    /// Unknown error
    case unknownError(String)
}
```

### Error Properties

```swift
public extension AuthenticationError {
    /// Error description
    var errorDescription: String? {
        switch self {
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .timeoutError(let reason):
            return "Timeout error: \(reason)"
        case .invalidCredentials(let reason):
            return "Invalid credentials: \(reason)"
        case .tokenExpired(let reason):
            return "Token expired: \(reason)"
        case .tokenInvalid(let reason):
            return "Token invalid: \(reason)"
        case .tokenNotFound(let reason):
            return "Token not found: \(reason)"
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .authorizationFailed(let reason):
            return "Authorization failed: \(reason)"
        case .biometricError(let reason):
            return "Biometric error: \(reason)"
        case .mfaError(let reason):
            return "MFA error: \(reason)"
        case .securityError(let reason):
            return "Security error: \(reason)"
        case .configurationError(let reason):
            return "Configuration error: \(reason)"
        case .unknownError(let reason):
            return "Unknown error: \(reason)"
        }
    }
    
    /// Error recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Check your internet connection and try again"
        case .timeoutError:
            return "Try again or check your network speed"
        case .invalidCredentials:
            return "Check your username and password"
        case .tokenExpired:
            return "Refresh your authentication token"
        case .tokenInvalid:
            return "Re-authenticate to get a new token"
        case .tokenNotFound:
            return "Log in again to get a new token"
        case .authenticationFailed:
            return "Check your credentials and try again"
        case .authorizationFailed:
            return "Check your permissions and try again"
        case .biometricError:
            return "Check your biometric settings"
        case .mfaError:
            return "Check your MFA configuration"
        case .securityError:
            return "Check your security settings"
        case .configurationError:
            return "Check your authentication configuration"
        case .unknownError:
            return "Try again or contact support"
        }
    }
}
```

---

## 📱 Usage Examples

### OAuth Authentication

```swift
// Create OAuth manager
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
        print("Refresh token: \(authResult.refreshToken)")
        print("Expires in: \(authResult.expiresIn) seconds")
        
    case .failure(let error):
        print("❌ OAuth authorization failed: \(error)")
    }
}

// Refresh access token
oauthManager.refreshToken(refreshToken) { result in
    switch result {
    case .success(let tokenResult):
        print("✅ Token refresh successful")
        print("New access token: \(tokenResult.accessToken)")
        
    case .failure(let error):
        print("❌ Token refresh failed: \(error)")
    }
}
```

### JWT Authentication

```swift
// Create JWT manager
let jwtManager = JWTAuthenticationManager()

// Configure JWT
let jwtConfig = JWTConfiguration()
jwtConfig.secretKey = "your_jwt_secret"
jwtConfig.algorithm = .hs256
jwtConfig.expirationTime = 3600 // 1 hour
jwtConfig.enableRefresh = true

jwtManager.configure(jwtConfig)

// Create JWT token
let claims = JWTClaims(
    userId: "123",
    email: "user@company.com",
    role: "user"
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
        
    case .failure(let error):
        print("❌ JWT token validation failed: \(error)")
    }
}
```

### Security Features

```swift
// Create security manager
let securityManager = SecurityManager()

// Configure security
let securityConfig = SecurityConfiguration()
securityConfig.enableCertificatePinning = true
securityConfig.enableSSLPinning = true
securityConfig.enableEncryption = true
securityConfig.encryptionAlgorithm = .aes256

securityManager.configure(securityConfig)

// Encrypt sensitive data
let sensitiveData = "sensitive information".data(using: .utf8)!
securityManager.encrypt(sensitiveData) { result in
    switch result {
    case .success(let encryptedData):
        print("✅ Data encrypted successfully")
        // Store encrypted data securely
        
    case .failure(let error):
        print("❌ Data encryption failed: \(error)")
    }
}

// Decrypt data
securityManager.decrypt(encryptedData) { result in
    switch result {
    case .success(let decryptedData):
        print("✅ Data decrypted successfully")
        let originalText = String(data: decryptedData, encoding: .utf8)
        print("Original text: \(originalText ?? "")")
        
    case .failure(let error):
        print("❌ Data decryption failed: \(error)")
    }
}

// Hash password
let password = "user_password".data(using: .utf8)!
securityManager.hash(password, algorithm: .sha256) { result in
    switch result {
    case .success(let hashedPassword):
        print("✅ Password hashed successfully")
        // Store hashed password securely
        
    case .failure(let error):
        print("❌ Password hashing failed: \(error)")
    }
}
```

---

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import NetworkingArchitecturePro

class AuthenticationTests: XCTestCase {
    var oauthManager: OAuthManager!
    var jwtManager: JWTAuthenticationManager!
    var securityManager: SecurityManager!
    
    override func setUp() {
        super.setUp()
        oauthManager = OAuthManager()
        jwtManager = JWTAuthenticationManager()
        securityManager = SecurityManager()
    }
    
    override func tearDown() {
        oauthManager = nil
        jwtManager = nil
        securityManager = nil
        super.tearDown()
    }
    
    func testOAuthConfiguration() {
        let config = OAuthConfiguration()
        config.clientId = "test_client_id"
        config.clientSecret = "test_client_secret"
        config.redirectURI = "com.test.app://oauth/callback"
        
        oauthManager.configure(config)
        
        XCTAssertEqual(oauthManager.configuration.clientId, "test_client_id")
        XCTAssertEqual(oauthManager.configuration.clientSecret, "test_client_secret")
        XCTAssertEqual(oauthManager.configuration.redirectURI, "com.test.app://oauth/callback")
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
    
    func testSecurityConfiguration() {
        let config = SecurityConfiguration()
        config.enableCertificatePinning = true
        config.enableSSLPinning = true
        config.enableEncryption = true
        
        securityManager.configure(config)
        
        XCTAssertTrue(securityManager.configuration.enableCertificatePinning)
        XCTAssertTrue(securityManager.configuration.enableSSLPinning)
        XCTAssertTrue(securityManager.configuration.enableEncryption)
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
    
    func testJWTFlow() {
        let expectation = XCTestExpectation(description: "JWT flow")
        
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

For additional support and questions about Authentication API:

- **Documentation**: [Authentication Guide](AuthenticationGuide.md)
- **Examples**: [Authentication Examples](../Examples/AuthenticationExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this API reference helped you!**
