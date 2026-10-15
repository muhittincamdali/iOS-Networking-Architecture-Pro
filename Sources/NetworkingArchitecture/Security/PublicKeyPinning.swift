import CryptoKit
import Foundation
import Security

/// Accepts a server only when its certificate chain contains one of your public keys.
///
/// A pin is the Base64 SHA-256 hash of a certificate's SubjectPublicKeyInfo, the same value
/// HPKP and most pinning tools use. Get it for a live server with:
///
/// ```sh
/// openssl s_client -connect api.example.com:443 -servername api.example.com </dev/null \
///   | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der \
///   | openssl dgst -sha256 -binary | base64
/// ```
///
/// Pin at least two keys per host, the current one and a backup (or the intermediate CA's),
/// so a certificate renewal does not lock your app out of its own server.
///
/// ```swift
/// let pinning = PublicKeyPinning(pins: [
///     "api.example.com": ["mJQ0eC8m/jQuFjpXw4JrSA0XAtwlmWblq7m63NkNVqI=", "<backup pin>"]
/// ])
/// let client = NetworkClient(baseURL: apiURL, transport: URLSessionTransport(pinning: pinning))
/// ```
///
/// The system's own certificate validation always runs first; a pin only narrows down which
/// valid certificates are accepted. Hosts without pins are validated as usual.
public struct PublicKeyPinning: Sendable {
    /// The outcome of evaluating a server.
    public enum Evaluation: Sendable, Equatable {
        /// The chain is valid and contains a pinned key.
        case trusted
        /// The host has no pins; the system's default handling applies.
        case notPinned
        /// The chain failed system validation, or contains none of the pinned keys.
        case rejected(String)
    }

    private let pins: [String: Set<String>]
    private let includesSubdomains: Bool

    /// Creates a pin set.
    ///
    /// - Parameters:
    ///   - pins: For each host name, the accepted Base64 SHA-256 SubjectPublicKeyInfo hashes,
    ///     with or without a `sha256/` prefix.
    ///   - includesSubdomains: Whether the pins of `example.com` also apply to
    ///     `api.example.com`. A more specific host's own pins take precedence.
    public init(pins: [String: Set<String>], includesSubdomains: Bool = false) {
        var normalized: [String: Set<String>] = [:]
        for (host, hostPins) in pins {
            // Accept the "sha256/…" form that OkHttp and HPKP tools print.
            let hashes = hostPins.map { $0.hasPrefix("sha256/") ? String($0.dropFirst(7)) : $0 }
            normalized[host.lowercased(), default: []].formUnion(hashes)
        }
        self.pins = normalized
        self.includesSubdomains = includesSubdomains
    }

    /// The pins that apply to `host`, or `nil` when it has none.
    public func pins(for host: String) -> Set<String>? {
        let host = host.lowercased()
        if let exact = pins[host] { return exact }
        guard includesSubdomains else { return nil }
        let match = pins.keys
            .filter { host.hasSuffix("." + $0) }
            .max { $0.count < $1.count }
        return match.flatMap { pins[$0] }
    }

    /// Validates `trust` for `host` with the system policy and checks it against the pins.
    public func evaluate(_ trust: SecTrust, host: String) -> Evaluation {
        guard let expected = pins(for: host) else { return .notPinned }
        SecTrustSetPolicies(trust, SecPolicyCreateSSL(true, host as CFString))
        var error: CFError?
        guard SecTrustEvaluateWithError(trust, &error) else {
            return .rejected(error.map { CFErrorCopyDescription($0) as String } ?? "the certificate is not trusted")
        }
        let chain = (SecTrustCopyCertificateChain(trust) as? [SecCertificate]) ?? []
        let found = chain.contains { certificate in
            Self.publicKeyHash(of: certificate).map(expected.contains) ?? false
        }
        return found ? .trusted : .rejected("no certificate in the chain has a pinned public key")
    }

    /// The Base64 SHA-256 hash of the certificate's SubjectPublicKeyInfo, or `nil` for a key
    /// type other than RSA or elliptic curve P-256, P-384 or P-521.
    public static func publicKeyHash(of certificate: SecCertificate) -> String? {
        guard let key = SecCertificateCopyKey(certificate),
              let attributes = SecKeyCopyAttributes(key) as? [CFString: Any],
              let type = attributes[kSecAttrKeyType] as? String,
              let bits = attributes[kSecAttrKeySizeInBits] as? Int,
              let raw = SecKeyCopyExternalRepresentation(key, nil) as Data?,
              let algorithm = algorithmIdentifier(type: type, bits: bits) else {
            return nil
        }
        // SubjectPublicKeyInfo ::= SEQUENCE { algorithm, BIT STRING subjectPublicKey }
        let bitString = DER.element(tag: 0x03, content: Data([0x00]) + raw)
        let info = DER.element(tag: 0x30, content: algorithm + bitString)
        return Data(SHA256.hash(data: info)).base64EncodedString()
    }

    private static func algorithmIdentifier(type: String, bits: Int) -> Data? {
        if type == (kSecAttrKeyTypeRSA as String) {
            // SEQUENCE { OID 1.2.840.113549.1.1.1 (rsaEncryption), NULL }
            return Data([0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00])
        }
        guard type == (kSecAttrKeyTypeECSECPrimeRandom as String) else { return nil }
        // OID 1.2.840.10045.2.1 (ecPublicKey) followed by the curve's OID.
        let ecPublicKey: [UInt8] = [0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01]
        let curve: [UInt8]
        switch bits {
        case 256: curve = [0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07]
        case 384: curve = [0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x22]
        case 521: curve = [0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x23]
        default: return nil
        }
        return DER.element(tag: 0x30, content: Data(ecPublicKey + curve))
    }
}

/// Just enough DER encoding to rebuild a SubjectPublicKeyInfo.
enum DER {
    static func element(tag: UInt8, content: Data) -> Data {
        Data([tag]) + length(content.count) + content
    }

    static func length(_ count: Int) -> Data {
        guard count >= 0x80 else { return Data([UInt8(count)]) }
        var bytes: [UInt8] = []
        var remaining = count
        while remaining > 0 {
            bytes.insert(UInt8(remaining & 0xFF), at: 0)
            remaining >>= 8
        }
        return Data([0x80 | UInt8(bytes.count)] + bytes)
    }
}
