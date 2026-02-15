//
//  StatisticsView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query private var babies: [Baby]
    @Query(sort: \FeedingRecord.timestamp, order: .reverse) private var feedingRecords: [FeedingRecord]
    @Query(sort: \SleepRecord.startTime, order: .reverse) private var sleepRecords: [SleepRecord]
    @Query(sort: \DiaperRecord.timestamp, order: .reverse) private var diaperRecords: [DiaperRecord]
    
    @State private var selectedBaby: Baby?
    @State private var timeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case all = "全部"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    babySelector

                    VStack(alignment: .leading, spacing: 8) {
                        Text("统计周期")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Picker("时间范围", selection: $timeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(12)
                    .cardStyle()
                    .padding(.horizontal)
                    
                    if let baby = selectedBaby {
                        feedingChart(for: baby)
                        sleepChart(for: baby)
                        diaperStats(for: baby)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("统计")
            .appPageBackground()
            .onAppear {
                if selectedBaby == nil {
                    selectedBaby = babies.first
                }
            }
            .onChange(of: babies) { _, newBabies in
                if selectedBaby == nil || !newBabies.contains(where: { $0.id == selectedBaby?.id }) {
                    selectedBaby = newBabies.first
                }
            }
        }
    }
    
    private var babySelector: some View {
        Menu {
            ForEach(babies) { baby in
                Button(action: { selectedBaby = baby }) {
                    Text(baby.name)
                }
            }
        } label: {
            HStack {
                Image(systemName: "figure.and.child.holdinghands")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.brand)
                    .padding(8)
                    .background(AppTheme.brand.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(selectedBaby?.name ?? "选择宝宝")
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .cardStyle()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Feeding Chart
    
    private func feedingChart(for baby: Baby) -> some View {
        let data = getFeedingData(for: baby)
        
        return VStack(alignment: .leading, spacing: 16) {
            sectionHeader(symbol: "drop.fill", title: "喂奶统计")
            
            Chart(data) { item in
                BarMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("次数", item.count)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
            .padding()
            .cardStyle()
            .padding(.horizontal)
            
            // Summary stats
            HStack(spacing: 16) {
                statCard(
                    label: "总次数",
                    value: "\(data.reduce(0) { $0 + $1.count })",
                    symbol: "drop.fill"
                )
                
                statCard(
                    label: "日均次数",
                    value: String(format: "%.1f", Double(data.reduce(0) { $0 + $1.count }) / Double(max(data.count, 1))),
                    symbol: "chart.bar.fill"
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Sleep Chart
    
    private func sleepChart(for baby: Baby) -> some View {
        let data = getSleepData(for: baby)
        
        return VStack(alignment: .leading, spacing: 16) {
            sectionHeader(symbol: "moon.stars.fill", title: "睡眠统计")
            
            Chart(data) { item in
                AreaMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("时长", item.hours)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.5), Color.purple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("时长", item.hours)
                )
                .foregroundStyle(Color.purple)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            }
            .frame(height: 200)
            .padding()
            .cardStyle()
            .padding(.horizontal)
            
            // Summary stats
            HStack(spacing: 16) {
                statCard(
                    label: "总睡眠",
                    value: String(format: "%.1fh", data.reduce(0.0) { $0 + $1.hours }),
                    symbol: "moon.zzz.fill"
                )
                
                statCard(
                    label: "日均睡眠",
                    value: String(format: "%.1fh", data.reduce(0.0) { $0 + $1.hours } / Double(max(data.count, 1))),
                    symbol: "chart.line.uptrend.xyaxis"
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Diaper Stats
    
    private func diaperStats(for baby: Baby) -> some View {
        let data = getDiaperData(for: baby)
        
        return VStack(alignment: .leading, spacing: 16) {
            sectionHeader(symbol: "sparkles.rectangle.stack.fill", title: "换尿布统计")
            
            HStack(spacing: 12) {
                statCard(
                    label: "小便",
                    value: "\(data.wetCount)次",
                    symbol: "drop.fill",
                    color: .cyan
                )
                
                statCard(
                    label: "大便",
                    value: "\(data.dirtyCount)次",
                    symbol: "sparkles.rectangle.stack.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                statCard(
                    label: "总次数",
                    value: "\(data.totalCount)次",
                    symbol: "chart.bar.fill",
                    color: .green
                )
                
                statCard(
                    label: "日均次数",
                    value: String(format: "%.1f", data.avgPerDay),
                    symbol: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func statCard(label: String, value: String, symbol: String, color: Color = .blue) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
                .padding(8)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }

    private func sectionHeader(symbol: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(AppTheme.brand)
            Text(title)
                .font(.title3.weight(.bold))
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Data Processing
    
    private func getFeedingData(for baby: Baby) -> [ChartData] {
        let calendar = Calendar.current
        let records = feedingRecords.filter { $0.babyId == baby.id }
        
        let startDate: Date
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        case .all:
            startDate = baby.birthday
        }
        
        var dataDict: [Date: Int] = [:]
        
        for record in records where record.timestamp >= startDate {
            let dayStart = calendar.startOfDay(for: record.timestamp)
            dataDict[dayStart, default: 0] += 1
        }
        
        return dataDict.map { ChartData(date: $0.key, count: $0.value, hours: 0) }
            .sorted { $0.date < $1.date }
    }
    
    private func getSleepData(for baby: Baby) -> [ChartData] {
        let calendar = Calendar.current
        let records = sleepRecords.filter { $0.babyId == baby.id && $0.endTime != nil }
        
        let startDate: Date
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        case .all:
            startDate = baby.birthday
        }
        
        var dataDict: [Date: TimeInterval] = [:]
        
        for record in records where record.startTime >= startDate {
            let dayStart = calendar.startOfDay(for: record.startTime)
            dataDict[dayStart, default: 0] += record.duration
        }
        
        return dataDict.map { ChartData(date: $0.key, count: 0, hours: $0.value / 3600) }
            .sorted { $0.date < $1.date }
    }
    
    private func getDiaperData(for baby: Baby) -> DiaperData {
        let calendar = Calendar.current
        let records = diaperRecords.filter { $0.babyId == baby.id }
        
        let startDate: Date
        let days: Int
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
            days = 7
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
            days = 30
        case .all:
            startDate = baby.birthday
            days = max(1, calendar.dateComponents([.day], from: baby.birthday, to: Date()).day ?? 1)
        }
        
        let filteredRecords = records.filter { $0.timestamp >= startDate }
        
        let wetCount = filteredRecords.filter { $0.hasWet }.count
        let dirtyCount = filteredRecords.filter { $0.hasDirty }.count
        let totalCount = filteredRecords.count
        
        return DiaperData(
            wetCount: wetCount,
            dirtyCount: dirtyCount,
            totalCount: totalCount,
            avgPerDay: Double(totalCount) / Double(days)
        )
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let hours: Double
}

struct DiaperData {
    let wetCount: Int
    let dirtyCount: Int
    let totalCount: Int
    let avgPerDay: Double
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self])
}
