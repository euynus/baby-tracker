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
    @Query(sort: \VaccinationRecord.administeredAt, order: .reverse) private var vaccinationRecords: [VaccinationRecord]

    @State private var selectedBaby: Baby?
    @State private var showingFeedingSheet = false
    @State private var showingSleepSheet = false
    @State private var showingDiaperSheet = false
    @State private var showingTemperatureSheet = false
    @State private var showingVaccinationSheet = false

    private let actionColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    headerCard

                    if babies.isEmpty {
                        noBabyCard
                    } else {
                        babySelector
                        quickActionsGrid
                        timelineSection
                    }
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
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
            .sheet(isPresented: $showingVaccinationSheet) {
                if let baby = selectedBaby {
                    NavigationStack {
                        VaccinationCenterView(baby: baby)
                    }
                }
            }
        }
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

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日概览")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.88))
                    Text(selectedBaby?.name ?? "欢迎使用")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(selectedBaby?.age ?? "先添加宝宝开始记录")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.88))
                }
                Spacer()
                Image(systemName: babyGlyph)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(10)
                    .background(.white.opacity(0.20))
                    .clipShape(Circle())
            }

            HStack(spacing: 8) {
                metricChip(title: "喂奶", value: "\(todayFeedingCount)次")
                metricChip(title: "尿布", value: "\(todayDiaperCount)次")
                metricChip(title: "睡眠", value: String(format: "%.1fh", todaySleepHours))
            }
        }
        .padding(18)
        .gradientCard(AppTheme.heroGradient)
    }

    private var babySelector: some View {
        Menu {
            ForEach(babies) { baby in
                Button(action: { selectedBaby = baby }) {
                    Text(baby.name)
                }
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.brand.opacity(0.18))
                        .frame(width: 36, height: 36)
                    Image(systemName: "figure.and.child.holdinghands")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.brand)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("当前宝宝")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(selectedBaby?.name ?? "选择宝宝")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .cardStyle()
        }
    }

    private var quickActionsGrid: some View {
        LazyVGrid(columns: actionColumns, spacing: 14) {
            QuickActionButton(
                symbol: "drop.fill",
                title: "喂奶",
                subtitle: lastFeedingTime,
                gradient: AppTheme.feedingGradient,
                action: { showingFeedingSheet = true }
            )

            QuickActionButton(
                symbol: "moon.stars.fill",
                title: "睡眠",
                subtitle: activeSleep != nil ? "进行中" : lastSleepTime,
                gradient: AppTheme.sleepGradient,
                action: { showingSleepSheet = true }
            )

            QuickActionButton(
                symbol: "sparkles.rectangle.stack.fill",
                title: "尿布",
                subtitle: lastDiaperTime,
                gradient: AppTheme.diaperGradient,
                action: { showingDiaperSheet = true }
            )

            QuickActionButton(
                symbol: "thermometer.medium",
                title: "体温",
                subtitle: "记录测量",
                gradient: AppTheme.growthGradient,
                action: { showingTemperatureSheet = true }
            )

            QuickActionButton(
                symbol: "syringe.fill",
                title: "疫苗",
                subtitle: nextVaccinationDueText,
                gradient: AppTheme.vaccineGradient,
                action: { showingVaccinationSheet = true }
            )
        }
        .slideIn(from: .bottom)
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日时间线")
                    .font(.title3.weight(.bold))
                Spacer()
                Text(Date.now, format: .dateTime.month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            let todayRecords = getTodayRecords()
            if todayRecords.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "text.badge.plus")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(.secondary.opacity(0.7))
                    Text("今天还没有记录")
                        .font(.headline)
                    Text("点击上方卡片，开始记录宝宝动态。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
                .cardStyle()
            } else {
                ForEach(Array(todayRecords.enumerated()), id: \.element.id) { index, record in
                    TimelineItemView(record: record)
                        .fadeIn(delay: Double(index) * 0.04)
                }
            }
        }
    }

    private var noBabyCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(AppTheme.brand)
            Text("还没有宝宝档案")
                .font(.headline)
            Text("请到“我的”页面添加宝宝信息后开始记录。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .cardStyle()
    }

    private func metricChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.88))
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var babyGlyph: String {
        guard let baby = selectedBaby else { return "heart.fill" }
        switch baby.gender {
        case .male: return "figure.child"
        case .female: return "figure.stand"
        case .other: return "figure.2"
        }
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

    private var selectedBabyVaccinationRecords: [VaccinationRecord] {
        guard let selectedBaby else { return [] }
        return vaccinationRecords.filter { $0.babyId == selectedBaby.id }
    }

    private var todayFeedingCount: Int {
        selectedBabyFeedingRecords.filter { Calendar.current.isDateInToday($0.timestamp) }.count
    }

    private var todayDiaperCount: Int {
        selectedBabyDiaperRecords.filter { Calendar.current.isDateInToday($0.timestamp) }.count
    }

    private var todaySleepHours: Double {
        selectedBabySleepRecords
            .filter { Calendar.current.isDateInToday($0.startTime) }
            .reduce(0.0) { total, record in
                if record.isActive {
                    return total + Date.now.timeIntervalSince(record.startTime)
                }
                return total + record.duration
            } / 3600
    }

    private var lastFeedingTime: String {
        guard let last = selectedBabyFeedingRecords.first else {
            return "暂无"
        }
        return timeAgo(from: last.timestamp)
    }

    private var lastSleepTime: String {
        guard let last = selectedBabySleepRecords.first(where: { !$0.isActive }) else {
            return "暂无"
        }
        return timeAgo(from: last.startTime)
    }

    private var activeSleep: SleepRecord? {
        selectedBabySleepRecords.first(where: { $0.isActive })
    }

    private var lastDiaperTime: String {
        guard let last = selectedBabyDiaperRecords.first else {
            return "暂无"
        }
        return timeAgo(from: last.timestamp)
    }

    private var nextVaccinationDueText: String {
        guard let selectedBaby else {
            return "暂无"
        }
        guard let next = VaccinationSchedule.nextPendingMilestone(
            for: selectedBaby,
            records: selectedBabyVaccinationRecords
        ) else {
            return "首年已完成"
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(next.dueDate) {
            return "今天应种"
        }
        if next.dueDate < Date.now {
            return "已逾期"
        }

        let days = calendar.dateComponents([.day], from: Date.now, to: next.dueDate).day ?? 0
        if days <= 30 {
            return "\(days)天后"
        }
        return next.plan.ageDescription
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

        var records: [TimelineRecord] = []

        selectedBabyFeedingRecords
            .filter { calendar.isDateInToday($0.timestamp) }
            .forEach { records.append(.feeding($0)) }

        selectedBabySleepRecords
            .filter { calendar.isDateInToday($0.startTime) }
            .forEach { records.append(.sleep($0)) }

        selectedBabyDiaperRecords
            .filter { calendar.isDateInToday($0.timestamp) }
            .forEach { records.append(.diaper($0)) }

        selectedBabyVaccinationRecords
            .filter { calendar.isDateInToday($0.administeredAt) }
            .forEach { records.append(.vaccination($0)) }

        return records.sorted { $0.timestamp > $1.timestamp }
    }
}

// Timeline record wrapper
enum TimelineRecord: Identifiable {
    case feeding(FeedingRecord)
    case sleep(SleepRecord)
    case diaper(DiaperRecord)
    case vaccination(VaccinationRecord)

    var id: UUID {
        switch self {
        case .feeding(let record): return record.id
        case .sleep(let record): return record.id
        case .diaper(let record): return record.id
        case .vaccination(let record): return record.id
        }
    }

    var timestamp: Date {
        switch self {
        case .feeding(let record): return record.timestamp
        case .sleep(let record): return record.startTime
        case .diaper(let record): return record.timestamp
        case .vaccination(let record): return record.administeredAt
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self, VaccinationRecord.self])
}
