// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThinkLocally",
    platforms: [.macOS("26.0")],
    targets: [
        .executableTarget(
            name: "ThinkLocally",
            path: "Sources/ThinkLocally"
        ),
        .testTarget(
            name: "ThinkLocallyTests",
            dependencies: ["ThinkLocally"],
            path: "Tests/ThinkLocallyTests"
        ),
    ]
)
