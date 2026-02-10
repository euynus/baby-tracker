//
//  ProfileView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            Text("我的")
                .font(.title)
            Text("开发中...")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("我的")
    }
}

#Preview {
    ProfileView()
}
