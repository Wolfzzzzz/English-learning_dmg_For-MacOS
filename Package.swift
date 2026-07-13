// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IELTSDictation",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "IELTSDictationCore",
            targets: ["IELTSDictationCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IELTSDictationCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "IELTSDictationCoreTests",
            dependencies: ["IELTSDictationCore"]
        ),
        .executableTarget(
            name: "IELTSDictationApp",
            dependencies: ["IELTSDictationCore"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
