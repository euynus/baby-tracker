//
//  FeedingRecord.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftData

@Model
final class FeedingRecord {
    var id: UUID = UUID()
    var babyId: UUID = UUID()
    var timestamp: Date = Date()
    var method: FeedingMethod = FeedingMethod.breastfeeding
    
    // For breastfeeding
    var leftDuration: Int? // in seconds
    var rightDuration: Int? // in seconds
    
    // For bottle/formula
    var amount: Double? // in ml
    
    var notes: String?
    
    init(babyId: UUID, timestamp: Date, method: FeedingMethod) {
        self.id = UUID()
        self.babyId = babyId
        self.timestamp = timestamp
        self.method = method
    }
    
    var totalDuration: Int {
        (leftDuration ?? 0) + (rightDuration ?? 0)
    }
    
    var durationText: String {
        let total = totalDuration
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // Backward-compatible alias used by older tests/views.
    var type: FeedingMethod {
        get { method }
        set { method = newValue }
    }

    convenience init(
        baby: Baby,
        type: FeedingMethod,
        amount: Double? = nil,
        leftDuration: Int? = nil,
        rightDuration: Int? = nil,
        timestamp: Date = Date()
    ) {
        self.init(babyId: baby.id, timestamp: timestamp, method: type)
        self.amount = amount
        self.leftDuration = leftDuration
        self.rightDuration = rightDuration
    }
}

enum FeedingMethod: String, Codable {
    case breastfeeding = "breastfeeding"
    case bottle = "bottle"
    case mixed = "mixed"
}

enum BreastSide: String, Codable {
    case left = "left"
    case right = "right"
    case both = "both"
}
