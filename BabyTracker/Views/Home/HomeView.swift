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
                VStack(spacing: 20) {
                    heroSection

                    if babies.isEmpty {
                        AppEmptyStateCard(
                            symbol: "person.crop.circle.badge.plus",
                            title: "还没有宝宝档案",
                            message: "先去“我的”里添加宝宝资料，首页和记录流才会完整启动。"
                        )
                    } else {
                        babySelector
                        todayMetricsSection
                        quickActionsSection
                        focusSection
                        timelineSection
                    }
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.top, 12)
                .padding(.bottom, 22)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Baby Tracker")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.brand)
                        Text("记录")
                            .font(.headline.weight(.bold))
                    }
                }
            }
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

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("今日照护")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text(selectedBaby?.name ?? "宝宝日记")
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(selectedBaby?.age ?? "把喂养、睡眠、尿布和疫苗整理进一条清晰时间线。")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.90))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 10) {
                    AppIconBadge(symbol: babyGlyph, colors: AppTheme.mintHeroGradient, size: 52)
                    Text(Date.now, format: .dateTime.month().day().weekday(.wide))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.84))
                }
            }

            HStack(spacing: 10) {
                AppStatusChip(title: "今日记录", value: "\(todayTotalRecordCount) 条")
                AppStatusChip(title: "最近喂奶", value: lastFeedingTime)
                AppStatusChip(title: "疫苗提醒", value: nextVaccinationDueText)
            }
        }
        .padding(20)
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
            HStack(spacing: 14) {
                AppIconBadge(
                    symbol: "figure.and.child.holdinghands",
                    colors: AppTheme.mintHeroGradient,
                    size: 44
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("当前照护对象")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(selectedBaby?.name ?? "选择宝宝")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(selectedBaby?.age ?? "--")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .cardStyle()
        }
    }

    private var todayMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Dashboard",
                title: "今日节奏",
                subtitle: "把喂养、睡眠、尿布和照护提醒放在同一屏。"
            )

            LazyVGrid(columns: actionColumns, spacing: 12) {
                AppMetricTile(
                    title: "喂奶",
                    value: "\(todayFeedingCount) 次",
                    detail: lastFeedingTime == "暂无" ? "今天还没开始记录" : "上次 \(lastFeedingTime)",
                    symbol: "drop.fill",
                    gradient: AppTheme.feedingGradient,
                    emphasized: true
                )

                AppMetricTile(
                    title: "睡眠",
                    value: String(format: "%.1f 小时", todaySleepHours),
                    detail: activeSleep != nil ? "当前睡眠进行中" : sleepStatusText,
                    symbol: "moon.stars.fill",
                    gradient: AppTheme.sleepGradient,
                    emphasized: true
                )

                AppMetricTile(
                    title: "尿布",
                    value: "\(todayDiaperCount) 次",
                    detail: lastDiaperTime == "暂无" ? "今日暂无更换" : "上次 \(lastDiaperTime)",
                    symbol: "sparkles.rectangle.stack.fill",
                    gradient: AppTheme.diaperGradient
                )

                AppMetricTile(
                    title: "疫苗",
                    value: nextVaccinationDueText,
                    detail: vaccinationProgressDescription,
                    symbol: "syringe.fill",
                    gradient: AppTheme.vaccineGradient
                )
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Actions",
                title: "快捷记录",
                subtitle: "常用操作保持大按钮、短路径和明确反馈。"
            )

            LazyVGrid(columns: actionColumns, spacing: 14) {
                QuickActionButton(
                    symbol: "drop.fill",
                    title: "喂奶",
                    subtitle: "直接补一条喂养记录",
                    gradient: AppTheme.feedingGradient,
                    action: { showingFeedingSheet = true }
                )

                QuickActionButton(
                    symbol: "moon.stars.fill",
                    title: "睡眠",
                    subtitle: activeSleep != nil ? "查看当前计时" : "开始或结束睡眠",
                    gradient: AppTheme.sleepGradient,
                    action: { showingSleepSheet = true }
                )

                QuickActionButton(
                    symbol: "sparkles.rectangle.stack.fill",
                    title: "尿布",
                    subtitle: "快速登记状态变化",
                    gradient: AppTheme.diaperGradient,
                    action: { showingDiaperSheet = true }
                )

                QuickActionButton(
                    symbol: "thermometer.medium",
                    title: "体温/生长",
                    subtitle: "补充今天的测量数据",
                    gradient: AppTheme.growthGradient,
                    action: { showingTemperatureSheet = true }
                )

                QuickActionButton(
                    symbol: "syringe.fill",
                    title: "疫苗中心",
                    subtitle: "查看计划与接种登记",
                    gradient: AppTheme.vaccineGradient,
                    action: { showingVaccinationSheet = true }
                )
            }
        }
        .slideIn(from: .bottom)
    }

    private var focusSection: some View {
        let focus = currentFocus

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Focus",
                title: "当前关注",
                subtitle: "把最该处理的一件事提到首页第二层。"
            )

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    Label("正在关注", systemImage: focus.icon)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.92))

                    Spacer()

                    if case .activeSleep(let sleep, _) = focus {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            Text(formatDuration(max(0, context.date.timeIntervalSince(sleep.startTime))))
                                .font(.caption.weight(.bold))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
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
                    .foregroundStyle(.white.opacity(0.92))

                if let secondary = focus.secondary {
                    Text(secondary)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.82))
                }

                Button(focus.buttonTitle) {
                    handleFocusAction(focus.action)
                }
                .buttonStyle(
                    AppPrimaryButtonStyle(
                        gradient: [.white.opacity(0.98), .white.opacity(0.90)],
                        foregroundColor: focus.buttonForeground
                    )
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .gradientCard(focus.gradient)
        }
        .fadeIn(delay: 0.05)
    }

    private var timelineSection: some View {
        let todayRecords = getTodayRecords()

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Timeline",
                title: "今日时间线",
                subtitle: "按时间回看今天的照护节奏和关键节点。"
            )

            if todayRecords.isEmpty {
                AppEmptyStateCard(
                    symbol: "text.badge.plus",
                    title: "今天还没有记录",
                    message: "先从上面的快捷记录开始，时间线会自动形成。"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(todayRecords.enumerated()), id: \.element.id) { index, record in
                        TimelineItemView(record: record)
                            .fadeIn(delay: Double(index) * 0.05)
                    }
                }
            }
        }
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

    private var todayTotalRecordCount: Int {
        getTodayRecords().count
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

    private var sleepStatusText: String {
        if activeSleep != nil {
            return "正在睡眠"
        }
        return lastSleepTime == "暂无" ? "今日暂无睡眠记录" : "上次 \(lastSleepTime)"
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

    private var vaccinationProgressDescription: String {
        guard let selectedBaby else { return "还未选择宝宝" }
        let track = VaccinationSchedule.storedTrack(for: selectedBaby.id)
        guard let next = VaccinationSchedule.nextPendingMilestone(
            for: selectedBaby,
            records: selectedBabyVaccinationRecords,
            track: track
        ) else {
            return "首年方案已记录完成"
        }
        return "\(track.title) · \(focusDateText(next.dueDate))"
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
                        detail: dayOffset < 0 ? "已经逾期，建议尽快补种或先登记既往接种记录。" : "今天应种，建议提前确认门诊安排。",
                        secondary: "方案：\(track.title) · 推荐：\(next.plan.ageDescription)"
                    )
                }

                if dayOffset <= 7 {
                    return .vaccination(
                        title: "\(next.plan.vaccineName) \(next.plan.doseLabel)",
                        detail: "\(dayOffset) 天后应种，现在安排会更从容。",
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
            return "最近一次喂奶在 \(timeAgo(from: feeding.timestamp))"
        case .sleep(let sleep):
            if sleep.isActive {
                return "最近一次记录仍在睡眠中，开始于 \(formatClock(sleep.startTime))"
            }
            return "最近一次睡眠开始于 \(formatClock(sleep.startTime))"
        case .diaper(let diaper):
            return "最近一次尿布记录在 \(timeAgo(from: diaper.timestamp))"
        case .vaccination(let vaccination):
            return "今天已登记 \(vaccination.vaccineName)\(vaccination.doseLabel)"
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
            return "这次睡眠从 \(startedAt) 开始，首页会持续显示计时。"
        case .vaccination(_, let detail, _):
            return detail
        case .emptyDay:
            return "先补一条喂奶、睡眠或尿布，今天的节奏就会自动建立。"
        case .progress(_, let latestSummary):
            return latestSummary
        }
    }

    var secondary: String? {
        switch self {
        case .activeSleep:
            return "需要结束本次睡眠时，可以直接从这里进入计时页。"
        case .vaccination(_, _, let secondary):
            return secondary
        case .emptyDay:
            return "建议先从最常用的喂奶记录开始。"
        case .progress:
            return "继续补齐今天的照护轨迹，回看会更完整。"
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
