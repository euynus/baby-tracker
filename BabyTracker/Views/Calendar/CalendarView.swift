//
//  CalendarView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            Text("日历")
                .font(.title)
            Text("开发中...")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("日历")
    }
}

#Preview {
    CalendarView()
}
