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
    var id: UUID = UUID()
    var babyId: UUID = UUID()
    var timestamp: Date = Date()
    var hasWet: Bool = false
    var hasDirty: Bool = false
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

    // Backward-compatible aliases used by older tests/views.
    var isWet: Bool {
        get { hasWet }
        set { hasWet = newValue }
    }

    var isDirty: Bool {
        get { hasDirty }
        set { hasDirty = newValue }
    }

    enum StoolColor: String, CaseIterable, Codable {
        case yellow = "黄色"
        case green = "绿色"
        case brown = "棕色"
        case black = "黑色"
        case white = "白色"
    }

    enum StoolConsistency: String, CaseIterable, Codable {
        case loose = "糊状"
        case normal = "成形"
        case hard = "干硬"
        case watery = "稀水"
    }

    var stoolColor: StoolColor? {
        get { color.flatMap(StoolColor.init(rawValue:)) }
        set { color = newValue?.rawValue }
    }

    var stoolConsistency: StoolConsistency? {
        get { consistency.flatMap(StoolConsistency.init(rawValue:)) }
        set { consistency = newValue?.rawValue }
    }

    convenience init(
        baby: Baby,
        isWet: Bool,
        isDirty: Bool,
        stoolColor: StoolColor? = nil,
        stoolConsistency: StoolConsistency? = nil,
        timestamp: Date = Date()
    ) {
        self.init(babyId: baby.id, timestamp: timestamp, hasWet: isWet, hasDirty: isDirty)
        self.stoolColor = stoolColor
        self.stoolConsistency = stoolConsistency
    }
}
