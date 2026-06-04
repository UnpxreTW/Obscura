// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Obscura",
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Obscura"),
    ]
)
