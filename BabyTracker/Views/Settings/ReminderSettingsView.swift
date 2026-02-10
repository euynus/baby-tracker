//
//  ReminderSettingsView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct ReminderSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    
    @AppStorage("feedingReminderEnabled") private var feedingReminderEnabled = false
    @AppStorage("feedingInterval") private var feedingInterval: Double = 3 * 3600 // 3 hours
    
    @AppStorage("diaperReminderEnabled") private var diaperReminderEnabled = false
    @AppStorage("diaperInterval") private var diaperInterval: Double = 2 * 3600 // 2 hours
    
    let baby: Baby
    
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
                        if enabled {
                            notificationManager.scheduleFeedingReminder(
                                interval: feedingInterval,
                                babyName: baby.name
                            )
                        } else {
                            notificationManager.cancelReminder(type: "feeding", babyName: baby.name)
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
                        if feedingReminderEnabled {
                            notificationManager.scheduleFeedingReminder(
                                interval: interval,
                                babyName: baby.name
                            )
                        }
                    }
                }
            }
            
            Section("换尿布提醒") {
                Toggle("启用提醒", isOn: $diaperReminderEnabled)
                    .onChange(of: diaperReminderEnabled) { _, enabled in
                        if enabled {
                            notificationManager.scheduleDiaperReminder(
                                interval: diaperInterval,
                                babyName: baby.name
                            )
                        } else {
                            notificationManager.cancelReminder(type: "diaper", babyName: baby.name)
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
                        if diaperReminderEnabled {
                            notificationManager.scheduleDiaperReminder(
                                interval: interval,
                                babyName: baby.name
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("提醒设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
    }
}
