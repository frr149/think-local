// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThinkLocal",
    platforms: [.macOS("26.0")],
    targets: [
        .executableTarget(
            name: "ThinkLocal",
            path: "Sources/ThinkLocal"
        ),
        .testTarget(
            name: "ThinkLocalTests",
            dependencies: ["ThinkLocal"],
            path: "Tests/ThinkLocalTests"
        ),
    ]
)
