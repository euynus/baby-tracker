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
    
    func scheduleFeedingReminder(interval: TimeInterval, babyName: String) {
        let content = UNMutableNotificationContent()
        content.title = "喂奶提醒"
        content.body = "该给\(babyName)喂奶了 🍼"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: "feeding-\(babyName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDiaperReminder(interval: TimeInterval, babyName: String) {
        let content = UNMutableNotificationContent()
        content.title = "换尿布提醒"
        content.body = "该给\(babyName)换尿布了 💩"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: "diaper-\(babyName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelReminder(type: String, babyName: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["\(type)-\(babyName)"]
        )
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
