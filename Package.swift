// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NetworkingArchitecture",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "NetworkingArchitecture", targets: ["NetworkingArchitecture"]),
        .library(name: "NetworkingArchitectureTesting", targets: ["NetworkingArchitectureTesting"])
    ],
    targets: [
        .target(
            name: "NetworkingArchitecture",
            path: "Sources/NetworkingArchitecture"
        ),
        .target(
            name: "NetworkingArchitectureTesting",
            dependencies: ["NetworkingArchitecture"],
            path: "Sources/NetworkingArchitectureTesting"
        ),
        .testTarget(
            name: "NetworkingArchitectureTests",
            dependencies: ["NetworkingArchitecture", "NetworkingArchitectureTesting"],
            path: "Tests/NetworkingArchitectureTests"
        )
    ]
)
