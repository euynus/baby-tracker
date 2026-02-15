//
//  GrowthChartView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData
import Charts

struct GrowthChartView: View {
    let baby: Baby
    
    @Query private var growthRecords: [GrowthRecord]
    @State private var chartType: ChartType = .weight
    
    enum ChartType: String, CaseIterable {
        case weight = "体重"
        case height = "身高"
        case headCircumference = "头围"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Chart type picker
                Picker("图表类型", selection: $chartType) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Chart
                chartView
                    .frame(height: 300)
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                
                // Legend
                legendView
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                
                // Latest measurement
                if let latest = latestMeasurement {
                    latestCard(measurement: latest)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("生长曲线")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
    }
    
    @ViewBuilder
    private var chartView: some View {
        let records = growthRecords.filter { $0.babyId == baby.id }
            .sorted { $0.timestamp < $1.timestamp }
        
        switch chartType {
        case .weight:
            weightChart(records: records)
        case .height:
            heightChart(records: records)
        case .headCircumference:
            headChart(records: records)
        }
    }
    
    private func weightChart(records: [GrowthRecord]) -> some View {
        let ageInMonths = getAgeInMonths(from: baby.birthday)
        let whoData = WHOStandards.weightPercentiles(gender: baby.gender, ageMonths: min(ageInMonths, 24))
        
        return Chart {
            // WHO percentiles (background reference)
            ForEach(whoData.indices, id: \.self) { index in
                LineMark(
                    x: .value("月龄", whoData[index].month),
                    y: .value("体重", whoData[index].p50)
                )
                .foregroundStyle(Color.gray.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
            }
            
            // Baby's actual data
            ForEach(records, id: \.id) { record in
                if let weight = record.weight {
                    let ageMonths = getAgeInMonths(from: baby.birthday, to: record.timestamp)
                    PointMark(
                        x: .value("月龄", ageMonths),
                        y: .value("体重", weight / 1000)
                    )
                    .foregroundStyle(Color.blue)
                    .symbol(.circle)
                    .symbolSize(100)
                    
                    LineMark(
                        x: .value("月龄", ageMonths),
                        y: .value("体重", weight / 1000)
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }
        }
        .chartXAxisLabel("月龄")
        .chartYAxisLabel("体重 (kg)")
    }
    
    private func heightChart(records: [GrowthRecord]) -> some View {
        let ageInMonths = getAgeInMonths(from: baby.birthday)
        let whoData = WHOStandards.heightPercentiles(gender: baby.gender, ageMonths: min(ageInMonths, 24))
        
        return Chart {
            // WHO percentiles
            ForEach(whoData.indices, id: \.self) { index in
                LineMark(
                    x: .value("月龄", whoData[index].month),
                    y: .value("身高", whoData[index].p50)
                )
                .foregroundStyle(Color.gray.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
            }
            
            // Baby's data
            ForEach(records, id: \.id) { record in
                if let height = record.height {
                    let ageMonths = getAgeInMonths(from: baby.birthday, to: record.timestamp)
                    PointMark(
                        x: .value("月龄", ageMonths),
                        y: .value("身高", height)
                    )
                    .foregroundStyle(Color.green)
                    .symbol(.circle)
                    .symbolSize(100)
                    
                    LineMark(
                        x: .value("月龄", ageMonths),
                        y: .value("身高", height)
                    )
                    .foregroundStyle(Color.green)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }
        }
        .chartXAxisLabel("月龄")
        .chartYAxisLabel("身高 (cm)")
    }
    
    private func headChart(records: [GrowthRecord]) -> some View {
        return Chart {
            ForEach(records, id: \.id) { record in
                if let headCircumference = record.headCircumference {
                    let ageMonths = getAgeInMonths(from: baby.birthday, to: record.timestamp)
                    PointMark(
                        x: .value("月龄", ageMonths),
                        y: .value("头围", headCircumference)
                    )
                    .foregroundStyle(Color.purple)
                    .symbol(.circle)
                    .symbolSize(100)
                    
                    LineMark(
                        x: .value("月龄", ageMonths),
                        y: .value("头围", headCircumference)
                    )
                    .foregroundStyle(Color.purple)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }
        }
        .chartXAxisLabel("月龄")
        .chartYAxisLabel("头围 (cm)")
    }
    
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("图例")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(chartColor)
                        .frame(width: 8, height: 8)
                    Text("实际数据")
                        .font(.caption)
                }
                
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 20, height: 2)
                    Text("WHO 标准（50%）")
                        .font(.caption)
                }
            }
        }
    }
    
    private var chartColor: Color {
        switch chartType {
        case .weight: return .blue
        case .height: return .green
        case .headCircumference: return .purple
        }
    }
    
    private var latestMeasurement: GrowthRecord? {
        growthRecords
            .filter { $0.babyId == baby.id }
            .sorted { $0.timestamp > $1.timestamp }
            .first
    }
    
    private func latestCard(measurement: GrowthRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最新测量")
                .font(.headline)
            
            VStack(spacing: 8) {
                if let weight = measurement.weight {
                    measurementRow(symbol: "scalemass.fill", label: "体重", value: String(format: "%.2f kg", weight / 1000))
                }
                
                if let height = measurement.height {
                    measurementRow(symbol: "ruler.fill", label: "身高", value: String(format: "%.1f cm", height))
                }
                
                if let head = measurement.headCircumference {
                    measurementRow(symbol: "circle.dashed", label: "头围", value: String(format: "%.1f cm", head))
                }
                
                Divider()
                
                HStack {
                    Text("记录日期")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(measurement.timestamp, style: .date)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .cardStyle()
        }
        .padding(12)
        .cardStyle()
    }
    
    private func measurementRow(symbol: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(chartColor)
                .frame(width: 24, height: 24)
                .background(chartColor.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(chartColor)
        }
    }
    
    private func getAgeInMonths(from birthday: Date, to date: Date = Date()) -> Int {
        let components = Calendar.current.dateComponents([.month], from: birthday, to: date)
        return components.month ?? 0
    }
}

// WHO Growth Standards (simplified data)
struct WHOStandards {
    struct Percentile {
        let month: Int
        let p50: Double
    }
    
    static func weightPercentiles(gender: Gender, ageMonths: Int) -> [Percentile] {
        // WHO 2006 standards (simplified, 50th percentile only)
        let maleData: [Percentile] = [
            Percentile(month: 0, p50: 3.3),
            Percentile(month: 1, p50: 4.5),
            Percentile(month: 2, p50: 5.6),
            Percentile(month: 3, p50: 6.4),
            Percentile(month: 6, p50: 7.9),
            Percentile(month: 9, p50: 9.0),
            Percentile(month: 12, p50: 9.6),
            Percentile(month: 24, p50: 12.2)
        ]
        
        let femaleData: [Percentile] = [
            Percentile(month: 0, p50: 3.2),
            Percentile(month: 1, p50: 4.2),
            Percentile(month: 2, p50: 5.1),
            Percentile(month: 3, p50: 5.8),
            Percentile(month: 6, p50: 7.3),
            Percentile(month: 9, p50: 8.2),
            Percentile(month: 12, p50: 8.9),
            Percentile(month: 24, p50: 11.5)
        ]
        
        return gender == .male ? maleData : femaleData
    }
    
    static func heightPercentiles(gender: Gender, ageMonths: Int) -> [Percentile] {
        let maleData: [Percentile] = [
            Percentile(month: 0, p50: 49.9),
            Percentile(month: 1, p50: 54.7),
            Percentile(month: 2, p50: 58.4),
            Percentile(month: 3, p50: 61.4),
            Percentile(month: 6, p50: 67.6),
            Percentile(month: 9, p50: 72.0),
            Percentile(month: 12, p50: 75.7),
            Percentile(month: 24, p50: 87.1)
        ]
        
        let femaleData: [Percentile] = [
            Percentile(month: 0, p50: 49.1),
            Percentile(month: 1, p50: 53.7),
            Percentile(month: 2, p50: 57.1),
            Percentile(month: 3, p50: 59.8),
            Percentile(month: 6, p50: 65.7),
            Percentile(month: 9, p50: 70.1),
            Percentile(month: 12, p50: 74.0),
            Percentile(month: 24, p50: 85.7)
        ]
        
        return gender == .male ? maleData : femaleData
    }
}

#Preview {
    NavigationStack {
        GrowthChartView(baby: Baby(name: "小宝", birthday: Date().addingTimeInterval(-90 * 24 * 3600), gender: .male))
    }
    .modelContainer(for: [GrowthRecord.self])
}
