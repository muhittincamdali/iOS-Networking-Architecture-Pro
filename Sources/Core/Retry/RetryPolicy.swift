// RetryPolicy.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import Foundation

/// Retry policy configuration
public struct RetryPolicy: Sendable {
    
    // MARK: - Properties
    
    /// Maximum number of retry attempts
    public let maxAttempts: Int
    
    /// Retry strategy
    public let strategy: RetryStrategy
    
    /// Errors that should trigger a retry
    public let retryableErrors: Set<RetryableError>
    
    /// HTTP status codes that should trigger a retry
    public let retryableStatusCodes: Set<Int>
    
    /// Whether to retry on timeout
    public let retryOnTimeout: Bool
    
    /// Whether to retry on connection errors
    public let retryOnConnectionError: Bool
    
    // MARK: - Initialization
    
    public init(
        maxAttempts: Int = 3,
        strategy: RetryStrategy = .exponential(base: 1.0, multiplier: 2.0),
        retryableErrors: Set<RetryableError> = [.timeout, .connectionError, .serverError],
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504],
        retryOnTimeout: Bool = true,
        retryOnConnectionError: Bool = true
    ) {
        self.maxAttempts = maxAttempts
        self.strategy = strategy
        self.retryableErrors = retryableErrors
        self.retryableStatusCodes = retryableStatusCodes
        self.retryOnTimeout = retryOnTimeout
        self.retryOnConnectionError = retryOnConnectionError
    }
    
    // MARK: - Presets
    
    /// Default retry policy
    public static let `default` = RetryPolicy()
    
    /// No retry
    public static let noRetry = RetryPolicy(maxAttempts: 0)
    
    /// Aggressive retry with more attempts
    public static let aggressive = RetryPolicy(
        maxAttempts: 5,
        strategy: .exponential(base: 0.5, multiplier: 2.0)
    )
    
    /// Conservative retry with longer delays
    public static let conservative = RetryPolicy(
        maxAttempts: 3,
        strategy: .exponential(base: 2.0, multiplier: 3.0)
    )
    
    /// Immediate retry without delay
    public static let immediate = RetryPolicy(
        maxAttempts: 3,
        strategy: .immediate
    )
    
    /// Fixed delay retry
    public static func fixed(delay: TimeInterval, attempts: Int = 3) -> RetryPolicy {
        RetryPolicy(maxAttempts: attempts, strategy: .constant(delay))
    }
    
    // MARK: - Retry Decision
    
    /// Determine if an error should trigger a retry
    public func shouldRetry(error: NetworkError, attempt: Int) -> Bool {
        guard attempt < maxAttempts else { return false }
        
        switch error {
        case .timeout:
            return retryOnTimeout
        case .noConnection, .connectionRefused, .connectionReset, .dnsLookupFailed:
            return retryOnConnectionError
        case .serverError(let code, _):
            return retryableStatusCodes.contains(code)
        case .rateLimited:
            return retryableStatusCodes.contains(429)
        default:
            return error.isRecoverable
        }
    }
    
    /// Determine if an HTTP status code should trigger a retry
    public func shouldRetry(statusCode: Int, attempt: Int) -> Bool {
        guard attempt < maxAttempts else { return false }
        return retryableStatusCodes.contains(statusCode)
    }
}

// MARK: - Retry Strategy

/// Strategy for calculating retry delays
public enum RetryStrategy: Sendable {
    /// No delay between retries
    case immediate
    
    /// Constant delay between retries
    case constant(TimeInterval)
    
    /// Exponential backoff
    case exponential(base: TimeInterval, multiplier: Double)
    
    /// Custom delay calculation
    case custom(@Sendable (Int) -> TimeInterval)
    
    /// Calculate delay for attempt
    public func delay(for attempt: Int) -> TimeInterval {
        switch self {
        case .immediate:
            return 0
        case .constant(let delay):
            return delay
        case .exponential(let base, let multiplier):
            return base * pow(multiplier, Double(attempt))
        case .custom(let calculator):
            return calculator(attempt)
        }
    }
}

// MARK: - Retryable Error

/// Types of errors that can trigger retries
public enum RetryableError: Hashable, Sendable {
    case timeout
    case connectionError
    case serverError
    case rateLimited
    case custom(String)
}

// MARK: - Retry Context

/// Context for tracking retry attempts
public struct RetryContext: Sendable {
    public let originalRequest: URLRequest
    public var currentAttempt: Int
    public var errors: [Error]
    public var startTime: Date
    
    public init(request: URLRequest) {
        self.originalRequest = request
        self.currentAttempt = 0
        self.errors = []
        self.startTime = Date()
    }
    
    /// Total elapsed time since first attempt
    public var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
    
    /// Record an error
    public mutating func recordError(_ error: Error) {
        errors.append(error)
        currentAttempt += 1
    }
}

// MARK: - Retry Interceptor

/// Interceptor that handles retry logic
public struct RetryInterceptor: Interceptor {
    private let policy: RetryPolicy
    private let maxDelay: TimeInterval
    
    public init(policy: RetryPolicy = .default, maxDelay: TimeInterval = 60) {
        self.policy = policy
        self.maxDelay = maxDelay
    }
    
    public func intercept(request: URLRequest, context: RequestContext) async throws -> URLRequest {
        // Could add retry-related headers here
        var mutableRequest = request
        mutableRequest.setValue("\(context.retryCount)", forHTTPHeaderField: "X-Retry-Count")
        return mutableRequest
    }
}

// MARK: - Jitter

/// Add jitter to retry delays to prevent thundering herd
public enum Jitter {
    /// No jitter
    case none
    
    /// Full jitter (0 to delay)
    case full
    
    /// Equal jitter (delay/2 to delay)
    case equal
    
    /// Decorrelated jitter
    case decorrelated
    
    /// Apply jitter to delay
    public func apply(to delay: TimeInterval) -> TimeInterval {
        switch self {
        case .none:
            return delay
        case .full:
            return Double.random(in: 0...delay)
        case .equal:
            return delay / 2 + Double.random(in: 0...(delay / 2))
        case .decorrelated:
            return Double.random(in: delay...(delay * 3))
        }
    }
}

// MARK: - Circuit Breaker Integration

/// Circuit breaker state for retry decisions
public enum CircuitState: Sendable {
    case closed      // Normal operation
    case open        // Failing, reject requests
    case halfOpen    // Testing if service recovered
}

/// Circuit breaker for preventing cascading failures
public actor CircuitBreaker {
    private var state: CircuitState = .closed
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    
    private let failureThreshold: Int
    private let resetTimeout: TimeInterval
    
    public init(failureThreshold: Int = 5, resetTimeout: TimeInterval = 30) {
        self.failureThreshold = failureThreshold
        self.resetTimeout = resetTimeout
    }
    
    /// Check if request should be allowed
    public func shouldAllow() -> Bool {
        switch state {
        case .closed:
            return true
        case .open:
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > resetTimeout {
                state = .halfOpen
                return true
            }
            return false
        case .halfOpen:
            return true
        }
    }
    
    /// Record a successful request
    public func recordSuccess() {
        failureCount = 0
        state = .closed
    }
    
    /// Record a failed request
    public func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()
        
        if failureCount >= failureThreshold {
            state = .open
        }
    }
    
    /// Current state
    public var currentState: CircuitState {
        state
    }
}
