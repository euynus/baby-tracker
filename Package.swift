// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BabyTracker",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BabyTracker",
            targets: ["BabyTracker"]
        )
    ],
    targets: [
        .target(
            name: "BabyTracker",
            path: "BabyTracker",
            exclude: [
                "Assets.xcassets",
                "Preview Content"
            ]
        ),
        .testTarget(
            name: "BabyTrackerBDDTests",
            dependencies: ["BabyTracker"],
            path: "BabyTrackerBDDTests"
        )
    ]
)
