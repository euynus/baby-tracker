//
//  TimelineItemView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct TimelineItemView: View {
    let record: TimelineRecord
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(timeText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                if let detail = detailText {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
    
    private var icon: String {
        switch record {
        case .feeding: return "🍼"
        case .sleep: return "💤"
        case .diaper: return "💩"
        }
    }
    
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: record.timestamp)
    }
    
    private var description: String {
        switch record {
        case .feeding(let feeding):
            switch feeding.method {
            case .breastfeeding:
                var sides: [String] = []
                if let left = feeding.leftDuration, left > 0 {
                    sides.append("左侧")
                }
                if let right = feeding.rightDuration, right > 0 {
                    sides.append("右侧")
                }
                return "母乳 " + sides.joined(separator: " + ")
            case .bottle:
                return "奶粉"
            case .mixed:
                return "混合喂养"
            }
            
        case .sleep(let sleep):
            return sleep.isActive ? "睡眠中..." : "睡眠"
            
        case .diaper(let diaper):
            return diaper.typeDescription
        }
    }
    
    private var detailText: String? {
        switch record {
        case .feeding(let feeding):
            var details: [String] = []
            if feeding.method == .breastfeeding && feeding.totalDuration > 0 {
                details.append("时长: \(feeding.durationText)")
            }
            if let amount = feeding.amount {
                details.append("奶量: \(Int(amount))ml")
            }
            return details.isEmpty ? nil : details.joined(separator: " · ")
            
        case .sleep(let sleep):
            return "时长: \(sleep.durationText)"
            
        case .diaper(let diaper):
            var details: [String] = []
            if let color = diaper.color {
                details.append("颜色: \(color)")
            }
            if let consistency = diaper.consistency {
                details.append(consistency)
            }
            return details.isEmpty ? nil : details.joined(separator: " · ")
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        TimelineItemView(record: .feeding(FeedingRecord(
            babyId: UUID(),
            timestamp: Date(),
            method: .breastfeeding
        )))
        
        TimelineItemView(record: .sleep(SleepRecord(
            babyId: UUID(),
            startTime: Date().addingTimeInterval(-3600)
        )))
        
        TimelineItemView(record: .diaper(DiaperRecord(
            babyId: UUID(),
            timestamp: Date(),
            hasWet: true,
            hasDirty: true
        )))
    }
    .padding()
}
