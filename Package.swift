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
        // No TCA dependency. Project uses MVVM patterns and native Swift frameworks.
        // If needed, add optional dependencies here.
    ],
    targets: [
        .target(
            name: "AIContextIOS",
            dependencies: [
                // No ComposableArchitecture dependency required (MVVM preferred)
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