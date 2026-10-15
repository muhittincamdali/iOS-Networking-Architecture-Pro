import Foundation
import Security
import Testing
@testable import NetworkingArchitecture

/// A protection space that hands out a prepared trust, so the delegate can be tested without
/// a TLS handshake.
private final class TrustProtectionSpace: URLProtectionSpace, @unchecked Sendable {
    private let trust: SecTrust?

    init(host: String, trust: SecTrust?, method: String = NSURLAuthenticationMethodServerTrust) {
        self.trust = trust
        super.init(host: host, port: 443, protocol: "https", realm: nil, authenticationMethod: method)
    }

    required init?(coder: NSCoder) { nil }

    override var serverTrust: SecTrust? { trust }
}

private final class IgnoringSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}

@Suite("Public key pinning")
struct PublicKeyPinningTests {
    /// Inside the validity of the test certificates (October 2026 to October 2027), fixed so
    /// the tests do not expire with them.
    private let verifyDate = Date(timeIntervalSince1970: 1_796_083_200) // 2026-12-01

    /// A trust for the leaf and CA, anchored at the test CA when `anchored` is true.
    private func trust(host: String = "pinned.test", anchored: Bool = true) throws -> SecTrust {
        let leaf = PinningFixtures.certificate(PinningFixtures.leafDER)
        let ca = PinningFixtures.certificate(PinningFixtures.caDER)
        var trust: SecTrust?
        let status = SecTrustCreateWithCertificates([leaf, ca] as CFArray, SecPolicyCreateSSL(true, host as CFString), &trust)
        let created = try #require(trust)
        #expect(status == errSecSuccess)
        if anchored {
            SecTrustSetAnchorCertificates(created, [ca] as CFArray)
            SecTrustSetAnchorCertificatesOnly(created, true)
        }
        SecTrustSetNetworkFetchAllowed(created, false)
        SecTrustSetVerifyDate(created, verifyDate as CFDate)
        return created
    }

    @Test("Hashes match OpenSSL for RSA and elliptic curve keys", arguments: [
        (PinningFixtures.caDER, PinningFixtures.caPin),
        (PinningFixtures.leafDER, PinningFixtures.leafPin),
        (PinningFixtures.p384DER, PinningFixtures.p384Pin),
        (PinningFixtures.rsa3072DER, PinningFixtures.rsa3072Pin)
    ])
    func hashesMatchOpenSSL(der: Data, pin: String) {
        #expect(PublicKeyPinning.publicKeyHash(of: PinningFixtures.certificate(der)) == pin)
    }

    @Test func pinnedLeafOrCAKeyIsTrusted() throws {
        for pin in [PinningFixtures.leafPin, PinningFixtures.caPin, "sha256/" + PinningFixtures.leafPin] {
            let pinning = PublicKeyPinning(pins: ["pinned.test": [pin, "backup-pin="]])
            #expect(pinning.evaluate(try trust(), host: "pinned.test") == .trusted)
        }
    }

    @Test func unpinnedKeyIsRejected() throws {
        let pinning = PublicKeyPinning(pins: ["pinned.test": [PinningFixtures.p384Pin]])
        guard case .rejected = pinning.evaluate(try trust(), host: "pinned.test") else {
            Issue.record("Expected rejection")
            return
        }
    }

    @Test func aPinDoesNotOverrideSystemValidation() throws {
        let pinning = PublicKeyPinning(pins: ["pinned.test": [PinningFixtures.leafPin]])
        guard case .rejected = pinning.evaluate(try trust(anchored: false), host: "pinned.test") else {
            Issue.record("An untrusted chain must be rejected even when its key is pinned")
            return
        }
    }

    @Test func hostNameMustMatchTheCertificate() throws {
        let pinning = PublicKeyPinning(pins: ["other.test": [PinningFixtures.leafPin]])
        guard case .rejected = pinning.evaluate(try trust(host: "other.test"), host: "other.test") else {
            Issue.record("A certificate for pinned.test must not be accepted for other.test")
            return
        }
    }

    @Test func hostsWithoutPinsAreLeftToTheSystem() throws {
        let pinning = PublicKeyPinning(pins: ["pinned.test": [PinningFixtures.leafPin]])
        #expect(pinning.evaluate(try trust(), host: "unrelated.test") == .notPinned)
    }

    @Test func subdomainsUseTheMostSpecificPins() {
        let pinning = PublicKeyPinning(
            pins: ["pinned.test": ["parent="], "api.pinned.test": ["child="], "PINNED.test": ["upper="]],
            includesSubdomains: true
        )
        #expect(pinning.pins(for: "API.pinned.test") == ["child="])
        #expect(pinning.pins(for: "cdn.pinned.test") == ["parent=", "upper="])
        #expect(pinning.pins(for: "evilpinned.test") == nil)
        #expect(PublicKeyPinning(pins: ["pinned.test": ["p="]]).pins(for: "cdn.pinned.test") == nil)
    }

    @Test func delegateAcceptsRejectsOrDefers() throws {
        let delegate = PinningSessionDelegate(pinning: PublicKeyPinning(pins: ["pinned.test": [PinningFixtures.leafPin]]))
        func answer(_ space: URLProtectionSpace) -> URLSession.AuthChallengeDisposition {
            let challenge = URLAuthenticationChallenge(
                protectionSpace: space, proposedCredential: nil, previousFailureCount: 0,
                failureResponse: nil, error: nil, sender: IgnoringSender()
            )
            return delegate.handle(challenge).0
        }
        #expect(answer(TrustProtectionSpace(host: "pinned.test", trust: try trust())) == .useCredential)
        #expect(answer(TrustProtectionSpace(host: "pinned.test", trust: try trust(anchored: false))) == .cancelAuthenticationChallenge)
        #expect(answer(TrustProtectionSpace(host: "other.test", trust: try trust())) == .performDefaultHandling)
        #expect(answer(TrustProtectionSpace(host: "pinned.test", trust: nil, method: NSURLAuthenticationMethodHTTPBasic)) == .performDefaultHandling)
    }

    @Test func rejectedServerFailsTheRequestAsUntrusted() async throws {
        let identity = try Self.leafIdentity()
        let server = try await LocalHTTPServer(identity: identity) { _ in .body(Data("secret".utf8)) }
        let rejections = EventLog()
        let delegate = PinningSessionDelegate(pinning: PublicKeyPinning(pins: ["127.0.0.1": [PinningFixtures.leafPin]])) { host, _ in
            rejections.append(host)
        }
        let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        let client = NetworkClient(configuration: .init(retryPolicy: .none), transport: URLSessionTransport(session: session))
        let error = await #expect(throws: NetworkError.self) {
            try await client.send(Endpoint<Data>.get(server.url("/").absoluteString))
        }
        guard case .transport(let urlError)? = error else {
            Issue.record("Expected a transport error, got \(String(describing: error))")
            return
        }
        #expect(urlError.code == .serverCertificateUntrusted)
        #expect(urlError.localizedDescription.contains("certificate pinning"))
        #expect(rejections.all == ["127.0.0.1"])
    }

    static func leafIdentity() throws -> SecIdentity {
        var options: [String: Any] = [kSecImportExportPassphrase as String: "test"]
        #if os(macOS)
        // Without this, macOS imports the identity into the login keychain.
        if #available(macOS 15, *) {
            options[kSecImportToMemoryOnly as String] = true
        }
        #endif
        var items: CFArray?
        let status = SecPKCS12Import(PinningFixtures.leafIdentity as CFData, options as CFDictionary, &items)
        #expect(status == errSecSuccess)
        let first = try #require((items as? [[String: Any]])?.first)
        let identity = try #require(first[kSecImportItemIdentity as String])
        return identity as! SecIdentity
    }
}
