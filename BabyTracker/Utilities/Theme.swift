//
//  Theme.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct AppTheme {
    // MARK: - Core Colors

    static let brand = Color(red: 0.92, green: 0.43, blue: 0.27)
    static let brandDeep = Color(red: 0.83, green: 0.33, blue: 0.18)
    static let secondary = Color(red: 0.19, green: 0.59, blue: 0.63)
    static let accent = Color(red: 0.47, green: 0.72, blue: 0.57)
    static let ink = Color(red: 0.16, green: 0.21, blue: 0.28)
    static let mutedInk = Color(red: 0.43, green: 0.48, blue: 0.56)
    static let warning = Color(red: 0.90, green: 0.60, blue: 0.23)
    static let danger = Color(red: 0.83, green: 0.30, blue: 0.28)

    static let feeding = Color(red: 0.96, green: 0.68, blue: 0.28)
    static let sleep = Color(red: 0.33, green: 0.55, blue: 0.88)
    static let diaper = Color(red: 0.49, green: 0.73, blue: 0.43)
    static let growth = Color(red: 0.23, green: 0.73, blue: 0.67)
    static let vaccine = Color(red: 0.39, green: 0.58, blue: 0.87)

    // MARK: - Gradients

    static let feedingGradient = [Color(red: 0.99, green: 0.80, blue: 0.43), Color(red: 0.95, green: 0.53, blue: 0.25)]
    static let sleepGradient = [Color(red: 0.48, green: 0.68, blue: 0.96), Color(red: 0.24, green: 0.40, blue: 0.79)]
    static let diaperGradient = [Color(red: 0.70, green: 0.86, blue: 0.48), Color(red: 0.39, green: 0.63, blue: 0.33)]
    static let growthGradient = [Color(red: 0.31, green: 0.83, blue: 0.76), Color(red: 0.16, green: 0.58, blue: 0.63)]
    static let vaccineGradient = [Color(red: 0.43, green: 0.68, blue: 0.95), Color(red: 0.23, green: 0.42, blue: 0.82)]
    static let heroGradient = [Color(red: 0.98, green: 0.73, blue: 0.48), Color(red: 0.91, green: 0.38, blue: 0.27)]
    static let mintHeroGradient = [Color(red: 0.62, green: 0.87, blue: 0.76), Color(red: 0.20, green: 0.62, blue: 0.65)]
    static let disabledGradient = [Color(red: 0.76, green: 0.79, blue: 0.83), Color(red: 0.63, green: 0.66, blue: 0.71)]

    // MARK: - Surfaces

    static func pageGradient(for scheme: ColorScheme) -> LinearGradient {
        let colors = scheme == .dark
            ? [
                Color(red: 0.08, green: 0.09, blue: 0.13),
                Color(red: 0.11, green: 0.13, blue: 0.18),
                Color(red: 0.09, green: 0.12, blue: 0.16)
            ]
            : [
                Color(red: 0.99, green: 0.97, blue: 0.94),
                Color(red: 0.98, green: 0.95, blue: 0.91),
                Color(red: 0.95, green: 0.97, blue: 0.95)
            ]

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func surfaceFill(for scheme: ColorScheme) -> LinearGradient {
        let colors = scheme == .dark
            ? [Color.white.opacity(0.10), Color.white.opacity(0.06)]
            : [Color.white.opacity(0.90), Color.white.opacity(0.72)]

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func elevatedSurfaceFill(for scheme: ColorScheme) -> LinearGradient {
        let colors = scheme == .dark
            ? [Color.white.opacity(0.15), Color.white.opacity(0.09)]
            : [Color.white, Color(red: 0.99, green: 0.98, blue: 0.96)]

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func glassFill(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.40)
    }

    static func tabBarFill(for scheme: ColorScheme) -> LinearGradient {
        let colors = scheme == .dark
            ? [Color(red: 0.13, green: 0.15, blue: 0.20), Color(red: 0.11, green: 0.13, blue: 0.18)]
            : [Color.white.opacity(0.92), Color(red: 0.98, green: 0.96, blue: 0.93)]

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func surfaceBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.10) : Color.white.opacity(0.75)
    }

    static func subtleBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }

    static func shadowColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .black.opacity(0.35) : Color(red: 0.41, green: 0.31, blue: 0.23).opacity(0.10)
    }

    static func iconPlate(for color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.20), color.opacity(0.10)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Typography

    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)

    // MARK: - Spacing

    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24

    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 20
    static let cornerRadiusLarge: CGFloat = 28

    // MARK: - Shadows

    static let shadowLight = Shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    static let shadowMedium = Shadow(color: .black.opacity(0.14), radius: 18, y: 8)
    static let shadowHeavy = Shadow(color: .black.opacity(0.18), radius: 24, y: 12)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat = 0
    let y: CGFloat
}

// MARK: - View Modifiers

private struct AppPageBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    AppTheme.pageGradient(for: colorScheme)
                        .ignoresSafeArea()

                    Circle()
                        .fill(AppTheme.brand.opacity(colorScheme == .dark ? 0.14 : 0.18))
                        .frame(width: 360, height: 360)
                        .blur(radius: 36)
                        .offset(x: 150, y: -260)

                    Circle()
                        .fill(AppTheme.secondary.opacity(colorScheme == .dark ? 0.12 : 0.16))
                        .frame(width: 260, height: 260)
                        .blur(radius: 26)
                        .offset(x: -140, y: 240)

                    Rectangle()
                        .fill(.clear)
                        .background(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.06 : 0.08))
                        .mask(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.50), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .ignoresSafeArea()
                }
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
                radius: 16,
                x: 0,
                y: 8
            )
    }
}

private struct ElevatedCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(AppTheme.elevatedSurfaceFill(for: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(AppTheme.surfaceBorder(for: colorScheme), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
            .shadow(
                color: AppTheme.shadowColor(for: colorScheme),
                radius: 24,
                x: 0,
                y: 10
            )
    }
}

private struct AppFieldModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppTheme.glassFill(for: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.subtleBorder(for: colorScheme), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(SoftCardModifier())
    }

    func elevatedCardStyle() -> some View {
        modifier(ElevatedCardModifier())
    }

    func gradientCard(_ colors: [Color]) -> some View {
        background(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .stroke(Color.white.opacity(0.26), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 18, x: 0, y: 10)
    }

    func appPageBackground() -> some View {
        modifier(AppPageBackgroundModifier())
    }

    func appInputFieldStyle() -> some View {
        modifier(AppFieldModifier())
    }
}

// MARK: - Shared UI

struct AppSectionTitle: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.brand)
                }

                Text(title)
                    .font(AppTheme.title2)
                    .foregroundStyle(AppTheme.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.brand)
            }
        }
    }
}

struct AppIconBadge: View {
    let symbol: String
    let colors: [Color]
    var size: CGFloat = 42

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.36, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: size * 0.34, style: .continuous))
    }
}

struct AppMetricTile: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String
    let gradient: [Color]
    var emphasized: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AppIconBadge(symbol: symbol, colors: gradient, size: emphasized ? 48 : 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(emphasized ? .title3.weight(.bold) : .headline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct AppStatusChip: View {
    let title: String
    let value: String
    var tint: Color = AppTheme.brand

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tint.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct AppEmptyStateCard: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            AppIconBadge(symbol: symbol, colors: AppTheme.heroGradient, size: 52)
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.vertical, 28)
        .cardStyle()
    }
}

struct AppActionRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = AppTheme.brand

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(AppTheme.iconPlate(for: tint))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .cardStyle()
    }
}

struct AppPrimaryButtonStyle: ButtonStyle {
    let gradient: [Color]
    let foregroundColor: Color

    init(
        gradient: [Color] = AppTheme.heroGradient,
        foregroundColor: Color = .white
    ) {
        self.gradient = gradient
        self.foregroundColor = foregroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring, value: configuration.isPressed)
    }
}

// MARK: - Appearance Settings

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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionTitle(
                        eyebrow: "主题",
                        title: "外观设置",
                        subtitle: "在浅色、深色和跟随系统之间切换。"
                    )

                    Picker("外观", selection: $appearance) {
                        ForEach(Appearance.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(18)
                .elevatedCardStyle()

                VStack(alignment: .leading, spacing: 14) {
                    AppSectionTitle(
                        eyebrow: "预览",
                        title: "主题色板",
                        subtitle: "统一的功能配色会同步作用到记录、统计和提醒。"
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        gradientPreview("喂养", icon: "drop.fill", colors: AppTheme.feedingGradient)
                        gradientPreview("睡眠", icon: "moon.stars.fill", colors: AppTheme.sleepGradient)
                        gradientPreview("尿布", icon: "sparkles.rectangle.stack.fill", colors: AppTheme.diaperGradient)
                        gradientPreview("生长", icon: "chart.line.uptrend.xyaxis", colors: AppTheme.growthGradient)
                    }
                }
                .padding(18)
                .cardStyle()
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 16)
        }
        .navigationTitle("外观设置")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
    }

    private func gradientPreview(_ title: String, icon: String, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            AppIconBadge(symbol: icon, colors: colors, size: 46)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("统一视觉语义")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(16)
        .gradientCard(colors)
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
