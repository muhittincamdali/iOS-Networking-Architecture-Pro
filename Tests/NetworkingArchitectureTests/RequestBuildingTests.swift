import Foundation
import Testing
@testable import NetworkingArchitecture

@Suite("Building requests")
struct RequestBuildingTests {
    private let base = URL(string: "https://api.example.com/v1")!

    private func request<R>(_ endpoint: Endpoint<R>, base: URL? = URL(string: "https://api.example.com/v1")!,
                            headers: HTTPHeaders = [:]) throws -> URLRequest {
        try URLRequestBuilder.makeRequest(for: endpoint, baseURL: base, defaultHeaders: headers, encoder: JSONEncoder())
    }

    @Test("Paths are appended to the base URL path", arguments: [
        ("users/42", "https://api.example.com/v1/users/42"),
        ("/users/42", "https://api.example.com/v1/users/42"),
        ("users/42/", "https://api.example.com/v1/users/42/"),
        ("", "https://api.example.com/v1")
    ])
    func appendsPath(path: String, expected: String) throws {
        #expect(try request(Endpoint<Data>.get(path)).url?.absoluteString == expected)
    }

    @Test func baseURLWithTrailingSlashDoesNotDoubleTheSlash() throws {
        let url = try request(Endpoint<Data>.get("/users"), base: URL(string: "https://api.example.com/v1/")!).url
        #expect(url?.absoluteString == "https://api.example.com/v1/users")
    }

    @Test func fullURLPathIgnoresTheBaseURL() throws {
        let url = try request(Endpoint<Data>.get("https://cdn.example.com/a.json")).url
        #expect(url?.absoluteString == "https://cdn.example.com/a.json")
    }

    @Test func pathIsPercentEncoded() throws {
        let url = try request(Endpoint<Data>.get("search/swift concurrency")).url
        #expect(url?.absoluteString == "https://api.example.com/v1/search/swift%20concurrency")
    }

    @Test func queryValuesEncodePlusAndReservedCharacters() throws {
        let endpoint = Endpoint<Data>.get("search", query: [
            URLQueryItem(name: "q", value: "c++ & swift"),
            URLQueryItem(name: "sum", value: "1+1=2"),
            URLQueryItem(name: "flag", value: nil)
        ])
        let query = try request(endpoint).url?.query(percentEncoded: true)
        #expect(query == "q=c%2B%2B%20%26%20swift&sum=1%2B1%3D2&flag")
    }

    @Test func queryInThePathIsKeptAndExtended() throws {
        let endpoint = Endpoint<Data>.get("items?page=2", query: [URLQueryItem(name: "size", value: "10")])
        #expect(try request(endpoint).url?.absoluteString == "https://api.example.com/v1/items?page=2&size=10")
    }

    @Test func relativePathWithoutBaseURLThrows() {
        #expect(throws: NetworkError.self) {
            try request(Endpoint<Data>.get("users"), base: nil)
        }
    }

    @Test func endpointHeadersReplaceDefaultHeadersRegardlessOfCase() throws {
        let endpoint = Endpoint<Data>.get("users", headers: ["accept": "text/csv"])
        let built = try request(endpoint, headers: ["Accept": "application/json", "X-App": "demo"])
        #expect(built.value(forHTTPHeaderField: "Accept") == "text/csv")
        #expect(built.value(forHTTPHeaderField: "X-App") == "demo")
    }

    @Test("Header values with line breaks are rejected", arguments: [
        "value\r\nX-Injected: 1", "value\nX-Injected: 1", "value\rX", "nul\0byte"
    ])
    func rejectsHeaderInjection(value: String) {
        let endpoint = Endpoint<Data>.get("users", headers: ["X-Trace": value])
        #expect {
            try request(endpoint)
        } throws: { error in
            guard case NetworkError.invalidRequest = error else { return false }
            return true
        }
    }

    @Test func headerNameWithLineBreakIsRejected() {
        let endpoint = Endpoint<Data>.get("users", headers: ["X-A\r\nX-B": "1"])
        #expect(throws: NetworkError.self) { try request(endpoint) }
    }

    @Test func jsonBodyIsEncodedWithContentType() throws {
        struct Payload: Codable, Equatable { let name: String }
        let built = try request(Endpoint<Data>.post("users", body: .json(Payload(name: "Ada"))))
        #expect(built.httpMethod == "POST")
        #expect(built.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let decoded = try JSONDecoder().decode(Payload.self, from: try #require(built.httpBody))
        #expect(decoded == Payload(name: "Ada"))
    }

    @Test func failingBodyEncodingBecomesEncodingFailed() {
        struct Unencodable: Encodable, Sendable {
            func encode(to encoder: any Encoder) throws {
                throw EncodingError.invalidValue(0, .init(codingPath: [], debugDescription: "no"))
            }
        }
        #expect {
            try request(Endpoint<Data>.post("x", body: .json(Unencodable())))
        } throws: { error in
            guard case NetworkError.encodingFailed = error else { return false }
            return true
        }
    }

    @Test("Timeouts that are not positive are rejected", arguments: [Duration.zero, .seconds(-1)])
    func rejectsInvalidTimeout(timeout: Duration) {
        let endpoint = Endpoint<Data>.get("x").with(\.timeout, timeout)
        #expect(throws: NetworkError.self) { try request(endpoint) }
    }

    @Test func validTimeoutIsApplied() throws {
        let built = try request(Endpoint<Data>.get("x").with(\.timeout, .milliseconds(2500)))
        #expect(built.timeoutInterval == 2.5)
    }

    @Test func methodNamesAreUppercasedAndIdempotencyFollowsRFC9110() {
        #expect(HTTPMethod(rawValue: "patch") == .patch)
        #expect(HTTPMethod.get.isIdempotent && HTTPMethod.put.isIdempotent && HTTPMethod.delete.isIdempotent)
        #expect(!HTTPMethod.post.isIdempotent && !HTTPMethod.patch.isIdempotent)
    }
}

@Suite("Header fields")
struct HTTPHeadersTests {
    @Test func lookupIgnoresCase() {
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        #expect(headers["content-type"] == "application/json")
        headers["CONTENT-TYPE"] = "text/plain"
        #expect(headers.count == 1)
        #expect(headers["Content-Type"] == "text/plain")
        headers["content-type"] = nil
        #expect(headers.count == 0)
    }

    @Test func equalityIgnoresNameCaseAndOrder() {
        let first: HTTPHeaders = ["A": "1", "b": "2"]
        let second: HTTPHeaders = ["B": "2", "a": "1"]
        #expect(first == second)
        #expect(first.hashValue == second.hashValue)
        #expect(first != ["A": "1", "B": "3"])
    }

    @Test func mergeReplacesFieldsWithTheSameName() {
        var headers: HTTPHeaders = ["Accept": "application/json", "X-A": "1"]
        headers.merge(["accept": "text/html"])
        #expect(headers["Accept"] == "text/html")
        #expect(headers.count == 2)
    }
}
