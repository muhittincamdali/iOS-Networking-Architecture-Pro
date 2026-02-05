// GraphQLTests.swift
// iOS-Networking-Architecture-Pro
//
// Created by Muhittin Camdali
// Copyright © 2025. All rights reserved.

import XCTest
@testable import NetworkingGraphQL

final class GraphQLTests: XCTestCase {
    
    // MARK: - Request Tests
    
    func testGraphQLRequestEncoding() throws {
        let request = GraphQLRequest(
            query: "query { users { id name } }",
            variables: ["limit": 10],
            operationName: "GetUsers"
        )
        
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["query"] as? String, "query { users { id name } }")
        XCTAssertEqual(json["operationName"] as? String, "GetUsers")
        XCTAssertNotNil(json["variables"])
    }
    
    func testGraphQLResponseDecoding() throws {
        let json = """
        {
            "data": {"user": {"id": 1, "name": "Test"}},
            "errors": null
        }
        """.data(using: .utf8)!
        
        struct UserData: Decodable {
            let user: UserResponse
        }
        
        struct UserResponse: Decodable {
            let id: Int
            let name: String
        }
        
        let response = try JSONDecoder().decode(GraphQLResponse<UserData>.self, from: json)
        XCTAssertEqual(response.data?.user.id, 1)
        XCTAssertEqual(response.data?.user.name, "Test")
        XCTAssertNil(response.errors)
    }
    
    func testGraphQLErrorDecoding() throws {
        let json = """
        {
            "data": null,
            "errors": [
                {
                    "message": "Field not found",
                    "locations": [{"line": 1, "column": 10}],
                    "path": ["user", "email"]
                }
            ]
        }
        """.data(using: .utf8)!
        
        struct EmptyData: Decodable {}
        
        let response = try JSONDecoder().decode(GraphQLResponse<EmptyData>.self, from: json)
        XCTAssertNil(response.data)
        XCTAssertEqual(response.errors?.count, 1)
        XCTAssertEqual(response.errors?.first?.message, "Field not found")
    }
    
    // MARK: - Fragment Tests
    
    func testGraphQLFragment() {
        let fragment = GraphQLFragment(
            name: "UserFields",
            onType: "User",
            fields: "id name email"
        )
        
        let definition = fragment.definition
        XCTAssertTrue(definition.contains("fragment UserFields on User"))
        XCTAssertTrue(definition.contains("id name email"))
    }
    
    // MARK: - Builder Tests
    
    func testGraphQLBuilder() {
        let query = graphQL {
            "query GetUser($id: ID!) {"
            "  user(id: $id) {"
            "    id"
            "    name"
            "  }"
            "}"
        }
        
        XCTAssertTrue(query.contains("query GetUser"))
        XCTAssertTrue(query.contains("user(id: $id)"))
    }
    
    // MARK: - AnyCodable Tests
    
    func testAnyCodableEncoding() throws {
        let values: [String: AnyCodable] = [
            "string": AnyCodable("hello"),
            "int": AnyCodable(42),
            "double": AnyCodable(3.14),
            "bool": AnyCodable(true),
            "array": AnyCodable([1, 2, 3])
        ]
        
        let data = try JSONEncoder().encode(values)
        let decoded = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(decoded["string"] as? String, "hello")
        XCTAssertEqual(decoded["int"] as? Int, 42)
        XCTAssertEqual(decoded["bool"] as? Bool, true)
    }
}
