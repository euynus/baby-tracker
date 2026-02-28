//
//  Theme.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors

    static let brand = Color(red: 0.95, green: 0.40, blue: 0.31)
    static let secondary = Color(red: 0.16, green: 0.60, blue: 0.66)
    static let accent = Color(red: 0.42, green: 0.74, blue: 0.62)
    static let ink = Color(red: 0.17, green: 0.23, blue: 0.33)
    static let warning = Color(red: 0.90, green: 0.58, blue: 0.22)
    static let danger = Color(red: 0.86, green: 0.32, blue: 0.28)

    static let feeding = Color("FeedingColor", bundle: .main)
    static let sleep = Color("SleepColor", bundle: .main)
    static let diaper = Color("DiaperColor", bundle: .main)
    static let growth = Color("GrowthColor", bundle: .main)
    static let vaccine = Color(red: 0.39, green: 0.61, blue: 0.89)

    // Gradients
    static let feedingGradient = [Color(red: 0.98, green: 0.73, blue: 0.32), Color(red: 0.97, green: 0.48, blue: 0.34)]
    static let sleepGradient = [Color(red: 0.28, green: 0.60, blue: 0.86), Color(red: 0.21, green: 0.43, blue: 0.80)]
    static let diaperGradient = [Color(red: 0.59, green: 0.78, blue: 0.40), Color(red: 0.39, green: 0.65, blue: 0.33)]
    static let growthGradient = [Color(red: 0.21, green: 0.74, blue: 0.70), Color(red: 0.18, green: 0.53, blue: 0.67)]
    static let vaccineGradient = [Color(red: 0.30, green: 0.62, blue: 0.88), Color(red: 0.22, green: 0.49, blue: 0.81)]

    static let heroGradient = [Color(red: 0.99, green: 0.64, blue: 0.43), Color(red: 0.97, green: 0.45, blue: 0.37)]
    static let disabledGradient = [Color(red: 0.66, green: 0.69, blue: 0.73), Color(red: 0.56, green: 0.59, blue: 0.63)]

    static func pageGradient(for scheme: ColorScheme) -> LinearGradient {
        let light = [Color(uiColor: .systemGroupedBackground), Color(uiColor: .systemGroupedBackground)]
        let dark = [Color(uiColor: .black), Color(uiColor: .black)]
        return LinearGradient(colors: scheme == .dark ? dark : light, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func surfaceFill(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(uiColor: .secondarySystemGroupedBackground) : Color(uiColor: .secondarySystemGroupedBackground)
    }

    static func surfaceBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }

    static func shadowColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.20) : .black.opacity(0.04)
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
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 24

    // MARK: - Shadows

    static let shadowLight = Shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    static let shadowMedium = Shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    static let shadowHeavy = Shadow(color: .black.opacity(0.16), radius: 16, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat = 0
    let y: CGFloat
}

// MARK: - View Extensions

private struct AppPageBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                AppTheme.pageGradient(for: colorScheme)
                .ignoresSafeArea()
            }
    }
}

private struct SoftCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(AppTheme.surfaceFill(for: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                    .stroke(AppTheme.surfaceBorder(for: colorScheme), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            .shadow(
                color: AppTheme.shadowColor(for: colorScheme),
                radius: 4,
                x: 0,
                y: 1
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .modifier(SoftCardModifier())
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
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
            .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
    }

    func appPageBackground() -> some View {
        self.modifier(AppPageBackgroundModifier())
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
                        gradientPreview("喂养", icon: "drop.fill", colors: AppTheme.feedingGradient)
                        gradientPreview("睡眠", icon: "moon.stars.fill", colors: AppTheme.sleepGradient)
                    }

                    HStack {
                        gradientPreview("尿布", icon: "sparkles", colors: AppTheme.diaperGradient)
                        gradientPreview("生长", icon: "chart.line.uptrend.xyaxis", colors: AppTheme.growthGradient)
                    }
                }
            }
        }
        .navigationTitle("外观设置")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func gradientPreview(_ title: String, icon: String, colors: [Color]) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.92))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .gradientCard(colors)
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
