# 🌐 WebSocket API Reference

<!-- TOC START -->
## Table of Contents
- [🌐 WebSocket API Reference](#-websocket-api-reference)
- [📋 Table of Contents](#-table-of-contents)
- [🚀 Overview](#-overview)
  - [🎯 Key Components](#-key-components)
- [📦 WebSocketClient](#-websocketclient)
  - [Class Definition](#class-definition)
  - [Initialization](#initialization)
  - [Configuration Methods](#configuration-methods)
  - [Connection Methods](#connection-methods)
  - [Message Methods](#message-methods)
  - [Utility Methods](#utility-methods)
- [💬 WebSocketMessage](#-websocketmessage)
  - [Structure Definition](#structure-definition)
  - [Message Types](#message-types)
  - [Initialization](#initialization)
  - [Utility Methods](#utility-methods)
- [⚙️ WebSocketConfiguration](#-websocketconfiguration)
  - [Structure Definition](#structure-definition)
  - [Default Configuration](#default-configuration)
  - [Configuration Examples](#configuration-examples)
- [🔄 ReconnectionConfiguration](#-reconnectionconfiguration)
  - [Structure Definition](#structure-definition)
  - [Reconnection Strategy](#reconnection-strategy)
  - [Configuration Examples](#configuration-examples)
- [❤️ HeartbeatConfiguration](#-heartbeatconfiguration)
  - [Structure Definition](#structure-definition)
  - [Default Configuration](#default-configuration)
  - [Configuration Examples](#configuration-examples)
- [🔐 SSLConfiguration](#-sslconfiguration)
  - [Structure Definition](#structure-definition)
  - [SSL Cipher Suites](#ssl-cipher-suites)
  - [TLS Versions](#tls-versions)
  - [Configuration Examples](#configuration-examples)
- [📡 WebSocketConnectionState](#-websocketconnectionstate)
  - [Enum Definition](#enum-definition)
  - [State Properties](#state-properties)
- [❌ WebSocketError](#-websocketerror)
  - [Error Types](#error-types)
  - [Error Properties](#error-properties)
- [🛠️ WebSocketMessageRouter](#-websocketmessagerouter)
  - [Class Definition](#class-definition)
  - [Handler Registration](#handler-registration)
  - [Message Routing](#message-routing)
  - [Usage Examples](#usage-examples)
- [📊 WebSocketHealthChecker](#-websockethealthchecker)
  - [Class Definition](#class-definition)
  - [Configuration](#configuration)
  - [Health Monitoring](#health-monitoring)
  - [Usage Examples](#usage-examples)
- [🔧 WebSocketMessageSerializer](#-websocketmessageserializer)
  - [Class Definition](#class-definition)
  - [Serialization Methods](#serialization-methods)
  - [Deserialization Methods](#deserialization-methods)
  - [Usage Examples](#usage-examples)
- [📱 Usage Examples](#-usage-examples)
  - [Chat Application](#chat-application)
  - [Real-time Notifications](#real-time-notifications)
- [🧪 Testing](#-testing)
  - [Unit Testing](#unit-testing)
  - [Integration Testing](#integration-testing)
- [📞 Support](#-support)
<!-- TOC END -->


## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [📦 WebSocketClient](#-websocketclient)
- [💬 WebSocketMessage](#-websocketmessage)
- [⚙️ WebSocketConfiguration](#-websocketconfiguration)
- [🔄 ReconnectionConfiguration](#-reconnectionconfiguration)
- [❤️ HeartbeatConfiguration](#-heartbeatconfiguration)
- [🔐 SSLConfiguration](#-sslconfiguration)
- [📡 WebSocketConnectionState](#-websocketconnectionstate)
- [❌ WebSocketError](#-websocketerror)
- [🛠️ WebSocketMessageRouter](#-websocketmessagerouter)
- [📊 WebSocketHealthChecker](#-websockethealthchecker)
- [🔧 WebSocketMessageSerializer](#-websocketmessageserializer)
- [📱 Usage Examples](#-usage-examples)
- [🧪 Testing](#-testing)

---

## 🚀 Overview

**WebSocket API Reference** provides comprehensive documentation for all WebSocket-related classes, protocols, and utilities in the iOS Networking Architecture Pro framework.

### 🎯 Key Components

- **WebSocketClient**: Main WebSocket client implementation
- **WebSocketMessage**: Message structure and types
- **WebSocketConfiguration**: Client configuration options
- **ReconnectionConfiguration**: Reconnection strategy configuration
- **HeartbeatConfiguration**: Heartbeat and health monitoring
- **SSLConfiguration**: Security and SSL/TLS configuration
- **WebSocketError**: Error types and handling
- **WebSocketMessageRouter**: Message routing and handling

---

## 📦 WebSocketClient

### Class Definition

```swift
public class WebSocketClient {
    // MARK: - Properties
    
    /// Current connection state
    public private(set) var connectionState: WebSocketConnectionState
    
    /// Configuration for the WebSocket client
    public private(set) var configuration: WebSocketConfiguration
    
    /// Whether the client is currently connected
    public var isConnected: Bool { connectionState == .connected }
    
    /// Whether the client is currently connecting
    public var isConnecting: Bool { connectionState == .connecting }
    
    /// Whether the client is currently reconnecting
    public var isReconnecting: Bool { connectionState == .reconnecting }
    
    // MARK: - Event Handlers
    
    /// Called when connection state changes
    public var onConnectionStateChange: ((WebSocketConnectionState) -> Void)?
    
    /// Called when a message is received
    public var onMessage: ((WebSocketMessage) -> Void)?
    
    /// Called when an error occurs
    public var onError: ((WebSocketError) -> Void)?
    
    /// Called when reconnection attempt starts
    public var onReconnectionAttempt: ((ReconnectionAttempt) -> Void)?
    
    /// Called when reconnection succeeds
    public var onReconnectionSuccess: (() -> Void)?
    
    /// Called when reconnection fails
    public var onReconnectionFailure: ((Error) -> Void)?
    
    /// Called when heartbeat is sent
    public var onHeartbeatSent: (() -> Void)?
    
    /// Called when heartbeat is received
    public var onHeartbeatReceived: (() -> Void)?
    
    /// Called when heartbeat times out
    public var onHeartbeatTimeout: (() -> Void)?
}
```

### Initialization

```swift
// Create WebSocket client
let webSocketClient = WebSocketClient()

// Create with configuration
let config = WebSocketConfiguration()
config.url = "wss://api.company.com/ws"
let webSocketClient = WebSocketClient(configuration: config)
```

### Configuration Methods

```swift
// Configure WebSocket client
func configure(_ configuration: WebSocketConfiguration)

// Configure reconnection
func configureReconnection(_ configuration: ReconnectionConfiguration)

// Configure heartbeat
func configureHeartbeat(_ configuration: HeartbeatConfiguration)

// Configure SSL/TLS
func configureSSL(_ configuration: SSLConfiguration)
```

### Connection Methods

```swift
// Connect to WebSocket
func connect(completion: @escaping (Result<Void, WebSocketError>) -> Void)

// Disconnect from WebSocket
func disconnect()

// Reconnect to WebSocket
func reconnect(completion: @escaping (Result<Void, WebSocketError>) -> Void)

// Reconnect with custom delay
func reconnect(delay: TimeInterval, completion: @escaping (Result<Void, WebSocketError>) -> Void)
```

### Message Methods

```swift
// Send message
func send(_ message: WebSocketMessage, completion: @escaping (Result<Void, WebSocketError>) -> Void)

// Send text message
func send(text: String, completion: @escaping (Result<Void, WebSocketError>) -> Void)

// Send binary message
func send(data: Data, completion: @escaping (Result<Void, WebSocketError>) -> Void)

// Send ping
func sendPing(completion: @escaping (Result<Void, WebSocketError>) -> Void)

// Send pong
func sendPong(completion: @escaping (Result<Void, WebSocketError>) -> Void)
```

### Utility Methods

```swift
// Get connection statistics
func getConnectionStats() -> WebSocketConnectionStats

// Get message statistics
func getMessageStats() -> WebSocketMessageStats

// Clear message queue
func clearMessageQueue()

// Set message queue size limit
func setMessageQueueLimit(_ limit: Int)
```

---

## 💬 WebSocketMessage

### Structure Definition

```swift
public struct WebSocketMessage {
    /// Message type
    public let type: WebSocketMessageType
    
    /// Message data
    public let data: Data
    
    /// Message timestamp
    public let timestamp: Date
    
    /// Message ID (for tracking)
    public let id: String
    
    /// Message metadata
    public let metadata: [String: Any]
}
```

### Message Types

```swift
public enum WebSocketMessageType {
    /// Text message
    case text
    
    /// Binary message
    case binary
    
    /// Ping message
    case ping
    
    /// Pong message
    case pong
    
    /// Close message
    case close
    
    /// Custom message type
    case custom(String)
}
```

### Initialization

```swift
// Create text message
let textMessage = WebSocketMessage(
    type: .text,
    data: "Hello, WebSocket!".data(using: .utf8)!
)

// Create binary message
let binaryMessage = WebSocketMessage(
    type: .binary,
    data: someBinaryData
)

// Create ping message
let pingMessage = WebSocketMessage(type: .ping)

// Create pong message
let pongMessage = WebSocketMessage(type: .pong)

// Create close message
let closeMessage = WebSocketMessage(
    type: .close,
    data: "1000".data(using: .utf8)!
)
```

### Utility Methods

```swift
// Get message as text
func asText() -> String?

// Get message as JSON
func asJSON<T: Codable>(_ type: T.Type) -> T?

// Get message size
var size: Int { data.count }

// Check if message is text
var isText: Bool { type == .text }

// Check if message is binary
var isBinary: Bool { type == .binary }

// Check if message is control message
var isControl: Bool { 
    type == .ping || type == .pong || type == .close 
}
```

---

## ⚙️ WebSocketConfiguration

### Structure Definition

```swift
public struct WebSocketConfiguration {
    /// WebSocket server URL
    public var url: String
    
    /// WebSocket protocols
    public var protocols: [String]
    
    /// Connection timeout in seconds
    public var timeout: TimeInterval
    
    /// Enable automatic reconnection
    public var enableReconnection: Bool
    
    /// Reconnection delay in seconds
    public var reconnectDelay: TimeInterval
    
    /// Maximum reconnection attempts
    public var maxReconnectionAttempts: Int
    
    /// Enable exponential backoff for reconnection
    public var exponentialBackoff: Bool
    
    /// Enable heartbeat
    public var enableHeartbeat: Bool
    
    /// Heartbeat interval in seconds
    public var heartbeatInterval: TimeInterval
    
    /// Heartbeat timeout in seconds
    public var heartbeatTimeout: TimeInterval
    
    /// Enable SSL/TLS
    public var enableSSL: Bool
    
    /// Enable SSL certificate pinning
    public var sslPinning: Bool
    
    /// Enable certificate validation
    public var certificateValidation: Bool
    
    /// Enable message compression
    public var enableCompression: Bool
    
    /// Maximum message size in bytes
    public var maxMessageSize: Int
    
    /// Enable logging
    public var enableLogging: Bool
    
    /// Custom headers
    public var headers: [String: String]
}
```

### Default Configuration

```swift
public extension WebSocketConfiguration {
    /// Default configuration
    static let `default` = WebSocketConfiguration(
        url: "",
        protocols: [],
        timeout: 30.0,
        enableReconnection: true,
        reconnectDelay: 5.0,
        maxReconnectionAttempts: 10,
        exponentialBackoff: true,
        enableHeartbeat: true,
        heartbeatInterval: 30.0,
        heartbeatTimeout: 10.0,
        enableSSL: true,
        sslPinning: false,
        certificateValidation: true,
        enableCompression: true,
        maxMessageSize: 1024 * 1024, // 1MB
        enableLogging: false,
        headers: [:]
    )
}
```

### Configuration Examples

```swift
// Basic configuration
let basicConfig = WebSocketConfiguration(
    url: "wss://api.company.com/ws",
    timeout: 30.0,
    enableReconnection: true
)

// Advanced configuration
let advancedConfig = WebSocketConfiguration(
    url: "wss://api.company.com/ws",
    protocols: ["chat", "notification"],
    timeout: 60.0,
    enableReconnection: true,
    reconnectDelay: 10.0,
    maxReconnectionAttempts: 20,
    exponentialBackoff: true,
    enableHeartbeat: true,
    heartbeatInterval: 60.0,
    heartbeatTimeout: 15.0,
    enableSSL: true,
    sslPinning: true,
    certificateValidation: true,
    enableCompression: true,
    maxMessageSize: 5 * 1024 * 1024, // 5MB
    enableLogging: true,
    headers: [
        "Authorization": "Bearer token",
        "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0"
    ]
)
```

---

## 🔄 ReconnectionConfiguration

### Structure Definition

```swift
public struct ReconnectionConfiguration {
    /// Enable automatic reconnection
    public var enableAutomaticReconnection: Bool
    
    /// Maximum reconnection attempts
    public var maxReconnectionAttempts: Int
    
    /// Initial reconnection delay in seconds
    public var initialReconnectionDelay: TimeInterval
    
    /// Maximum reconnection delay in seconds
    public var maxReconnectionDelay: TimeInterval
    
    /// Reconnection strategy
    public var strategy: ReconnectionStrategy
    
    /// Enable exponential backoff
    public var exponentialBackoff: Bool
    
    /// Backoff multiplier
    public var backoffMultiplier: Double
    
    /// Jitter factor for backoff
    public var jitterFactor: Double
}
```

### Reconnection Strategy

```swift
public enum ReconnectionStrategy {
    /// Fixed delay between attempts
    case fixed(delay: TimeInterval)
    
    /// Exponential backoff
    case exponentialBackoff(
        initialDelay: TimeInterval,
        maxDelay: TimeInterval,
        multiplier: Double
    )
    
    /// Custom reconnection strategy
    case custom((Int) -> TimeInterval)
}
```

### Configuration Examples

```swift
// Fixed delay reconnection
let fixedConfig = ReconnectionConfiguration(
    enableAutomaticReconnection: true,
    maxReconnectionAttempts: 10,
    initialReconnectionDelay: 5.0,
    maxReconnectionDelay: 60.0,
    strategy: .fixed(delay: 5.0)
)

// Exponential backoff reconnection
let exponentialConfig = ReconnectionConfiguration(
    enableAutomaticReconnection: true,
    maxReconnectionAttempts: 15,
    initialReconnectionDelay: 1.0,
    maxReconnectionDelay: 120.0,
    strategy: .exponentialBackoff(
        initialDelay: 1.0,
        maxDelay: 120.0,
        multiplier: 2.0
    )
)
```

---

## ❤️ HeartbeatConfiguration

### Structure Definition

```swift
public struct HeartbeatConfiguration {
    /// Enable heartbeat
    public var enableHeartbeat: Bool
    
    /// Heartbeat interval in seconds
    public var heartbeatInterval: TimeInterval
    
    /// Heartbeat timeout in seconds
    public var heartbeatTimeout: TimeInterval
    
    /// Maximum missed heartbeats before reconnection
    public var maxMissedHeartbeats: Int
    
    /// Heartbeat message format
    public var heartbeatMessage: String
    
    /// Enable heartbeat logging
    public var enableLogging: Bool
}
```

### Default Configuration

```swift
public extension HeartbeatConfiguration {
    /// Default heartbeat configuration
    static let `default` = HeartbeatConfiguration(
        enableHeartbeat: true,
        heartbeatInterval: 30.0,
        heartbeatTimeout: 10.0,
        maxMissedHeartbeats: 3,
        heartbeatMessage: "ping",
        enableLogging: false
    )
}
```

### Configuration Examples

```swift
// Basic heartbeat
let basicHeartbeat = HeartbeatConfiguration(
    enableHeartbeat: true,
    heartbeatInterval: 30.0,
    heartbeatTimeout: 10.0
)

// Advanced heartbeat
let advancedHeartbeat = HeartbeatConfiguration(
    enableHeartbeat: true,
    heartbeatInterval: 60.0,
    heartbeatTimeout: 15.0,
    maxMissedHeartbeats: 5,
    heartbeatMessage: """
    {
        "type": "heartbeat",
        "timestamp": "\(Date().timeIntervalSince1970)"
    }
    """,
    enableLogging: true
)
```

---

## 🔐 SSLConfiguration

### Structure Definition

```swift
public struct SSLConfiguration {
    /// Enable SSL/TLS
    public var enableSSL: Bool
    
    /// Enable SSL certificate pinning
    public var sslPinning: Bool
    
    /// Enable certificate validation
    public var certificateValidation: Bool
    
    /// Allowed cipher suites
    public var allowedCipherSuites: [SSLCipherSuite]
    
    /// Minimum TLS version
    public var minimumTLSVersion: TLSVersion
    
    /// Maximum TLS version
    public var maximumTLSVersion: TLSVersion
    
    /// Custom certificate validation
    public var customValidation: ((SecTrust) -> Bool)?
}
```

### SSL Cipher Suites

```swift
public enum SSLCipherSuite {
    case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384
    case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256
    case TLS_RSA_WITH_AES_256_GCM_SHA384
    case TLS_RSA_WITH_AES_128_GCM_SHA256
}
```

### TLS Versions

```swift
public enum TLSVersion {
    case tls1_0
    case tls1_1
    case tls1_2
    case tls1_3
}
```

### Configuration Examples

```swift
// Basic SSL configuration
let basicSSL = SSLConfiguration(
    enableSSL: true,
    sslPinning: false,
    certificateValidation: true
)

// Advanced SSL configuration
let advancedSSL = SSLConfiguration(
    enableSSL: true,
    sslPinning: true,
    certificateValidation: true,
    allowedCipherSuites: [
        .TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
        .TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    ],
    minimumTLSVersion: .tls1_2,
    maximumTLSVersion: .tls1_3
)
```

---

## 📡 WebSocketConnectionState

### Enum Definition

```swift
public enum WebSocketConnectionState {
    /// Disconnected state
    case disconnected
    
    /// Connecting state
    case connecting
    
    /// Connected state
    case connected
    
    /// Reconnecting state
    case reconnecting
    
    /// Failed state with error
    case failed(Error)
}
```

### State Properties

```swift
public extension WebSocketConnectionState {
    /// Whether the connection is active
    var isActive: Bool {
        switch self {
        case .connected, .connecting, .reconnecting:
            return true
        case .disconnected, .failed:
            return false
        }
    }
    
    /// Whether the connection is stable
    var isStable: Bool {
        switch self {
        case .connected:
            return true
        case .disconnected, .connecting, .reconnecting, .failed:
            return false
        }
    }
    
    /// Connection state description
    var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .reconnecting:
            return "Reconnecting"
        case .failed(let error):
            return "Failed: \(error.localizedDescription)"
        }
    }
}
```

---

## ❌ WebSocketError

### Error Types

```swift
public enum WebSocketError: Error, LocalizedError {
    /// Connection failed
    case connectionFailed(String)
    
    /// Message send failed
    case messageSendFailed(WebSocketMessage, String)
    
    /// Message receive failed
    case messageReceiveFailed(String)
    
    /// Protocol error
    case protocolError(String)
    
    /// Security error
    case securityError(String)
    
    /// Configuration error
    case configurationError(String)
    
    /// Timeout error
    case timeoutError(String)
    
    /// Network error
    case networkError(String)
    
    /// SSL/TLS error
    case sslError(String)
    
    /// Authentication error
    case authenticationError(String)
    
    /// Rate limit error
    case rateLimitError(String)
    
    /// Server error
    case serverError(String)
    
    /// Unknown error
    case unknownError(String)
}
```

### Error Properties

```swift
public extension WebSocketError {
    /// Error description
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .messageSendFailed(_, let reason):
            return "Message send failed: \(reason)"
        case .messageReceiveFailed(let reason):
            return "Message receive failed: \(reason)"
        case .protocolError(let reason):
            return "Protocol error: \(reason)"
        case .securityError(let reason):
            return "Security error: \(reason)"
        case .configurationError(let reason):
            return "Configuration error: \(reason)"
        case .timeoutError(let reason):
            return "Timeout error: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .sslError(let reason):
            return "SSL error: \(reason)"
        case .authenticationError(let reason):
            return "Authentication error: \(reason)"
        case .rateLimitError(let reason):
            return "Rate limit error: \(reason)"
        case .serverError(let reason):
            return "Server error: \(reason)"
        case .unknownError(let reason):
            return "Unknown error: \(reason)"
        }
    }
    
    /// Error recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .connectionFailed:
            return "Check your internet connection and try again"
        case .messageSendFailed:
            return "Check your message format and try again"
        case .messageReceiveFailed:
            return "Check your connection and try again"
        case .protocolError:
            return "Check your WebSocket protocol configuration"
        case .securityError:
            return "Check your SSL/TLS configuration"
        case .configurationError:
            return "Check your WebSocket configuration"
        case .timeoutError:
            return "Increase timeout value or check network"
        case .networkError:
            return "Check your network connection"
        case .sslError:
            return "Check your SSL certificate configuration"
        case .authenticationError:
            return "Check your authentication credentials"
        case .rateLimitError:
            return "Wait before sending more messages"
        case .serverError:
            return "Contact server administrator"
        case .unknownError:
            return "Try again or contact support"
        }
    }
}
```

---

## 🛠️ WebSocketMessageRouter

### Class Definition

```swift
public class WebSocketMessageRouter {
    /// Registered message handlers
    private var handlers: [String: (WebSocketMessage) -> Void]
    
    /// Default message handler
    private var defaultHandler: ((WebSocketMessage) -> Void)?
    
    /// Message serializer
    private let serializer: WebSocketMessageSerializer
    
    public init(serializer: WebSocketMessageSerializer = WebSocketMessageSerializer()) {
        self.handlers = [:]
        self.serializer = serializer
    }
}
```

### Handler Registration

```swift
// Register handler for message type
func registerHandler(for type: String, handler: @escaping (WebSocketMessage) -> Void)

// Register handler for multiple types
func registerHandler(for types: [String], handler: @escaping (WebSocketMessage) -> Void)

// Register default handler
func registerDefaultHandler(_ handler: @escaping (WebSocketMessage) -> Void)

// Unregister handler
func unregisterHandler(for type: String)

// Unregister all handlers
func unregisterAllHandlers()
```

### Message Routing

```swift
// Route message to appropriate handler
func route(_ message: WebSocketMessage)

// Route message with custom logic
func route(_ message: WebSocketMessage, customLogic: (WebSocketMessage) -> String?)

// Route message to specific handler
func route(_ message: WebSocketMessage, to type: String)
```

### Usage Examples

```swift
// Create message router
let router = WebSocketMessageRouter()

// Register handlers
router.registerHandler(for: "chat") { message in
    handleChatMessage(message)
}

router.registerHandler(for: "notification") { message in
    handleNotificationMessage(message)
}

router.registerHandler(for: "analytics") { message in
    handleAnalyticsMessage(message)
}

// Register default handler
router.registerDefaultHandler { message in
    print("Unhandled message: \(message)")
}

// Route messages
webSocketClient.onMessage { message in
    router.route(message)
}
```

---

## 📊 WebSocketHealthChecker

### Class Definition

```swift
public class WebSocketHealthChecker {
    /// Health check interval
    private var healthCheckInterval: TimeInterval
    
    /// Health check timeout
    private var healthCheckTimeout: TimeInterval
    
    /// Maximum failed health checks
    private var maxFailedHealthChecks: Int
    
    /// Failed health check count
    private var failedHealthChecks: Int
    
    /// Health check timer
    private var healthCheckTimer: Timer?
    
    /// WebSocket client
    private weak var webSocketClient: WebSocketClient?
    
    public init(
        interval: TimeInterval = 30.0,
        timeout: TimeInterval = 10.0,
        maxFailedChecks: Int = 3
    ) {
        self.healthCheckInterval = interval
        self.healthCheckTimeout = timeout
        self.maxFailedHealthChecks = maxFailedChecks
        self.failedHealthChecks = 0
    }
}
```

### Configuration

```swift
// Configure health checker
func configure(_ configuration: (WebSocketHealthChecker) -> Void)

// Set health check interval
func setHealthCheckInterval(_ interval: TimeInterval)

// Set health check timeout
func setHealthCheckTimeout(_ timeout: TimeInterval)

// Set maximum failed health checks
func setMaxFailedHealthChecks(_ max: Int)
```

### Health Monitoring

```swift
// Start health monitoring
func startMonitoring(_ webSocketClient: WebSocketClient, completion: @escaping (Bool) -> Void)

// Stop health monitoring
func stopMonitoring()

// Perform manual health check
func performHealthCheck(completion: @escaping (Bool) -> Void)

// Reset health check counters
func resetHealthCheckCounters()
```

### Usage Examples

```swift
// Create health checker
let healthChecker = WebSocketHealthChecker(
    interval: 30.0,
    timeout: 10.0,
    maxFailedChecks: 3
)

// Configure health checker
healthChecker.configure { checker in
    checker.setHealthCheckInterval(60.0)
    checker.setHealthCheckTimeout(15.0)
    checker.setMaxFailedHealthChecks(5)
}

// Start monitoring
healthChecker.startMonitoring(webSocketClient) { isHealthy in
    if isHealthy {
        print("✅ WebSocket connection is healthy")
    } else {
        print("⚠️ WebSocket connection health check failed")
        webSocketClient.reconnect()
    }
}

// Stop monitoring
healthChecker.stopMonitoring()
```

---

## 🔧 WebSocketMessageSerializer

### Class Definition

```swift
public class WebSocketMessageSerializer {
    /// JSON encoder
    private let encoder: JSONEncoder
    
    /// JSON decoder
    private let decoder: JSONDecoder
    
    /// Date formatter
    private let dateFormatter: DateFormatter
    
    public init(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.encoder = encoder
        self.decoder = decoder
        self.dateFormatter = DateFormatter()
        
        // Configure date formatting
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
}
```

### Serialization Methods

```swift
// Serialize object to JSON
func serialize<T: Codable>(_ object: T) -> WebSocketMessage?

// Serialize object to JSON with custom type
func serialize<T: Codable>(_ object: T, type: String) -> WebSocketMessage?

// Serialize object to binary
func serializeToBinary<T: Codable>(_ object: T) -> WebSocketMessage?

// Serialize dictionary to JSON
func serialize(_ dictionary: [String: Any]) -> WebSocketMessage?

// Serialize array to JSON
func serialize(_ array: [Any]) -> WebSocketMessage?
```

### Deserialization Methods

```swift
// Deserialize message to object
func deserialize<T: Codable>(_ message: WebSocketMessage, as type: T.Type) -> T?

// Deserialize message to dictionary
func deserializeToDictionary(_ message: WebSocketMessage) -> [String: Any]?

// Deserialize message to array
func deserializeToArray(_ message: WebSocketMessage) -> [Any]?

// Deserialize message to string
func deserializeToString(_ message: WebSocketMessage) -> String?
```

### Usage Examples

```swift
// Create serializer
let serializer = WebSocketMessageSerializer()

// Serialize chat message
let chatMessage = ChatMessage(
    type: "chat",
    content: "Hello, everyone!",
    timestamp: Date(),
    userId: "123"
)

let serializedMessage = serializer.serialize(chatMessage)
webSocketClient.send(serializedMessage!)

// Deserialize incoming message
webSocketClient.onMessage { message in
    if let chatMessage = serializer.deserialize(message, as: ChatMessage.self) {
        handleChatMessage(chatMessage)
    }
}

// Serialize custom type
let notificationMessage = serializer.serialize(
    notification,
    type: "notification"
)
```

---

## 📱 Usage Examples

### Chat Application

```swift
// Chat WebSocket implementation
class ChatWebSocket {
    private let webSocketClient: WebSocketClient
    private let messageRouter: WebSocketMessageRouter
    private let messageSerializer: WebSocketMessageSerializer
    
    init() {
        self.webSocketClient = WebSocketClient()
        self.messageRouter = WebSocketMessageRouter()
        self.messageSerializer = WebSocketMessageSerializer()
        setupMessageHandlers()
    }
    
    private func setupMessageHandlers() {
        messageRouter.registerHandler(for: "message") { message in
            if let chatMessage = self.messageSerializer.deserialize(message, as: ChatMessage.self) {
                self.handleChatMessage(chatMessage)
            }
        }
        
        messageRouter.registerHandler(for: "user_joined") { message in
            if let userEvent = self.messageSerializer.deserialize(message, as: UserEvent.self) {
                self.handleUserJoined(userEvent)
            }
        }
        
        messageRouter.registerHandler(for: "user_left") { message in
            if let userEvent = self.messageSerializer.deserialize(message, as: UserEvent.self) {
                self.handleUserLeft(userEvent)
            }
        }
    }
    
    func connect() {
        let wsConfig = WebSocketConfiguration(
            url: "wss://chat.company.com/ws",
            protocols: ["chat"],
            timeout: 30.0,
            enableReconnection: true,
            reconnectDelay: 5.0,
            maxReconnectionAttempts: 10,
            enableHeartbeat: true,
            heartbeatInterval: 30.0
        )
        
        webSocketClient.configure(wsConfig)
        webSocketClient.connect { result in
            switch result {
            case .success:
                print("✅ Connected to chat server")
            case .failure(let error):
                print("❌ Failed to connect: \(error)")
            }
        }
        
        webSocketClient.onMessage { message in
            self.messageRouter.route(message)
        }
    }
    
    func sendMessage(_ text: String) {
        let chatMessage = ChatMessage(
            type: "message",
            content: text,
            timestamp: Date(),
            userId: getCurrentUserId()
        )
        
        if let serializedMessage = messageSerializer.serialize(chatMessage) {
            webSocketClient.send(serializedMessage) { result in
                switch result {
                case .success:
                    print("✅ Message sent successfully")
                case .failure(let error):
                    print("❌ Failed to send message: \(error)")
                }
            }
        }
    }
    
    private func handleChatMessage(_ message: ChatMessage) {
        print("💬 \(message.userId): \(message.content)")
        // Update UI with new message
    }
    
    private func handleUserJoined(_ event: UserEvent) {
        print("👋 User joined: \(event.userId)")
        // Update UI with user joined
    }
    
    private func handleUserLeft(_ event: UserEvent) {
        print("👋 User left: \(event.userId)")
        // Update UI with user left
    }
}
```

### Real-time Notifications

```swift
// Notification WebSocket implementation
class NotificationWebSocket {
    private let webSocketClient: WebSocketClient
    private let messageSerializer: WebSocketMessageSerializer
    
    init() {
        self.webSocketClient = WebSocketClient()
        self.messageSerializer = WebSocketMessageSerializer()
    }
    
    func connect() {
        let wsConfig = WebSocketConfiguration(
            url: "wss://notifications.company.com/ws",
            protocols: ["notification"],
            timeout: 60.0,
            enableReconnection: true,
            reconnectDelay: 10.0,
            maxReconnectionAttempts: 20,
            enableHeartbeat: true,
            heartbeatInterval: 60.0,
            heartbeatTimeout: 15.0
        )
        
        webSocketClient.configure(wsConfig)
        webSocketClient.connect { result in
            switch result {
            case .success:
                print("✅ Connected to notification server")
            case .failure(let error):
                print("❌ Failed to connect: \(error)")
            }
        }
        
        webSocketClient.onMessage { message in
            self.handleNotification(message)
        }
        
        webSocketClient.onConnectionStateChange { state in
            switch state {
            case .connected:
                print("✅ Notification connection established")
            case .disconnected:
                print("❌ Notification connection lost")
            case .reconnecting:
                print("🔄 Reconnecting to notification server...")
            case .failed(let error):
                print("❌ Notification connection failed: \(error)")
            default:
                break
            }
        }
    }
    
    private func handleNotification(_ message: WebSocketMessage) {
        guard let notification = messageSerializer.deserialize(message, as: Notification.self) else {
            print("❌ Failed to deserialize notification")
            return
        }
        
        switch notification.type {
        case "push":
            showPushNotification(notification)
        case "email":
            handleEmailNotification(notification)
        case "sms":
            handleSMSNotification(notification)
        case "in_app":
            handleInAppNotification(notification)
        default:
            print("Unknown notification type: \(notification.type)")
        }
    }
    
    private func showPushNotification(_ notification: Notification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func handleEmailNotification(_ notification: Notification) {
        // Handle email notification
        print("📧 Email notification: \(notification.title)")
    }
    
    private func handleSMSNotification(_ notification: Notification) {
        // Handle SMS notification
        print("📱 SMS notification: \(notification.title)")
    }
    
    private func handleInAppNotification(_ notification: Notification) {
        // Handle in-app notification
        print("📱 In-app notification: \(notification.title)")
        // Update UI with notification
    }
}
```

---

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import NetworkingArchitecturePro

class WebSocketTests: XCTestCase {
    var webSocketClient: WebSocketClient!
    
    override func setUp() {
        super.setUp()
        webSocketClient = WebSocketClient()
    }
    
    override func tearDown() {
        webSocketClient = nil
        super.tearDown()
    }
    
    func testWebSocketConfiguration() {
        let config = WebSocketConfiguration(
            url: "wss://test.company.com/ws",
            timeout: 30.0,
            enableReconnection: true
        )
        
        webSocketClient.configure(config)
        
        XCTAssertEqual(webSocketClient.configuration.url, "wss://test.company.com/ws")
        XCTAssertEqual(webSocketClient.configuration.timeout, 30.0)
        XCTAssertTrue(webSocketClient.configuration.enableReconnection)
    }
    
    func testWebSocketConnection() {
        let expectation = XCTestExpectation(description: "WebSocket connection")
        
        let config = WebSocketConfiguration(
            url: "wss://echo.websocket.org"
        )
        
        webSocketClient.configure(config)
        webSocketClient.connect { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("WebSocket connection failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testMessageSending() {
        let expectation = XCTestExpectation(description: "Message sending")
        
        webSocketClient.onMessage { message in
            XCTAssertEqual(message.data, "Hello, WebSocket!".data(using: .utf8))
            expectation.fulfill()
        }
        
        let textMessage = WebSocketMessage(
            type: .text,
            data: "Hello, WebSocket!".data(using: .utf8)!
        )
        
        webSocketClient.send(textMessage) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Message sending failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testReconnection() {
        let expectation = XCTestExpectation(description: "WebSocket reconnection")
        
        let reconnectionConfig = ReconnectionConfiguration(
            enableAutomaticReconnection: true,
            maxReconnectionAttempts: 3,
            initialReconnectionDelay: 1.0,
            maxReconnectionDelay: 10.0,
            strategy: .exponentialBackoff(
                initialDelay: 1.0,
                maxDelay: 10.0,
                multiplier: 2.0
            )
        )
        
        webSocketClient.configureReconnection(reconnectionConfig)
        
        var reconnectionAttempts = 0
        webSocketClient.onReconnectionAttempt { attempt in
            reconnectionAttempts += 1
        }
        
        webSocketClient.onReconnectionSuccess {
            XCTAssertGreaterThan(reconnectionAttempts, 0)
            expectation.fulfill()
        }
        
        // Simulate connection failure and reconnection
        webSocketClient.connect { _ in
            // Force disconnect to trigger reconnection
            webSocketClient.disconnect()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

### Integration Testing

```swift
class WebSocketIntegrationTests: XCTestCase {
    func testWebSocketWithRealServer() {
        let expectation = XCTestExpectation(description: "Real server test")
        
        let webSocketClient = WebSocketClient()
        let config = WebSocketConfiguration(
            url: "wss://echo.websocket.org",
            timeout: 30.0,
            enableReconnection: true
        )
        
        webSocketClient.configure(config)
        
        var receivedMessages: [String] = []
        
        webSocketClient.onMessage { message in
            if let text = String(data: message.data, encoding: .utf8) {
                receivedMessages.append(text)
            }
        }
        
        webSocketClient.connect { result in
            switch result {
            case .success:
                // Send test messages
                let testMessages = [
                    "Hello, WebSocket!",
                    "Test message 1",
                    "Test message 2"
                ]
                
                for (index, testMessage) in testMessages.enumerated() {
                    let message = WebSocketMessage(
                        type: .text,
                        data: testMessage.data(using: .utf8)!
                    )
                    
                    webSocketClient.send(message) { result in
                        switch result {
                        case .success:
                            if index == testMessages.count - 1 {
                                // Wait for all messages to be received
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    XCTAssertEqual(receivedMessages.count, testMessages.count)
                                    expectation.fulfill()
                                }
                            }
                        case .failure(let error):
                            XCTFail("Message sending failed: \(error)")
                        }
                    }
                }
                
            case .failure(let error):
                XCTFail("WebSocket connection failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
```

---

## 📞 Support

For additional support and questions about WebSocket API:

- **Documentation**: [WebSocket Guide](WebSocketGuide.md)
- **Examples**: [WebSocket Examples](../Examples/WebSocketExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this API reference helped you!**
