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
    @State private var feedingInterval: Double = 3 * 3600 // 3 hours
    
    @State private var diaperReminderEnabled = false
    @State private var diaperInterval: Double = 2 * 3600 // 2 hours
    
    let baby: Baby

    private var feedingEnabledKey: String { "feedingReminderEnabled.\(baby.id.uuidString)" }
    private var feedingIntervalKey: String { "feedingInterval.\(baby.id.uuidString)" }
    private var diaperEnabledKey: String { "diaperReminderEnabled.\(baby.id.uuidString)" }
    private var diaperIntervalKey: String { "diaperInterval.\(baby.id.uuidString)" }
    
    var body: some View {
        Form {
            Section {
                if !notificationManager.isAuthorized {
                    Button("开启通知权限") {
                        Task {
                            await notificationManager.requestAuthorization()
                        }
                    }
                } else {
                    Text("✓ 通知权限已开启")
                        .foregroundStyle(.green)
                }
            } header: {
                Text("通知权限")
            } footer: {
                Text("需要开启通知权限才能接收提醒")
            }
            
            Section("喂奶提醒") {
                Toggle("启用提醒", isOn: $feedingReminderEnabled)
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
                
                if feedingReminderEnabled {
                    Picker("间隔时间", selection: $feedingInterval) {
                        Text("2小时").tag(2.0 * 3600)
                        Text("3小时").tag(3.0 * 3600)
                        Text("4小时").tag(4.0 * 3600)
                        Text("6小时").tag(6.0 * 3600)
                    }
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
                }
            }
            
            Section("换尿布提醒") {
                Toggle("启用提醒", isOn: $diaperReminderEnabled)
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
                
                if diaperReminderEnabled {
                    Picker("间隔时间", selection: $diaperInterval) {
                        Text("1小时").tag(1.0 * 3600)
                        Text("2小时").tag(2.0 * 3600)
                        Text("3小时").tag(3.0 * 3600)
                        Text("4小时").tag(4.0 * 3600)
                    }
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
                }
            }
        }
        .navigationTitle("提醒设置")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
            Task {
                await notificationManager.refreshAuthorizationStatus()
            }
        }
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
