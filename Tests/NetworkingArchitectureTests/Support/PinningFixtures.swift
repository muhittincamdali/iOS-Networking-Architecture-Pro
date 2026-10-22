import Foundation
import Security

/// Certificates made with OpenSSL for the pinning tests, and their pins as computed by
/// `openssl x509 -pubkey | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64`.
///
/// - `ca`: EC P-256 test CA.
/// - `leaf`: RSA 2048 server certificate for pinned.test and api.pinned.test, issued by `ca`.
/// - `p384`: self-signed EC P-384 certificate.
/// - `rsa3072`: self-signed RSA 3072 certificate.
/// - `leafIdentity`: `leaf` with its private key and `ca`, as PKCS #12 with the password "test".
enum PinningFixtures {
    static let caPin = "mJQ0eC8m/jQuFjpXw4JrSA0XAtwlmWblq7m63NkNVqI="
    static let leafPin = "PiOQPzn1cgBMSImK6i8/76naMc46YXyTHjjfyRMo6bY="
    static let p384Pin = "nTzrgycKRGpvp0ycbSCQCp7LxinAaj3ZitNP82iS0d4="
    static let rsa3072Pin = "ssGAnTS318q1IZp5wRqusfYIH0oEjoYt/n142uyWJzE="

    static let caDER = Data(base64Encoded: [
        "MIIBlTCCATygAwIBAgIULXAXTp3qjdCKpVMqrO8QpScdwOUwCgYIKoZIzj0EAwIwKTEnMCUGA1UEAwweTmV0d29ya2luZ0Fy",
        "Y2hpdGVjdHVyZSBUZXN0IENBMB4XDTI2MTAxNTAxNDExMFoXDTI5MDExNzAxNDExMFowKTEnMCUGA1UEAwweTmV0d29ya2lu",
        "Z0FyY2hpdGVjdHVyZSBUZXN0IENBMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE0/GDZLKY5jTAJKx1eJfnCWPzZK92qJuP",
        "KJgRoMoMzQXOtex1Vm6VYnPkVcv5FA/tAZYyrscQbIMiiyDro9b2A6NCMEAwHQYDVR0OBBYEFD6GO/Ka72UyOdO7bdeZto1O",
        "v0gUMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49BAMCA0cAMEQCIBYyqlHFFHmwtnU2a25oiYPR",
        "3QGwXMpz/Zk4NgaGLvEXAiAYncRo00J9wKDZfB5YaC1Z8gTzottbKrHgEUk8+yc4og=="
    ].joined())!

    static let leafDER = Data(base64Encoded: [
        "MIICazCCAhCgAwIBAgIUHyBCnYzqCfzZcLZJvqeOX6s6VLkwCgYIKoZIzj0EAwIwKTEnMCUGA1UEAwweTmV0d29ya2luZ0Fy",
        "Y2hpdGVjdHVyZSBUZXN0IENBMB4XDTI2MTAxNTAxNDExMFoXDTI3MTAxNTAxNDExMFowFjEUMBIGA1UEAwwLcGlubmVkLnRl",
        "c3QwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDH8cSHvpgftRe9RXAtO47H0QEBOjJvp1xBQTgNAYQwu7gXCtwp",
        "TDchZmfqL9rSsUaNbaFInyLA+wLUjGPrMB4hErA4MW9bLMw7zGlTTJAJup5pnjFlhiFSAYMRuFgw4kOa5x6zvrgDtlBswUQo",
        "hqzW7yl6i5uaUFcgXN3so85R/DAoE1cmHevxE6SYN4rpW2FNbapYP1P/CSyP+bbbKC54TQF7CyJNZdOTIf99LXaPP876ZEy9",
        "E1CkdkLxGvEDZ6QmB3hHS4WjSUvE5++EcQPwi1fAt57iKsldp4LYptrt+ljq/dgTWuH+H0BmWrtLWWjMeLNshaC5yuwdfstW",
        "AzGnAgMBAAGjXjBcMCcGA1UdEQQgMB6CC3Bpbm5lZC50ZXN0gg9hcGkucGlubmVkLnRlc3QwEwYDVR0lBAwwCgYIKwYBBQUH",
        "AwEwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCBaAwCgYIKoZIzj0EAwIDSQAwRgIhALThu2kpIfAp6L6mXoTbPRrO/9en",
        "vV6lGXNwJLrvxrUOAiEA4FRYUpQEvzzbbop7bBXo4Zr6Mbj2FzqPxU3PDjrnnzc="
    ].joined())!

    static let p384DER = Data(base64Encoded: [
        "MIIBmjCCAR+gAwIBAgIUHXipAIoRGpvCNYAJUcVp5bIVNxUwCgYIKoZIzj0EAwMwFDESMBAGA1UEAwwJcDM4NC50ZXN0MB4X",
        "DTI2MTAxNTAxNDExMFoXDTI5MDExNzAxNDExMFowFDESMBAGA1UEAwwJcDM4NC50ZXN0MHYwEAYHKoZIzj0CAQYFK4EEACID",
        "YgAEwAODEBCztX/OUeKb66HY9QkWoX4jXLYG74oV6YXnNqik6gOUV1zS4r2avApt0qHt1lUDw6/tfe1D0awjiEFXHOer/o8O",
        "GcYY39xNy+hIYJOwaIRSyX+8Xhgk0hlgBea9ozIwMDAdBgNVHQ4EFgQUPT0KU3HuFNyPuNRD51UAavAa/IswDwYDVR0TAQH/",
        "BAUwAwEB/zAKBggqhkjOPQQDAwNpADBmAjEArY+dSqeefNFBj6bA4puzs7ytOuxPWPYIhbk9A9vF+77BP2/o9/rHRSPBpF0V",
        "WZ9xAjEAjQAMsDEJi1XQVjazPzo0aeHMoHgw8hjOEyZTKJog3LTi6sfyFxqJAUUgSUZoaBzM"
    ].joined())!

    static let rsa3072DER = Data(base64Encoded: [
        "MIID7jCCAlagAwIBAgIUHyWtQvC/Z4FxvZmFB4oC5H2QMWswDQYJKoZIhvcNAQELBQAwFzEVMBMGA1UEAwwMcnNhMzA3Mi50",
        "ZXN0MB4XDTI2MTAxNTAxNDExMFoXDTI5MDExNzAxNDExMFowFzEVMBMGA1UEAwwMcnNhMzA3Mi50ZXN0MIIBojANBgkqhkiG",
        "9w0BAQEFAAOCAY8AMIIBigKCAYEAugR7+AxZSt+zwDyrZ4YGQ1mZA4L7Kc8kjnvPDZOwQGeSxD1ChjXEZ+jBfzm5DaL6P0cy",
        "4d+lOc0iFK9RQxBwkYsIymaHNCSYiw0+qJbEe05rVYbGHgGUVc5HkCwwYLocD6i7u6KsFHuqU58ATdUIAbdFgKC7aZGjSDpZ",
        "KCz91TXOy1itLU076HthhwaFKQb5kQ1d1LHT+GR2VE1LZeOasiSVj3DuSU3l4bYFkcU9xOGig9ukA4kldn3mKhRoTn3U7NZe",
        "xvIn60EjqXxtTatKiJhfFHIjpNXmYFPt1K/wYTof/OGBWs9MxjUH4vjLNs+oK1MvKWcOsf0vxGDi30YG0KLaGpMiqFHKfFMQ",
        "TaL3NOotBBbxm3gx3YDqZ9y2SEZYsxFFvpBHld5Jzj+Ysu7S8nZmPqosnJtWA9T+89sBCuIPst++sY5Oawpy2OEpwMNDCOEW",
        "M3aZa9atZXNUKdP1/A/xihBVySU0ATer7xJB6kBn5mDaDd7G1vpCKvOUlekHAgMBAAGjMjAwMB0GA1UdDgQWBBQKQ2BIX/4G",
        "t9lC7ZL/NDJBJuDATDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBgQApUUnvPeGONFgC8SoiyI/TqHL9bQ7O",
        "JCy1SVwBL1Ve+lGPciOVIcp9nvl6aHmHcnGAr14gBVcPrpjy3bbYBsfI53KZNcdA1lEcEvk1sSuot+5VRHG9xt/nX00CQnd+",
        "yBMxZJJ2eGo8oGd3/1X5Es4PJMw/Sfb+4crOpAsQjaVOGl64UH5rc6njnJsoEOyIrJ7u2l/9JNArflOLHFCvrmCrfy9OpkCD",
        "gAqZHV78qg7VX+Gr2uztteCRjVNwxnKQ3FP2H0nY2x4AHw4PV6uUopjBpAKQ8J4KjvppAIW1T0u1lAHxmuwaj3qfU8q9EKgu",
        "si8+7jmhLtPuCwJ7L7seL7GvITwXMIL81gueAaWb2fePjkJHEp6F9TKBIitLnl4y2paJ2HrxtS6FV1ysIixRHR2QOWYPpgCT",
        "eehCjF1CbsMofaOaS+EpVTvlZdhB/RSXLBBJs2MIwroeN0vmuu4L9QkERUY/NAYGC9TT212dBaMzCxUUTLdegsY6mFbNWTOF",
        "u/Q="
    ].joined())!

    static let leafIdentity = Data(base64Encoded: [
        "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",
        "ENkYuW6c7+ZLugRIar2NRIECAggA"
    ].joined())!

    static func certificate(_ der: Data) -> SecCertificate {
        SecCertificateCreateWithData(nil, der as CFData)!
    }
}
