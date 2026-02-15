//
//  iCloudSyncView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct iCloudSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var cloudManager: CloudKitManager

    init(cloudManager: CloudKitManager = .shared) {
        self.cloudManager = cloudManager
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                statusHeroCard
                syncStatusCard
                actionsCard
                helpCard
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("iCloud 同步")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .onAppear {
            cloudManager.checkiCloudStatus()
        }
    }

    private var statusHeroCard: some View {
        HStack(spacing: 12) {
            Image(systemName: cloudManager.iCloudAvailable ? "icloud.fill" : "icloud.slash.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("iCloud 状态")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(cloudManager.iCloudAvailable ? "可用，可在设备间同步" : "不可用，请检查 Apple ID")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer()
        }
        .padding(16)
        .gradientCard([AppTheme.secondary, AppTheme.brand])
    }

    private var syncStatusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("同步状态")
                .font(.headline)

            statusRow

            if let lastSync = cloudManager.lastSyncTime {
                row(symbol: "clock.arrow.circlepath", title: "上次同步", trailing: lastSync.formatted(date: .omitted, time: .shortened))
            }
        }
        .padding(14)
        .cardStyle()
    }

    @ViewBuilder
    private var statusRow: some View {
        switch cloudManager.syncStatus {
        case .idle:
            row(symbol: "checkmark.circle", title: "当前", trailing: "就绪", trailingColor: .secondary)

        case .syncing:
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(AppTheme.secondary)
                Text("同步中")
                    .font(.subheadline)
                Spacer()
                ProgressView()
            }

        case .success:
            row(symbol: "checkmark.circle.fill", title: "当前", trailing: "成功", trailingColor: .green)

        case .error(let message):
            VStack(alignment: .leading, spacing: 6) {
                row(symbol: "exclamationmark.triangle.fill", title: "当前", trailing: "失败", trailingColor: .red)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var actionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("操作")
                .font(.headline)

            Button(action: { cloudManager.manualSync(modelContext: modelContext) }) {
                Label("立即同步", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: canSync ? [AppTheme.secondary, AppTheme.brand] : [Color.gray.opacity(0.35), Color.gray.opacity(0.45)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            }
            .disabled(!canSync)
            .scaleButton()
        }
        .padding(14)
        .cardStyle()
    }

    private var helpCard: some View {
        NavigationLink {
            VStack(alignment: .leading, spacing: 12) {
                Text("iCloud 设置帮助")
                    .font(.title3.weight(.semibold))
                Text("请在系统设置中登录 Apple ID，并在 iCloud 中开启本应用权限。数据会由系统自动同步。")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("帮助")
            .appPageBackground()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(AppTheme.secondary)
                Text("iCloud 设置帮助")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private var canSync: Bool {
        cloudManager.iCloudAvailable && cloudManager.syncStatus != .syncing
    }

    private func row(symbol: String, title: String, trailing: String, trailingColor: Color = .primary) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
                .frame(width: 28, height: 28)
                .background(AppTheme.secondary.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(trailing)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(trailingColor)
        }
    }
}

#Preview {
    NavigationStack {
        iCloudSyncView()
    }
}
