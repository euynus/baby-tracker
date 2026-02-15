//
//  BabyTrackerApp.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct BabyTrackerApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @AppStorage("appearance") private var appearance: String = "跟随系统"
    private let sharedModelContainer: ModelContainer
    private static let startupLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.babytracker.app",
        category: "AppLifecycle"
    )

    init() {
        let logger = Self.startupLogger
        sharedModelContainer = AppPersistence.makeResilientAppContainer(onFailure: { error in
            logger.error("ModelContainer 初始化失败，尝试降级策略: \(error.localizedDescription, privacy: .public)")
        })
    }
    
    private var preferredScheme: ColorScheme? {
        switch appearance {
        case "浅色": return .light
        case "深色": return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(authManager)
                    .preferredColorScheme(preferredScheme)
            } else {
                AuthenticationView()
                    .environmentObject(authManager)
                    .preferredColorScheme(preferredScheme)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
