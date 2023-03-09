// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "comet-ios-instant-wallet",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15),
        
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "comet-ios-instant-wallet",
            targets: ["comet-ios-instant-wallet"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.5"),
        .package(name: "Solana", url: "https://github.com/metaplex-foundation/Solana.Swift", from: "2.0.0"),
        .package(name: "AWSiOSSDKV2", url: "https://github.com/aws-amplify/aws-sdk-ios-spm", from: "2.28.0"),
    ],
    
    targets: [
        .target(
            name: "comet-ios-instant-wallet",
            dependencies: [
                "Yams",
                "Solana",
                .product(name: "AWSCore", package: "AWSiOSSDKV2"),
                .product(name: "AWSKMS", package: "AWSiOSSDKV2"),
            ])
    ]
)
