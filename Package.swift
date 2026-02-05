// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkingArchitecture",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        // Core networking library
        .library(
            name: "NetworkingArchitecture",
            targets: ["NetworkingArchitecture"]
        ),
        // REST API module
        .library(
            name: "NetworkingREST",
            targets: ["NetworkingREST"]
        ),
        // GraphQL module
        .library(
            name: "NetworkingGraphQL",
            targets: ["NetworkingGraphQL"]
        ),
        // WebSocket module
        .library(
            name: "NetworkingWebSocket",
            targets: ["NetworkingWebSocket"]
        ),
        // Server-Sent Events module
        .library(
            name: "NetworkingSSE",
            targets: ["NetworkingSSE"]
        ),
        // gRPC module
        .library(
            name: "NetworkingGRPC",
            targets: ["NetworkingGRPC"]
        ),
        // Full bundle
        .library(
            name: "NetworkingArchitectureFull",
            targets: [
                "NetworkingArchitecture",
                "NetworkingREST",
                "NetworkingGraphQL",
                "NetworkingWebSocket",
                "NetworkingSSE",
                "NetworkingGRPC"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    ],
    targets: [
        // MARK: - Core Module
        .target(
            name: "NetworkingArchitecture",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            path: "Sources/Core"
        ),
        
        // MARK: - REST Module
        .target(
            name: "NetworkingREST",
            dependencies: ["NetworkingArchitecture"],
            path: "Sources/REST"
        ),
        
        // MARK: - GraphQL Module
        .target(
            name: "NetworkingGraphQL",
            dependencies: ["NetworkingArchitecture"],
            path: "Sources/GraphQL"
        ),
        
        // MARK: - WebSocket Module
        .target(
            name: "NetworkingWebSocket",
            dependencies: ["NetworkingArchitecture"],
            path: "Sources/WebSocket"
        ),
        
        // MARK: - SSE Module
        .target(
            name: "NetworkingSSE",
            dependencies: ["NetworkingArchitecture"],
            path: "Sources/SSE"
        ),
        
        // MARK: - gRPC Module
        .target(
            name: "NetworkingGRPC",
            dependencies: ["NetworkingArchitecture"],
            path: "Sources/gRPC"
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "NetworkingArchitectureTests",
            dependencies: [
                "NetworkingArchitecture",
                "NetworkingREST",
                "NetworkingGraphQL",
                "NetworkingWebSocket",
                "NetworkingSSE",
                "NetworkingGRPC"
            ],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
