import Foundation
import Testing
@testable import NetworkingArchitecture

@Suite("Retry policy")
struct RetryPolicyTests {
    private func statusError(_ code: Int, headers: HTTPHeaders = [:]) -> NetworkError {
        .unacceptableStatusCode(code, HTTPResponse(value: Data(), statusCode: code, headers: headers))
    }

    private let middle: () -> Double = { 0.5 }

    @Test func delaysGrowExponentiallyAndStopAtTheMaximum() {
        let policy = RetryPolicy(baseDelay: .seconds(1), maximumDelay: .seconds(5), multiplier: 2, jitter: 0)
        #expect(policy.delay(forRetry: 1, random: middle) == .seconds(1))
        #expect(policy.delay(forRetry: 2, random: middle) == .seconds(2))
        #expect(policy.delay(forRetry: 3, random: middle) == .seconds(4))
        #expect(policy.delay(forRetry: 4, random: middle) == .seconds(5))
        #expect(policy.delay(forRetry: 1_000, random: middle) == .seconds(5))
        #expect(policy.delay(forRetry: .max, random: middle) == .seconds(5))
        #expect(policy.delay(forRetry: 0, random: middle) == .seconds(1))
        #expect(policy.delay(forRetry: .min, random: middle) == .seconds(1))
    }

    @Test func jitterStaysWithinItsShare() {
        let policy = RetryPolicy(baseDelay: .seconds(10), maximumDelay: .seconds(60), jitter: 0.2)
        #expect(policy.delay(forRetry: 1) { 0 } == .seconds(8))
        #expect(policy.delay(forRetry: 1) { 1 } == .seconds(12))
    }

    @Test("Non-finite and out-of-range settings do not trap", arguments: [
        Double.nan, .infinity, -.infinity, -3, 0
    ])
    func survivesBadNumbers(value: Double) {
        let policy = RetryPolicy(baseDelay: .seconds(1), maximumDelay: .seconds(30), multiplier: value, jitter: value)
        let delay = policy.delay(forRetry: 3) { value }
        #expect(delay >= .zero)
        #expect(delay <= .seconds(30))
    }

    @Test func negativeBaseDelayBecomesZero() {
        let policy = RetryPolicy(baseDelay: .seconds(-5), jitter: 0)
        #expect(policy.delay(forRetry: 1, random: middle) == .zero)
    }

    @Test("Attempts are clamped to 1...10", arguments: [(Int.min, 1), (0, 1), (4, 4), (11, 10), (Int.max, 10)])
    func clampsAttempts(requested: Int, expected: Int) {
        var policy = RetryPolicy(maximumAttempts: requested)
        #expect(policy.maximumAttempts == expected)
        policy.maximumAttempts = requested
        #expect(policy.maximumAttempts == expected)
    }

    @Test func retriesTransientStatusCodesUntilTheLastAttempt() {
        let policy = RetryPolicy(maximumAttempts: 3)
        #expect(policy.decision(for: statusError(503), method: .get, attempt: 1, random: middle) != .doNotRetry)
        #expect(policy.decision(for: statusError(503), method: .get, attempt: 2, random: middle) != .doNotRetry)
        #expect(policy.decision(for: statusError(503), method: .get, attempt: 3, random: middle) == .doNotRetry)
    }

    @Test("Client errors are not retried", arguments: [400, 401, 403, 404, 422])
    func doesNotRetryClientErrors(code: Int) {
        #expect(RetryPolicy.default.decision(for: statusError(code), method: .get, attempt: 1) == .doNotRetry)
    }

    @Test func doesNotRetryPostUnlessAllowed() {
        var policy = RetryPolicy.default
        #expect(policy.decision(for: statusError(503), method: .post, attempt: 1) == .doNotRetry)
        policy.retriesNonIdempotentRequests = true
        #expect(policy.decision(for: statusError(503), method: .post, attempt: 1) != .doNotRetry)
    }

    @Test func retriesConnectivityErrorsButNotOthers() {
        let policy = RetryPolicy.default
        #expect(policy.decision(for: .transport(URLError(.timedOut)), method: .get, attempt: 1) != .doNotRetry)
        #expect(policy.decision(for: .transport(URLError(.badServerResponse)), method: .get, attempt: 1) == .doNotRetry)
        #expect(policy.decision(for: .cancelled, method: .get, attempt: 1) == .doNotRetry)
    }

    @Test func retryAfterSecondsReplacesTheBackoff() {
        let decision = RetryPolicy.default.decision(for: statusError(429, headers: ["Retry-After": "7"]), method: .get, attempt: 1)
        #expect(decision == .retry(after: .seconds(7), reason: .transientFailure))
    }

    @Test func retryAfterLongerThanTheLimitStopsRetrying() {
        let error = statusError(503, headers: ["Retry-After": "3600"])
        #expect(RetryPolicy.default.decision(for: error, method: .get, attempt: 1) == .doNotRetry)
    }

    @Test("Retry-After numbers too large for Int do not trap", arguments: [
        "99999999999999999999999999", "9223372036854775807", "9223372036854775808"
    ])
    func hugeRetryAfter(value: String) {
        #expect(RetryAfter.delay(value) != nil)
        let error = statusError(503, headers: ["Retry-After": value])
        #expect(RetryPolicy.default.decision(for: error, method: .get, attempt: 1) == .doNotRetry)
    }

    @Test func retryAfterHTTPDate() {
        let now = Date(timeIntervalSince1970: 1_445_412_480) // Wed, 21 Oct 2015 07:28:00 GMT
        #expect(RetryAfter.delay("Wed, 21 Oct 2015 07:28:30 GMT", now: now) == .seconds(30))
        #expect(RetryAfter.delay("Wed, 21 Oct 2015 07:00:00 GMT", now: now) == .zero)
    }

    @Test("Malformed Retry-After falls back to the backoff", arguments: ["-5", "soon", "", "1.5", " 12abc"])
    func malformedRetryAfter(value: String) {
        let policy = RetryPolicy(baseDelay: .seconds(1), jitter: 0)
        let decision = policy.decision(for: statusError(503, headers: ["Retry-After": value]), method: .get, attempt: 1)
        #expect(decision == .retry(after: .seconds(1), reason: .transientFailure))
    }

    @Test func noneNeverRetries() {
        #expect(RetryPolicy.none.decision(for: statusError(503), method: .get, attempt: 1) == .doNotRetry)
    }
}
