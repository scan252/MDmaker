// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MDmaker",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Ink.git", from: "0.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "MDmaker",
            dependencies: [
                .product(name: "Ink", package: "Ink"),
            ],
            path: "Sources/MDmaker"
        ),
    ]
)
