import Foundation

/// What ``URLSessionTransport`` does when a server answers with a redirect.
///
/// An origin is a scheme, a host and a port, with the default port of `http`, `https`, `ws` and
/// `wss` filled in. Every policy but ``follow`` refuses a redirect whose `Location` holds a user
/// name or password, and a redirect from `https` to `http`.
public enum RedirectPolicy: Sendable, Hashable {
    /// Follows every redirect the way `URLSession` does by default. `URLSession` drops
    /// `Authorization` when the redirect leaves the origin, but forwards every other header,
    /// including API keys in custom headers, and the body of a `307` or `308` redirect.
    case follow

    /// Follows a redirect only when it stays on the origin of the request it answers; a redirect
    /// to another origin is not followed and the `3xx` response is returned to the caller, with its
    /// `Location` header. This is the default.
    case followSameOrigin

    /// Follows redirects to other origins too, but sends the request there without its body and
    /// without the headers that carry a credential: every header whose name the default
    /// ``Redactor`` always hides, such as `X-API-Key`, `Cookie` or a name with `token`, `key` or
    /// `auth`, and every header whose value starts with an authentication scheme
    /// (`X-Upstream: Bearer …`) or that the free-text rule of ``Redactor/redact(text:)`` would
    /// cut. The headers that describe the body (`Content-Type`, `Content-Length`,
    /// `Content-Encoding`) go with it. A redirect that stays on the origin keeps everything.
    case followSafely

    /// Never follows redirects; the `3xx` response is returned to the caller.
    case doNotFollow

    /// The request to send for a redirect from `original` to `redirect`, or `nil` to stop and
    /// return the redirect response.
    func request(redirecting original: URLRequest?, to redirect: URLRequest) -> URLRequest? {
        switch self {
        case .follow:
            return redirect
        case .doNotFollow:
            return nil
        case .followSameOrigin, .followSafely:
            guard let to = redirect.url, to.user == nil, to.password == nil else { return nil }
            guard let from = original?.url else { return self == .followSafely ? Self.withoutCredentials(redirect) : nil }
            if from.scheme?.lowercased() == "https", to.scheme?.lowercased() == "http" { return nil }
            if Self.sameOrigin(from, to) { return redirect }
            return self == .followSafely ? Self.withoutCredentials(redirect) : nil
        }
    }

    /// The headers that describe a body, removed with it.
    private static let bodyHeaders = ["Content-Type", "Content-Length", "Content-Encoding"]

    /// The redirect without its body and without the headers that carry a credential.
    private static func withoutCredentials(_ redirect: URLRequest) -> URLRequest {
        var stripped = redirect
        for (name, value) in redirect.allHTTPHeaderFields ?? [:] where Redactor.default.carriesCredential(headerName: name, value: value) {
            stripped.setValue(nil, forHTTPHeaderField: name)
        }
        if stripped.httpBody != nil || stripped.httpBodyStream != nil {
            stripped.httpBody = nil
            stripped.httpBodyStream = nil
            for name in bodyHeaders { stripped.setValue(nil, forHTTPHeaderField: name) }
        }
        return stripped
    }

    /// Scheme, host and port all equal, with default ports filled in.
    static func sameOrigin(_ first: URL, _ second: URL) -> Bool {
        func origin(_ url: URL) -> (String, String, Int?) {
            let scheme = url.scheme?.lowercased() ?? ""
            return (scheme, url.host?.lowercased() ?? "", url.port ?? defaultPorts[scheme])
        }
        return origin(first) == origin(second)
    }

    private static let defaultPorts = ["http": 80, "ws": 80, "https": 443, "wss": 443]
}
