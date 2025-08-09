# 🌐 WebSocket Guide

## 📋 Table of Contents

- [🚀 Overview](#-overview)
- [⚡ Quick Start](#-quick-start)
- [🔧 Configuration](#-configuration)
- [📡 Connection Management](#-connection-management)
- [💬 Message Handling](#-message-handling)
- [🔄 Reconnection](#-reconnection)
- [❤️ Heartbeat](#-heartbeat)
- [📊 Error Handling](#-error-handling)
- [🔐 Security](#-security)
- [📱 Examples](#-examples)
- [🧪 Testing](#-testing)
- [📚 API Reference](#-api-reference)

---

## 🚀 Overview

**WebSocket Guide** provides comprehensive documentation for implementing real-time WebSocket communication in iOS applications using the iOS Networking Architecture Pro framework.

### 🎯 Key Features

- **Real-time Communication**: Bidirectional communication with servers
- **Connection Management**: Automatic connection lifecycle management
- **Message Handling**: Type-safe message handling and routing
- **Reconnection**: Automatic reconnection with exponential backoff
- **Heartbeat**: Connection health monitoring and keep-alive
- **Security**: WebSocket security and authentication
- **Error Handling**: Comprehensive error handling and recovery
- **Performance**: Optimized for high-performance real-time communication

---

## ⚡ Quick Start

### Basic WebSocket Setup

```swift
import NetworkingArchitecturePro

// Initialize WebSocket client
let webSocketClient = WebSocketClient()

// Configure WebSocket
let wsConfig = WebSocketConfiguration()
wsConfig.url = "wss://api.company.com/ws"
wsConfig.enableReconnection = true
wsConfig.heartbeatInterval = 30 // seconds
wsConfig.maxReconnectionAttempts = 5

// Setup WebSocket client
webSocketClient.configure(wsConfig)

// Connect to WebSocket
webSocketClient.connect { result in
    switch result {
    case .success:
        print("✅ WebSocket connected successfully")
    case .failure(let error):
        print("❌ WebSocket connection failed: \(error)")
    }
}
```

### Message Handling

```swift
// Send text message
let textMessage = WebSocketMessage(
    type: .text,
    data: "Hello, WebSocket!"
)

webSocketClient.send(textMessage) { result in
    switch result {
    case .success:
        print("✅ Message sent successfully")
    case .failure(let error):
        print("❌ Message sending failed: \(error)")
    }
}

// Listen for incoming messages
webSocketClient.onMessage { message in
    print("📨 Received message: \(message.data)")
    
    switch message.type {
    case .text:
        handleTextMessage(message.data)
    case .binary:
        handleBinaryMessage(message.data)
    case .ping:
        handlePingMessage()
    case .pong:
        handlePongMessage()
    }
}
```

---

## 🔧 Configuration

### WebSocket Configuration Options

```swift
let wsConfig = WebSocketConfiguration()

// Connection settings
wsConfig.url = "wss://api.company.com/ws"
wsConfig.protocols = ["chat", "notification"]
wsConfig.timeout = 30 // seconds

// Reconnection settings
wsConfig.enableReconnection = true
wsConfig.reconnectDelay = 5 // seconds
wsConfig.maxReconnectionAttempts = 10
wsConfig.exponentialBackoff = true

// Heartbeat settings
wsConfig.enableHeartbeat = true
wsConfig.heartbeatInterval = 30 // seconds
wsConfig.heartbeatTimeout = 10 // seconds

// Security settings
wsConfig.enableSSL = true
wsConfig.sslPinning = true
wsConfig.certificateValidation = true

// Performance settings
wsConfig.enableCompression = true
wsConfig.maxMessageSize = 1024 * 1024 // 1MB
wsConfig.enableLogging = true
```

### Advanced Configuration

```swift
// Custom WebSocket configuration
let customConfig = WebSocketConfiguration()

// Custom headers
customConfig.headers = [
    "Authorization": "Bearer \(accessToken)",
    "User-Agent": "iOS-Networking-Architecture-Pro/1.0.0",
    "Accept": "application/json"
]

// Custom protocols
customConfig.protocols = ["chat", "notification", "analytics"]

// Custom timeout settings
customConfig.connectionTimeout = 15 // seconds
customConfig.readTimeout = 60 // seconds
customConfig.writeTimeout = 30 // seconds

// Custom reconnection strategy
customConfig.reconnectionStrategy = .exponentialBackoff(
    initialDelay: 1,
    maxDelay: 60,
    multiplier: 2.0
)
```

---

## 📡 Connection Management

### Connection Lifecycle

```swift
// Connection state monitoring
webSocketClient.onConnectionStateChange { state in
    switch state {
    case .connecting:
        print("🔄 WebSocket connecting...")
        showConnectingIndicator()
        
    case .connected:
        print("✅ WebSocket connected")
        hideConnectingIndicator()
        showConnectedStatus()
        
    case .disconnected:
        print("❌ WebSocket disconnected")
        showDisconnectedStatus()
        
    case .reconnecting:
        print("🔄 WebSocket reconnecting...")
        showReconnectingIndicator()
        
    case .failed(let error):
        print("❌ WebSocket connection failed: \(error)")
        showErrorStatus(error)
    }
}
```

### Connection Health Monitoring

```swift
// Connection health checker
let healthChecker = WebSocketHealthChecker()

// Configure health checking
healthChecker.configure { config in
    config.healthCheckInterval = 30 // seconds
    config.healthCheckTimeout = 10 // seconds
    config.maxFailedHealthChecks = 3
}

// Start health monitoring
healthChecker.startMonitoring(webSocketClient) { isHealthy in
    if isHealthy {
        print("✅ WebSocket connection is healthy")
    } else {
        print("⚠️ WebSocket connection health check failed")
        webSocketClient.reconnect()
    }
}
```

---

## 💬 Message Handling

### Message Types

```swift
// Text message
let textMessage = WebSocketMessage(
    type: .text,
    data: "Hello, server!"
)

// Binary message
let binaryData = "Hello, binary!".data(using: .utf8)!
let binaryMessage = WebSocketMessage(
    type: .binary,
    data: binaryData
)

// Ping message
let pingMessage = WebSocketMessage(type: .ping)

// Pong message
let pongMessage = WebSocketMessage(type: .pong)
```

### Message Routing

```swift
// Message router
let messageRouter = WebSocketMessageRouter()

// Register message handlers
messageRouter.registerHandler(for: "chat") { message in
    handleChatMessage(message)
}

messageRouter.registerHandler(for: "notification") { message in
    handleNotificationMessage(message)
}

messageRouter.registerHandler(for: "analytics") { message in
    handleAnalyticsMessage(message)
}

// Route incoming messages
webSocketClient.onMessage { message in
    messageRouter.route(message)
}
```

### Message Serialization

```swift
// Message serializer
let messageSerializer = WebSocketMessageSerializer()

// Serialize message to JSON
let chatMessage = ChatMessage(
    type: "chat",
    content: "Hello, everyone!",
    timestamp: Date(),
    userId: "123"
)

let serializedMessage = messageSerializer.serialize(chatMessage)
webSocketClient.send(serializedMessage)

// Deserialize incoming message
webSocketClient.onMessage { message in
    if let chatMessage = messageSerializer.deserialize(message, as: ChatMessage.self) {
        handleChatMessage(chatMessage)
    }
}
```

---

## 🔄 Reconnection

### Automatic Reconnection

```swift
// Configure automatic reconnection
let reconnectionConfig = ReconnectionConfiguration()
reconnectionConfig.enableAutomaticReconnection = true
reconnectionConfig.maxReconnectionAttempts = 10
reconnectionConfig.initialReconnectionDelay = 1 // second
reconnectionConfig.maxReconnectionDelay = 60 // seconds
reconnectionConfig.exponentialBackoff = true

webSocketClient.configureReconnection(reconnectionConfig)

// Monitor reconnection events
webSocketClient.onReconnectionAttempt { attempt in
    print("🔄 Reconnection attempt \(attempt.number)/\(attempt.maxAttempts)")
}

webSocketClient.onReconnectionSuccess {
    print("✅ Reconnection successful")
}

webSocketClient.onReconnectionFailure { error in
    print("❌ Reconnection failed: \(error)")
}
```

### Manual Reconnection

```swift
// Manual reconnection
webSocketClient.reconnect { result in
    switch result {
    case .success:
        print("✅ Manual reconnection successful")
    case .failure(let error):
        print("❌ Manual reconnection failed: \(error)")
    }
}

// Force reconnection with custom delay
webSocketClient.reconnect(delay: 5) { result in
    switch result {
    case .success:
        print("✅ Forced reconnection successful")
    case .failure(let error):
        print("❌ Forced reconnection failed: \(error)")
    }
}
```

---

## ❤️ Heartbeat

### Heartbeat Configuration

```swift
// Configure heartbeat
let heartbeatConfig = HeartbeatConfiguration()
heartbeatConfig.enableHeartbeat = true
heartbeatConfig.heartbeatInterval = 30 // seconds
heartbeatConfig.heartbeatTimeout = 10 // seconds
heartbeatConfig.maxMissedHeartbeats = 3

webSocketClient.configureHeartbeat(heartbeatConfig)

// Monitor heartbeat events
webSocketClient.onHeartbeatSent {
    print("💓 Heartbeat sent")
}

webSocketClient.onHeartbeatReceived {
    print("💓 Heartbeat received")
}

webSocketClient.onHeartbeatTimeout {
    print("⚠️ Heartbeat timeout")
    webSocketClient.reconnect()
}
```

### Custom Heartbeat

```swift
// Custom heartbeat implementation
class CustomHeartbeat {
    private var timer: Timer?
    private let interval: TimeInterval
    
    init(interval: TimeInterval = 30) {
        self.interval = interval
    }
    
    func start(webSocketClient: WebSocketClient) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            let heartbeatMessage = WebSocketMessage(
                type: .text,
                data: "heartbeat"
            )
            
            webSocketClient.send(heartbeatMessage) { result in
                switch result {
                case .success:
                    print("💓 Custom heartbeat sent")
                case .failure(let error):
                    print("❌ Custom heartbeat failed: \(error)")
                }
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
```

---

## 📊 Error Handling

### Error Types

```swift
// WebSocket error handling
webSocketClient.onError { error in
    switch error {
    case .connectionFailed(let reason):
        print("❌ Connection failed: \(reason)")
        handleConnectionFailure(reason)
        
    case .messageSendFailed(let message, let reason):
        print("❌ Message send failed: \(reason)")
        handleMessageSendFailure(message, reason)
        
    case .messageReceiveFailed(let reason):
        print("❌ Message receive failed: \(reason)")
        handleMessageReceiveFailure(reason)
        
    case .protocolError(let reason):
        print("❌ Protocol error: \(reason)")
        handleProtocolError(reason)
        
    case .securityError(let reason):
        print("❌ Security error: \(reason)")
        handleSecurityError(reason)
    }
}
```

### Error Recovery

```swift
// Error recovery strategies
class WebSocketErrorRecovery {
    private let webSocketClient: WebSocketClient
    private var errorCount = 0
    private let maxErrors = 5
    
    init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
    }
    
    func handleError(_ error: WebSocketError) {
        errorCount += 1
        
        if errorCount >= maxErrors {
            print("⚠️ Too many errors, stopping reconnection")
            webSocketClient.disconnect()
            return
        }
        
        switch error {
        case .connectionFailed:
            // Retry connection with exponential backoff
            let delay = pow(2.0, Double(errorCount))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.webSocketClient.reconnect()
            }
            
        case .messageSendFailed:
            // Queue message for retry
            queueMessageForRetry()
            
        case .messageReceiveFailed:
            // Continue listening, don't reconnect
            break
            
        case .protocolError:
            // Reconnect to reset protocol state
            webSocketClient.reconnect()
            
        case .securityError:
            // Handle security error (e.g., re-authenticate)
            handleSecurityError()
        }
    }
}
```

---

## 🔐 Security

### SSL/TLS Configuration

```swift
// SSL/TLS configuration
let sslConfig = SSLConfiguration()
sslConfig.enableSSL = true
sslConfig.sslPinning = true
sslConfig.certificateValidation = true
sslConfig.allowedCipherSuites = [
    .TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
    .TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
]

webSocketClient.configureSSL(sslConfig)
```

### Authentication

```swift
// WebSocket authentication
class WebSocketAuthenticator {
    private let webSocketClient: WebSocketClient
    private let authToken: String
    
    init(webSocketClient: WebSocketClient, authToken: String) {
        self.webSocketClient = webSocketClient
        self.authToken = authToken
    }
    
    func authenticate() {
        let authMessage = WebSocketMessage(
            type: .text,
            data: """
            {
                "type": "auth",
                "token": "\(authToken)"
            }
            """
        )
        
        webSocketClient.send(authMessage) { result in
            switch result {
            case .success:
                print("✅ Authentication successful")
            case .failure(let error):
                print("❌ Authentication failed: \(error)")
            }
        }
    }
}
```

---

## 📱 Examples

### Chat Application

```swift
// Chat WebSocket implementation
class ChatWebSocket {
    private let webSocketClient: WebSocketClient
    private let messageRouter: WebSocketMessageRouter
    
    init() {
        self.webSocketClient = WebSocketClient()
        self.messageRouter = WebSocketMessageRouter()
        setupMessageHandlers()
    }
    
    private func setupMessageHandlers() {
        messageRouter.registerHandler(for: "message") { message in
            self.handleChatMessage(message)
        }
        
        messageRouter.registerHandler(for: "user_joined") { message in
            self.handleUserJoined(message)
        }
        
        messageRouter.registerHandler(for: "user_left") { message in
            self.handleUserLeft(message)
        }
    }
    
    func connect() {
        let wsConfig = WebSocketConfiguration()
        wsConfig.url = "wss://chat.company.com/ws"
        wsConfig.enableReconnection = true
        
        webSocketClient.configure(wsConfig)
        webSocketClient.connect()
        
        webSocketClient.onMessage { message in
            self.messageRouter.route(message)
        }
    }
    
    func sendMessage(_ text: String) {
        let message = ChatMessage(
            type: "message",
            content: text,
            timestamp: Date(),
            userId: getCurrentUserId()
        )
        
        let serializedMessage = messageSerializer.serialize(message)
        webSocketClient.send(serializedMessage)
    }
}
```

### Real-time Notifications

```swift
// Notification WebSocket implementation
class NotificationWebSocket {
    private let webSocketClient: WebSocketClient
    
    init() {
        self.webSocketClient = WebSocketClient()
    }
    
    func connect() {
        let wsConfig = WebSocketConfiguration()
        wsConfig.url = "wss://notifications.company.com/ws"
        wsConfig.enableHeartbeat = true
        wsConfig.heartbeatInterval = 60 // seconds
        
        webSocketClient.configure(wsConfig)
        webSocketClient.connect()
        
        webSocketClient.onMessage { message in
            self.handleNotification(message)
        }
    }
    
    private func handleNotification(_ message: WebSocketMessage) {
        guard let notification = messageSerializer.deserialize(message, as: Notification.self) else {
            return
        }
        
        switch notification.type {
        case "push":
            showPushNotification(notification)
        case "email":
            handleEmailNotification(notification)
        case "sms":
            handleSMSNotification(notification)
        default:
            print("Unknown notification type: \(notification.type)")
        }
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
    
    func testWebSocketConnection() {
        let expectation = XCTestExpectation(description: "WebSocket connection")
        
        let wsConfig = WebSocketConfiguration()
        wsConfig.url = "wss://echo.websocket.org"
        
        webSocketClient.configure(wsConfig)
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
            XCTAssertEqual(message.data, "Hello, WebSocket!")
            expectation.fulfill()
        }
        
        let textMessage = WebSocketMessage(
            type: .text,
            data: "Hello, WebSocket!"
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
}
```

### Integration Testing

```swift
class WebSocketIntegrationTests: XCTestCase {
    func testWebSocketReconnection() {
        let expectation = XCTestExpectation(description: "WebSocket reconnection")
        
        let webSocketClient = WebSocketClient()
        let reconnectionConfig = ReconnectionConfiguration()
        reconnectionConfig.enableAutomaticReconnection = true
        reconnectionConfig.maxReconnectionAttempts = 3
        
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

---

## 📚 API Reference

### WebSocketClient

```swift
class WebSocketClient {
    // Configuration
    func configure(_ config: WebSocketConfiguration)
    func configureReconnection(_ config: ReconnectionConfiguration)
    func configureHeartbeat(_ config: HeartbeatConfiguration)
    func configureSSL(_ config: SSLConfiguration)
    
    // Connection management
    func connect(completion: @escaping (Result<Void, WebSocketError>) -> Void)
    func disconnect()
    func reconnect(completion: @escaping (Result<Void, WebSocketError>) -> Void)
    func reconnect(delay: TimeInterval, completion: @escaping (Result<Void, WebSocketError>) -> Void)
    
    // Message handling
    func send(_ message: WebSocketMessage, completion: @escaping (Result<Void, WebSocketError>) -> Void)
    var onMessage: ((WebSocketMessage) -> Void)?
    
    // Event handlers
    var onConnectionStateChange: ((WebSocketConnectionState) -> Void)?
    var onError: ((WebSocketError) -> Void)?
    var onReconnectionAttempt: ((ReconnectionAttempt) -> Void)?
    var onReconnectionSuccess: (() -> Void)?
    var onReconnectionFailure: ((Error) -> Void)?
    var onHeartbeatSent: (() -> Void)?
    var onHeartbeatReceived: (() -> Void)?
    var onHeartbeatTimeout: (() -> Void)?
}
```

### WebSocketMessage

```swift
struct WebSocketMessage {
    let type: WebSocketMessageType
    let data: Data
    
    init(type: WebSocketMessageType, data: Data)
    init(type: WebSocketMessageType, text: String)
    init(type: WebSocketMessageType)
}

enum WebSocketMessageType {
    case text
    case binary
    case ping
    case pong
    case close
}
```

### WebSocketConfiguration

```swift
struct WebSocketConfiguration {
    var url: String
    var protocols: [String]
    var timeout: TimeInterval
    var enableReconnection: Bool
    var reconnectDelay: TimeInterval
    var maxReconnectionAttempts: Int
    var exponentialBackoff: Bool
    var enableHeartbeat: Bool
    var heartbeatInterval: TimeInterval
    var heartbeatTimeout: TimeInterval
    var enableSSL: Bool
    var sslPinning: Bool
    var certificateValidation: Bool
    var enableCompression: Bool
    var maxMessageSize: Int
    var enableLogging: Bool
    var headers: [String: String]
}
```

---

## 🎯 Best Practices

### Performance Optimization

1. **Message Batching**: Batch multiple messages to reduce network overhead
2. **Compression**: Enable message compression for large payloads
3. **Connection Pooling**: Reuse connections when possible
4. **Memory Management**: Properly dispose of WebSocket instances
5. **Background Processing**: Handle messages on background queues

### Security Considerations

1. **SSL/TLS**: Always use secure WebSocket connections (wss://)
2. **Certificate Pinning**: Implement certificate pinning for additional security
3. **Authentication**: Implement proper authentication mechanisms
4. **Input Validation**: Validate all incoming messages
5. **Rate Limiting**: Implement rate limiting for message sending

### Error Handling

1. **Graceful Degradation**: Handle connection failures gracefully
2. **Retry Logic**: Implement intelligent retry mechanisms
3. **User Feedback**: Provide clear feedback to users about connection status
4. **Logging**: Log all WebSocket events for debugging
5. **Monitoring**: Monitor WebSocket performance and health

### Testing Strategy

1. **Unit Tests**: Test individual WebSocket components
2. **Integration Tests**: Test WebSocket with real servers
3. **Performance Tests**: Test WebSocket performance under load
4. **Security Tests**: Test WebSocket security features
5. **UI Tests**: Test WebSocket integration with UI

---

## 📞 Support

For additional support and questions about WebSocket implementation:

- **Documentation**: [WebSocket API Reference](WebSocketAPI.md)
- **Examples**: [WebSocket Examples](../Examples/WebSocketExamples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro/discussions)

---

**⭐ Star this repository if this guide helped you!**
