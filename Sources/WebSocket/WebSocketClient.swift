// WebSocketClient.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import NetworkingArchitecture

/// WebSocket client for real-time communication
public actor WebSocketClient {
    
    // MARK: - Properties
    
    private let url: URL
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    private var isConnected: Bool = false
    private var reconnectAttempts: Int = 0
    private var messageHandlers: [UUID: @Sendable (WebSocketMessage) -> Void] = [:]
    private var connectionHandlers: [UUID: @Sendable (WebSocketConnectionState) -> Void] = [:]
    private let configuration: WebSocketConfiguration
    
    // MARK: - Initialization
    
    public init(
        url: URL,
        configuration: WebSocketConfiguration = .default,
        session: URLSession = .shared
    ) {
        self.url = url
        self.configuration = configuration
        self.session = session
    }
    
    // MARK: - Connection
    
    /// Connect to WebSocket server
    public func connect() async throws {
        guard !isConnected else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = configuration.connectionTimeout
        
        // Add headers
        for (key, value) in configuration.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add protocols
        if !configuration.protocols.isEmpty {
            // Protocols are handled by URLSessionWebSocketTask
        }
        
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        
        isConnected = true
        reconnectAttempts = 0
        
        notifyConnectionState(.connected)
        
        // Start receiving messages
        Task { await receiveLoop() }
        
        // Start ping/pong
        if configuration.pingInterval > 0 {
            Task { await pingLoop() }
        }
    }
    
    /// Disconnect from WebSocket server
    public func disconnect(code: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) {
        webSocketTask?.cancel(with: code, reason: reason)
        webSocketTask = nil
        isConnected = false
        notifyConnectionState(.disconnected(reason: nil))
    }
    
    /// Current connection state
    public var connectionState: WebSocketConnectionState {
        isConnected ? .connected : .disconnected(reason: nil)
    }
    
    // MARK: - Sending
    
    /// Send text message
    public func send(_ text: String) async throws {
        guard isConnected else {
            throw WebSocketError.notConnected
        }
        
        try await webSocketTask?.send(.string(text))
    }
    
    /// Send binary data
    public func send(_ data: Data) async throws {
        guard isConnected else {
            throw WebSocketError.notConnected
        }
        
        try await webSocketTask?.send(.data(data))
    }
    
    /// Send Codable object as JSON
    public func send<T: Encodable>(_ object: T) async throws {
        let data = try JSONEncoder().encode(object)
        try await send(data)
    }
    
    // MARK: - Receiving
    
    /// Receive messages as AsyncStream
    public func messages() -> AsyncStream<WebSocketMessage> {
        AsyncStream { continuation in
            let id = UUID()
            Task {
                await addMessageHandler(id: id) { message in
                    continuation.yield(message)
                }
            }
            
            continuation.onTermination = { _ in
                Task {
                    await self.removeMessageHandler(id: id)
                }
            }
        }
    }
    
    /// Receive typed messages
    public func messages<T: Decodable>(as type: T.Type) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            let id = UUID()
            Task {
                await addMessageHandler(id: id) { message in
                    switch message {
                    case .text(let string):
                        if let data = string.data(using: .utf8),
                           let decoded = try? JSONDecoder().decode(T.self, from: data) {
                            continuation.yield(decoded)
                        }
                    case .data(let data):
                        if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                            continuation.yield(decoded)
                        }
                    }
                }
            }
            
            continuation.onTermination = { _ in
                Task {
                    await self.removeMessageHandler(id: id)
                }
            }
        }
    }
    
    // MARK: - Handlers
    
    /// Add message handler
    public func onMessage(_ handler: @escaping @Sendable (WebSocketMessage) -> Void) -> UUID {
        let id = UUID()
        messageHandlers[id] = handler
        return id
    }
    
    /// Remove message handler
    public func removeMessageHandler(id: UUID) {
        messageHandlers.removeValue(forKey: id)
    }
    
    /// Add connection state handler
    public func onConnectionState(_ handler: @escaping @Sendable (WebSocketConnectionState) -> Void) -> UUID {
        let id = UUID()
        connectionHandlers[id] = handler
        return id
    }
    
    /// Remove connection handler
    public func removeConnectionHandler(id: UUID) {
        connectionHandlers.removeValue(forKey: id)
    }
    
    // MARK: - Private
    
    private func addMessageHandler(id: UUID, handler: @escaping @Sendable (WebSocketMessage) -> Void) {
        messageHandlers[id] = handler
    }
    
    private func receiveLoop() async {
        while isConnected {
            do {
                guard let message = try await webSocketTask?.receive() else { break }
                
                let wsMessage: WebSocketMessage
                switch message {
                case .string(let text):
                    wsMessage = .text(text)
                case .data(let data):
                    wsMessage = .data(data)
                @unknown default:
                    continue
                }
                
                notifyMessage(wsMessage)
                
            } catch {
                if isConnected {
                    await handleDisconnection(error: error)
                }
                break
            }
        }
    }
    
    private func pingLoop() async {
        while isConnected {
            do {
                try await Task.sleep(nanoseconds: UInt64(configuration.pingInterval * 1_000_000_000))
                
                guard isConnected else { break }
                
                webSocketTask?.sendPing { [weak self] error in
                    if error != nil {
                        Task { await self?.handleDisconnection(error: error) }
                    }
                }
            } catch {
                break
            }
        }
    }
    
    private func handleDisconnection(error: Error?) async {
        isConnected = false
        notifyConnectionState(.disconnected(reason: error?.localizedDescription))
        
        // Auto-reconnect
        if configuration.autoReconnect && reconnectAttempts < configuration.maxReconnectAttempts {
            reconnectAttempts += 1
            let delay = configuration.reconnectDelay * Double(reconnectAttempts)
            
            notifyConnectionState(.reconnecting(attempt: reconnectAttempts))
            
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            do {
                try await connect()
            } catch {
                await handleDisconnection(error: error)
            }
        }
    }
    
    private func notifyMessage(_ message: WebSocketMessage) {
        for handler in messageHandlers.values {
            handler(message)
        }
    }
    
    private func notifyConnectionState(_ state: WebSocketConnectionState) {
        for handler in connectionHandlers.values {
            handler(state)
        }
    }
}

// MARK: - WebSocket Message

/// WebSocket message type
public enum WebSocketMessage: Sendable {
    case text(String)
    case data(Data)
    
    /// Decode message as JSON
    public func decode<T: Decodable>(as type: T.Type) throws -> T {
        let data: Data
        switch self {
        case .text(let string):
            guard let d = string.data(using: .utf8) else {
                throw WebSocketError.invalidMessage
            }
            data = d
        case .data(let d):
            data = d
        }
        return try JSONDecoder().decode(type, from: data)
    }
}

// MARK: - WebSocket Connection State

/// WebSocket connection state
public enum WebSocketConnectionState: Sendable {
    case disconnected(reason: String?)
    case connecting
    case connected
    case reconnecting(attempt: Int)
}

// MARK: - WebSocket Error

/// WebSocket-specific errors
public enum WebSocketError: Error, LocalizedError, Sendable {
    case notConnected
    case connectionFailed(String)
    case invalidMessage
    case sendFailed(String)
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "WebSocket is not connected"
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .invalidMessage:
            return "Invalid WebSocket message"
        case .sendFailed(let reason):
            return "Failed to send message: \(reason)"
        case .timeout:
            return "WebSocket operation timed out"
        }
    }
}

// MARK: - WebSocket Configuration

/// WebSocket configuration
public struct WebSocketConfiguration: Sendable {
    public let connectionTimeout: TimeInterval
    public let pingInterval: TimeInterval
    public let autoReconnect: Bool
    public let maxReconnectAttempts: Int
    public let reconnectDelay: TimeInterval
    public let headers: [String: String]
    public let protocols: [String]
    
    public init(
        connectionTimeout: TimeInterval = 30,
        pingInterval: TimeInterval = 30,
        autoReconnect: Bool = true,
        maxReconnectAttempts: Int = 5,
        reconnectDelay: TimeInterval = 2,
        headers: [String: String] = [:],
        protocols: [String] = []
    ) {
        self.connectionTimeout = connectionTimeout
        self.pingInterval = pingInterval
        self.autoReconnect = autoReconnect
        self.maxReconnectAttempts = maxReconnectAttempts
        self.reconnectDelay = reconnectDelay
        self.headers = headers
        self.protocols = protocols
    }
    
    public static let `default` = WebSocketConfiguration()
}

// MARK: - WebSocket Channel

/// Typed WebSocket channel for specific message types
public actor WebSocketChannel<Incoming: Decodable, Outgoing: Encodable> {
    private let client: WebSocketClient
    
    public init(client: WebSocketClient) {
        self.client = client
    }
    
    /// Send typed message
    public func send(_ message: Outgoing) async throws {
        try await client.send(message)
    }
    
    /// Receive typed messages
    public func receive() -> AsyncThrowingStream<Incoming, Error> {
        client.messages(as: Incoming.self)
    }
}
