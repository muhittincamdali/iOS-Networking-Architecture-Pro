# 🛡️ Security API Reference

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [📦 SecurityManager](#-securitymanager)
- [🔐 EncryptionManager](#-encryptionmanager)
- [🔑 KeychainManager](#-keychainmanager)
- [⚙️ SecurityConfiguration](#-securityconfiguration)
- [❌ SecurityError](#-securityerror)
- [📱 Usage Examples](#-usage-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**Security API Reference** provides comprehensive documentation for all security-related classes, protocols, and utilities in the iOS Networking Architecture Pro framework.

### 🎯 Key Components

- **SecurityManager**: Main security manager implementation
- **EncryptionManager**: Data encryption and decryption
- **KeychainManager**: Secure keychain operations
- **SecurityConfiguration**: Security configuration options
- **SecurityError**: Error types and handling

---

## 📦 SecurityManager

### Class Definition

```swift
public class SecurityManager {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: SecurityConfiguration
    
    /// Encryption manager
    public private(set) var encryptionManager: EncryptionManager
    
    /// Keychain manager
    public private(set) var keychainManager: KeychainManager
    
    /// Whether security is enabled
    public var isEnabled: Bool
    
    // MARK: - Event Handlers
    
    /// Called when security check passes
    public var onSecurityCheckPassed: (() -> Void)?
    
    /// Called when security check fails
    public var onSecurityCheckFailed: ((SecurityError) -> Void)?
    
    /// Called when encryption succeeds
    public var onEncryptionSuccess: ((Data) -> Void)?
    
    /// Called when decryption succeeds
    public var onDecryptionSuccess: ((Data) -> Void)?
}
```

### Initialization

```swift
// Create security manager
let securityManager = SecurityManager()

// Create with configuration
let config = SecurityConfiguration()
config.enableEncryption = true
config.enableCertificatePinning = true
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

// Check device security
func checkDeviceSecurity() -> SecurityStatus
```

---

## 🔐 EncryptionManager

### Class Definition

```swift
public class EncryptionManager {
    // MARK: - Properties
    
    /// Current encryption algorithm
    public private(set) var algorithm: EncryptionAlgorithm
    
    /// Encryption key
    public private(set) var encryptionKey: Data?
    
    /// Initialization vector
    public private(set) var iv: Data?
    
    /// Whether encryption is enabled
    public var isEnabled: Bool
    
    // MARK: - Event Handlers
    
    /// Called when encryption succeeds
    public var onEncryptionSuccess: ((Data) -> Void)?
    
    /// Called when encryption fails
    public var onEncryptionFailure: ((SecurityError) -> Void)?
    
    /// Called when decryption succeeds
    public var onDecryptionSuccess: ((Data) -> Void)?
    
    /// Called when decryption fails
    public var onDecryptionFailure: ((SecurityError) -> Void)?
}
```

### Encryption Algorithms

```swift
public enum EncryptionAlgorithm {
    case aes128
    case aes256
    case chaCha20
    case des
    case tripleDES
}
```

### Encryption Methods

```swift
// Encrypt data
func encrypt(_ data: Data, completion: @escaping (Result<Data, SecurityError>) -> Void)

// Decrypt data
func decrypt(_ data: Data, completion: @escaping (Result<Data, SecurityError>) -> Void)

// Generate encryption key
func generateEncryptionKey() -> Data?

// Set encryption key
func setEncryptionKey(_ key: Data)

// Generate initialization vector
func generateIV() -> Data?

// Set initialization vector
func setIV(_ iv: Data)

// Get encrypted data size
func getEncryptedSize(for dataSize: Int) -> Int
```

---

## 🔑 KeychainManager

### Class Definition

```swift
public class KeychainManager {
    // MARK: - Properties
    
    /// Keychain service identifier
    public private(set) var serviceIdentifier: String
    
    /// Keychain access group
    public private(set) var accessGroup: String?
    
    /// Whether keychain is accessible
    public var isAccessible: Bool
    
    // MARK: - Event Handlers
    
    /// Called when keychain operation succeeds
    public var onKeychainSuccess: ((String) -> Void)?
    
    /// Called when keychain operation fails
    public var onKeychainFailure: ((SecurityError) -> Void)?
}
```

### Keychain Methods

```swift
// Save data to keychain
func save(_ data: Data, for key: String, completion: @escaping (Result<Void, SecurityError>) -> Void)

// Load data from keychain
func load(for key: String, completion: @escaping (Result<Data, SecurityError>) -> Void)

// Delete data from keychain
func delete(for key: String, completion: @escaping (Result<Void, SecurityError>) -> Void)

// Check if data exists in keychain
func exists(for key: String) -> Bool

// Get all keys in keychain
func getAllKeys() -> [String]

// Clear all data from keychain
func clearAll(completion: @escaping (Result<Void, SecurityError>) -> Void)
```

---

## ⚙️ SecurityConfiguration

### Structure Definition

```swift
public struct SecurityConfiguration {
    /// Enable encryption
    public var enableEncryption: Bool
    
    /// Enable certificate pinning
    public var enableCertificatePinning: Bool
    
    /// Enable SSL pinning
    public var enableSSLPinning: Bool
    
    /// Enable biometric authentication
    public var enableBiometricAuth: Bool
    
    /// Enable secure storage
    public var enableSecureStorage: Bool
    
    /// Encryption algorithm
    public var encryptionAlgorithm: EncryptionAlgorithm
    
    /// Hash algorithm
    public var hashAlgorithm: HashAlgorithm
    
    /// Certificate validation
    public var certificateValidation: CertificateValidation
    
    /// SSL configuration
    public var sslConfig: SSLConfiguration
    
    /// Keychain configuration
    public var keychainConfig: KeychainConfiguration
}
```

### Hash Algorithms

```swift
public enum HashAlgorithm {
    case md5
    case sha1
    case sha256
    case sha512
    case hmac
}
```

### Certificate Validation

```swift
public enum CertificateValidation {
    case none
    case basic
    case strict
    case custom
}
```

### Default Configuration

```swift
public extension SecurityConfiguration {
    /// Default configuration
    static let `default` = SecurityConfiguration(
        enableEncryption: true,
        enableCertificatePinning: true,
        enableSSLPinning: true,
        enableBiometricAuth: false,
        enableSecureStorage: true,
        encryptionAlgorithm: .aes256,
        hashAlgorithm: .sha256,
        certificateValidation: .strict
    )
}
```

---

## ❌ SecurityError

### Error Types

```swift
public enum SecurityError: Error, LocalizedError {
    /// Encryption error
    case encryptionError(String)
    
    /// Decryption error
    case decryptionError(String)
    
    /// Key generation error
    case keyGenerationError(String)
    
    /// Certificate error
    case certificateError(String)
    
    /// SSL error
    case sslError(String)
    
    /// Keychain error
    case keychainError(String)
    
    /// Biometric error
    case biometricError(String)
    
    /// Hash error
    case hashError(String)
    
    /// Validation error
    case validationError(String)
    
    /// Configuration error
    case configurationError(String)
    
    /// Unknown error
    case unknownError(String)
}
```

### Error Properties

```swift
public extension SecurityError {
    /// Error description
    var errorDescription: String? {
        switch self {
        case .encryptionError(let reason):
            return "Encryption error: \(reason)"
        case .decryptionError(let reason):
            return "Decryption error: \(reason)"
        case .keyGenerationError(let reason):
            return "Key generation error: \(reason)"
        case .certificateError(let reason):
            return "Certificate error: \(reason)"
        case .sslError(let reason):
            return "SSL error: \(reason)"
        case .keychainError(let reason):
            return "Keychain error: \(reason)"
        case .biometricError(let reason):
            return "Biometric error: \(reason)"
        case .hashError(let reason):
            return "Hash error: \(reason)"
        case .validationError(let reason):
            return "Validation error: \(reason)"
        case .configurationError(let reason):
            return "Configuration error: \(reason)"
        case .unknownError(let reason):
            return "Unknown error: \(reason)"
        }
    }
    
    /// Error recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .encryptionError:
            return "Check your encryption configuration"
        case .decryptionError:
            return "Check your decryption key and algorithm"
        case .keyGenerationError:
            return "Check your key generation parameters"
        case .certificateError:
            return "Check your certificate configuration"
        case .sslError:
            return "Check your SSL configuration"
        case .keychainError:
            return "Check your keychain access permissions"
        case .biometricError:
            return "Check your biometric authentication settings"
        case .hashError:
            return "Check your hash algorithm configuration"
        case .validationError:
            return "Check your validation parameters"
        case .configurationError:
            return "Check your security configuration"
        case .unknownError:
            return "Try again or contact support"
        }
    }
}
```

---

## 📱 Usage Examples

### Basic Security Usage

```swift
// Create security manager
let securityManager = SecurityManager()

// Configure security
let config = SecurityConfiguration(
    enableEncryption: true,
    enableCertificatePinning: true,
    enableSSLPinning: true,
    enableSecureStorage: true,
    encryptionAlgorithm: .aes256,
    hashAlgorithm: .sha256,
    certificateValidation: .strict
)
securityManager.configure(config)

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
```

### Advanced Security Usage

```swift
// Create advanced security manager
let securityManager = SecurityManager()

// Configure with advanced settings
let advancedConfig = SecurityConfiguration(
    enableEncryption: true,
    enableCertificatePinning: true,
    enableSSLPinning: true,
    enableBiometricAuth: true,
    enableSecureStorage: true,
    encryptionAlgorithm: .aes256,
    hashAlgorithm: .sha512,
    certificateValidation: .strict
)
securityManager.configure(advancedConfig)

// Hash password with salt
let password = "user_password".data(using: .utf8)!
let salt = securityManager.generateSecureRandomData(length: 32)!

var passwordWithSalt = Data()
passwordWithSalt.append(password)
passwordWithSalt.append(salt)

securityManager.hash(passwordWithSalt, algorithm: .sha512) { result in
    switch result {
    case .success(let hashedPassword):
        print("✅ Password hashed successfully")
        // Store hashed password and salt securely
        
    case .failure(let error):
        print("❌ Password hashing failed: \(error)")
    }
}

// Verify password
let storedHashedPassword = // ... get from secure storage
let inputPassword = "user_password".data(using: .utf8)!
let storedSalt = // ... get from secure storage

var inputPasswordWithSalt = Data()
inputPasswordWithSalt.append(inputPassword)
inputPasswordWithSalt.append(storedSalt)

securityManager.hash(inputPasswordWithSalt, algorithm: .sha512) { result in
    switch result {
    case .success(let hashedInputPassword):
        let isPasswordValid = hashedInputPassword == storedHashedPassword
        print("Password valid: \(isPasswordValid)")
        
    case .failure(let error):
        print("❌ Password verification failed: \(error)")
    }
}
```

### Keychain Usage

```swift
// Create keychain manager
let keychainManager = KeychainManager()

// Save sensitive data to keychain
let sensitiveData = "sensitive information".data(using: .utf8)!
keychainManager.save(sensitiveData, for: "user_credentials") { result in
    switch result {
    case .success:
        print("✅ Data saved to keychain successfully")
        
    case .failure(let error):
        print("❌ Failed to save to keychain: \(error)")
    }
}

// Load data from keychain
keychainManager.load(for: "user_credentials") { result in
    switch result {
    case .success(let data):
        let text = String(data: data, encoding: .utf8)
        print("✅ Data loaded from keychain: \(text ?? "")")
        
    case .failure(let error):
        print("❌ Failed to load from keychain: \(error)")
    }
}

// Delete data from keychain
keychainManager.delete(for: "user_credentials") { result in
    switch result {
    case .success:
        print("✅ Data deleted from keychain successfully")
        
    case .failure(let error):
        print("❌ Failed to delete from keychain: \(error)")
    }
}
```

---

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import NetworkingArchitecturePro

class SecurityTests: XCTestCase {
    var securityManager: SecurityManager!
    var encryptionManager: EncryptionManager!
    var keychainManager: KeychainManager!
    
    override func setUp() {
        super.setUp()
        securityManager = SecurityManager()
        encryptionManager = EncryptionManager()
        keychainManager = KeychainManager()
    }
    
    override func tearDown() {
        securityManager = nil
        encryptionManager = nil
        keychainManager = nil
        super.tearDown()
    }
    
    func testSecurityConfiguration() {
        let config = SecurityConfiguration(
            enableEncryption: true,
            enableCertificatePinning: true,
            enableSSLPinning: true,
            enableSecureStorage: true,
            encryptionAlgorithm: .aes256,
            hashAlgorithm: .sha256,
            certificateValidation: .strict
        )
        
        securityManager.configure(config)
        
        XCTAssertTrue(securityManager.configuration.enableEncryption)
        XCTAssertTrue(securityManager.configuration.enableCertificatePinning)
        XCTAssertTrue(securityManager.configuration.enableSSLPinning)
        XCTAssertEqual(securityManager.configuration.encryptionAlgorithm, .aes256)
        XCTAssertEqual(securityManager.configuration.hashAlgorithm, .sha256)
    }
    
    func testEncryption() {
        let expectation = XCTestExpectation(description: "Encryption test")
        
        let testData = "test data".data(using: .utf8)!
        
        securityManager.encrypt(testData) { result in
            switch result {
            case .success(let encryptedData):
                XCTAssertNotEqual(encryptedData, testData)
                
                // Test decryption
                self.securityManager.decrypt(encryptedData) { decryptResult in
                    switch decryptResult {
                    case .success(let decryptedData):
                        XCTAssertEqual(decryptedData, testData)
                        expectation.fulfill()
                        
                    case .failure(let error):
                        XCTFail("Decryption failed: \(error)")
                    }
                }
                
            case .failure(let error):
                XCTFail("Encryption failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testHashing() {
        let expectation = XCTestExpectation(description: "Hashing test")
        
        let testData = "test data".data(using: .utf8)!
        
        securityManager.hash(testData, algorithm: .sha256) { result in
            switch result {
            case .success(let hashedData):
                XCTAssertNotEqual(hashedData, testData)
                XCTAssertEqual(hashedData.count, 32) // SHA256 hash size
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Hashing failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

### Integration Testing

```swift
class SecurityIntegrationTests: XCTestCase {
    func testKeychainOperations() {
        let expectation = XCTestExpectation(description: "Keychain operations")
        
        let keychainManager = KeychainManager()
        let testData = "test keychain data".data(using: .utf8)!
        let testKey = "test_key"
        
        // Save data to keychain
        keychainManager.save(testData, for: testKey) { saveResult in
            switch saveResult {
            case .success:
                // Load data from keychain
                keychainManager.load(for: testKey) { loadResult in
                    switch loadResult {
                    case .success(let loadedData):
                        XCTAssertEqual(loadedData, testData)
                        
                        // Delete data from keychain
                        keychainManager.delete(for: testKey) { deleteResult in
                            switch deleteResult {
                            case .success:
                                // Verify data is deleted
                                let exists = keychainManager.exists(for: testKey)
                                XCTAssertFalse(exists)
                                expectation.fulfill()
                                
                            case .failure(let error):
                                XCTFail("Failed to delete from keychain: \(error)")
                            }
                        }
                        
                    case .failure(let error):
                        XCTFail("Failed to load from keychain: \(error)")
                    }
                }
                
            case .failure(let error):
                XCTFail("Failed to save to keychain: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

---

## 📞 Support

For additional support and questions about Security API:

- **Documentation**: [Security Guide](SecurityGuide.md)
- **Examples**: [Security Examples](../Examples/SecurityExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this API reference helped you!**
