// WebSocketTests.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import XCTest
@testable import NetworkingWebSocket

final class WebSocketTests: XCTestCase {
    
    // MARK: - Configuration Tests
    
    func testDefaultConfiguration() {
        let config = WebSocketConfiguration.default
        
        XCTAssertEqual(config.connectionTimeout, 30)
        XCTAssertEqual(config.pingInterval, 30)
        XCTAssertTrue(config.autoReconnect)
        XCTAssertEqual(config.maxReconnectAttempts, 5)
    }
    
    func testCustomConfiguration() {
        let config = WebSocketConfiguration(
            connectionTimeout: 60,
            pingInterval: 15,
            autoReconnect: false,
            maxReconnectAttempts: 3,
            reconnectDelay: 5,
            headers: ["X-Custom": "Value"],
            protocols: ["chat"]
        )
        
        XCTAssertEqual(config.connectionTimeout, 60)
        XCTAssertEqual(config.pingInterval, 15)
        XCTAssertFalse(config.autoReconnect)
        XCTAssertEqual(config.headers["X-Custom"], "Value")
    }
    
    // MARK: - Message Tests
    
    func testTextMessageDecoding() throws {
        let message = WebSocketMessage.text("{\"type\":\"chat\",\"content\":\"Hello\"}")
        
        struct ChatMessage: Decodable {
            let type: String
            let content: String
        }
        
        let decoded = try message.decode(as: ChatMessage.self)
        XCTAssertEqual(decoded.type, "chat")
        XCTAssertEqual(decoded.content, "Hello")
    }
    
    func testDataMessageDecoding() throws {
        let json = "{\"value\":42}"
        let data = json.data(using: .utf8)!
        let message = WebSocketMessage.data(data)
        
        struct TestData: Decodable {
            let value: Int
        }
        
        let decoded = try message.decode(as: TestData.self)
        XCTAssertEqual(decoded.value, 42)
    }
    
    // MARK: - Error Tests
    
    func testWebSocketErrors() {
        let notConnected = WebSocketError.notConnected
        XCTAssertTrue(notConnected.localizedDescription.contains("not connected"))
        
        let connectionFailed = WebSocketError.connectionFailed("Timeout")
        XCTAssertTrue(connectionFailed.localizedDescription.contains("Timeout"))
        
        let invalidMessage = WebSocketError.invalidMessage
        XCTAssertTrue(invalidMessage.localizedDescription.contains("Invalid"))
    }
    
    // MARK: - Connection State Tests
    
    func testConnectionStates() {
        let disconnected = WebSocketConnectionState.disconnected(reason: "Server closed")
        let connecting = WebSocketConnectionState.connecting
        let connected = WebSocketConnectionState.connected
        let reconnecting = WebSocketConnectionState.reconnecting(attempt: 2)
        
        switch disconnected {
        case .disconnected(let reason):
            XCTAssertEqual(reason, "Server closed")
        default:
            XCTFail("Expected disconnected state")
        }
        
        switch reconnecting {
        case .reconnecting(let attempt):
            XCTAssertEqual(attempt, 2)
        default:
            XCTFail("Expected reconnecting state")
        }
    }
}
