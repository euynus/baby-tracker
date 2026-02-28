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

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 54)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .cardStyle()
        }
        .buttonStyle(.plain)
        .scaleButton(scale: 0.98)
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
