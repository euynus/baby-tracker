//
//  QuickActionButton.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 48))
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickActionButton(
        icon: "🍼",
        title: "喂奶",
        subtitle: "2小时前",
        gradient: [Color.blue.opacity(0.2), Color.blue.opacity(0.4)],
        action: {}
    )
    .padding()
}
