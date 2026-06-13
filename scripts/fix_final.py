import os
import re

dir_path = "/Users/muhittincamdali/Desktop/Claude Projects/GitHub/iOS-Networking-Architecture-Pro/Sources"

def fix_rest():
    path = os.path.join(dir_path, "REST/RESTClient.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    
    # Use AnyCodable for patch body to satisfy Encodable requirement
    content = content.replace('changes: [String: Sendable])', 'changes: [String: AnyCodable])')
    
    with open(path, 'w') as f: f.write(content)
    print("Fixed RESTClient patch")

def fix_websocket():
    path = os.path.join(dir_path, "WebSocket/WebSocketClient.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    
    # Make receive() async
    content = content.replace('func receive() -> AsyncThrowingStream<Incoming, Error> {', 'func receive() async -> AsyncThrowingStream<Incoming, Error> {')
    
    with open(path, 'w') as f: f.write(content)
    print("Fixed WebSocketClient receive")

fix_rest()
fix_websocket()
