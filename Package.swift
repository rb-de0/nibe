// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
    let CMeCab = "CMeCab"
    let headerFrag = "-I/usr/include"
    let linkFrag = "-L/usr/lib"
#endif

#if os(macOS)
    let CMeCab = "CMeCabOSX"
    let headerFrag = "-I/usr/local/include"
    let linkFrag = "-L/usr/local/lib"
#endif

let package = Package(
    name: "Nibe",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/sqlite-kit", from: "4.0.0"),
        .package(name: "VaporCSRF", url: "https://github.com/brokenhandsio/vapor-csrf.git", from: "1.0.0"),
        .package(name: "VaporSecurityHeaders", url: "https://github.com/brokenhandsio/VaporSecurityHeaders.git", from: "3.0.0"),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "6.0.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.43.1")
    ],
    targets: [
        .target(name: "Run", dependencies: [
            .target(name: "Nibe"),
        ]),
        .target(name: "Nibe", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "SQLiteKit", package: "sqlite-kit"),
            .product(name: "MongoKitten", package: "MongoKitten"),
            .target(name: "MeCab"),
            "VaporCSRF",
            "VaporSecurityHeaders"
        ]),
        .target(
            name: "MeCab",
            dependencies: [
                .target(name: CMeCab)
            ],
            cSettings: [
                .unsafeFlags([headerFrag])
            ],
            swiftSettings: [
                .unsafeFlags([headerFrag])
            ],
            linkerSettings: [.unsafeFlags([linkFrag])]
        ),
        .systemLibrary(name: CMeCab),
        .testTarget(name: "NibeTests", dependencies: [
            .target(name: "Nibe")
        ]),
    ]
)
