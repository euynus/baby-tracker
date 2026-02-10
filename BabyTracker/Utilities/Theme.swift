//
//  Theme.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    
    static let feeding = Color("FeedingColor", bundle: .main)
    static let sleep = Color("SleepColor", bundle: .main)
    static let diaper = Color("DiaperColor", bundle: .main)
    static let growth = Color("GrowthColor", bundle: .main)
    
    // Gradients
    static let feedingGradient = [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]
    static let sleepGradient = [Color.purple.opacity(0.6), Color.pink.opacity(0.4)]
    static let diaperGradient = [Color.yellow.opacity(0.6), Color.orange.opacity(0.4)]
    static let growthGradient = [Color.red.opacity(0.6), Color.pink.opacity(0.4)]
    
    // Dark mode adaptive gradients
    static func adaptiveGradient(_ lightColors: [Color], darkColors: [Color]? = nil) -> [Color] {
        // In a real implementation, check the current color scheme
        return lightColors
    }
    
    // MARK: - Typography
    
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Spacing
    
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    
    // MARK: - Shadows
    
    static let shadowLight = Shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    static let shadowMedium = Shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    static let shadowHeavy = Shadow(color: .black.opacity(0.16), radius: 16, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(color: AppTheme.shadowLight.color, radius: AppTheme.shadowLight.radius, y: AppTheme.shadowLight.y)
    }
    
    func gradientCard(_ colors: [Color]) -> some View {
        self
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppTheme.cornerRadiusLarge)
            .shadow(color: AppTheme.shadowLight.color, radius: AppTheme.shadowLight.radius, y: AppTheme.shadowLight.y)
    }
}

// MARK: - Dark Mode Toggle View

struct AppearanceSettingsView: View {
    @AppStorage("appearance") private var appearance: Appearance = .system
    
    enum Appearance: String, CaseIterable {
        case light = "浅色"
        case dark = "深色"
        case system = "跟随系统"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    var body: some View {
        Form {
            Section {
                Picker("外观", selection: $appearance) {
                    ForEach(Appearance.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("主题设置")
            } footer: {
                Text("选择应用的外观模式")
            }
            
            Section("预览") {
                VStack(spacing: 16) {
                    HStack {
                        gradientPreview("喂养", colors: AppTheme.feedingGradient)
                        gradientPreview("睡眠", colors: AppTheme.sleepGradient)
                    }
                    
                    HStack {
                        gradientPreview("尿布", colors: AppTheme.diaperGradient)
                        gradientPreview("生长", colors: AppTheme.growthGradient)
                    }
                }
            }
        }
        .navigationTitle("外观设置")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func gradientPreview(_ title: String, colors: [Color]) -> some View {
        VStack {
            Text("🍼")
                .font(.title)
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
