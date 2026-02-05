// SSEClient.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation
import NetworkingArchitecture

/// Server-Sent Events (SSE) client
public actor SSEClient {
    
    // MARK: - Properties
    
    private let url: URL
    private let session: URLSession
    private var task: URLSessionDataTask?
    private var isConnected: Bool = false
    private var lastEventId: String?
    private var retryDelay: TimeInterval = 3.0
    private let configuration: SSEConfiguration
    
    private var eventHandlers: [String: [@Sendable (SSEEvent) -> Void]] = [:]
    private var allEventHandlers: [@Sendable (SSEEvent) -> Void] = []
    private var connectionHandlers: [@Sendable (SSEConnectionState) -> Void] = []
    
    // MARK: - Initialization
    
    public init(
        url: URL,
        configuration: SSEConfiguration = .default,
        session: URLSession = .shared
    ) {
        self.url = url
        self.configuration = configuration
        self.session = session
    }
    
    // MARK: - Connection
    
    /// Connect to SSE endpoint
    public func connect() async throws {
        guard !isConnected else { return }
        
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        // Add last event ID for reconnection
        if let lastId = lastEventId {
            request.setValue(lastId, forHTTPHeaderField: "Last-Event-ID")
        }
        
        // Add custom headers
        for (key, value) in configuration.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        isConnected = true
        notifyState(.connected)
        
        // Start streaming
        await startStreaming(request: request)
    }
    
    /// Disconnect from SSE endpoint
    public func disconnect() {
        task?.cancel()
        task = nil
        isConnected = false
        notifyState(.disconnected)
    }
    
    // MARK: - Event Handling
    
    /// Subscribe to specific event type
    public func on(_ eventType: String, handler: @escaping @Sendable (SSEEvent) -> Void) {
        if eventHandlers[eventType] == nil {
            eventHandlers[eventType] = []
        }
        eventHandlers[eventType]?.append(handler)
    }
    
    /// Subscribe to all events
    public func onAny(_ handler: @escaping @Sendable (SSEEvent) -> Void) {
        allEventHandlers.append(handler)
    }
    
    /// Subscribe to connection state changes
    public func onStateChange(_ handler: @escaping @Sendable (SSEConnectionState) -> Void) {
        connectionHandlers.append(handler)
    }
    
    /// Get events as AsyncStream
    public func events() -> AsyncStream<SSEEvent> {
        AsyncStream { continuation in
            Task {
                await self.onAny { event in
                    continuation.yield(event)
                }
            }
        }
    }
    
    /// Get events of specific type
    public func events(ofType type: String) -> AsyncStream<SSEEvent> {
        AsyncStream { continuation in
            Task {
                await self.on(type) { event in
                    continuation.yield(event)
                }
            }
        }
    }
    
    /// Get typed events
    public func events<T: Decodable>(as type: T.Type) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            Task {
                await self.onAny { event in
                    if let data = event.data?.data(using: .utf8),
                       let decoded = try? JSONDecoder().decode(T.self, from: data) {
                        continuation.yield(decoded)
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func startStreaming(request: URLRequest) async {
        // Use bytes(for:) for streaming
        do {
            let (bytes, response) = try await session.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw SSEError.connectionFailed("Invalid response")
            }
            
            var buffer = ""
            var currentEvent = SSEEventBuilder()
            
            for try await byte in bytes {
                guard isConnected else { break }
                
                guard let char = String(bytes: [byte], encoding: .utf8) else { continue }
                buffer += char
                
                // Process line by line
                while let newlineIndex = buffer.firstIndex(of: "\n") {
                    let line = String(buffer[..<newlineIndex])
                    buffer = String(buffer[buffer.index(after: newlineIndex)...])
                    
                    if line.isEmpty {
                        // Empty line = dispatch event
                        if let event = currentEvent.build() {
                            lastEventId = event.id ?? lastEventId
                            await dispatchEvent(event)
                        }
                        currentEvent = SSEEventBuilder()
                    } else if line.hasPrefix(":") {
                        // Comment, ignore
                    } else if line.hasPrefix("event:") {
                        currentEvent.type = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    } else if line.hasPrefix("data:") {
                        let data = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                        if currentEvent.data == nil {
                            currentEvent.data = data
                        } else {
                            currentEvent.data! += "\n" + data
                        }
                    } else if line.hasPrefix("id:") {
                        currentEvent.id = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    } else if line.hasPrefix("retry:") {
                        if let delay = TimeInterval(line.dropFirst(6).trimmingCharacters(in: .whitespaces)) {
                            retryDelay = delay / 1000 // Convert ms to seconds
                        }
                    }
                }
            }
            
        } catch {
            if isConnected {
                await handleDisconnection(error: error)
            }
        }
    }
    
    private func dispatchEvent(_ event: SSEEvent) async {
        // Notify type-specific handlers
        if let type = event.type, let handlers = eventHandlers[type] {
            for handler in handlers {
                handler(event)
            }
        }
        
        // Notify "message" handlers for events without type
        if event.type == nil, let handlers = eventHandlers["message"] {
            for handler in handlers {
                handler(event)
            }
        }
        
        // Notify all-event handlers
        for handler in allEventHandlers {
            handler(event)
        }
    }
    
    private func handleDisconnection(error: Error) async {
        isConnected = false
        notifyState(.disconnected)
        
        // Auto-reconnect
        if configuration.autoReconnect {
            notifyState(.reconnecting)
            
            try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            
            do {
                try await connect()
            } catch {
                await handleDisconnection(error: error)
            }
        }
    }
    
    private func notifyState(_ state: SSEConnectionState) {
        for handler in connectionHandlers {
            handler(state)
        }
    }
}

// MARK: - SSE Event

/// Server-Sent Event
public struct SSEEvent: Sendable {
    public let type: String?
    public let data: String?
    public let id: String?
    public let retry: TimeInterval?
    
    /// Decode data as JSON
    public func decode<T: Decodable>(as type: T.Type) throws -> T {
        guard let data = data?.data(using: .utf8) else {
            throw SSEError.invalidData
        }
        return try JSONDecoder().decode(type, from: data)
    }
}

// MARK: - SSE Event Builder

private struct SSEEventBuilder {
    var type: String?
    var data: String?
    var id: String?
    var retry: TimeInterval?
    
    func build() -> SSEEvent? {
        guard data != nil || type != nil else { return nil }
        return SSEEvent(type: type, data: data, id: id, retry: retry)
    }
}

// MARK: - SSE Connection State

/// SSE connection state
public enum SSEConnectionState: Sendable {
    case disconnected
    case connecting
    case connected
    case reconnecting
}

// MARK: - SSE Error

/// SSE-specific errors
public enum SSEError: Error, LocalizedError, Sendable {
    case connectionFailed(String)
    case invalidData
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "SSE connection failed: \(reason)"
        case .invalidData:
            return "Invalid SSE data"
        case .timeout:
            return "SSE connection timed out"
        }
    }
}

// MARK: - SSE Configuration

/// SSE configuration
public struct SSEConfiguration: Sendable {
    public let autoReconnect: Bool
    public let headers: [String: String]
    public let timeout: TimeInterval
    
    public init(
        autoReconnect: Bool = true,
        headers: [String: String] = [:],
        timeout: TimeInterval = 60
    ) {
        self.autoReconnect = autoReconnect
        self.headers = headers
        self.timeout = timeout
    }
    
    public static let `default` = SSEConfiguration()
}

// MARK: - EventSource

/// W3C EventSource compatible interface
public actor EventSource {
    public enum ReadyState: Int, Sendable {
        case connecting = 0
        case open = 1
        case closed = 2
    }
    
    private let client: SSEClient
    private var _readyState: ReadyState = .connecting
    
    public var readyState: ReadyState { _readyState }
    
    public init(url: URL) {
        self.client = SSEClient(url: url)
    }
    
    public func open() async throws {
        _readyState = .connecting
        try await client.connect()
        _readyState = .open
    }
    
    public func close() {
        client.disconnect()
        _readyState = .closed
    }
    
    public func addEventListener(_ type: String, handler: @escaping @Sendable (SSEEvent) -> Void) async {
        await client.on(type, handler: handler)
    }
}
