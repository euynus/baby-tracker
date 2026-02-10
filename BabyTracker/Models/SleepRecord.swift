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
    var id: UUID
    var babyId: UUID
    var startTime: Date
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
}
