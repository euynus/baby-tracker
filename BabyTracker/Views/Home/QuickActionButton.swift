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
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 48))
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
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
            .shadow(
                color: .black.opacity(isPressed ? 0.15 : 0.08),
                radius: isPressed ? 12 : 8,
                y: isPressed ? 6 : 4
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring) {
                        isPressed = false
                    }
                }
        )
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
