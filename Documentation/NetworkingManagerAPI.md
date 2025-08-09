# 🌐 Networking Manager API Reference

<!-- TOC START -->
## Table of Contents
- [🌐 Networking Manager API Reference](#-networking-manager-api-reference)
- [📋 Table of Contents](#-table-of-contents)
- [🚀 Overview](#-overview)
  - [🎯 Key Features](#-key-features)
- [📦 NetworkingManager](#-networkingmanager)
  - [Class Definition](#class-definition)
  - [Initialization](#initialization)
  - [Configuration Methods](#configuration-methods)
  - [Lifecycle Methods](#lifecycle-methods)
  - [Utility Methods](#utility-methods)
- [⚙️ NetworkingConfiguration](#-networkingconfiguration)
  - [Structure Definition](#structure-definition)
  - [Default Configuration](#default-configuration)
- [🔧 NetworkMonitor](#-networkmonitor)
  - [Class Definition](#class-definition)
  - [Network Status](#network-status)
  - [Network Type](#network-type)
  - [Connection Quality](#connection-quality)
  - [Monitor Methods](#monitor-methods)
- [📊 NetworkStatistics](#-networkstatistics)
  - [Structure Definition](#structure-definition)
  - [Statistics Calculation](#statistics-calculation)
- [❌ NetworkingError](#-networkingerror)
  - [Error Types](#error-types)
  - [Error Properties](#error-properties)
- [📱 Usage Examples](#-usage-examples)
  - [Basic Networking Manager Usage](#basic-networking-manager-usage)
  - [Advanced Networking Manager Usage](#advanced-networking-manager-usage)
  - [Network Monitoring](#network-monitoring)
- [🧪 Testing](#-testing)
  - [Unit Testing](#unit-testing)
  - [Integration Testing](#integration-testing)
- [📞 Support](#-support)
<!-- TOC END -->


## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [📦 NetworkingManager](#-networkingmanager)
- [⚙️ NetworkingConfiguration](#-networkingconfiguration)
- [🔧 NetworkMonitor](#-networkmonitor)
- [📊 NetworkStatistics](#-networkstatistics)
- [❌ NetworkingError](#-networkingerror)
- [📱 Usage Examples](#-usage-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**Networking Manager API Reference** provides comprehensive documentation for the core networking manager and related utilities in the iOS Networking Architecture Pro framework.

### 🎯 Key Features

- **Centralized Management**: Unified networking management
- **Configuration Management**: Centralized configuration handling
- **Network Monitoring**: Real-time network status monitoring
- **Statistics Tracking**: Network performance statistics
- **Error Handling**: Comprehensive error management
- **Lifecycle Management**: Application lifecycle integration

---

## 📦 NetworkingManager

### Class Definition

```swift
public class NetworkingManager {
    // MARK: - Properties
    
    /// Current configuration
    public private(set) var configuration: NetworkingConfiguration
    
    /// Network monitor
    public private(set) var networkMonitor: NetworkMonitor
    
    /// Network statistics
    public private(set) var statistics: NetworkStatistics
    
    /// Whether networking is active
    public var isActive: Bool
    
    /// Current network status
    public var networkStatus: NetworkStatus
    
    // MARK: - Event Handlers
    
    /// Called when networking starts
    public var onNetworkingStart: (() -> Void)?
    
    /// Called when networking stops
    public var onNetworkingStop: (() -> Void)?
    
    /// Called when network status changes
    public var onNetworkStatusChange: ((NetworkStatus) -> Void)?
    
    /// Called when network error occurs
    public var onNetworkError: ((NetworkingError) -> Void)?
}
```

### Initialization

```swift
// Create networking manager
let networkingManager = NetworkingManager()

// Create with configuration
let config = NetworkingConfiguration()
config.enableHTTPClient = true
config.enableRESTAPI = true
let networkingManager = NetworkingManager(configuration: config)

// Create with custom monitor
let monitor = NetworkMonitor()
let networkingManager = NetworkingManager(monitor: monitor)
```

### Configuration Methods

```swift
// Configure networking manager
func configure(_ configuration: NetworkingConfiguration)

// Update configuration
func updateConfiguration(_ configuration: NetworkingConfiguration)

// Reset configuration to defaults
func resetConfiguration()
```

### Lifecycle Methods

```swift
// Start networking manager
func start(with configuration: NetworkingConfiguration)

// Stop networking manager
func stop()

// Pause networking manager
func pause()

// Resume networking manager
func resume()

// Restart networking manager
func restart()
```

### Utility Methods

```swift
// Get network status
func getNetworkStatus() -> NetworkStatus

// Get network statistics
func getNetworkStatistics() -> NetworkStatistics

// Clear network cache
func clearCache()

// Reset network statistics
func resetStatistics()

// Get network configuration
func getConfiguration() -> NetworkingConfiguration
```

---

## ⚙️ NetworkingConfiguration

### Structure Definition

```swift
public struct NetworkingConfiguration {
    /// Enable HTTP client
    public var enableHTTPClient: Bool
    
    /// Enable REST API
    public var enableRESTAPI: Bool
    
    /// Enable GraphQL
    public var enableGraphQL: Bool
    
    /// Enable WebSocket
    public var enableWebSocket: Bool
    
    /// Request timeout in seconds
    public var requestTimeout: TimeInterval
    
    /// Maximum retry attempts
    public var maxRetries: Int
    
    /// Enable request caching
    public var enableCaching: Bool
    
    /// Enable request logging
    public var enableLogging: Bool
    
    /// Enable request compression
    public var enableCompression: Bool
    
    /// Enable SSL certificate validation
    public var enableCertificateValidation: Bool
    
    /// Enable SSL certificate pinning
    public var enableSSLPinning: Bool
    
    /// Base URL for all requests
    public var baseURL: String?
    
    /// Default headers for all requests
    public var defaultHeaders: [String: String]
    
    /// Network reachability configuration
    public var reachabilityConfig: ReachabilityConfiguration
    
    /// Cache configuration
    public var cacheConfig: CacheConfiguration
    
    /// Logging configuration
    public var loggingConfig: LoggingConfiguration
}
```

### Default Configuration

```swift
public extension NetworkingConfiguration {
    /// Default configuration
    static let `default` = NetworkingConfiguration(
        enableHTTPClient: true,
        enableRESTAPI: true,
        enableGraphQL: true,
        enableWebSocket: true,
        requestTimeout: 30.0,
        maxRetries: 3,
        enableCaching: true,
        enableLogging: false,
        enableCompression: true,
        enableCertificateValidation: true,
        enableSSLPinning: false,
        baseURL: nil,
        defaultHeaders: [:],
        reachabilityConfig: .default,
        cacheConfig: .default,
        loggingConfig: .default
    )
}
```

---

## 🔧 NetworkMonitor

### Class Definition

```swift
public class NetworkMonitor {
    // MARK: - Properties
    
    /// Current network status
    public private(set) var networkStatus: NetworkStatus
    
    /// Network reachability
    public private(set) var isReachable: Bool
    
    /// Network type
    public private(set) var networkType: NetworkType
    
    /// Connection quality
    public private(set) var connectionQuality: ConnectionQuality
    
    // MARK: - Event Handlers
    
    /// Called when network status changes
    public var onNetworkStatusChange: ((NetworkStatus) -> Void)?
    
    /// Called when network becomes reachable
    public var onNetworkReachable: (() -> Void)?
    
    /// Called when network becomes unreachable
    public var onNetworkUnreachable: (() -> Void)?
    
    /// Called when network type changes
    public var onNetworkTypeChange: ((NetworkType) -> Void)?
}
```

### Network Status

```swift
public enum NetworkStatus {
    case unknown
    case notReachable
    case reachableViaWiFi
    case reachableViaWWAN
    case reachableViaEthernet
}
```

### Network Type

```swift
public enum NetworkType {
    case none
    case wifi
    case cellular
    case ethernet
    case unknown
}
```

### Connection Quality

```swift
public enum ConnectionQuality {
    case poor
    case fair
    case good
    case excellent
    case unknown
}
```

### Monitor Methods

```swift
// Start network monitoring
func startMonitoring()

// Stop network monitoring
func stopMonitoring()

// Get current network status
func getCurrentNetworkStatus() -> NetworkStatus

// Check if network is reachable
func isNetworkReachable() -> Bool

// Get network type
func getNetworkType() -> NetworkType

// Get connection quality
func getConnectionQuality() -> ConnectionQuality

// Get network interface info
func getNetworkInterfaceInfo() -> NetworkInterfaceInfo?
```

---

## 📊 NetworkStatistics

### Structure Definition

```swift
public struct NetworkStatistics {
    /// Total requests made
    public let totalRequests: Int
    
    /// Successful requests
    public let successfulRequests: Int
    
    /// Failed requests
    public let failedRequests: Int
    
    /// Average response time
    public let averageResponseTime: TimeInterval
    
    /// Total bytes sent
    public let totalBytesSent: Int64
    
    /// Total bytes received
    public let totalBytesReceived: Int64
    
    /// Cache hit rate
    public let cacheHitRate: Double
    
    /// Error rate
    public let errorRate: Double
    
    /// Success rate
    public let successRate: Double
    
    /// Network uptime
    public let networkUptime: TimeInterval
    
    /// Last request timestamp
    public let lastRequestTimestamp: Date?
}
```

### Statistics Calculation

```swift
public extension NetworkStatistics {
    /// Calculate success rate
    var successRate: Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(successfulRequests) / Double(totalRequests)
    }
    
    /// Calculate error rate
    var errorRate: Double {
        guard totalRequests > 0 else { return 0.0 }
        return Double(failedRequests) / Double(totalRequests)
    }
    
    /// Calculate cache hit rate
    var cacheHitRate: Double {
        // Implementation depends on cache statistics
        return 0.0
    }
    
    /// Get statistics as dictionary
    var asDictionary: [String: Any] {
        return [
            "totalRequests": totalRequests,
            "successfulRequests": successfulRequests,
            "failedRequests": failedRequests,
            "averageResponseTime": averageResponseTime,
            "totalBytesSent": totalBytesSent,
            "totalBytesReceived": totalBytesReceived,
            "cacheHitRate": cacheHitRate,
            "errorRate": errorRate,
            "successRate": successRate,
            "networkUptime": networkUptime,
            "lastRequestTimestamp": lastRequestTimestamp?.timeIntervalSince1970
        ]
    }
}
```

---

## ❌ NetworkingError

### Error Types

```swift
public enum NetworkingError: Error, LocalizedError {
    /// Configuration error
    case configurationError(String)
    
    /// Network error
    case networkError(String)
    
    /// Timeout error
    case timeoutError(String)
    
    /// SSL error
    case sslError(String)
    
    /// Authentication error
    case authenticationError(String)
    
    /// Authorization error
    case authorizationError(String)
    
    /// Server error
    case serverError(String)
    
    /// Client error
    case clientError(String)
    
    /// Parsing error
    case parsingError(String)
    
    /// Validation error
    case validationError(String)
    
    /// Cache error
    case cacheError(String)
    
    /// Monitor error
    case monitorError(String)
    
    /// Statistics error
    case statisticsError(String)
    
    /// Unknown error
    case unknownError(String)
}
```

### Error Properties

```swift
public extension NetworkingError {
    /// Error description
    var errorDescription: String? {
        switch self {
        case .configurationError(let reason):
            return "Configuration error: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .timeoutError(let reason):
            return "Timeout error: \(reason)"
        case .sslError(let reason):
            return "SSL error: \(reason)"
        case .authenticationError(let reason):
            return "Authentication error: \(reason)"
        case .authorizationError(let reason):
            return "Authorization error: \(reason)"
        case .serverError(let reason):
            return "Server error: \(reason)"
        case .clientError(let reason):
            return "Client error: \(reason)"
        case .parsingError(let reason):
            return "Parsing error: \(reason)"
        case .validationError(let reason):
            return "Validation error: \(reason)"
        case .cacheError(let reason):
            return "Cache error: \(reason)"
        case .monitorError(let reason):
            return "Monitor error: \(reason)"
        case .statisticsError(let reason):
            return "Statistics error: \(reason)"
        case .unknownError(let reason):
            return "Unknown error: \(reason)"
        }
    }
    
    /// Error recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .configurationError:
            return "Check your networking configuration"
        case .networkError:
            return "Check your internet connection"
        case .timeoutError:
            return "Increase timeout value or check network"
        case .sslError:
            return "Check your SSL certificate configuration"
        case .authenticationError:
            return "Check your authentication credentials"
        case .authorizationError:
            return "Check your authorization permissions"
        case .serverError:
            return "Contact server administrator"
        case .clientError:
            return "Check your request parameters"
        case .parsingError:
            return "Check your response format"
        case .validationError:
            return "Check your validation parameters"
        case .cacheError:
            return "Check your cache configuration"
        case .monitorError:
            return "Check your network monitoring setup"
        case .statisticsError:
            return "Check your statistics configuration"
        case .unknownError:
            return "Try again or contact support"
        }
    }
}
```

---

## 📱 Usage Examples

### Basic Networking Manager Usage

```swift
// Create networking manager
let networkingManager = NetworkingManager()

// Configure networking
let config = NetworkingConfiguration(
    enableHTTPClient: true,
    enableRESTAPI: true,
    enableGraphQL: true,
    enableWebSocket: true,
    requestTimeout: 30.0,
    maxRetries: 3,
    enableCaching: true,
    enableLogging: false,
    enableCompression: true,
    enableCertificateValidation: true,
    enableSSLPinning: false,
    baseURL: "https://api.company.com",
    defaultHeaders: [
        "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
        "Accept": "application/json"
    ]
)

// Start networking manager
networkingManager.start(with: config)

// Monitor network status
networkingManager.onNetworkStatusChange = { status in
    switch status {
    case .reachableViaWiFi:
        print("✅ Network reachable via WiFi")
    case .reachableViaWWAN:
        print("✅ Network reachable via cellular")
    case .notReachable:
        print("❌ Network not reachable")
    case .unknown:
        print("❓ Network status unknown")
    default:
        break
    }
}

// Handle network errors
networkingManager.onNetworkError = { error in
    print("❌ Network error: \(error)")
}
```

### Advanced Networking Manager Usage

```swift
// Create advanced networking manager
let networkingManager = NetworkingManager()

// Configure with advanced settings
let advancedConfig = NetworkingConfiguration(
    enableHTTPClient: true,
    enableRESTAPI: true,
    enableGraphQL: true,
    enableWebSocket: true,
    requestTimeout: 60.0,
    maxRetries: 5,
    enableCaching: true,
    enableLogging: true,
    enableCompression: true,
    enableCertificateValidation: true,
    enableSSLPinning: true,
    baseURL: "https://api.company.com",
    defaultHeaders: [
        "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
        "Accept": "application/json",
        "Accept-Encoding": "gzip, deflate",
        "Cache-Control": "no-cache"
    ]
)

// Start networking manager
networkingManager.start(with: advancedConfig)

// Monitor network statistics
Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
    let stats = networkingManager.getNetworkStatistics()
    print("📊 Network Statistics:")
    print("- Total requests: \(stats.totalRequests)")
    print("- Success rate: \(stats.successRate * 100)%")
    print("- Average response time: \(stats.averageResponseTime)s")
    print("- Total bytes sent: \(stats.totalBytesSent)")
    print("- Total bytes received: \(stats.totalBytesReceived)")
}

// Handle lifecycle events
networkingManager.onNetworkingStart = {
    print("🚀 Networking manager started")
}

networkingManager.onNetworkingStop = {
    print("🛑 Networking manager stopped")
}

networkingManager.onNetworkStatusChange = { status in
    print("🌐 Network status changed: \(status)")
}

networkingManager.onNetworkError = { error in
    print("❌ Network error: \(error)")
    
    // Handle specific error types
    switch error {
    case .networkError:
        print("⚠️ Network connectivity issue")
    case .timeoutError:
        print("⚠️ Request timeout")
    case .sslError:
        print("⚠️ SSL certificate issue")
    case .authenticationError:
        print("⚠️ Authentication issue")
    default:
        print("⚠️ Unknown network error")
    }
}
```

### Network Monitoring

```swift
// Create network monitor
let networkMonitor = NetworkMonitor()

// Configure network monitoring
networkMonitor.startMonitoring()

// Monitor network status changes
networkMonitor.onNetworkStatusChange = { status in
    switch status {
    case .reachableViaWiFi:
        print("✅ Connected to WiFi")
    case .reachableViaWWAN:
        print("✅ Connected to cellular")
    case .notReachable:
        print("❌ No network connection")
    case .unknown:
        print("❓ Network status unknown")
    default:
        break
    }
}

// Monitor network reachability
networkMonitor.onNetworkReachable = {
    print("✅ Network became reachable")
}

networkMonitor.onNetworkUnreachable = {
    print("❌ Network became unreachable")
}

// Monitor network type changes
networkMonitor.onNetworkTypeChange = { type in
    switch type {
    case .wifi:
        print("📶 Connected to WiFi")
    case .cellular:
        print("📱 Connected to cellular")
    case .ethernet:
        print("🔌 Connected to Ethernet")
    case .none:
        print("❌ No network connection")
    case .unknown:
        print("❓ Unknown network type")
    }
}

// Get network information
let networkStatus = networkMonitor.getCurrentNetworkStatus()
let isReachable = networkMonitor.isNetworkReachable()
let networkType = networkMonitor.getNetworkType()
let connectionQuality = networkMonitor.getConnectionQuality()

print("Network Status: \(networkStatus)")
print("Is Reachable: \(isReachable)")
print("Network Type: \(networkType)")
print("Connection Quality: \(connectionQuality)")
```

---

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import NetworkingArchitecturePro

class NetworkingManagerTests: XCTestCase {
    var networkingManager: NetworkingManager!
    
    override func setUp() {
        super.setUp()
        networkingManager = NetworkingManager()
    }
    
    override func tearDown() {
        networkingManager = nil
        super.tearDown()
    }
    
    func testNetworkingConfiguration() {
        let config = NetworkingConfiguration(
            enableHTTPClient: true,
            enableRESTAPI: true,
            enableGraphQL: true,
            enableWebSocket: true,
            requestTimeout: 30.0,
            maxRetries: 3,
            enableCaching: true
        )
        
        networkingManager.configure(config)
        
        XCTAssertTrue(networkingManager.configuration.enableHTTPClient)
        XCTAssertTrue(networkingManager.configuration.enableRESTAPI)
        XCTAssertTrue(networkingManager.configuration.enableGraphQL)
        XCTAssertTrue(networkingManager.configuration.enableWebSocket)
        XCTAssertEqual(networkingManager.configuration.requestTimeout, 30.0)
        XCTAssertEqual(networkingManager.configuration.maxRetries, 3)
        XCTAssertTrue(networkingManager.configuration.enableCaching)
    }
    
    func testNetworkMonitor() {
        let networkMonitor = NetworkMonitor()
        
        // Test network status
        let status = networkMonitor.getCurrentNetworkStatus()
        XCTAssertNotNil(status)
        
        // Test network reachability
        let isReachable = networkMonitor.isNetworkReachable()
        XCTAssertNotNil(isReachable)
        
        // Test network type
        let networkType = networkMonitor.getNetworkType()
        XCTAssertNotNil(networkType)
        
        // Test connection quality
        let connectionQuality = networkMonitor.getConnectionQuality()
        XCTAssertNotNil(connectionQuality)
    }
    
    func testNetworkStatistics() {
        let stats = NetworkStatistics(
            totalRequests: 100,
            successfulRequests: 95,
            failedRequests: 5,
            averageResponseTime: 0.5,
            totalBytesSent: 1024 * 1024,
            totalBytesReceived: 5 * 1024 * 1024,
            cacheHitRate: 0.8,
            errorRate: 0.05,
            successRate: 0.95,
            networkUptime: 3600.0,
            lastRequestTimestamp: Date()
        )
        
        XCTAssertEqual(stats.totalRequests, 100)
        XCTAssertEqual(stats.successfulRequests, 95)
        XCTAssertEqual(stats.failedRequests, 5)
        XCTAssertEqual(stats.averageResponseTime, 0.5)
        XCTAssertEqual(stats.totalBytesSent, 1024 * 1024)
        XCTAssertEqual(stats.totalBytesReceived, 5 * 1024 * 1024)
        XCTAssertEqual(stats.cacheHitRate, 0.8)
        XCTAssertEqual(stats.errorRate, 0.05)
        XCTAssertEqual(stats.successRate, 0.95)
        XCTAssertEqual(stats.networkUptime, 3600.0)
        XCTAssertNotNil(stats.lastRequestTimestamp)
    }
}
```

### Integration Testing

```swift
class NetworkingManagerIntegrationTests: XCTestCase {
    func testNetworkingManagerLifecycle() {
        let expectation = XCTestExpectation(description: "Networking manager lifecycle")
        
        let networkingManager = NetworkingManager()
        let config = NetworkingConfiguration.default
        
        var startCalled = false
        var stopCalled = false
        
        networkingManager.onNetworkingStart = {
            startCalled = true
        }
        
        networkingManager.onNetworkingStop = {
            stopCalled = true
            expectation.fulfill()
        }
        
        // Start networking manager
        networkingManager.start(with: config)
        
        // Wait a bit
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Stop networking manager
            networkingManager.stop()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(startCalled)
        XCTAssertTrue(stopCalled)
    }
    
    func testNetworkMonitoring() {
        let expectation = XCTestExpectation(description: "Network monitoring")
        
        let networkMonitor = NetworkMonitor()
        
        networkMonitor.onNetworkStatusChange = { status in
            XCTAssertNotNil(status)
            expectation.fulfill()
        }
        
        networkMonitor.startMonitoring()
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

---

## 📞 Support

For additional support and questions about Networking Manager:

- **Documentation**: [Networking Manager Guide](NetworkingManagerGuide.md)
- **Examples**: [Networking Manager Examples](../Examples/NetworkingManagerExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this API reference helped you!**
