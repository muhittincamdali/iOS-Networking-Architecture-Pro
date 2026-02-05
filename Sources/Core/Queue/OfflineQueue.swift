// OfflineQueue.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Queued request for offline execution
public struct QueuedRequest: Codable, Sendable, Identifiable {
    public let id: UUID
    public let url: URL
    public let method: String
    public let headers: [String: String]
    public let body: Data?
    public let priority: Int
    public let createdAt: Date
    public let expiresAt: Date?
    public var retryCount: Int
    public var lastError: String?
    
    public init(
        id: UUID = UUID(),
        url: URL,
        method: String,
        headers: [String: String] = [:],
        body: Data? = nil,
        priority: Int = 0,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.priority = priority
        self.createdAt = Date()
        self.expiresAt = expiresAt
        self.retryCount = 0
    }
    
    public init(request: URLRequest, priority: Int = 0, expiresAt: Date? = nil) {
        self.id = UUID()
        self.url = request.url ?? URL(string: "invalid://")!
        self.method = request.httpMethod ?? "GET"
        self.headers = request.allHTTPHeaderFields ?? [:]
        self.body = request.httpBody
        self.priority = priority
        self.createdAt = Date()
        self.expiresAt = expiresAt
        self.retryCount = 0
    }
    
    /// Whether the request has expired
    public var isExpired: Bool {
        if let expiresAt = expiresAt {
            return Date() > expiresAt
        }
        return false
    }
    
    /// Convert back to URLRequest
    public func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

/// Offline queue for storing requests when network is unavailable
public actor OfflineQueue {
    
    // MARK: - Properties
    
    private var queue: [QueuedRequest] = []
    private let maxSize: Int
    private let persistenceURL: URL?
    private var isProcessing: Bool = false
    
    // MARK: - Initialization
    
    public init(maxSize: Int = 100, persistenceURL: URL? = nil) {
        self.maxSize = maxSize
        self.persistenceURL = persistenceURL
        
        // Load persisted queue
        if let url = persistenceURL {
            Task {
                await loadFromDisk(url: url)
            }
        }
    }
    
    // MARK: - Queue Operations
    
    /// Add a request to the queue
    public func enqueue(_ request: QueuedRequest) throws {
        guard queue.count < maxSize else {
            throw NetworkError.offlineQueueFull
        }
        
        queue.append(request)
        queue.sort { $0.priority > $1.priority }
        
        // Persist
        Task { await saveToDisk() }
    }
    
    /// Add a URLRequest to the queue
    public func enqueue(_ request: URLRequest, priority: Int = 0, expiresAt: Date? = nil) throws {
        let queued = QueuedRequest(request: request, priority: priority, expiresAt: expiresAt)
        try enqueue(queued)
    }
    
    /// Get next request from queue
    public func dequeue() -> QueuedRequest? {
        // Remove expired requests
        queue.removeAll { $0.isExpired }
        
        guard !queue.isEmpty else { return nil }
        
        let request = queue.removeFirst()
        Task { await saveToDisk() }
        return request
    }
    
    /// Peek at next request without removing
    public func peek() -> QueuedRequest? {
        queue.first { !$0.isExpired }
    }
    
    /// Remove a specific request
    public func remove(id: UUID) {
        queue.removeAll { $0.id == id }
        Task { await saveToDisk() }
    }
    
    /// Clear all queued requests
    public func clear() {
        queue.removeAll()
        Task { await saveToDisk() }
    }
    
    /// Number of queued requests
    public var count: Int {
        queue.filter { !$0.isExpired }.count
    }
    
    /// Whether queue is empty
    public var isEmpty: Bool {
        count == 0
    }
    
    /// Whether queue is full
    public var isFull: Bool {
        queue.count >= maxSize
    }
    
    /// Get all queued requests
    public func getAll() -> [QueuedRequest] {
        queue.filter { !$0.isExpired }
    }
    
    // MARK: - Processing
    
    /// Process all queued requests
    public func processQueue(
        using client: NetworkClient,
        onResult: @escaping @Sendable (QueuedRequest, Result<RawResponse, Error>) async -> Void
    ) async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        while let request = dequeue() {
            do {
                let urlRequest = request.asURLRequest()
                let endpoint = RawEndpoint(request: urlRequest)
                let response = try await client.executeRaw(endpoint: endpoint)
                await onResult(request, .success(response))
            } catch {
                var mutableRequest = request
                mutableRequest.retryCount += 1
                mutableRequest.lastError = error.localizedDescription
                
                // Re-queue if retries available
                if mutableRequest.retryCount < 3 {
                    try? enqueue(mutableRequest)
                }
                
                await onResult(request, .failure(error))
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveToDisk() {
        guard let url = persistenceURL else { return }
        
        do {
            let data = try JSONEncoder().encode(queue)
            try data.write(to: url)
        } catch {
            // Log error
        }
    }
    
    private func loadFromDisk(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            queue = try JSONDecoder().decode([QueuedRequest].self, from: data)
            queue.removeAll { $0.isExpired }
        } catch {
            queue = []
        }
    }
}

// MARK: - Raw Endpoint

/// Endpoint created from URLRequest
private struct RawEndpoint: Endpoint {
    let request: URLRequest
    
    var baseURL: URL { request.url ?? URL(string: "invalid://")! }
    var path: String { "" }
    var method: HTTPMethod { HTTPMethod(rawValue: request.httpMethod ?? "GET") ?? .get }
    var headers: [String: String] { request.allHTTPHeaderFields ?? [:] }
    var queryParameters: [String: Any]? { nil }
    var body: RequestBody? {
        request.httpBody.map { .data($0) }
    }
    var timeoutInterval: TimeInterval? { request.timeoutInterval }
    var cachePolicy: CachePolicy { .noCache }
    var retryPolicy: RetryPolicy { .noRetry }
    var requiresAuthentication: Bool { false }
    var contentType: ContentType { .json }
    var acceptType: ContentType { .json }
    
    func asURLRequest() throws -> URLRequest { request }
}

// MARK: - Network Reachability

/// Monitor network connectivity
public actor NetworkReachability {
    public enum Status: Sendable {
        case unknown
        case notReachable
        case reachableViaWiFi
        case reachableViaCellular
    }
    
    private var currentStatus: Status = .unknown
    private var listeners: [UUID: @Sendable (Status) -> Void] = [:]
    
    public init() {}
    
    /// Current network status
    public var status: Status {
        currentStatus
    }
    
    /// Whether network is reachable
    public var isReachable: Bool {
        switch currentStatus {
        case .reachableViaWiFi, .reachableViaCellular:
            return true
        default:
            return false
        }
    }
    
    /// Add a listener for status changes
    public func addListener(_ listener: @escaping @Sendable (Status) -> Void) -> UUID {
        let id = UUID()
        listeners[id] = listener
        return id
    }
    
    /// Remove a listener
    public func removeListener(_ id: UUID) {
        listeners.removeValue(forKey: id)
    }
    
    /// Update status (called from system monitoring)
    public func updateStatus(_ status: Status) {
        guard status != currentStatus else { return }
        currentStatus = status
        
        for listener in listeners.values {
            listener(status)
        }
    }
}

// MARK: - Sync Manager

/// Manages synchronization between offline queue and server
public actor SyncManager {
    private let client: NetworkClient
    private let offlineQueue: OfflineQueue
    private let reachability: NetworkReachability
    private var isSyncing: Bool = false
    
    public init(
        client: NetworkClient,
        offlineQueue: OfflineQueue,
        reachability: NetworkReachability
    ) {
        self.client = client
        self.offlineQueue = offlineQueue
        self.reachability = reachability
    }
    
    /// Start automatic sync when network becomes available
    public func startAutoSync() {
        Task {
            let id = await reachability.addListener { [weak self] status in
                guard let self = self else { return }
                Task {
                    if status == .reachableViaWiFi || status == .reachableViaCellular {
                        await self.sync()
                    }
                }
            }
        }
    }
    
    /// Manually trigger sync
    public func sync() async {
        guard !isSyncing else { return }
        guard await reachability.isReachable else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        await offlineQueue.processQueue(using: client) { request, result in
            switch result {
            case .success:
                // Request succeeded
                break
            case .failure:
                // Handle failure
                break
            }
        }
    }
    
    /// Get sync status
    public var syncStatus: SyncStatus {
        SyncStatus(
            isSyncing: isSyncing,
            pendingCount: 0, // Would get from offlineQueue
            isOnline: true   // Would get from reachability
        )
    }
}

// MARK: - Sync Status

/// Current synchronization status
public struct SyncStatus: Sendable {
    public let isSyncing: Bool
    public let pendingCount: Int
    public let isOnline: Bool
    
    public var hasPendingItems: Bool {
        pendingCount > 0
    }
}
