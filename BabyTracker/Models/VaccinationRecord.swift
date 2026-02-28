//
//  VaccinationRecord.swift
//  BabyTracker
//
//  Created on 2026-02-28.
//

import Foundation
import SwiftData

@Model
final class VaccinationRecord {
    var id: UUID = UUID()
    var babyId: UUID = UUID()
    var trackRaw: String = VaccinationTrack.free.rawValue

    // Program identity
    var vaccineCode: String = ""
    var vaccineName: String = ""
    var doseLabel: String = ""
    var recommendedAgeDescription: String = ""
    var dueDate: Date = Date()

    // Actual administration
    var administeredAt: Date = Date()
    var institution: String?
    var batchNumber: String?

    // Safety notes
    var hasAdverseReaction: Bool = false
    var reactionNotes: String?
    var notes: String?

    init(
        babyId: UUID,
        vaccineCode: String,
        vaccineName: String,
        doseLabel: String,
        recommendedAgeDescription: String,
        dueDate: Date,
        administeredAt: Date = Date(),
        track: VaccinationTrack = .free
    ) {
        self.id = UUID()
        self.babyId = babyId
        self.trackRaw = track.rawValue
        self.vaccineCode = vaccineCode
        self.vaccineName = vaccineName
        self.doseLabel = doseLabel
        self.recommendedAgeDescription = recommendedAgeDescription
        self.dueDate = dueDate
        self.administeredAt = administeredAt
    }

    var track: VaccinationTrack {
        get { VaccinationTrack(rawValue: trackRaw) ?? .free }
        set { trackRaw = newValue.rawValue }
    }
}
