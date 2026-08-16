// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiscoveryCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "DiscoveryCore", targets: ["DiscoveryCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "DiscoveryCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .testTarget(name: "DiscoveryCoreTests", dependencies: ["DiscoveryCore"])
    ]
)
