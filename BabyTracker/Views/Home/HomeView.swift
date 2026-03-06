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
                        todayFocusCard
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

    private var todayFocusCard: some View {
        let focus = currentFocus

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("今日关注", systemImage: focus.icon)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.92))
                Spacer()
                if case .activeSleep(let sleep, _) = focus {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text(formatDuration(max(0, context.date.timeIntervalSince(sleep.startTime))))
                            .font(.caption.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                }
            }

            Text(focus.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(focus.detail)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))

            if let secondary = focus.secondary {
                Text(secondary)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.84))
            }

            Button(focus.buttonTitle) {
                handleFocusAction(focus.action)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(focus.buttonForeground)
            .minimumTappableSize()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .gradientCard(focus.gradient)
        .fadeIn(delay: 0.05)
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
        let today = Date.now
        return selectedBabySleepRecords
            .reduce(0.0) { total, record in
                total + record.duration(overlapping: today)
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
        let track = VaccinationSchedule.storedTrack(for: selectedBaby.id)
        guard let next = VaccinationSchedule.nextPendingMilestone(
            for: selectedBaby,
            records: selectedBabyVaccinationRecords,
            track: track
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

    private var currentFocus: HomeFocus {
        if let activeSleep {
            return .activeSleep(
                sleep: activeSleep,
                startedAt: formatClock(activeSleep.startTime)
            )
        }

        if let selectedBaby {
            let track = VaccinationSchedule.storedTrack(for: selectedBaby.id)
            if let next = VaccinationSchedule.nextPendingMilestone(
                for: selectedBaby,
                records: selectedBabyVaccinationRecords,
                track: track
            ) {
                let calendar = Calendar.current
                let dayOffset = calendar.dateComponents(
                    [.day],
                    from: calendar.startOfDay(for: Date.now),
                    to: calendar.startOfDay(for: next.dueDate)
                ).day ?? 0

                if dayOffset <= 0 {
                    return .vaccination(
                        title: "\(next.plan.vaccineName) \(next.plan.doseLabel)",
                        detail: dayOffset < 0 ? "已逾期，建议尽快补种或登记记录。" : "今天应种，建议尽快查看接种安排。",
                        secondary: "方案：\(track.title) · 推荐：\(next.plan.ageDescription)"
                    )
                }

                if dayOffset <= 7 {
                    return .vaccination(
                        title: "\(next.plan.vaccineName) \(next.plan.doseLabel)",
                        detail: "\(dayOffset)天后应种，提前确认门诊安排会更稳妥。",
                        secondary: "方案：\(track.title) · 建议日期：\(focusDateText(next.dueDate))"
                    )
                }
            }
        }

        let todayRecords = getTodayRecords()
        if todayRecords.isEmpty {
            return .emptyDay
        }

        return .progress(
            count: todayRecords.count,
            latestSummary: timelineSummary(for: todayRecords[0])
        )
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

    private func handleFocusAction(_ action: HomeFocusAction) {
        switch action {
        case .feeding:
            showingFeedingSheet = true
        case .sleep:
            showingSleepSheet = true
        case .vaccination:
            showingVaccinationSheet = true
        }
    }

    private func timelineSummary(for record: TimelineRecord) -> String {
        switch record {
        case .feeding(let feeding):
            return "最近一次喂奶在\(timeAgo(from: feeding.timestamp))"
        case .sleep(let sleep):
            if sleep.isActive {
                return "最近一次记录为睡眠中，开始于\(formatClock(sleep.startTime))"
            }
            return "最近一次睡眠开始于\(formatClock(sleep.startTime))"
        case .diaper(let diaper):
            return "最近一次尿布记录在\(timeAgo(from: diaper.timestamp))"
        case .vaccination(let vaccination):
            return "今天已登记\(vaccination.vaccineName)\(vaccination.doseLabel)"
        }
    }

    private func formatClock(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func focusDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    private func getTodayRecords() -> [TimelineRecord] {
        let calendar = Calendar.current

        var records: [TimelineRecord] = []

        selectedBabyFeedingRecords
            .filter { calendar.isDateInToday($0.timestamp) }
            .forEach { records.append(.feeding($0)) }

        selectedBabySleepRecords
            .filter { $0.duration(overlapping: Date.now, calendar: calendar) > 0 }
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

private enum HomeFocusAction {
    case feeding
    case sleep
    case vaccination
}

private enum HomeFocus {
    case activeSleep(sleep: SleepRecord, startedAt: String)
    case vaccination(title: String, detail: String, secondary: String)
    case emptyDay
    case progress(count: Int, latestSummary: String)

    var icon: String {
        switch self {
        case .activeSleep:
            return "moon.zzz.fill"
        case .vaccination:
            return "syringe.fill"
        case .emptyDay:
            return "sparkles"
        case .progress:
            return "checklist"
        }
    }

    var title: String {
        switch self {
        case .activeSleep:
            return "宝宝正在睡眠"
        case .vaccination(let title, _, _):
            return title
        case .emptyDay:
            return "开始今天第一条记录"
        case .progress(let count, _):
            return "今天已记录 \(count) 条"
        }
    }

    var detail: String {
        switch self {
        case .activeSleep(_, let startedAt):
            return "本次睡眠从 \(startedAt) 开始，首页会持续显示实时计时。"
        case .vaccination(_, let detail, _):
            return detail
        case .emptyDay:
            return "先记一条喂奶、睡眠或尿布，今天的时间线就会自动建立。"
        case .progress(_, let latestSummary):
            return latestSummary
        }
    }

    var secondary: String? {
        switch self {
        case .activeSleep:
            return "需要结束本次睡眠时，可直接从这里进入计时页。"
        case .vaccination(_, _, let secondary):
            return secondary
        case .emptyDay:
            return "建议先从最常用的喂奶记录开始。"
        case .progress:
            return "继续补充记录，晚些时候回看会更完整。"
        }
    }

    var buttonTitle: String {
        switch self {
        case .activeSleep:
            return "查看计时"
        case .vaccination:
            return "查看疫苗"
        case .emptyDay:
            return "记录喂奶"
        case .progress:
            return "继续记录"
        }
    }

    var buttonForeground: Color {
        switch self {
        case .activeSleep:
            return AppTheme.sleep
        case .vaccination:
            return AppTheme.vaccine
        case .emptyDay:
            return AppTheme.feeding
        case .progress:
            return AppTheme.brand
        }
    }

    var gradient: [Color] {
        switch self {
        case .activeSleep:
            return AppTheme.sleepGradient
        case .vaccination:
            return AppTheme.vaccineGradient
        case .emptyDay:
            return AppTheme.feedingGradient
        case .progress:
            return AppTheme.heroGradient
        }
    }

    var action: HomeFocusAction {
        switch self {
        case .activeSleep:
            return .sleep
        case .vaccination:
            return .vaccination
        case .emptyDay, .progress:
            return .feeding
        }
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
