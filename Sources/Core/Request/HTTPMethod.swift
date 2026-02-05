// HTTPMethod.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// HTTP methods supported by the framework
public enum HTTPMethod: String, Sendable, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
    
    /// Whether this method typically has a request body
    public var hasBody: Bool {
        switch self {
        case .post, .put, .patch:
            return true
        case .get, .delete, .head, .options, .trace, .connect:
            return false
        }
    }
    
    /// Whether this method is idempotent
    public var isIdempotent: Bool {
        switch self {
        case .get, .put, .delete, .head, .options, .trace:
            return true
        case .post, .patch, .connect:
            return false
        }
    }
    
    /// Whether this method is safe (doesn't modify resources)
    public var isSafe: Bool {
        switch self {
        case .get, .head, .options, .trace:
            return true
        case .post, .put, .patch, .delete, .connect:
            return false
        }
    }
    
    /// Whether this method is cacheable by default
    public var isCacheable: Bool {
        switch self {
        case .get, .head:
            return true
        default:
            return false
        }
    }
}
