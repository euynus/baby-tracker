//
//  ContentView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("记录", systemImage: "house.fill")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Label("统计", systemImage: "chart.xyaxis.line")
                }
                .tag(1)
            
            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar.badge.clock")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .tint(AppTheme.brand)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

#Preview {
    ContentView()
}
