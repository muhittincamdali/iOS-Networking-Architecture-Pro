// Repository.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Protocol for data repository pattern
public protocol Repository: Actor {
    associatedtype Entity: Codable & Sendable & Identifiable
    associatedtype ID: Hashable & Sendable
    
    /// Fetch entity by ID
    func get(id: ID) async throws -> Entity?
    
    /// Fetch all entities
    func getAll() async throws -> [Entity]
    
    /// Create new entity
    func create(_ entity: Entity) async throws -> Entity
    
    /// Update existing entity
    func update(_ entity: Entity) async throws -> Entity
    
    /// Delete entity by ID
    func delete(id: ID) async throws
    
    /// Fetch with pagination
    func getPage(page: Int, pageSize: Int) async throws -> PaginatedResponse<Entity>
    
    /// Refresh from remote
    func refresh() async throws
}

// MARK: - Network Repository

/// Base repository implementation with network client
public actor NetworkRepository<Entity: Codable & Sendable & Identifiable>: Repository where Entity.ID: Hashable & Sendable {
    public typealias ID = Entity.ID
    
    private let client: NetworkClient
    private let baseEndpoint: String
    private let cache: any NetworkCache
    private var localCache: [ID: Entity] = [:]
    
    public init(
        client: NetworkClient,
        baseEndpoint: String,
        cache: (any NetworkCache)? = nil
    ) {
        self.client = client
        self.baseEndpoint = baseEndpoint
        self.cache = cache ?? InMemoryCache(maxSize: 10 * 1024 * 1024)
    }
    
    public func get(id: ID) async throws -> Entity? {
        // Check local cache first
        if let cached = localCache[id] {
            return cached
        }
        
        let endpoint = GenericEndpoint<Entity>(
            baseURL: URL(string: baseEndpoint)!,
            path: "/\(id)",
            method: .get
        )
        
        let response = try await client.execute(Request(endpoint: endpoint))
        localCache[id] = response.data
        return response.data
    }
    
    public func getAll() async throws -> [Entity] {
        let endpoint = GenericEndpoint<[Entity]>(
            baseURL: URL(string: baseEndpoint)!,
            path: "",
            method: .get
        )
        
        let response = try await client.execute(Request(endpoint: endpoint))
        
        // Update local cache
        for entity in response.data {
            localCache[entity.id as! ID] = entity
        }
        
        return response.data
    }
    
    public func create(_ entity: Entity) async throws -> Entity {
        let endpoint = GenericEndpoint<Entity>(
            baseURL: URL(string: baseEndpoint)!,
            path: "",
            method: .post,
            body: .json(entity)
        )
        
        let response = try await client.execute(Request(endpoint: endpoint))
        localCache[response.data.id as! ID] = response.data
        return response.data
    }
    
    public func update(_ entity: Entity) async throws -> Entity {
        let endpoint = GenericEndpoint<Entity>(
            baseURL: URL(string: baseEndpoint)!,
            path: "/\(entity.id)",
            method: .put,
            body: .json(entity)
        )
        
        let response = try await client.execute(Request(endpoint: endpoint))
        localCache[response.data.id as! ID] = response.data
        return response.data
    }
    
    public func delete(id: ID) async throws {
        let endpoint = GenericEndpoint<EmptyResponse>(
            baseURL: URL(string: baseEndpoint)!,
            path: "/\(id)",
            method: .delete
        )
        
        _ = try await client.execute(Request(endpoint: endpoint))
        localCache.removeValue(forKey: id)
    }
    
    public func getPage(page: Int, pageSize: Int) async throws -> PaginatedResponse<Entity> {
        let endpoint = GenericEndpoint<PaginatedResponse<Entity>>(
            baseURL: URL(string: baseEndpoint)!,
            path: "",
            method: .get,
            queryParameters: ["page": page, "page_size": pageSize]
        )
        
        let response = try await client.execute(Request(endpoint: endpoint))
        
        // Update local cache
        for entity in response.data.items {
            localCache[entity.id as! ID] = entity
        }
        
        return response.data
    }
    
    public func refresh() async throws {
        localCache.removeAll()
        _ = try await getAll()
    }
    
    /// Clear local cache
    public func clearCache() {
        localCache.removeAll()
    }
    
    /// Get cached entities
    public func getCached() -> [Entity] {
        Array(localCache.values)
    }
}

// MARK: - Generic Endpoint

/// Generic endpoint implementation
public struct GenericEndpoint<Response>: Endpoint {
    public let baseURL: URL
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let queryParameters: [String: Any]?
    public let body: RequestBody?
    public let timeoutInterval: TimeInterval?
    public let cachePolicy: CachePolicy
    public let retryPolicy: RetryPolicy
    public let requiresAuthentication: Bool
    public let contentType: ContentType
    public let acceptType: ContentType
    
    public init(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryParameters: [String: Any]? = nil,
        body: RequestBody? = nil,
        timeoutInterval: TimeInterval? = nil,
        cachePolicy: CachePolicy = .default,
        retryPolicy: RetryPolicy = .default,
        requiresAuthentication: Bool = false,
        contentType: ContentType = .json,
        acceptType: ContentType = .json
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.retryPolicy = retryPolicy
        self.requiresAuthentication = requiresAuthentication
        self.contentType = contentType
        self.acceptType = acceptType
    }
}

// MARK: - Cached Repository

/// Repository with offline-first caching
public actor CachedRepository<Entity: Codable & Sendable & Identifiable>: Repository where Entity.ID: Hashable & Sendable {
    public typealias ID = Entity.ID
    
    private let networkRepository: NetworkRepository<Entity>
    private let localStorage: any LocalStorage<Entity>
    private let syncPolicy: SyncPolicy
    
    public init(
        networkRepository: NetworkRepository<Entity>,
        localStorage: any LocalStorage<Entity>,
        syncPolicy: SyncPolicy = .default
    ) {
        self.networkRepository = networkRepository
        self.localStorage = localStorage
        self.syncPolicy = syncPolicy
    }
    
    public func get(id: ID) async throws -> Entity? {
        // Try local first
        if let local = try await localStorage.get(id: id) {
            // Optionally refresh in background
            if syncPolicy.refreshOnRead {
                Task {
                    try? await refreshEntity(id: id)
                }
            }
            return local
        }
        
        // Fetch from network
        if let remote = try await networkRepository.get(id: id) {
            try await localStorage.save(remote)
            return remote
        }
        
        return nil
    }
    
    public func getAll() async throws -> [Entity] {
        // Get local
        let local = try await localStorage.getAll()
        
        // Refresh from network in background
        if syncPolicy.refreshOnRead {
            Task {
                try? await refresh()
            }
        }
        
        return local.isEmpty ? try await networkRepository.getAll() : local
    }
    
    public func create(_ entity: Entity) async throws -> Entity {
        // Save locally first
        try await localStorage.save(entity)
        
        // Then sync to network
        do {
            let remote = try await networkRepository.create(entity)
            try await localStorage.save(remote)
            return remote
        } catch {
            // Queue for later sync if offline
            await queueForSync(.create(entity))
            return entity
        }
    }
    
    public func update(_ entity: Entity) async throws -> Entity {
        // Update locally first
        try await localStorage.save(entity)
        
        // Then sync to network
        do {
            let remote = try await networkRepository.update(entity)
            try await localStorage.save(remote)
            return remote
        } catch {
            await queueForSync(.update(entity))
            return entity
        }
    }
    
    public func delete(id: ID) async throws {
        try await localStorage.delete(id: id)
        
        do {
            try await networkRepository.delete(id: id)
        } catch {
            await queueForSync(.delete(id))
        }
    }
    
    public func getPage(page: Int, pageSize: Int) async throws -> PaginatedResponse<Entity> {
        try await networkRepository.getPage(page: page, pageSize: pageSize)
    }
    
    public func refresh() async throws {
        let remote = try await networkRepository.getAll()
        for entity in remote {
            try await localStorage.save(entity)
        }
    }
    
    private func refreshEntity(id: ID) async throws {
        if let remote = try await networkRepository.get(id: id) {
            try await localStorage.save(remote)
        }
    }
    
    private func queueForSync(_ operation: SyncOperation<Entity>) async {
        // Queue operation for later sync
    }
}

// MARK: - Local Storage Protocol

/// Protocol for local storage implementations
public protocol LocalStorage<Entity>: Actor where Entity: Codable & Sendable & Identifiable {
    associatedtype Entity
    
    func get(id: Entity.ID) async throws -> Entity?
    func getAll() async throws -> [Entity]
    func save(_ entity: Entity) async throws
    func delete(id: Entity.ID) async throws
    func clear() async throws
}

// MARK: - Sync Operation

/// Operation to sync
public enum SyncOperation<Entity: Codable & Sendable & Identifiable>: Sendable {
    case create(Entity)
    case update(Entity)
    case delete(Entity.ID)
}

// MARK: - Sync Policy

/// Policy for synchronization
public struct SyncPolicy: Sendable {
    public let refreshOnRead: Bool
    public let syncInterval: TimeInterval?
    public let conflictResolution: ConflictResolution
    
    public init(
        refreshOnRead: Bool = true,
        syncInterval: TimeInterval? = nil,
        conflictResolution: ConflictResolution = .serverWins
    ) {
        self.refreshOnRead = refreshOnRead
        self.syncInterval = syncInterval
        self.conflictResolution = conflictResolution
    }
    
    public static let `default` = SyncPolicy()
    public static let offlineFirst = SyncPolicy(refreshOnRead: false)
    public static let networkFirst = SyncPolicy(refreshOnRead: true, syncInterval: 60)
}

// MARK: - Conflict Resolution

/// Strategy for resolving sync conflicts
public enum ConflictResolution: Sendable {
    case serverWins
    case clientWins
    case lastWriteWins
    case merge(@Sendable (Any, Any) -> Any)
}
