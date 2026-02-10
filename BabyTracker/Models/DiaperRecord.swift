//
//  DiaperRecord.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftData

@Model
final class DiaperRecord {
    var id: UUID
    var babyId: UUID
    var timestamp: Date
    var hasWet: Bool
    var hasDirty: Bool
    var color: String?
    var consistency: String?
    var notes: String?
    
    init(babyId: UUID, timestamp: Date, hasWet: Bool, hasDirty: Bool) {
        self.id = UUID()
        self.babyId = babyId
        self.timestamp = timestamp
        self.hasWet = hasWet
        self.hasDirty = hasDirty
    }
    
    var typeDescription: String {
        if hasWet && hasDirty {
            return "大便 + 小便"
        } else if hasDirty {
            return "大便"
        } else if hasWet {
            return "小便"
        }
        return "换尿布"
    }
}
