//
//  ContentView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: RootTab = .home
    @Namespace private var tabAnimation
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(RootTab.home)

            StatisticsView()
                .tag(RootTab.statistics)

            CalendarView()
                .tag(RootTab.calendar)

            ProfileView()
                .tag(RootTab.profile)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 10)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            ForEach(RootTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: tab.gradient,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 42, height: 34)
                                    .matchedGeometryEffect(id: "tab-pill", in: tabAnimation)
                            }

                            Image(systemName: tab.symbol)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(selectedTab == tab ? .white : AppTheme.mutedInk)
                                .frame(width: 42, height: 34)
                        }
                        .frame(width: 42, height: 34)

                        Text(tab.title)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(selectedTab == tab ? AppTheme.ink : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(AppTheme.tabBarFill(for: colorScheme))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(AppTheme.surfaceBorder(for: colorScheme), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: AppTheme.shadowColor(for: colorScheme), radius: 20, x: 0, y: 8)
    }
}

private enum RootTab: Int, CaseIterable, Identifiable {
    case home
    case statistics
    case calendar
    case profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "记录"
        case .statistics: return "统计"
        case .calendar: return "日历"
        case .profile: return "我的"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "sparkles"
        case .statistics: return "chart.xyaxis.line"
        case .calendar: return "calendar.badge.clock"
        case .profile: return "person.crop.circle"
        }
    }

    var gradient: [Color] {
        switch self {
        case .home: return AppTheme.heroGradient
        case .statistics: return AppTheme.growthGradient
        case .calendar: return AppTheme.sleepGradient
        case .profile: return AppTheme.mintHeroGradient
        }
    }
}

#Preview {
    ContentView()
}
