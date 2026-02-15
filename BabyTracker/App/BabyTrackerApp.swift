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
        do {
            sharedModelContainer = try AppPersistence.makeAppContainer()
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
