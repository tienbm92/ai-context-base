// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AIContextIOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AIContextIOS",
            targets: ["AIContextIOS"]
        ),
    ],
    dependencies: [
        // Optional: Add TCA dependency
        // .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AIContextIOS",
            dependencies: [
                // Optional: TCA dependency
                // .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "AIContextIOSTests",
            dependencies: ["AIContextIOS"]
        ),
    ]
)