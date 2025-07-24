// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExpressionKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ExpressionKit",
            targets: ["ExpressionKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ExpressionKitCore",
            dependencies: [],
            path: "CPP/Sources/ExpressionKitCore",
            sources: ["ExpressionKitBridge.cpp"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("../../../"),
                .unsafeFlags(["-std=c++17"])
            ]
        ),
        .target(
            name: "ExpressionKit",
            dependencies: ["ExpressionKitCore"],
            path: "Swift/Sources/ExpressionKit"
        ),
        .testTarget(
            name: "ExpressionKitTests",
            dependencies: ["ExpressionKit"],
            path: "Swift/Tests/ExpressionKitTests"
        ),
    ]
)