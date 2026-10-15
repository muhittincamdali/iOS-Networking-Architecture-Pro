import Foundation

extension NetworkClient {
    /// Sends a `GET` or `HEAD` request through the cache, following the endpoint's
    /// ``CachePolicy``. Returns the undecoded body.
    func cachedResponse<Response>(
        for request: URLRequest,
        endpoint: Endpoint<Response>,
        cache: any ResponseCache
    ) async throws -> HTTPResponse<Data> {
        let policy = endpoint.cachePolicy
        // The key depends on the adapted request (it includes the Authorization header), so it
        // is computed in `prepare`, after the interceptors ran.
        let lookup = Locked<(key: String, entry: CachedResponse?)?>(nil)
        let prepare: (URLRequest) async -> Preparation<Data> = { adapted in
            let key = CacheKey.make(for: adapted)
            let entry = await cache.cachedResponse(for: key)
            lookup.withLock { $0 = (key, entry) }
            guard let entry else { return .send(adapted) }
            switch policy {
            case .cacheFirst(let maxAge) where entry.age() < maxAge:
                return .respond(entry.httpResponse)
            case .revalidate:
                return .send(Self.addingValidators(of: entry, to: adapted))
            default:
                return .send(adapted)
            }
        }

        let result: PerformResult<Data>
        do {
            result = try await perform(
                request,
                endpoint: endpoint,
                extraAcceptedStatusCodes: policy == .revalidate ? [304] : [],
                prepare: prepare
            ) { request in
                try await self.transport.send(request, maximumResponseSize: self.configuration.maximumResponseSize)
            }
        } catch let error as NetworkError {
            guard case .networkFirst(let maxStale) = policy,
                  error.isConnectivityProblem || (error.statusCode ?? 0) >= 500,
                  let entry = lookup.withLock({ $0?.entry }),
                  entry.age() <= maxStale else {
                throw error
            }
            return entry.httpResponse.with(source: .staleCache, attempts: error.response?.attempts ?? 1)
        }

        let response = result.response
        guard response.source == .network, let key = lookup.withLock({ $0?.key }) else { return response }
        let entry = lookup.withLock { $0?.entry }

        if response.statusCode == 304 {
            guard var entry else {
                throw NetworkError.unacceptableStatusCode(304, response)
            }
            entry.storedAt = Date()
            entry.headers.merge(Self.revalidationHeaders(of: response))
            await cache.store(entry, for: key)
            return entry.httpResponse.with(source: .revalidatedCache, attempts: response.attempts)
        }
        if Self.isStorable(response) {
            let stored = CachedResponse(data: response.value, statusCode: response.statusCode, headers: response.headers, url: response.url)
            await cache.store(stored, for: key)
        }
        return response
    }

    private static func addingValidators(of entry: CachedResponse, to request: URLRequest) -> URLRequest {
        var request = request
        if let tag = entry.entityTag, request.value(forHTTPHeaderField: "If-None-Match") == nil {
            request.setValue(tag, forHTTPHeaderField: "If-None-Match")
        }
        if let date = entry.lastModified, request.value(forHTTPHeaderField: "If-Modified-Since") == nil {
            request.setValue(date, forHTTPHeaderField: "If-Modified-Since")
        }
        return request
    }

    /// The headers a 304 may update on the stored response (RFC 9111, section 4.3.4).
    private static func revalidationHeaders(of response: HTTPResponse<Data>) -> HTTPHeaders {
        var headers = HTTPHeaders()
        for name in ["ETag", "Last-Modified", "Cache-Control", "Expires", "Date"] {
            if let value = response.headers[name] {
                headers[name] = value
            }
        }
        return headers
    }

    /// Only successful responses without `Cache-Control: no-store` are stored.
    static func isStorable(_ response: HTTPResponse<Data>) -> Bool {
        guard (200..<300).contains(response.statusCode) else { return false }
        let directives = (response.headers["Cache-Control"] ?? "")
            .lowercased()
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        return !directives.contains("no-store")
    }
}
