import Foundation
import NetworkingArchitecture

/// Real-time synchronization example demonstrating WebSocket communication and conflict resolution
class RealTimeSyncExample {
    
    private let networkManager = NetworkManager.shared
    
    init() {
        setupRealTimeSync()
    }
    
    // MARK: - Setup
    
    private func setupRealTimeSync() {
        let syncConfig = SyncConfiguration()
        syncConfig.enableWebSocket = true
        syncConfig.syncInterval = 5.0
        syncConfig.enableConflictResolution = true
        
        networkManager.enableSync(syncConfig)
        print("✅ Real-time sync enabled")
    }
    
    // MARK: - WebSocket Communication Example
    
    func demonstrateWebSocketCommunication() {
        print("\n📡 WebSocket Communication Example")
        print("==================================")
        
        // Simulate WebSocket connection
        print("🔌 Connecting to WebSocket server...")
        print("✅ WebSocket connected successfully")
        
        // Send message
        let message = SyncMessage(
            id: UUID().uuidString,
            type: .data,
            payload: ["action": "update", "userId": 1],
            timestamp: Date()
        )
        
        print("📤 Sending message: \(message.id)")
        print("📋 Message type: \(message.type.rawValue)")
        print("📦 Payload: \(message.payload)")
        
        // Simulate response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("📥 Received response: Message acknowledged")
            print("✅ WebSocket communication successful")
        }
    }
    
    // MARK: - Conflict Resolution Example
    
    func demonstrateConflictResolution() {
        print("\n⚔️ Conflict Resolution Example")
        print("==============================")
        
        // Simulate conflicting data
        let localUser = User(id: 1, name: "John Doe", email: "john@example.com", version: 2)
        let remoteUser = User(id: 1, name: "John Smith", email: "john.smith@example.com", version: 3)
        
        print("📱 Local version: \(localUser.name) (v\(localUser.version))")
        print("🌐 Remote version: \(remoteUser.name) (v\(remoteUser.version))")
        
        // Detect conflict
        if localUser.version < remoteUser.version {
            print("⚠️ Conflict detected: Remote version is newer")
            
            // Resolve conflict
            let resolvedUser = resolveConflict(local: localUser, remote: remoteUser)
            print("✅ Conflict resolved: \(resolvedUser.name)")
            print("📊 Final version: v\(resolvedUser.version)")
        }
    }
    
    private func resolveConflict(local: User, remote: User) -> User {
        // Simple conflict resolution: prefer remote version
        return User(
            id: remote.id,
            name: remote.name,
            email: remote.email,
            version: remote.version + 1
        )
    }
    
    // MARK: - Delta Synchronization Example
    
    func demonstrateDeltaSync() {
        print("\n🔄 Delta Synchronization Example")
        print("================================")
        
        // Simulate data changes
        let changes = [
            DataChange(id: 1, type: .create, data: ["name": "New User"]),
            DataChange(id: 2, type: .update, data: ["email": "updated@example.com"]),
            DataChange(id: 3, type: .delete, data: [:])
        ]
        
        print("📊 Detected \(changes.count) changes:")
        
        for change in changes {
            print("   - \(change.type.rawValue): ID \(change.id)")
        }
        
        // Sync changes
        print("\n🔄 Syncing changes...")
        
        for change in changes {
            syncChange(change)
        }
        
        print("✅ All changes synchronized successfully")
    }
    
    private func syncChange(_ change: DataChange) {
        print("   📤 Syncing \(change.type.rawValue) for ID \(change.id)")
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("   ✅ \(change.type.rawValue) synced successfully")
        }
    }
    
    // MARK: - Multi-Device Sync Example
    
    func demonstrateMultiDeviceSync() {
        print("\n📱 Multi-Device Sync Example")
        print("============================")
        
        let devices = [
            Device(id: "iphone-1", name: "iPhone 15 Pro", lastSync: Date()),
            Device(id: "ipad-1", name: "iPad Pro", lastSync: Date().addingTimeInterval(-300)),
            Device(id: "mac-1", name: "MacBook Pro", lastSync: Date().addingTimeInterval(-600))
        ]
        
        print("📱 Connected devices:")
        for device in devices {
            print("   - \(device.name) (Last sync: \(formatDate(device.lastSync)))")
        }
        
        // Sync across devices
        print("\n🔄 Syncing across devices...")
        
        for device in devices {
            syncToDevice(device)
        }
        
        print("✅ Multi-device sync completed")
    }
    
    private func syncToDevice(_ device: Device) {
        print("   📤 Syncing to \(device.name)...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("   ✅ \(device.name) synced successfully")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Sync Analytics Example
    
    func demonstrateSyncAnalytics() {
        print("\n📊 Sync Analytics Example")
        print("=========================")
        
        let analytics = SyncAnalytics(
            totalSyncs: 150,
            successfulSyncs: 145,
            failedSyncs: 5,
            averageSyncTime: 2.3,
            conflictsResolved: 12,
            devicesConnected: 3
        )
        
        print("📈 Sync Performance Metrics:")
        print("   Total syncs: \(analytics.totalSyncs)")
        print("   Successful: \(analytics.successfulSyncs)")
        print("   Failed: \(analytics.failedSyncs)")
        print("   Success rate: \(String(format: "%.1f", Double(analytics.successfulSyncs) / Double(analytics.totalSyncs) * 100))%")
        print("   Average sync time: \(analytics.averageSyncTime)s")
        print("   Conflicts resolved: \(analytics.conflictsResolved)")
        print("   Devices connected: \(analytics.devicesConnected)")
        
        // Performance analysis
        let successRate = Double(analytics.successfulSyncs) / Double(analytics.totalSyncs)
        if successRate > 0.95 {
            print("   🎯 Excellent sync performance!")
        } else if successRate > 0.90 {
            print("   ✅ Good sync performance")
        } else {
            print("   ⚠️ Sync performance needs improvement")
        }
    }
    
    // MARK: - Offline Sync Example
    
    func demonstrateOfflineSync() {
        print("\n📴 Offline Sync Example")
        print("========================")
        
        // Simulate offline mode
        print("📴 Device went offline")
        
        // Queue changes while offline
        let offlineChanges = [
            "Create new user",
            "Update user profile",
            "Delete old data"
        ]
        
        print("📝 Queued changes while offline:")
        for change in offlineChanges {
            print("   - \(change)")
        }
        
        // Simulate coming back online
        print("\n📶 Device back online")
        print("🔄 Syncing queued changes...")
        
        for (index, change) in offlineChanges.enumerated() {
            print("   📤 Syncing: \(change)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("   ✅ Synced: \(change)")
                
                if index == offlineChanges.count - 1 {
                    print("✅ All offline changes synced successfully")
                }
            }
        }
    }
}

// MARK: - Usage Example

func runRealTimeSyncExample() {
    let example = RealTimeSyncExample()
    
    // Run all demonstrations
    example.demonstrateWebSocketCommunication()
    example.demonstrateConflictResolution()
    example.demonstrateDeltaSync()
    example.demonstrateMultiDeviceSync()
    example.demonstrateSyncAnalytics()
    example.demonstrateOfflineSync()
}

// MARK: - Supporting Types

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let version: Int
}

struct SyncMessage: Codable {
    let id: String
    let type: MessageType
    let payload: [String: Any]
    let timestamp: Date
    
    enum MessageType: String, Codable {
        case data = "data"
        case sync = "sync"
        case conflict = "conflict"
    }
}

struct DataChange: Codable {
    let id: Int
    let type: ChangeType
    let data: [String: Any]
    
    enum ChangeType: String, Codable {
        case create = "create"
        case update = "update"
        case delete = "delete"
    }
}

struct Device: Codable {
    let id: String
    let name: String
    let lastSync: Date
}

struct SyncAnalytics {
    let totalSyncs: Int
    let successfulSyncs: Int
    let failedSyncs: Int
    let averageSyncTime: TimeInterval
    let conflictsResolved: Int
    let devicesConnected: Int
} 