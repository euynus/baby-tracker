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

    var education: VaccinationEducation {
        VaccinationEducationLibrary.education(for: self)
    }

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

struct VaccinationEducation {
    let summary: String
    let protectsAgainst: String
    let whyItMatters: String
    let reminder: String
}

private enum VaccinationEducationLibrary {
    static func education(for plan: VaccinationPlanItem) -> VaccinationEducation {
        let name = plan.vaccineName

        if name.contains("卡介苗") {
            return VaccinationEducation(
                summary: "卡介苗主要用于预防结核病，尤其是婴幼儿更容易出现的重症结核表现。",
                protectsAgainst: "重点保护结核性脑膜炎和播散性结核等严重结核病。",
                whyItMatters: "新生儿和婴幼儿感染结核后，更容易发展成重症，因此通常建议出生后尽早接种。",
                reminder: "接种后局部可能出现小结节、结痂或留疤，属于常见反应；异常红肿、化脓或发热应咨询门诊。"
            )
        }

        if name.contains("乙肝疫苗") {
            return VaccinationEducation(
                summary: "乙肝疫苗用于预防乙型肝炎病毒感染，是婴儿期非常重要的基础疫苗。",
                protectsAgainst: "可降低乙肝病毒感染，以及后续慢性肝炎、肝硬化和肝癌风险。",
                whyItMatters: "越早建立保护越能减少母婴传播和婴幼儿早期感染后的慢性化风险。",
                reminder: "按程序完成全程接种更重要；如遇接种延迟，应按门诊建议补种，不必自行重启全程。"
            )
        }

        if name.contains("百白破疫苗") {
            return VaccinationEducation(
                summary: "百白破疫苗用于预防白喉、百日咳和破伤风三种疾病。",
                protectsAgainst: "其中百日咳对小月龄婴儿风险较高，白喉和破伤风也可能导致严重并发症。",
                whyItMatters: "婴儿期分次接种可以逐步建立保护，减少严重呼吸道感染和神经系统并发症风险。",
                reminder: "接种后常见轻度发热、哭闹或局部红肿；若高热持续或精神反应差，应及时就医。"
            )
        }

        if name.contains("脊灰灭活疫苗") {
            return VaccinationEducation(
                summary: "脊灰灭活疫苗（IPV）用于预防脊髓灰质炎，属于灭活疫苗。",
                protectsAgainst: "脊灰可导致肢体无力甚至永久性瘫痪，重症时还可能影响呼吸肌。",
                whyItMatters: "婴儿期尽早建立基础免疫，有助于降低脊灰病毒导致重症并发症的风险。",
                reminder: "灭活疫苗不含活病毒，通常耐受性较好；仍建议按门诊安排完成后续剂次。"
            )
        }

        if name.contains("脊灰减毒活疫苗") {
            return VaccinationEducation(
                summary: "脊灰减毒活疫苗（bOPV）同样用于预防脊髓灰质炎，常用于后续程序强化保护。",
                protectsAgainst: "主要帮助建立针对脊灰病毒的持续保护，并增强肠道相关免疫。",
                whyItMatters: "与前序脊灰程序配合使用，可以完善婴儿期的脊灰免疫屏障。",
                reminder: "属于口服减毒活疫苗时，应按接种门诊要求配合；具体剂型和程序以当地门诊安排为准。"
            )
        }

        if name.contains("A群流脑多糖疫苗") {
            return VaccinationEducation(
                summary: "A群流脑多糖疫苗用于预防A群脑膜炎奈瑟菌引起的流行性脑脊髓膜炎。",
                protectsAgainst: "流脑可引起脑膜炎和败血症，起病急，重症进展快。",
                whyItMatters: "婴幼儿免疫系统尚未成熟，按月龄建立保护有助于降低重症和聚集性传播风险。",
                reminder: "接种安排可能因地区门诊执行细则略有差异，最终以接种证和属地门诊通知为准。"
            )
        }

        if name.contains("麻腮风疫苗") {
            return VaccinationEducation(
                summary: "麻腮风疫苗（MMR）用于同时预防麻疹、流行性腮腺炎和风疹。",
                protectsAgainst: "麻疹传染性很强，风疹和腮腺炎也可能带来严重并发症。",
                whyItMatters: "在适龄阶段接种，有助于尽早建立群体和个体保护，降低暴发传播风险。",
                reminder: "属于减毒活疫苗，接种后如出现轻度发热或皮疹可先观察；持续不适应联系门诊。"
            )
        }

        if name.contains("乙脑减毒活疫苗") {
            return VaccinationEducation(
                summary: "乙脑减毒活疫苗用于预防乙型脑炎，这是一种经蚊虫传播的病毒性疾病。",
                protectsAgainst: "乙脑重症可累及中枢神经系统，造成脑炎、抽搐或长期神经系统后遗症。",
                whyItMatters: "在流行地区和流行季前建立保护尤其重要，儿童是重点保护人群。",
                reminder: "除按时接种外，防蚊措施仍然重要；出现持续高热或神经系统症状应立即就医。"
            )
        }

        if name.contains("五联疫苗") {
            return VaccinationEducation(
                summary: "五联疫苗把百白破、脊灰和 Hib 相关保护整合在同一次接种中。",
                protectsAgainst: "可同时预防白喉、百日咳、破伤风、脊髓灰质炎以及 b 型流感嗜血杆菌引起的侵袭性感染。",
                whyItMatters: "联合疫苗可减少单次接种针次，同时覆盖多种婴幼儿阶段的重要感染性疾病。",
                reminder: "不同门诊可提供的联合疫苗品牌和程序可能不同，是否适用以接种门诊评估为准。"
            )
        }

        if name.contains("肺炎球菌结合疫苗") {
            return VaccinationEducation(
                summary: "肺炎球菌结合疫苗用于预防部分常见肺炎链球菌血清型引起的感染。",
                protectsAgainst: "可降低侵袭性肺炎球菌病、肺炎、中耳炎等风险，婴幼儿是重点保护人群。",
                whyItMatters: "小月龄儿童更容易因肺炎链球菌出现重症感染，按程序接种有助于尽早建立保护。",
                reminder: "这是自费可选疫苗之一，具体剂型和补种节奏需结合起始月龄和门诊可用疫苗确认。"
            )
        }

        if name.contains("轮状病毒疫苗") {
            return VaccinationEducation(
                summary: "轮状病毒疫苗用于预防轮状病毒导致的急性胃肠炎。",
                protectsAgainst: "主要帮助减少严重腹泻、呕吐和脱水，尤其是婴幼儿住院风险。",
                whyItMatters: "轮状病毒是婴幼儿严重腹泻的常见原因之一，按窗口期尽早接种更有意义。",
                reminder: "轮状疫苗通常有起始月龄和完成月龄限制，错过窗口时应尽快咨询门诊是否还能接种。"
            )
        }

        return VaccinationEducation(
            summary: "该疫苗用于在适龄阶段帮助宝宝建立针对相关传染病的免疫保护。",
            protectsAgainst: "具体保护范围以疫苗说明书、接种证和门诊告知为准。",
            whyItMatters: "婴幼儿阶段感染后更容易发生重症或并发症，按程序接种可以降低相关风险。",
            reminder: "本页为科普性介绍，具体禁忌、不良反应和补种安排请以接种门诊意见为准。"
        )
    }
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
