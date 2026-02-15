//
//  BabyTrackerApp.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

@main
struct BabyTrackerApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @AppStorage("appearance") private var appearance: String = "跟随系统"
    private let sharedModelContainer: ModelContainer

    init() {
        let isRunningUnitTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: isRunningUnitTests,
            groupContainer: isRunningUnitTests ? .none : .automatic,
            cloudKitDatabase: isRunningUnitTests ? .none : .automatic
        )

        do {
            sharedModelContainer = try ModelContainer(
                for: Baby.self,
                FeedingRecord.self,
                SleepRecord.self,
                DiaperRecord.self,
                GrowthRecord.self,
                PhotoRecord.self,
                configurations: configuration
            )
        } catch {
            fatalError("ModelContainer 初始化失败: \(error)")
        }
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
