// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TranslateBar",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TranslateBar", targets: ["TranslateBar"])
    ],
    targets: [
        .executableTarget(
            name: "TranslateBar",
            path: "Sources/TranslateBar"
        ),
        .testTarget(
            name: "TranslateBarTests",
            dependencies: ["TranslateBar"],
            path: "Tests/TranslateBarTests"
        )
    ]
)
