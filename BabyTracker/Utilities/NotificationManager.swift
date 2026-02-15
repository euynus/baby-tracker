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
    
    func cancelReminder(type: String, babyId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["\(type)-\(babyId.uuidString)"]
        )
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
