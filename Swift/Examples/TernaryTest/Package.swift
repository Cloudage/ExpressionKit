// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TernaryTest",
    dependencies: [
        .package(path: "../../../")
    ],
    targets: [
        .executableTarget(
            name: "TernaryTest",
            dependencies: ["ExpressionKit"],
            path: "Sources"
        )
    ]
)