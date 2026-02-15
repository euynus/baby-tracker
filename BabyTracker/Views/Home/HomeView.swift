//
//  HomeView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var babies: [Baby]
    @Query(sort: \FeedingRecord.timestamp, order: .reverse) private var feedingRecords: [FeedingRecord]
    @Query(sort: \SleepRecord.startTime, order: .reverse) private var sleepRecords: [SleepRecord]
    @Query(sort: \DiaperRecord.timestamp, order: .reverse) private var diaperRecords: [DiaperRecord]
    
    @State private var selectedBaby: Baby?
    @State private var showingFeedingSheet = false
    @State private var showingSleepSheet = false
    @State private var showingDiaperSheet = false
    @State private var showingTemperatureSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Baby selector
                    babySelector
                    
                    // Quick action buttons
                    quickActionsGrid
                    
                    // Today's timeline
                    if selectedBaby != nil {
                        timelineSection()
                    }
                }
                .padding()
            }
            .navigationTitle("宝宝日记")
            .sheet(isPresented: $showingFeedingSheet) {
                if let baby = selectedBaby {
                    FeedingRecordView(baby: baby)
                }
            }
            .sheet(isPresented: $showingSleepSheet) {
                if let baby = selectedBaby {
                    SleepTimerView(baby: baby)
                }
            }
            .sheet(isPresented: $showingDiaperSheet) {
                if let baby = selectedBaby {
                    DiaperRecordView(baby: baby)
                }
            }
            .sheet(isPresented: $showingTemperatureSheet) {
                if let baby = selectedBaby {
                    GrowthRecordView(baby: baby)
                }
            }
        }
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
    
    private var babySelector: some View {
        Menu {
            ForEach(babies) { baby in
                Button(action: { selectedBaby = baby }) {
                    Text(baby.name)
                }
            }
        } label: {
            HStack {
                Text("👶")
                    .font(.title2)
                Text(selectedBaby?.name ?? "选择宝宝")
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var quickActionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            QuickActionButton(
                icon: "🍼",
                title: "喂奶",
                subtitle: lastFeedingTime,
                gradient: [Color.blue.opacity(0.2), Color.blue.opacity(0.4)],
                action: { showingFeedingSheet = true }
            )

            QuickActionButton(
                icon: "💤",
                title: "睡眠",
                subtitle: activeSleep != nil ? "进行中" : lastSleepTime,
                gradient: [Color.purple.opacity(0.2), Color.purple.opacity(0.4)],
                action: { showingSleepSheet = true }
            )

            QuickActionButton(
                icon: "💩",
                title: "尿布",
                subtitle: lastDiaperTime,
                gradient: [Color.yellow.opacity(0.2), Color.yellow.opacity(0.4)],
                action: { showingDiaperSheet = true }
            )

            QuickActionButton(
                icon: "🌡️",
                title: "体温",
                subtitle: "-",
                gradient: [Color.red.opacity(0.2), Color.red.opacity(0.4)],
                action: { showingTemperatureSheet = true }
            )
        }
        .slideIn(from: .bottom)
    }
    
    private func timelineSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日记录")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text(Date.now, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Combine and sort all records for today
            let todayRecords = getTodayRecords()
            
            if todayRecords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("暂无记录")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("点击上方按钮开始记录")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .fadeIn()
            } else {
                ForEach(Array(todayRecords.enumerated()), id: \.element.id) { index, record in
                    TimelineItemView(record: record)
                        .fadeIn(delay: Double(index) * 0.05)
                }
            }
        }
    }
    
    private var lastFeedingTime: String {
        guard let last = selectedBabyFeedingRecords.first else {
            return "-"
        }
        return timeAgo(from: last.timestamp)
    }
    
    private var lastSleepTime: String {
        guard let last = selectedBabySleepRecords.first(where: { !$0.isActive }) else {
            return "-"
        }
        return timeAgo(from: last.startTime)
    }
    
    private var activeSleep: SleepRecord? {
        selectedBabySleepRecords.first(where: { $0.isActive })
    }
    
    private var lastDiaperTime: String {
        guard let last = selectedBabyDiaperRecords.first else {
            return "-"
        }
        return timeAgo(from: last.timestamp)
    }

    private var selectedBabyFeedingRecords: [FeedingRecord] {
        guard let selectedBaby else { return [] }
        return feedingRecords.filter { $0.babyId == selectedBaby.id }
    }

    private var selectedBabySleepRecords: [SleepRecord] {
        guard let selectedBaby else { return [] }
        return sleepRecords.filter { $0.babyId == selectedBaby.id }
    }

    private var selectedBabyDiaperRecords: [DiaperRecord] {
        guard let selectedBaby else { return [] }
        return diaperRecords.filter { $0.babyId == selectedBaby.id }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date.now.timeIntervalSince(date)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小时前"
        } else if minutes > 0 {
            return "\(minutes)分钟前"
        } else {
            return "刚刚"
        }
    }
    
    private func getTodayRecords() -> [TimelineRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var records: [TimelineRecord] = []
        
        // Add feeding records
        selectedBabyFeedingRecords
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .forEach { records.append(.feeding($0)) }
        
        // Add sleep records
        selectedBabySleepRecords
            .filter { calendar.isDate($0.startTime, inSameDayAs: today) }
            .forEach { records.append(.sleep($0)) }
        
        // Add diaper records
        selectedBabyDiaperRecords
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .forEach { records.append(.diaper($0)) }
        
        return records.sorted { $0.timestamp > $1.timestamp }
    }
}

// Timeline record wrapper
enum TimelineRecord: Identifiable {
    case feeding(FeedingRecord)
    case sleep(SleepRecord)
    case diaper(DiaperRecord)
    
    var id: UUID {
        switch self {
        case .feeding(let record): return record.id
        case .sleep(let record): return record.id
        case .diaper(let record): return record.id
        }
    }
    
    var timestamp: Date {
        switch self {
        case .feeding(let record): return record.timestamp
        case .sleep(let record): return record.startTime
        case .diaper(let record): return record.timestamp
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self])
}
