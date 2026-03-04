// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BabyTracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
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
                "Preview Content",
                "Utilities/AuthenticationManager.swift",
                "Utilities/CloudKitManager.swift",
                "Utilities/NotificationManager.swift",
                "Views/Authentication",
                "Views/Settings/SecuritySettingsView.swift",
                "Views/Settings/iCloudSyncView.swift",
                "Views/Settings/ReminderSettingsView.swift"
            ],
            sources: [
                "Models",
                "ViewModels/BreastfeedingTimerViewModel.swift",
                "Utilities/AppPersistence.swift",
                "Utilities/ModelContext+Persistence.swift",
                "Utilities/VaccinationSchedule.swift"
            ]
        ),
        .testTarget(
            name: "BabyTrackerBDDTests",
            dependencies: ["BabyTracker"],
            path: "BabyTrackerBDDTests"
        )
    ]
)
