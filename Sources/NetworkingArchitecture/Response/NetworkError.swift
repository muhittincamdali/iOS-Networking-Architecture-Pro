import Foundation

/// The errors that ``NetworkClient`` throws.
///
/// Every failure of a request ends as one of these cases, so a `catch` can tell an offline
/// device from a server error or a model that no longer matches the JSON:
///
/// ```swift
/// do {
///     let user = try await client.send(API.user(id: 42))
/// } catch NetworkError.unacceptableStatusCode(404, _) {
///     showNotFound()
/// } catch let error as NetworkError where error.isConnectivityProblem {
///     showOfflineBanner()
/// }
/// ```
public enum NetworkError: Error, Sendable {
    /// The endpoint could not be turned into a request: the URL is malformed, or a header
    /// name or value contains a line break.
    case invalidRequest(String)

    /// The request body could not be encoded.
    case encodingFailed(any Error)

    /// The request did not reach the server or no complete response came back.
    case transport(URLError)

    /// The server answered with a status code outside the endpoint's accepted range.
    case unacceptableStatusCode(Int, HTTPResponse<Data>)

    /// The response body could not be decoded into the endpoint's response type.
    case decodingFailed(any Error, HTTPResponse<Data>)

    /// The response body was larger than ``NetworkClient/Configuration/maximumResponseSize``.
    case responseTooLarge(limit: Int)

    /// A ``CircuitBreaker`` refused the request because the service failed repeatedly.
    /// The value is how long the breaker stays open.
    case circuitOpen(retryAfter: Duration)

    /// Refreshing the credentials failed; the underlying error is the refresh error.
    case authenticationFailed(any Error)

    /// The server sent something that is not an HTTP response.
    case invalidResponse

    /// More streamed messages or events than the limit were waiting to be read, because the
    /// code iterating the stream fell behind. The stream is closed instead of buffering
    /// without bound.
    case bufferOverflow(limit: Int)

    /// The task was cancelled.
    case cancelled

    /// The HTTP response that came with the error, if the server answered.
    public var response: HTTPResponse<Data>? {
        switch self {
        case .unacceptableStatusCode(_, let response), .decodingFailed(_, let response):
            response
        default:
            nil
        }
    }

    /// The status code of the response, if the server answered.
    public var statusCode: Int? { response?.statusCode }

    /// For an interrupted download, the data to continue it with
    /// ``NetworkClient/download(_:to:resumingFrom:progress:)``. `nil` when the server does not
    /// support resuming (it needs to send `Accept-Ranges` and an `ETag` or `Last-Modified`).
    public var resumeData: Data? {
        guard case .transport(let error) = self else { return nil }
        return error.downloadTaskResumeData
    }

    /// Whether the error means the device could not reach the server (offline, DNS failure,
    /// connection lost or timed out).
    public var isConnectivityProblem: Bool {
        guard case .transport(let error) = self else { return false }
        return Self.connectivityCodes.contains(error.code)
    }

    static let connectivityCodes: Set<URLError.Code> = [
        .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost,
        .dnsLookupFailed, .timedOut, .dataNotAllowed, .internationalRoamingOff
    ]

    /// Wraps any error thrown while performing a request.
    init(_ error: any Error) {
        switch error {
        case let error as NetworkError:
            self = error
        case is CancellationError:
            self = .cancelled
        case let error as URLError where error.code == .cancelled:
            self = .cancelled
        case let error as URLError:
            self = .transport(error)
        default:
            self = .transport(URLError(.unknown, userInfo: [NSUnderlyingErrorKey: error]))
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidRequest(let reason):
            "The request is invalid: \(reason)"
        case .encodingFailed(let error):
            "The request body could not be encoded: \(error.localizedDescription)"
        case .transport(let error):
            error.localizedDescription
        case .unacceptableStatusCode(let code, _):
            "The server answered with status \(code) (\(HTTPURLResponse.localizedString(forStatusCode: code)))."
        case .decodingFailed(let error, _):
            "The response could not be decoded: \(error)"
        case .responseTooLarge(let limit):
            "The response is larger than the limit of \(limit) bytes."
        case .circuitOpen(let duration):
            "Requests are paused after repeated failures; try again in \(duration)."
        case .authenticationFailed(let error):
            "Signing in again failed: \(error.localizedDescription)"
        case .invalidResponse:
            "The server sent a response that is not HTTP."
        case .bufferOverflow(let limit):
            "More than \(limit) received items were waiting to be read."
        case .cancelled:
            "The request was cancelled."
        }
    }
}
