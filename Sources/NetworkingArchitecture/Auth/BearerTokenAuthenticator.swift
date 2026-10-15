import Foundation

/// An OAuth 2.0 style access token with an optional refresh token and expiry date.
public struct BearerToken: Sendable, Codable, Hashable {
    /// The token sent in the `Authorization: Bearer …` header.
    public var accessToken: String

    /// The token used to get a new access token, if the server issued one.
    public var refreshToken: String?

    /// When the access token stops being accepted, if known.
    public var expiresAt: Date?

    /// Creates a token.
    public init(accessToken: String, refreshToken: String? = nil, expiresAt: Date? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    /// Whether the token expires before `now + interval`. A token without an expiry date
    /// never does.
    public func expires(within interval: Duration, now: Date = Date()) -> Bool {
        guard let expiresAt else { return false }
        return expiresAt.timeIntervalSince(now) <= interval.timeInterval
    }
}

/// Adds a bearer token to requests and refreshes it when it expires or the server answers
/// `401 Unauthorized`.
///
/// ```swift
/// let authenticator = BearerTokenAuthenticator(
///     token: savedToken,
///     allowedHosts: ["api.example.com"]
/// ) { expired in
///     try await authClient.send(API.refresh(expired.refreshToken))
/// }
///
/// var configuration = NetworkClient.Configuration()
/// configuration.interceptors = [authenticator]
/// ```
///
/// - **One refresh at a time.** When many requests fail with 401 together, the first one
///   starts the refresh and the others wait for its result, so the refresh endpoint is called
///   once.
/// - **One retry per request.** A request is retried at most once after a refresh; if the
///   server still answers 401, the 401 is thrown instead of refreshing again and again.
/// - **Only to your hosts, only encrypted.** The token is only added to `https` (and `wss`)
///   requests for `allowedHosts`, so an absolute URL to another server (a CDN, a redirect
///   target in a response) never receives it, and neither does a plain `http` request that
///   an App Transport Security exception would let through.
/// - **Before it expires.** A token whose ``BearerToken/expiresAt`` falls within
///   `refreshLeeway` is refreshed before the request is sent.
///
/// When the refresh fails, the request throws ``NetworkError/authenticationFailed(_:)``.
/// That is the point to sign the user out with ``setToken(_:)``.
public actor BearerTokenAuthenticator: RequestInterceptor {
    /// Exchanges an expired or rejected token for a new one.
    public typealias Refresh = @Sendable (BearerToken) async throws -> BearerToken

    /// The error inside ``NetworkError/authenticationFailed(_:)`` when the token was removed
    /// with ``setToken(_:)`` while a refresh was running.
    public struct SignedOut: Error, Sendable {}

    private var token: BearerToken?
    private var refreshTask: Task<BearerToken, any Error>?
    private var generation = 0
    private let allowedHosts: [String]
    private let refreshLeeway: Duration
    private let onTokenChange: (@Sendable (BearerToken?) -> Void)?
    private let refresh: Refresh

    /// Creates an authenticator.
    ///
    /// - Parameters:
    ///   - token: The current token, or `nil` until the user signs in.
    ///   - allowedHosts: Hosts that receive the token, over `https` or `wss` only.
    ///     `"*.example.com"` also matches every subdomain of `example.com`. Hosts are compared
    ///     without regard to case.
    ///   - refreshLeeway: How long before ``BearerToken/expiresAt`` the token is refreshed.
    ///   - onTokenChange: Called after every refresh and ``setToken(_:)``, for saving the
    ///     token to the keychain.
    ///   - refresh: Returns a new token for an expired one.
    public init(
        token: BearerToken?,
        allowedHosts: Set<String>,
        refreshLeeway: Duration = .seconds(30),
        onTokenChange: (@Sendable (BearerToken?) -> Void)? = nil,
        refresh: @escaping Refresh
    ) {
        self.token = token
        self.allowedHosts = allowedHosts.map { $0.lowercased() }
        self.refreshLeeway = refreshLeeway
        self.onTokenChange = onTokenChange
        self.refresh = refresh
    }

    /// The token requests are currently sent with.
    public var currentToken: BearerToken? { token }

    /// Replaces the token, for example after signing in, or removes it with `nil` when
    /// signing out. A refresh that is still running when you call this does not overwrite
    /// the new value.
    public func setToken(_ newToken: BearerToken?) {
        generation += 1
        token = newToken
        refreshTask = nil
        onTokenChange?(newToken)
    }

    public func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        guard isAllowed(request), var current = token else { return request }
        if current.expires(within: refreshLeeway) {
            current = try await refreshed(from: current)
        }
        var request = request
        request.setValue("Bearer \(current.accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    public func retry(_ request: URLRequest, dueTo error: NetworkError, context: RequestContext) async throws -> RetryDecision {
        guard error.statusCode == 401,
              isAllowed(request),
              context.retryCount(for: .authentication) == 0,
              let current = token else {
            return .doNotRetry
        }
        // A request sent with an older token only needs the current one, not a new refresh.
        if request.value(forHTTPHeaderField: "Authorization") == "Bearer \(current.accessToken)" {
            _ = try await refreshed(from: current)
        }
        return .retry(after: .zero, reason: .authentication)
    }

    /// Returns a refreshed token, starting a refresh or joining the one that is running.
    private func refreshed(from stale: BearerToken) async throws -> BearerToken {
        if let refreshTask {
            return try await Self.value(of: refreshTask)
        }
        let startGeneration = generation
        let refresh = self.refresh
        let task = Task { try await refresh(stale) }
        refreshTask = task
        do {
            let fresh = try await Self.value(of: task)
            guard generation == startGeneration else {
                // setToken(_:) was called during the refresh; its value wins.
                guard let token else { throw NetworkError.authenticationFailed(SignedOut()) }
                return token
            }
            refreshTask = nil
            token = fresh
            onTokenChange?(fresh)
            return fresh
        } catch {
            if generation == startGeneration {
                refreshTask = nil
            }
            throw error
        }
    }

    private static func value(of task: Task<BearerToken, any Error>) async throws -> BearerToken {
        do {
            return try await task.value
        } catch {
            throw NetworkError.authenticationFailed(error)
        }
    }

    /// Schemes that encrypt the token on the wire.
    private static let secureSchemes: Set<String> = ["https", "wss"]

    private func isAllowed(_ request: URLRequest) -> Bool {
        guard let url = request.url,
              let scheme = url.scheme?.lowercased(), Self.secureSchemes.contains(scheme),
              let host = url.host?.lowercased() else { return false }
        return allowedHosts.contains { pattern in
            if pattern.hasPrefix("*.") {
                let domain = pattern.dropFirst(2)
                return host == domain || host.hasSuffix("." + domain)
            }
            return host == pattern
        }
    }
}
