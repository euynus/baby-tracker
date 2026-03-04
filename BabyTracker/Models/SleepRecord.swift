//
//  SleepRecord.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftData

@Model
final class SleepRecord {
    var id: UUID = UUID()
    var babyId: UUID = UUID()
    var startTime: Date = Date()
    var endTime: Date?
    var notes: String?
    
    init(babyId: UUID, startTime: Date) {
        self.id = UUID()
        self.babyId = babyId
        self.startTime = startTime
    }
    
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var durationText: String {
        let total = Int(duration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return String(format: "%d:%02d", hours, minutes)
    }
    
    var isActive: Bool {
        endTime == nil
    }

    /// Duration overlapping the given day, used for cross-day statistics.
    func duration(
        overlapping day: Date,
        calendar: Calendar = .current,
        now: Date = .now
    ) -> TimeInterval {
        let intervalEnd = endTime ?? now
        guard intervalEnd > startTime else { return 0 }

        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return 0 }

        let sleepInterval = DateInterval(start: startTime, end: intervalEnd)
        let dayInterval = DateInterval(start: dayStart, end: dayEnd)
        return sleepInterval.intersection(with: dayInterval)?.duration ?? 0
    }

    convenience init(baby: Baby, startTime: Date, endTime: Date? = nil) {
        self.init(babyId: baby.id, startTime: startTime)
        self.endTime = endTime
    }
}
