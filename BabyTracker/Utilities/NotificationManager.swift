//
//  NotificationManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false

    private init() {
        Task {
            await refreshAuthorizationStatus()
        }
    }
    
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                isAuthorized = granted
            }
        } catch {
            print("通知权限请求失败: \(error)")
        }
    }
    
    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        }
    }

    func scheduleFeedingReminder(interval: TimeInterval, babyId: UUID, babyName: String) {
        let content = UNMutableNotificationContent()
        content.title = "喂奶提醒"
        content.body = "该给\(babyName)喂奶了 🍼"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(
            identifier: "feeding-\(babyId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("添加喂奶提醒失败: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDiaperReminder(interval: TimeInterval, babyId: UUID, babyName: String) {
        let content = UNMutableNotificationContent()
        content.title = "换尿布提醒"
        content.body = "该给\(babyName)换尿布了 💩"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(
            identifier: "diaper-\(babyId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("添加换尿布提醒失败: \(error.localizedDescription)")
            }
        }
    }

    func scheduleVaccinationReminder(
        baby: Baby,
        records: [VaccinationRecord],
        track: VaccinationTrack,
        daysAhead: Int
    ) {
        guard let next = VaccinationSchedule.nextPendingMilestone(
            for: baby,
            records: records,
            track: track
        ) else {
            cancelReminder(type: "vaccine", babyId: baby.id)
            return
        }

        let calendar = Calendar.current
        let dueDate = calendar.startOfDay(for: next.dueDate)
        let reminderDay = calendar.date(byAdding: .day, value: -daysAhead, to: dueDate) ?? dueDate

        // Normalize to a daytime reminder for better visibility.
        let reminderDate = calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: reminderDay
        ) ?? reminderDay

        if reminderDate <= Date.now {
            // If the target time has passed, schedule an immediate one-time reminder.
            let content = UNMutableNotificationContent()
            content.title = "疫苗提醒"
            content.body = "\(baby.name)：\(next.plan.vaccineName)\(next.plan.doseLabel)已到提醒时间"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(
                identifier: "vaccine-\(baby.id.uuidString)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("添加疫苗提醒失败: \(error.localizedDescription)")
                }
            }
            return
        }

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )

        let content = UNMutableNotificationContent()
        content.title = "疫苗提醒"
        content.body = "\(baby.name)：请按时接种\(next.plan.vaccineName)\(next.plan.doseLabel)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "vaccine-\(baby.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("添加疫苗提醒失败: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelReminder(type: String, babyId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["\(type)-\(babyId.uuidString)"]
        )
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
