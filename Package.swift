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
        .library(name: "NetworkingArchitecture", targets: ["NetworkingArchitecture"])
    ],
    targets: [
        .target(
            name: "NetworkingArchitecture",
            path: "Sources/NetworkingArchitecture"
        ),
        .testTarget(
            name: "NetworkingArchitectureTests",
            dependencies: ["NetworkingArchitecture"],
            path: "Tests/NetworkingArchitectureTests"
        )
    ]
)
