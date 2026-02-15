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
    var id: UUID = UUID()
    var babyId: UUID = UUID()
    var timestamp: Date = Date()
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

    // Backward-compatible convenience initializers used by views/tests.
    convenience init(
        baby: Baby,
        weight: Double? = nil,
        height: Double? = nil,
        headCircumference: Double? = nil,
        temperature: Double? = nil,
        timestamp: Date = Date()
    ) {
        self.init(babyId: baby.id, timestamp: timestamp)
        self.weight = weight
        self.height = height
        self.headCircumference = headCircumference
        self.temperature = temperature
    }
}
