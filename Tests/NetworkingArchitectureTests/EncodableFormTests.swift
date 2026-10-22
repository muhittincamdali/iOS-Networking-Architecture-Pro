import Foundation
import Testing
@testable import NetworkingArchitecture

@Suite("Encodable forms")
struct EncodableFormTests {
    struct Filter: Encodable {
        let query: String
        let tags: [String]
        let page: Int
        let exact: Bool
        let cursor: String?
        let range: Range
        struct Range: Encodable { let from: Double; let to: Double }
    }

    @Test func flattensObjectsArraysAndScalars() throws {
        let filter = Filter(query: "a b", tags: ["ios", "net"], page: 2, exact: true, cursor: nil, range: .init(from: 1.5, to: 3))
        let form = try URLEncodedForm(encoding: filter)
        #expect(form.fields.map { "\($0.name)=\($0.value)" } == [
            "exact=true", "page=2", "query=a b", "range[from]=1.5", "range[to]=3", "tags[]=ios", "tags[]=net"
        ])
        #expect(form.encodedString.hasPrefix("exact=true&page=2&query=a+b&range%5Bfrom%5D=1.5"))
    }

    @Test func topLevelValuesOtherThanObjectsAreRejected() {
        #expect(throws: EncodingError.self) { try URLEncodedForm(encoding: ["a", "b"]) }
        #expect(throws: EncodingError.self) { try URLEncodedForm(encoding: 42) }
    }

    @Test func deepNestingIsRejected() {
        final class Node: Encodable {
            let child: Node?
            init(depth: Int) { child = depth > 0 ? Node(depth: depth - 1) : nil }
        }
        #expect(throws: EncodingError.self) { try URLEncodedForm(encoding: Node(depth: 40)) }
        #expect(throws: Never.self) { try URLEncodedForm(encoding: Node(depth: 10)) }
    }
}
