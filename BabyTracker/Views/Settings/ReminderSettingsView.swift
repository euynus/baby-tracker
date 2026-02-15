//
//  ReminderSettingsView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct ReminderSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var feedingReminderEnabled = false
    @State private var feedingInterval: Double = 3 * 3600

    @State private var diaperReminderEnabled = false
    @State private var diaperInterval: Double = 2 * 3600

    let baby: Baby

    private var feedingEnabledKey: String { "feedingReminderEnabled.\(baby.id.uuidString)" }
    private var feedingIntervalKey: String { "feedingInterval.\(baby.id.uuidString)" }
    private var diaperEnabledKey: String { "diaperReminderEnabled.\(baby.id.uuidString)" }
    private var diaperIntervalKey: String { "diaperInterval.\(baby.id.uuidString)" }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                permissionCard
                feedingCard
                diaperCard
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("提醒设置")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .onAppear {
            loadSettings()
            Task {
                await notificationManager.refreshAuthorizationStatus()
            }
        }
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("通知权限")
                .font(.headline)

            if notificationManager.isAuthorized {
                Label("已开启通知权限", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline.weight(.semibold))
            } else {
                Text("需要开启通知权限才能接收提醒")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("开启通知权限") {
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [AppTheme.secondary, AppTheme.brand],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
                .scaleButton()
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var feedingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("喂奶提醒", systemImage: "drop.fill")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $feedingReminderEnabled)
                    .labelsHidden()
                    .onChange(of: feedingReminderEnabled) { _, enabled in
                        persistFeedingSettings()
                        if enabled {
                            notificationManager.scheduleFeedingReminder(
                                interval: feedingInterval,
                                babyId: baby.id,
                                babyName: baby.name
                            )
                        } else {
                            notificationManager.cancelReminder(type: "feeding", babyId: baby.id)
                        }
                    }
            }

            if feedingReminderEnabled {
                Text("提醒间隔")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("喂奶间隔", selection: $feedingInterval) {
                    Text("2小时").tag(2.0 * 3600)
                    Text("3小时").tag(3.0 * 3600)
                    Text("4小时").tag(4.0 * 3600)
                    Text("6小时").tag(6.0 * 3600)
                }
                .pickerStyle(.segmented)
                .onChange(of: feedingInterval) { _, interval in
                    persistFeedingSettings()
                    if feedingReminderEnabled {
                        notificationManager.scheduleFeedingReminder(
                            interval: interval,
                            babyId: baby.id,
                            babyName: baby.name
                        )
                    }
                }
            } else {
                Text("关闭状态，不会发送喂奶提醒")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var diaperCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("换尿布提醒", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $diaperReminderEnabled)
                    .labelsHidden()
                    .onChange(of: diaperReminderEnabled) { _, enabled in
                        persistDiaperSettings()
                        if enabled {
                            notificationManager.scheduleDiaperReminder(
                                interval: diaperInterval,
                                babyId: baby.id,
                                babyName: baby.name
                            )
                        } else {
                            notificationManager.cancelReminder(type: "diaper", babyId: baby.id)
                        }
                    }
            }

            if diaperReminderEnabled {
                Text("提醒间隔")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("尿布间隔", selection: $diaperInterval) {
                    Text("1小时").tag(1.0 * 3600)
                    Text("2小时").tag(2.0 * 3600)
                    Text("3小时").tag(3.0 * 3600)
                    Text("4小时").tag(4.0 * 3600)
                }
                .pickerStyle(.segmented)
                .onChange(of: diaperInterval) { _, interval in
                    persistDiaperSettings()
                    if diaperReminderEnabled {
                        notificationManager.scheduleDiaperReminder(
                            interval: interval,
                            babyId: baby.id,
                            babyName: baby.name
                        )
                    }
                }
            } else {
                Text("关闭状态，不会发送换尿布提醒")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard

        feedingReminderEnabled = defaults.object(forKey: feedingEnabledKey) as? Bool ?? false
        feedingInterval = defaults.object(forKey: feedingIntervalKey) as? Double ?? 3 * 3600

        diaperReminderEnabled = defaults.object(forKey: diaperEnabledKey) as? Bool ?? false
        diaperInterval = defaults.object(forKey: diaperIntervalKey) as? Double ?? 2 * 3600
    }

    private func persistFeedingSettings() {
        let defaults = UserDefaults.standard
        defaults.set(feedingReminderEnabled, forKey: feedingEnabledKey)
        defaults.set(feedingInterval, forKey: feedingIntervalKey)
    }

    private func persistDiaperSettings() {
        let defaults = UserDefaults.standard
        defaults.set(diaperReminderEnabled, forKey: diaperEnabledKey)
        defaults.set(diaperInterval, forKey: diaperIntervalKey)
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
    }
}
