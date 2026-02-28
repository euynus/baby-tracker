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
            iconBadge

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(titleText)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(timeText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                if let detail = detailText {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var iconBadge: some View {
        Image(systemName: iconSymbol)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .padding(9)
            .background(
                LinearGradient(colors: iconGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var iconSymbol: String {
        switch record {
        case .feeding: return "drop.fill"
        case .sleep: return "moon.stars.fill"
        case .diaper: return "sparkles.rectangle.stack.fill"
        case .vaccination: return "syringe.fill"
        }
    }

    private var iconGradient: [Color] {
        switch record {
        case .feeding: return AppTheme.feedingGradient
        case .sleep: return AppTheme.sleepGradient
        case .diaper: return AppTheme.diaperGradient
        case .vaccination: return AppTheme.vaccineGradient
        }
    }

    private var titleText: String {
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
                return "母乳喂养" + (sides.isEmpty ? "" : " · " + sides.joined(separator: " + "))
            case .bottle:
                return "奶粉喂养"
            case .mixed:
                return "混合喂养"
            }

        case .sleep(let sleep):
            return sleep.isActive ? "正在睡眠" : "睡眠结束"

        case .diaper(let diaper):
            return diaper.typeDescription

        case .vaccination(let vaccination):
            return "\(vaccination.vaccineName) \(vaccination.doseLabel)"
        }
    }

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: record.timestamp)
    }

    private var detailText: String? {
        switch record {
        case .feeding(let feeding):
            var details: [String] = []
            if feeding.method == .breastfeeding && feeding.totalDuration > 0 {
                details.append("时长 \(feeding.durationText)")
            }
            if let amount = feeding.amount {
                details.append("奶量 \(Int(amount))ml")
            }
            return details.isEmpty ? nil : details.joined(separator: " · ")

        case .sleep(let sleep):
            return "时长 \(sleep.durationText)"

        case .diaper(let diaper):
            var details: [String] = []
            if let color = diaper.color {
                details.append("颜色 \(color)")
            }
            if let consistency = diaper.consistency {
                details.append(consistency)
            }
            return details.isEmpty ? nil : details.joined(separator: " · ")

        case .vaccination(let vaccination):
            var details: [String] = []
            if let institution = vaccination.institution {
                details.append(institution)
            }
            if vaccination.hasAdverseReaction {
                details.append("已记录不良反应")
            }
            return details.isEmpty ? "疫苗接种登记" : details.joined(separator: " · ")
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
