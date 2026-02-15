//
//  QuickActionButton.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct QuickActionButton: View {
    let symbol: String
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(9)
                        .background(.white.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                    Spacer()

                    Image(systemName: "arrow.up.forward")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.84))
                }

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                    .stroke(Color.white.opacity(0.30), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            .shadow(
                color: .black.opacity(isPressed ? 0.16 : 0.09),
                radius: isPressed ? 14 : 10,
                x: 0,
                y: isPressed ? 8 : 5
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    QuickActionButton(
        symbol: "drop.fill",
        title: "喂奶",
        subtitle: "2小时前",
        gradient: AppTheme.feedingGradient,
        action: {}
    )
    .padding()
}
