import Foundation

/// A `URLSession` delegate that answers server trust challenges with ``PublicKeyPinning``.
///
/// ``URLSessionTransport/init(configuration:pinning:)`` creates a session with this delegate
/// for you. Use the delegate directly when you build the `URLSession` yourself.
///
/// When a server is rejected the connection is cancelled, and a request sent through
/// ``URLSessionTransport`` fails with ``NetworkError/transport(_:)`` and the code
/// `URLError.serverCertificateUntrusted`, whose description gives the reason.
public final class PinningSessionDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    /// The pins to enforce.
    public let pinning: PublicKeyPinning

    private let onRejection: (@Sendable (_ host: String, _ reason: String) -> Void)?
    private let rejections = Locked<[Int: String]>([:])

    /// Creates a delegate.
    ///
    /// - Parameter onRejection: Called with the host and the reason whenever a server is
    ///   rejected, for logging or reporting.
    public init(pinning: PublicKeyPinning, onRejection: (@Sendable (_ host: String, _ reason: String) -> Void)? = nil) {
        self.pinning = pinning
        self.onRejection = onRejection
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let (disposition, credential, reason) = handle(challenge)
        if let reason {
            rejections.withLock { rejections in
                // Bounded: with a session that is not used through URLSessionTransport, nobody
                // takes the reasons out.
                if rejections.count >= 64 { rejections.removeAll() }
                rejections[task.taskIdentifier] = reason
            }
        }
        completionHandler(disposition, credential)
    }

    /// Returns and forgets why the server of `task` was rejected, if it was.
    func takeRejection(for task: URLSessionTask) -> String? {
        rejections.withLock { $0.removeValue(forKey: task.taskIdentifier) }
    }

    /// Decides how to answer `challenge`; the third value is the reason for a rejection.
    func handle(_ challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?, String?) {
        let space = challenge.protectionSpace
        guard space.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = space.serverTrust else {
            return (.performDefaultHandling, nil, nil)
        }
        switch pinning.evaluate(trust, host: space.host) {
        case .notPinned:
            return (.performDefaultHandling, nil, nil)
        case .trusted:
            return (.useCredential, URLCredential(trust: trust), nil)
        case .rejected(let reason):
            onRejection?(space.host, reason)
            return (.cancelAuthenticationChallenge, nil, "\(space.host): \(reason)")
        }
    }
}

extension URLSessionTransport {
    /// Creates a transport whose session enforces `pinning`.
    ///
    /// The session keeps a strong reference to its delegate until it is invalidated; create
    /// one transport per pin set and keep it for the life of the app.
    public init(
        configuration: URLSessionConfiguration = .default,
        pinning: PublicKeyPinning,
        redirectPolicy: RedirectPolicy = .followSafely
    ) {
        let delegate = PinningSessionDelegate(pinning: pinning)
        self.init(
            session: URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil),
            redirectPolicy: redirectPolicy
        )
    }
}
