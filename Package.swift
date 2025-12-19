// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ThemeKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ThemeKit",
            targets: ["ThemeKit"]
        )
    ],
    targets: [
        .target(
            name: "ThemeKit",
            path: "Sources"
        ),
        .testTarget(
            name: "ThemeKitTests",
            dependencies: ["ThemeKit"]
        )
    ]
)
