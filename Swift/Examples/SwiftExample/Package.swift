// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ExpressionKitExample",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(path: "../../..")  // In real usage: .package(url: "https://github.com/Cloudage/ExpressionKit.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ExpressionKitExample",
            dependencies: ["ExpressionKit"]
        )
    ]
)