//
//  PhotoRecord.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftData

@Model
final class PhotoRecord {
    var id: UUID
    var babyId: UUID
    var timestamp: Date
    var imageData: Data
    var caption: String?
    
    // Associated record IDs (optional)
    var feedingRecordId: UUID?
    var sleepRecordId: UUID?
    var diaperRecordId: UUID?
    var growthRecordId: UUID?
    
    init(babyId: UUID, timestamp: Date, imageData: Data, caption: String? = nil) {
        self.id = UUID()
        self.babyId = babyId
        self.timestamp = timestamp
        self.imageData = imageData
        self.caption = caption
    }
}
