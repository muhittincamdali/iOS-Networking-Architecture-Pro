import Foundation

/// What ``URLSessionTransport`` does when a server answers with a redirect.
public enum RedirectPolicy: Sendable, Hashable {
    /// Follows every redirect the way `URLSession` does by default. `URLSession` drops
    /// `Authorization` when the redirect leaves the origin, but forwards every other header,
    /// including API keys in custom headers.
    case follow

    /// Follows redirects, but removes credential headers when the redirect leaves the
    /// origin: every header whose name the default ``Redactor`` always hides, such as
    /// `X-API-Key`, `Cookie` or a name with `token`, `key` or `auth`, and every header whose
    /// value starts with an authentication scheme (`X-Upstream: Bearer …`) or that the
    /// free-text rule of ``Redactor/redact(text:)`` would cut. Refuses redirects from `https`
    /// to `http`. This is the default.
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
        case .followSafely:
            guard let from = original?.url, let to = redirect.url else { return redirect }
            if from.scheme?.lowercased() == "https", to.scheme?.lowercased() == "http" {
                return nil
            }
            guard !Self.sameOrigin(from, to) else { return redirect }
            var stripped = redirect
            for (name, value) in redirect.allHTTPHeaderFields ?? [:]
            where Redactor.default.carriesCredential(headerName: name, value: value) {
                stripped.setValue(nil, forHTTPHeaderField: name)
            }
            return stripped
        }
    }

    /// Scheme, host and port all equal, with default ports filled in.
    static func sameOrigin(_ first: URL, _ second: URL) -> Bool {
        func origin(_ url: URL) -> (String, String, Int) {
            let scheme = url.scheme?.lowercased() ?? ""
            let defaultPort = scheme == "https" || scheme == "wss" ? 443 : 80
            return (scheme, url.host?.lowercased() ?? "", url.port ?? defaultPort)
        }
        return origin(first) == origin(second)
    }
}
