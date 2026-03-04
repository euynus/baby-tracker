//
//  ExportManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftData
import PDFKit
import UniformTypeIdentifiers

class ExportManager {
    
    // MARK: - CSV Export
    
    static func exportToCSV(
        baby: Baby,
        feedingRecords: [FeedingRecord],
        sleepRecords: [SleepRecord],
        diaperRecords: [DiaperRecord],
        growthRecords: [GrowthRecord],
        vaccinationRecords: [VaccinationRecord]
    ) -> URL? {
        var csvContent = "宝宝日记导出 - \(baby.name)\n\n"
        
        // Feeding records
        csvContent += "喂养记录\n"
        csvContent += "时间,方式,左侧时长(分),右侧时长(分),奶量(ml),备注\n"
        
        for record in feedingRecords.filter({ $0.babyId == baby.id }).sorted(by: { $0.timestamp > $1.timestamp }) {
            let timestamp = formatDate(record.timestamp)
            let method = methodString(record.method)
            let leftMin = record.leftDuration.map { String($0 / 60) } ?? ""
            let rightMin = record.rightDuration.map { String($0 / 60) } ?? ""
            let amount = record.amount.map { String(format: "%.0f", $0) } ?? ""
            let notes = record.notes ?? ""
            
            csvContent += csvLine([timestamp, method, leftMin, rightMin, amount, notes])
        }
        
        csvContent += "\n睡眠记录\n"
        csvContent += "开始时间,结束时间,时长(小时),备注\n"
        
        for record in sleepRecords.filter({ $0.babyId == baby.id && $0.endTime != nil }).sorted(by: { $0.startTime > $1.startTime }) {
            guard let endTime = record.endTime else { continue }
            let start = formatDate(record.startTime)
            let end = formatDate(endTime)
            let duration = String(format: "%.1f", record.duration / 3600)
            let notes = record.notes ?? ""
            
            csvContent += csvLine([start, end, duration, notes])
        }
        
        csvContent += "\n尿布记录\n"
        csvContent += "时间,类型,颜色,性状,备注\n"
        
        for record in diaperRecords.filter({ $0.babyId == baby.id }).sorted(by: { $0.timestamp > $1.timestamp }) {
            let timestamp = formatDate(record.timestamp)
            let type = record.typeDescription
            let color = record.color ?? ""
            let consistency = record.consistency ?? ""
            let notes = record.notes ?? ""
            
            csvContent += csvLine([timestamp, type, color, consistency, notes])
        }
        
        csvContent += "\n生长记录\n"
        csvContent += "时间,体重(kg),身高(cm),头围(cm),体温(°C),备注\n"
        
        for record in growthRecords.filter({ $0.babyId == baby.id }).sorted(by: { $0.timestamp > $1.timestamp }) {
            let timestamp = formatDate(record.timestamp)
            let weight = record.weight.map { String(format: "%.2f", $0 / 1000) } ?? ""
            let height = record.height.map { String(format: "%.1f", $0) } ?? ""
            let head = record.headCircumference.map { String(format: "%.1f", $0) } ?? ""
            let temp = record.temperature.map { String(format: "%.1f", $0) } ?? ""
            let notes = record.notes ?? ""
            
            csvContent += csvLine([timestamp, weight, height, head, temp, notes])
        }

        csvContent += "\n疫苗记录\n"
        csvContent += "接种时间,方案,疫苗,剂次,推荐月龄,机构,批号,不良反应,备注\n"

        for record in vaccinationRecords.filter({ $0.babyId == baby.id }).sorted(by: { $0.administeredAt > $1.administeredAt }) {
            let administeredAt = formatDate(record.administeredAt)
            let track = record.track.title
            let vaccine = record.vaccineName
            let dose = record.doseLabel
            let recommendedAge = record.recommendedAgeDescription
            let institution = record.institution ?? ""
            let batch = record.batchNumber ?? ""
            let adverse = record.hasAdverseReaction ? "是" : "否"
            let notes = record.notes ?? ""

            csvContent += csvLine([administeredAt, track, vaccine, dose, recommendedAge, institution, batch, adverse, notes])
        }
        
        // Save to temp file
        let safeName = safeFileComponent(baby.name)
        let fileName = "宝宝日记_\(safeName)_\(Date().timeIntervalSince1970).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("CSV导出失败: \(error)")
            return nil
        }
    }
    
    // MARK: - PDF Export
    
    static func exportToPDF(
        baby: Baby,
        feedingRecords: [FeedingRecord],
        sleepRecords: [SleepRecord],
        diaperRecords: [DiaperRecord],
        growthRecords: [GrowthRecord],
        vaccinationRecords: [VaccinationRecord]
    ) -> URL? {
        let pageSize = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        let safeName = safeFileComponent(baby.name)
        let fileName = "宝宝日记_\(safeName)_\(Date().timeIntervalSince1970).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()
                
                var yPosition: CGFloat = 50
                let margin: CGFloat = 40
                
                // Title
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.black
                ]
                let title = "宝宝日记 - \(baby.name)"
                title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
                yPosition += 40
                
                // Baby info
                let infoAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.gray
                ]
                let info = "出生日期: \(formatDate(baby.birthday)) | 年龄: \(baby.age)"
                info.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: infoAttributes)
                yPosition += 30
                
                // Content attributes
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
                let contentAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
                
                // Summary statistics
                "📊 统计摘要".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: headerAttributes)
                yPosition += 25
                
                let feedingCount = feedingRecords.filter { $0.babyId == baby.id }.count
                let sleepCount = sleepRecords.filter { $0.babyId == baby.id }.count
                let diaperCount = diaperRecords.filter { $0.babyId == baby.id }.count
                let vaccinationCount = vaccinationRecords.filter { $0.babyId == baby.id }.count
                
                "总喂养次数: \(feedingCount)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: contentAttributes)
                yPosition += 20
                "总睡眠记录: \(sleepCount)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: contentAttributes)
                yPosition += 20
                "总换尿布: \(diaperCount)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: contentAttributes)
                yPosition += 20
                "总疫苗登记: \(vaccinationCount)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: contentAttributes)
                yPosition += 40
                
                // Recent records
                "🍼 最近喂养记录（最近10条）".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: headerAttributes)
                yPosition += 25
                
                let recentFeeding = feedingRecords.filter { $0.babyId == baby.id }
                    .sorted { $0.timestamp > $1.timestamp }
                    .prefix(10)
                
                for record in recentFeeding {
                    let line = "\(formatDate(record.timestamp)) - \(methodString(record.method))"
                    line.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: contentAttributes)
                    yPosition += 18
                    
                    if yPosition > pageSize.height - 50 {
                        context.beginPage()
                        yPosition = 50
                    }
                }
                
                yPosition += 20
                
                // Footer
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor.lightGray
                ]
                let footer = "导出时间: \(formatDate(Date())) | 由宝宝日记App生成"
                footer.draw(at: CGPoint(x: margin, y: pageSize.height - 30), withAttributes: footerAttributes)
            }
            
            return tempURL
        } catch {
            print("PDF导出失败: \(error)")
            return nil
        }
    }
    
    // MARK: - Helpers
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private static func methodString(_ method: FeedingMethod) -> String {
        switch method {
        case .breastfeeding: return "母乳"
        case .bottle: return "奶粉"
        case .mixed: return "混合"
        }
    }

    private static func csvLine(_ fields: [String]) -> String {
        fields.map(csvSafeField).joined(separator: ",") + "\n"
    }

    private static func csvSafeField(_ field: String) -> String {
        var sanitized = field
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        if let first = sanitized.first, ["=", "+", "-", "@", "\t"].contains(first) {
            sanitized = "'" + sanitized
        }

        sanitized = sanitized.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(sanitized)\""
    }

    private static func safeFileComponent(_ raw: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
            .union(.newlines)
            .union(.controlCharacters)

        let cleaned = raw
            .components(separatedBy: invalid)
            .joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned.isEmpty ? "未命名宝宝" : cleaned
    }
}
