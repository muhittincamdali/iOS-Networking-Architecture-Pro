// NetworkingArchitecture.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.
//
// Production-ready networking architecture with Clean Architecture pattern.

@_exported import Foundation

/// NetworkingArchitecture version
public let NetworkingArchitectureVersion = "2.0.0"

/// Primary namespace for the networking architecture framework
public enum NetworkingArchitecture {
    /// Framework configuration
    public static var configuration = NetworkingConfiguration.default
    
    /// Global interceptor chain
    public static var interceptors: [any Interceptor] = []
    
    /// Configure the framework globally
    /// - Parameter configuration: The configuration to apply
    public static func configure(_ configuration: NetworkingConfiguration) {
        self.configuration = configuration
    }
    
    /// Add a global interceptor
    /// - Parameter interceptor: The interceptor to add
    public static func addInterceptor(_ interceptor: any Interceptor) {
        interceptors.append(interceptor)
    }
    
    /// Remove all global interceptors
    public static func clearInterceptors() {
        interceptors.removeAll()
    }
}

// MARK: - Module Exports

// Re-export all core modules for convenience
@_exported import struct Foundation.URL
@_exported import struct Foundation.Data
@_exported import struct Foundation.URLRequest
@_exported import class Foundation.URLSession
@_exported import class Foundation.JSONEncoder
@_exported import class Foundation.JSONDecoder
