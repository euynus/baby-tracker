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
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    AppIconBadge(symbol: symbol, colors: gradient, size: 46)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                    .fill(.clear)
                    .overlay(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 110, height: 8)
                            .padding(.top, 12)
                            .padding(.leading, 12)
                    }
            )
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
