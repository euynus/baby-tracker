//
//  GrowthRecord.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftData

@Model
final class GrowthRecord {
    var id: UUID
    var babyId: UUID
    var timestamp: Date
    var weight: Double? // in grams
    var height: Double? // in cm
    var headCircumference: Double? // in cm
    var temperature: Double? // in Celsius
    var notes: String?
    
    init(babyId: UUID, timestamp: Date) {
        self.id = UUID()
        self.babyId = babyId
        self.timestamp = timestamp
    }
}
