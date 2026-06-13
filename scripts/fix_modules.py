import os
import re

dir_path = "/Users/muhittincamdali/Desktop/Claude Projects/GitHub/iOS-Networking-Architecture-Pro/Sources"

def fix_rest():
    path = os.path.join(dir_path, "REST/RESTClient.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    
    # 1. Explicit generic types for delete
    content = content.replace('_ = try await client.execute(Request(endpoint: endpoint))', '_ = try await client.execute(Request<EmptyResponse>(endpoint: endpoint))')
    
    # 2. Fix [String: Any] encodability in patch
    # Use [String: Sendable] or AnyCodable if available
    content = content.replace('changes: [String: Any])', 'changes: [String: Sendable])')
    
    # 3. GenericEndpoint non-Sendable Any
    content = content.replace('public let queryParameters: [String: Any]?', 'public let queryParameters: [String: Sendable]?')
    
    with open(path, 'w') as f: f.write(content)
    print("Fixed RESTClient")

def fix_graphql():
    path = os.path.join(dir_path, "GraphQL/GraphQLClient.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    content = content.replace('public let value: Any', 'public let value: Sendable')
    content = content.replace('init(_ value: Any)', 'init(_ value: Sendable)')
    with open(path, 'w') as f: f.write(content)
    print("Fixed GraphQLClient")

def fix_websocket():
    path = os.path.join(dir_path, "WebSocket/WebSocketClient.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    
    # Fix await messages(as:) call
    content = content.replace('client.messages(as: Incoming.self)', 'await client.messages(as: Incoming.self)')
    
    # Remove redundant await in Task for actor methods
    content = content.replace('await addMessageHandler', 'addMessageHandler')
    
    with open(path, 'w') as f: f.write(content)
    print("Fixed WebSocketClient")

def fix_sse():
    path = os.path.join(dir_path, "SSE/SSEClient.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    # Remove redundant await in Task
    content = content.replace('await self.onAny', 'self.onAny')
    content = content.replace('await self.on(', 'self.on(')
    with open(path, 'w') as f: f.write(content)
    print("Fixed SSEClient")

fix_rest()
fix_graphql()
fix_websocket()
fix_sse()
