import Foundation

extension NetworkClient {
    /// What to do with an adapted request before it is sent.
    enum Preparation<Payload: Sendable>: Sendable {
        /// Send this request (possibly with extra headers).
        case send(URLRequest)
        /// Do not send anything; answer with this response.
        case respond(HTTPResponse<Payload>)
    }

    /// The outcome of ``perform(_:endpoint:errorBody:extraAcceptedStatusCodes:prepare:attempt:)``.
    struct PerformResult<Payload: Sendable>: Sendable {
        /// The accepted response.
        let response: HTTPResponse<Payload>
        /// The request as it was sent the last time, after the interceptors adapted it.
        let request: URLRequest
    }

    /// Sends `request` until it succeeds or no interceptor and no retry policy wants another
    /// attempt, and never more than ``RetryPolicy/attemptLimit`` times.
    func perform<Payload: Sendable, Response>(
        _ request: URLRequest,
        endpoint: Endpoint<Response>,
        errorBody: (Payload) -> Data = { $0 as? Data ?? Data() },
        extraAcceptedStatusCodes: Set<Int> = [],
        prepare: ((URLRequest) async -> Preparation<Payload>)? = nil,
        attempt send: (URLRequest) async throws -> (Payload, HTTPURLResponse)
    ) async throws -> PerformResult<Payload> {
        let policy = endpoint.retryPolicy ?? configuration.retryPolicy
        let method = HTTPMethod(rawValue: request.httpMethod ?? "GET")
        var context = RequestContext(retryPolicy: policy)
        let clock = ContinuousClock()

        while true {
            guard !Task.isCancelled else { throw NetworkError.cancelled }
            var adapted = try await adapt(request, context: context)
            if let prepare {
                switch await prepare(adapted) {
                case .send(let prepared): adapted = prepared
                case .respond(let response): return PerformResult(response: response, request: adapted)
                }
            }
            notify(.willSend(adapted), context)
            let start = clock.now
            let failure: NetworkError
            do {
                let (payload, urlResponse) = try await send(adapted)
                let response = HTTPResponse(
                    value: payload,
                    statusCode: urlResponse.statusCode,
                    headers: HTTPHeaders(urlResponse),
                    url: urlResponse.url,
                    source: .network,
                    attempts: context.attempt
                )
                let accepted = endpoint.acceptableStatusCodes.contains(response.statusCode)
                    || extraAcceptedStatusCodes.contains(response.statusCode)
                let body = accepted ? (payload as? Data ?? Data()) : errorBody(payload)
                notify(.didReceive(adapted, response.map { _ in body }, duration: clock.now - start), context)
                await complete(adapted, .response(statusCode: response.statusCode), context)
                if accepted {
                    return PerformResult(response: response, request: adapted)
                }
                failure = .unacceptableStatusCode(response.statusCode, response.map { _ in body })
            } catch {
                let networkError = NetworkError(error)
                notify(.didFail(adapted, networkError, duration: clock.now - start), context)
                await complete(adapted, .failure(networkError), context)
                guard networkError.isRetryable else { throw networkError }
                failure = networkError
            }

            let delay = try await retryDelay(for: failure, request: adapted, method: method, context: &context)
            guard let delay else { throw failure }
            do {
                try await Task.sleep(for: delay)
            } catch {
                throw NetworkError.cancelled
            }
        }
    }

    private func adapt(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        var request = request
        for interceptor in configuration.interceptors {
            do {
                request = try await interceptor.adapt(request, context: context)
            } catch is CancellationError {
                throw NetworkError.cancelled
            }
        }
        return request
    }

    /// Asks the interceptors, then the retry policy, whether to retry. Returns the delay, or
    /// `nil` when the request should fail. Records the retry in `context`.
    private func retryDelay(
        for error: NetworkError,
        request: URLRequest,
        method: HTTPMethod,
        context: inout RequestContext
    ) async throws -> Duration? {
        guard context.attempt < RetryPolicy.attemptLimit else { return nil }
        var decision = RetryDecision.doNotRetry
        for interceptor in configuration.interceptors {
            decision = try await interceptor.retry(request, dueTo: error, context: context)
            if decision != .doNotRetry { break }
        }
        if decision == .doNotRetry {
            decision = context.retryPolicy.decision(for: error, method: method, attempt: context.attempt)
        }
        guard case .retry(let delay, let reason) = decision else { return nil }
        let wait = max(delay, .zero)
        notify(.willRetry(request, delay: wait, reason: reason), context)
        context.recordRetry(reason)
        return wait
    }

    private func notify(_ event: NetworkEvent, _ context: RequestContext) {
        for monitor in configuration.monitors {
            monitor.handle(event, context: context)
        }
    }

    private func complete(_ request: URLRequest, _ outcome: AttemptOutcome, _ context: RequestContext) async {
        for interceptor in configuration.interceptors {
            await interceptor.didComplete(request, outcome: outcome, context: context)
        }
    }
}

extension NetworkError {
    /// Errors that a retry cannot fix are thrown right away.
    var isRetryable: Bool {
        switch self {
        case .invalidRequest, .encodingFailed, .responseTooLarge, .cancelled, .authenticationFailed, .circuitOpen:
            false
        default:
            true
        }
    }
}
