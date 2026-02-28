//
//  VaccinationSchedule.swift
//  BabyTracker
//
//  Created on 2026-02-28.
//

import Foundation

enum VaccinationTrack: String, CaseIterable, Codable, Identifiable {
    case free
    case selfPaid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: return "免费免规"
        case .selfPaid: return "自费方案"
        }
    }

    var subtitle: String {
        switch self {
        case .free: return "国家免疫规划"
        case .selfPaid: return "可选联合/增强"
        }
    }
}

struct VaccinationPlanItem: Identifiable, Hashable {
    enum DueRule: Hashable {
        case birth
        case months(Int)
    }

    let track: VaccinationTrack
    let code: String
    let vaccineName: String
    let doseLabel: String
    let ageDescription: String
    let dueRule: DueRule
    let referenceNote: String

    var id: String { "\(track.rawValue)-\(code)" }

    func dueDate(for birthday: Date, calendar: Calendar = .current) -> Date {
        let birthStart = calendar.startOfDay(for: birthday)
        switch dueRule {
        case .birth:
            return birthStart
        case .months(let months):
            return calendar.date(byAdding: .month, value: months, to: birthStart) ?? birthStart
        }
    }
}

struct VaccinationMilestone: Identifiable {
    let plan: VaccinationPlanItem
    let dueDate: Date
    let record: VaccinationRecord?

    var id: String { plan.id }
    var isCompleted: Bool { record != nil }
    var isOverdue: Bool { !isCompleted && dueDate < Date.now }
}

enum VaccinationSchedule {
    static let programVersion = "国家免疫规划（2021版）+ 百白破程序调整（2025-01-01起）"
    static let freeProgramVersion = "免费免规：国家免疫规划（2021版）+ 百白破程序调整（2025-01-01起）"
    static let selfPaidProgramVersion = "自费方案：在免规基础上增加五联/肺炎结合/轮状等可选疫苗（以门诊为准）"

    // Backward compatibility alias used by existing tests/callers.
    static let newbornProgram: [VaccinationPlanItem] = freeProgram

    static func program(for track: VaccinationTrack) -> [VaccinationPlanItem] {
        switch track {
        case .free:
            return freeProgram
        case .selfPaid:
            return selfPaidProgram
        }
    }

    static func programVersion(for track: VaccinationTrack) -> String {
        switch track {
        case .free:
            return freeProgramVersion
        case .selfPaid:
            return selfPaidProgramVersion
        }
    }

    static func milestones(
        for baby: Baby,
        records: [VaccinationRecord],
        track: VaccinationTrack = .free,
        calendar: Calendar = .current
    ) -> [VaccinationMilestone] {
        let scopedRecords = records.filter { $0.track == track }
        let map = scopedRecords.reduce(into: [String: VaccinationRecord]()) { partialResult, record in
            let current = partialResult[record.vaccineCode]
            if current == nil || (current?.administeredAt ?? .distantPast) < record.administeredAt {
                partialResult[record.vaccineCode] = record
            }
        }

        return program(for: track)
            .map { plan in
                VaccinationMilestone(
                    plan: plan,
                    dueDate: plan.dueDate(for: baby.birthday, calendar: calendar),
                    record: map[plan.code]
                )
            }
            .sorted { lhs, rhs in
                if lhs.dueDate == rhs.dueDate {
                    return lhs.plan.code < rhs.plan.code
                }
                return lhs.dueDate < rhs.dueDate
            }
    }

    static func nextPendingMilestone(
        for baby: Baby,
        records: [VaccinationRecord],
        track: VaccinationTrack = .free,
        referenceDate: Date = .now
    ) -> VaccinationMilestone? {
        let all = milestones(for: baby, records: records, track: track)
        let pending = all.filter { !$0.isCompleted }

        if let upcoming = pending
            .filter({ $0.dueDate >= referenceDate })
            .min(by: { $0.dueDate < $1.dueDate }) {
            return upcoming
        }

        return pending.min(by: { $0.dueDate < $1.dueDate })
    }

    static func dueMilestones(
        for baby: Baby,
        records: [VaccinationRecord],
        track: VaccinationTrack = .free,
        referenceDate: Date = .now
    ) -> [VaccinationMilestone] {
        milestones(for: baby, records: records, track: track).filter { $0.dueDate <= referenceDate }
    }

    static func storedTrack(for babyId: UUID, defaults: UserDefaults = .standard) -> VaccinationTrack {
        let raw = defaults.string(forKey: trackKey(for: babyId))
        return VaccinationTrack(rawValue: raw ?? "") ?? .free
    }

    static func setStoredTrack(_ track: VaccinationTrack, for babyId: UUID, defaults: UserDefaults = .standard) {
        defaults.set(track.rawValue, forKey: trackKey(for: babyId))
    }

    private static func trackKey(for babyId: UUID) -> String {
        "vaccinationTrack.\(babyId.uuidString)"
    }

    private static let freeProgram: [VaccinationPlanItem] = [
        VaccinationPlanItem(
            track: .free,
            code: "BCG-1",
            vaccineName: "卡介苗(BCG)",
            doseLabel: "第1剂",
            ageDescription: "出生时",
            dueRule: .birth,
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "HepB-1",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第1剂",
            ageDescription: "出生后24小时内",
            dueRule: .birth,
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "HepB-2",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第2剂",
            ageDescription: "1月龄",
            dueRule: .months(1),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "DTaP-1",
            vaccineName: "百白破疫苗(DTaP)",
            doseLabel: "第1剂",
            ageDescription: "2月龄",
            dueRule: .months(2),
            referenceNote: "百白破程序调整通知（2025-01-01起执行）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "Polio-1",
            vaccineName: "脊灰灭活疫苗(IPV)",
            doseLabel: "第1剂",
            ageDescription: "2月龄",
            dueRule: .months(2),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "Polio-2",
            vaccineName: "脊灰灭活疫苗(IPV)",
            doseLabel: "第2剂",
            ageDescription: "3月龄",
            dueRule: .months(3),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "DTaP-2",
            vaccineName: "百白破疫苗(DTaP)",
            doseLabel: "第2剂",
            ageDescription: "4月龄",
            dueRule: .months(4),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "Polio-3",
            vaccineName: "脊灰减毒活疫苗(bOPV)",
            doseLabel: "第3剂",
            ageDescription: "4月龄",
            dueRule: .months(4),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "DTaP-3",
            vaccineName: "百白破疫苗(DTaP)",
            doseLabel: "第3剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "HepB-3",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第3剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "MenA-1",
            vaccineName: "A群流脑多糖疫苗(MPSV-A)",
            doseLabel: "第1剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "MMR-1",
            vaccineName: "麻腮风疫苗(MMR)",
            doseLabel: "第1剂",
            ageDescription: "8月龄",
            dueRule: .months(8),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "JE-L-1",
            vaccineName: "乙脑减毒活疫苗(JE-L)",
            doseLabel: "第1剂",
            ageDescription: "8月龄",
            dueRule: .months(8),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            track: .free,
            code: "MenA-2",
            vaccineName: "A群流脑多糖疫苗(MPSV-A)",
            doseLabel: "第2剂",
            ageDescription: "9月龄",
            dueRule: .months(9),
            referenceNote: "国家免疫规划（2021版）"
        )
    ]

    // Product design track: paid alternatives and extra optional vaccines for the first year.
    private static let selfPaidProgram: [VaccinationPlanItem] = [
        VaccinationPlanItem(
            track: .selfPaid,
            code: "BCG-1",
            vaccineName: "卡介苗(BCG)",
            doseLabel: "第1剂",
            ageDescription: "出生时",
            dueRule: .birth,
            referenceNote: "免规基础"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "HepB-1",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第1剂",
            ageDescription: "出生后24小时内",
            dueRule: .birth,
            referenceNote: "免规基础"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "HepB-2",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第2剂",
            ageDescription: "1月龄",
            dueRule: .months(1),
            referenceNote: "免规基础"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "Penta-1",
            vaccineName: "五联疫苗(DTaP-IPV-Hib)",
            doseLabel: "第1剂",
            ageDescription: "2月龄",
            dueRule: .months(2),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "Penta-2",
            vaccineName: "五联疫苗(DTaP-IPV-Hib)",
            doseLabel: "第2剂",
            ageDescription: "3月龄",
            dueRule: .months(3),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "Penta-3",
            vaccineName: "五联疫苗(DTaP-IPV-Hib)",
            doseLabel: "第3剂",
            ageDescription: "4月龄",
            dueRule: .months(4),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "PCV13-1",
            vaccineName: "13价肺炎球菌结合疫苗(PCV13)",
            doseLabel: "第1剂",
            ageDescription: "2月龄",
            dueRule: .months(2),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "PCV13-2",
            vaccineName: "13价肺炎球菌结合疫苗(PCV13)",
            doseLabel: "第2剂",
            ageDescription: "4月龄",
            dueRule: .months(4),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "PCV13-3",
            vaccineName: "13价肺炎球菌结合疫苗(PCV13)",
            doseLabel: "第3剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "Rota-1",
            vaccineName: "轮状病毒疫苗",
            doseLabel: "第1剂",
            ageDescription: "2月龄",
            dueRule: .months(2),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "Rota-2",
            vaccineName: "轮状病毒疫苗",
            doseLabel: "第2剂",
            ageDescription: "4月龄",
            dueRule: .months(4),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "Rota-3",
            vaccineName: "轮状病毒疫苗",
            doseLabel: "第3剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "自费可选"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "HepB-3",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第3剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "免规基础"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "MenA-1",
            vaccineName: "A群流脑多糖疫苗(MPSV-A)",
            doseLabel: "第1剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "免规基础"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "MMR-1",
            vaccineName: "麻腮风疫苗(MMR)",
            doseLabel: "第1剂",
            ageDescription: "8月龄",
            dueRule: .months(8),
            referenceNote: "免规基础"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "JE-L-1",
            vaccineName: "乙脑减毒活疫苗(JE-L)",
            doseLabel: "第1剂",
            ageDescription: "8月龄",
            dueRule: .months(8),
            referenceNote: "免规基础"
        ),
        VaccinationPlanItem(
            track: .selfPaid,
            code: "MenA-2",
            vaccineName: "A群流脑多糖疫苗(MPSV-A)",
            doseLabel: "第2剂",
            ageDescription: "9月龄",
            dueRule: .months(9),
            referenceNote: "免规基础"
        )
    ]
}
