//
//  VaccinationSchedule.swift
//  BabyTracker
//
//  Created on 2026-02-28.
//

import Foundation

struct VaccinationPlanItem: Identifiable, Hashable {
    enum DueRule: Hashable {
        case birth
        case months(Int)
    }

    let code: String
    let vaccineName: String
    let doseLabel: String
    let ageDescription: String
    let dueRule: DueRule
    let referenceNote: String

    var id: String { code }

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

    // Focused module scope: newborn/infant core schedule (0-12 months).
    static let newbornProgram: [VaccinationPlanItem] = [
        VaccinationPlanItem(
            code: "BCG-1",
            vaccineName: "卡介苗(BCG)",
            doseLabel: "第1剂",
            ageDescription: "出生时",
            dueRule: .birth,
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "HepB-1",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第1剂",
            ageDescription: "出生后24小时内",
            dueRule: .birth,
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "HepB-2",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第2剂",
            ageDescription: "1月龄",
            dueRule: .months(1),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "DTaP-1",
            vaccineName: "百白破疫苗(DTaP)",
            doseLabel: "第1剂",
            ageDescription: "2月龄",
            dueRule: .months(2),
            referenceNote: "百白破程序调整通知（2025-01-01起执行）"
        ),
        VaccinationPlanItem(
            code: "Polio-1",
            vaccineName: "脊灰灭活疫苗(IPV)",
            doseLabel: "第1剂",
            ageDescription: "2月龄",
            dueRule: .months(2),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "Polio-2",
            vaccineName: "脊灰灭活疫苗(IPV)",
            doseLabel: "第2剂",
            ageDescription: "3月龄",
            dueRule: .months(3),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "DTaP-2",
            vaccineName: "百白破疫苗(DTaP)",
            doseLabel: "第2剂",
            ageDescription: "4月龄",
            dueRule: .months(4),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "Polio-3",
            vaccineName: "脊灰减毒活疫苗(bOPV)",
            doseLabel: "第3剂",
            ageDescription: "4月龄",
            dueRule: .months(4),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "DTaP-3",
            vaccineName: "百白破疫苗(DTaP)",
            doseLabel: "第3剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "HepB-3",
            vaccineName: "乙肝疫苗(HepB)",
            doseLabel: "第3剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "MenA-1",
            vaccineName: "A群流脑多糖疫苗(MPSV-A)",
            doseLabel: "第1剂",
            ageDescription: "6月龄",
            dueRule: .months(6),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "MMR-1",
            vaccineName: "麻腮风疫苗(MMR)",
            doseLabel: "第1剂",
            ageDescription: "8月龄",
            dueRule: .months(8),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "JE-L-1",
            vaccineName: "乙脑减毒活疫苗(JE-L)",
            doseLabel: "第1剂",
            ageDescription: "8月龄",
            dueRule: .months(8),
            referenceNote: "国家免疫规划（2021版）"
        ),
        VaccinationPlanItem(
            code: "MenA-2",
            vaccineName: "A群流脑多糖疫苗(MPSV-A)",
            doseLabel: "第2剂",
            ageDescription: "9月龄",
            dueRule: .months(9),
            referenceNote: "国家免疫规划（2021版）"
        )
    ]

    static func milestones(for baby: Baby, records: [VaccinationRecord], calendar: Calendar = .current) -> [VaccinationMilestone] {
        let map = records.reduce(into: [String: VaccinationRecord]()) { partialResult, record in
            let current = partialResult[record.vaccineCode]
            if current == nil || (current?.administeredAt ?? .distantPast) < record.administeredAt {
                partialResult[record.vaccineCode] = record
            }
        }
        return newbornProgram
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

    static func nextPendingMilestone(for baby: Baby, records: [VaccinationRecord], referenceDate: Date = .now) -> VaccinationMilestone? {
        let all = milestones(for: baby, records: records)
        let pending = all.filter { !$0.isCompleted }

        // Prefer nearest upcoming one, fallback to earliest overdue one.
        if let upcoming = pending
            .filter({ $0.dueDate >= referenceDate })
            .min(by: { $0.dueDate < $1.dueDate }) {
            return upcoming
        }

        return pending.min(by: { $0.dueDate < $1.dueDate })
    }

    static func dueMilestones(for baby: Baby, records: [VaccinationRecord], referenceDate: Date = .now) -> [VaccinationMilestone] {
        milestones(for: baby, records: records).filter { $0.dueDate <= referenceDate }
    }
}
