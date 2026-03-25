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
    @Query(sort: \VaccinationRecord.administeredAt, order: .reverse) private var vaccinationRecords: [VaccinationRecord]

    @State private var selectedBaby: Baby?
    @State private var timeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case all = "全部"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroSection

                    if babies.isEmpty {
                        AppEmptyStateCard(
                            symbol: "chart.xyaxis.line",
                            title: "统计还没有内容",
                            message: "先添加宝宝并开始记录，趋势图和进度卡片就会自动建立。"
                        )
                    } else {
                        babySelector
                        timeRangeSelector

                        if let baby = selectedBaby {
                            overviewSection(for: baby)
                            feedingChart(for: baby)
                            sleepChart(for: baby)
                            diaperStats(for: baby)
                            vaccinationProgress(for: baby)
                        }
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
                        Text("统计")
                            .font(.headline.weight(.bold))
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
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("成长趋势")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text(selectedBaby?.name ?? "统计中心")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("把日常记录沉淀成可回看的照护节奏和完成度。")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.90))
                }

                Spacer()

                AppIconBadge(symbol: "chart.xyaxis.line", colors: AppTheme.growthGradient, size: 52)
            }

            HStack(spacing: 10) {
                AppStatusChip(title: "喂养趋势", value: overviewFeedingText)
                AppStatusChip(title: "睡眠趋势", value: overviewSleepText)
                AppStatusChip(title: "疫苗进度", value: overviewVaccineText)
            }
        }
        .padding(20)
        .gradientCard(AppTheme.mintHeroGradient)
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
                AppIconBadge(symbol: "figure.and.child.holdinghands", colors: AppTheme.heroGradient, size: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text("分析对象")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(selectedBaby?.name ?? "选择宝宝")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .cardStyle()
        }
        .disabled(babies.isEmpty)
    }

    private var timeRangeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Range",
                title: "统计周期",
                subtitle: "切换查看最近一周、本月或整个成长阶段。"
            )

            Picker("时间范围", selection: $timeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(16)
            .cardStyle()
        }
    }

    private func overviewSection(for baby: Baby) -> some View {
        let feeding = getFeedingData(for: baby)
        let sleep = getSleepData(for: baby)
        let diaper = getDiaperData(for: baby)
        let vaccine = getVaccinationProgress(for: baby)

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Overview",
                title: "重点摘要",
                subtitle: "先看这四个值，再决定要不要深入到图表。"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AppMetricTile(
                    title: "喂奶总次数",
                    value: "\(feeding.reduce(0) { $0 + $1.count })",
                    detail: averageFeedingText(from: feeding),
                    symbol: "drop.fill",
                    gradient: AppTheme.feedingGradient,
                    emphasized: true
                )

                AppMetricTile(
                    title: "总睡眠",
                    value: String(format: "%.1f 小时", sleep.reduce(0.0) { $0 + $1.hours }),
                    detail: averageSleepText(from: sleep),
                    symbol: "moon.stars.fill",
                    gradient: AppTheme.sleepGradient,
                    emphasized: true
                )

                AppMetricTile(
                    title: "尿布总次数",
                    value: "\(diaper.totalCount)",
                    detail: String(format: "日均 %.1f 次", diaper.avgPerDay),
                    symbol: "sparkles.rectangle.stack.fill",
                    gradient: AppTheme.diaperGradient
                )

                AppMetricTile(
                    title: "疫苗完成率",
                    value: String(format: "%.0f%%", vaccine.completionRate * 100),
                    detail: "已登记 \(vaccine.completedCount) / 应完成 \(vaccine.dueCount)",
                    symbol: "syringe.fill",
                    gradient: AppTheme.vaccineGradient
                )
            }
        }
    }

    private func feedingChart(for baby: Baby) -> some View {
        let data = getFeedingData(for: baby)

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Feeding",
                title: "喂奶趋势",
                subtitle: data.isEmpty ? "当前周期暂无喂养记录。" : "观察高频日和低频日，方便判断节奏是否稳定。"
            )

            if data.isEmpty {
                AppEmptyStateCard(
                    symbol: "drop.fill",
                    title: "暂无喂养记录",
                    message: "开始记录后，这里会自动显示按天汇总的喂奶次数。"
                )
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Chart(data) { item in
                        BarMark(
                            x: .value("日期", item.date, unit: .day),
                            y: .value("次数", item.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: AppTheme.feedingGradient,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .frame(height: 220)

                    HStack(spacing: 12) {
                        trendBadge(title: "峰值", value: "\(data.map(\.count).max() ?? 0) 次")
                        trendBadge(title: "日均", value: averageFeedingText(from: data))
                        trendBadge(title: "周期", value: timeRange.rawValue)
                    }
                }
                .padding(18)
                .cardStyle()
            }
        }
    }

    private func sleepChart(for baby: Baby) -> some View {
        let data = getSleepData(for: baby)

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Sleep",
                title: "睡眠趋势",
                subtitle: data.isEmpty ? "当前周期暂无睡眠记录。" : "用折线看睡眠时长变化，比单看总量更容易发现波动。"
            )

            if data.isEmpty {
                AppEmptyStateCard(
                    symbol: "moon.stars.fill",
                    title: "暂无睡眠记录",
                    message: "开始记录睡眠后，这里会按天累计时长。"
                )
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Chart(data) { item in
                        AreaMark(
                            x: .value("日期", item.date, unit: .day),
                            y: .value("时长", item.hours)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.sleep.opacity(0.42), AppTheme.sleep.opacity(0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("日期", item.date, unit: .day),
                            y: .value("时长", item.hours)
                        )
                        .foregroundStyle(
                            LinearGradient(colors: AppTheme.sleepGradient, startPoint: .leading, endPoint: .trailing)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        .interpolationMethod(.catmullRom)
                    }
                    .frame(height: 220)

                    HStack(spacing: 12) {
                        trendBadge(title: "最长", value: String(format: "%.1f 小时", data.map(\.hours).max() ?? 0))
                        trendBadge(title: "日均", value: averageSleepText(from: data))
                        trendBadge(title: "记录天数", value: "\(data.count)")
                    }
                }
                .padding(18)
                .cardStyle()
            }
        }
    }

    private func diaperStats(for baby: Baby) -> some View {
        let data = getDiaperData(for: baby)

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Diaper",
                title: "尿布统计",
                subtitle: data.totalCount == 0 ? "当前周期暂无换尿布记录。" : "把湿尿布和脏尿布拆开看，更适合做日常观察。"
            )

            if data.totalCount == 0 {
                AppEmptyStateCard(
                    symbol: "sparkles.rectangle.stack.fill",
                    title: "暂无尿布记录",
                    message: "开始记录后，这里会自动汇总小便、大便和总次数。"
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    AppMetricTile(
                        title: "小便",
                        value: "\(data.wetCount) 次",
                        detail: "观察排尿频率",
                        symbol: "drop.fill",
                        gradient: AppTheme.growthGradient
                    )

                    AppMetricTile(
                        title: "大便",
                        value: "\(data.dirtyCount) 次",
                        detail: "关注消化变化",
                        symbol: "sparkles.rectangle.stack.fill",
                        gradient: AppTheme.heroGradient
                    )

                    AppMetricTile(
                        title: "总次数",
                        value: "\(data.totalCount) 次",
                        detail: timeRange.rawValue,
                        symbol: "chart.bar.fill",
                        gradient: AppTheme.diaperGradient
                    )

                    AppMetricTile(
                        title: "日均频率",
                        value: String(format: "%.1f 次", data.avgPerDay),
                        detail: "用于横向比较",
                        symbol: "waveform.path.ecg",
                        gradient: AppTheme.sleepGradient
                    )
                }
            }
        }
    }

    private func vaccinationProgress(for baby: Baby) -> some View {
        let data = getVaccinationProgress(for: baby)

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Vaccine",
                title: "疫苗进度",
                subtitle: data.dueCount == 0 ? "当前周期没有应接种项目。" : "完成率和逾期数应该一起看，避免只看已完成数量。"
            )

            if data.dueCount == 0 {
                AppEmptyStateCard(
                    symbol: "syringe.fill",
                    title: "当前暂无应接种项目",
                    message: "如果已经登记完当前周期，这里会保持清空状态。"
                )
            } else {
                VStack(spacing: 12) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        AppMetricTile(
                            title: "应完成",
                            value: "\(data.dueCount) 项",
                            detail: "本周期应登记数量",
                            symbol: "calendar.badge.clock",
                            gradient: AppTheme.vaccineGradient
                        )

                        AppMetricTile(
                            title: "已登记",
                            value: "\(data.completedCount) 项",
                            detail: "当前已完成数量",
                            symbol: "checkmark.circle.fill",
                            gradient: AppTheme.mintHeroGradient
                        )

                        AppMetricTile(
                            title: "完成率",
                            value: String(format: "%.0f%%", data.completionRate * 100),
                            detail: "完成 / 应完成",
                            symbol: "chart.line.uptrend.xyaxis",
                            gradient: AppTheme.heroGradient
                        )

                        AppMetricTile(
                            title: "已逾期",
                            value: "\(data.overdueCount) 项",
                            detail: "建议尽快补种或补录",
                            symbol: "exclamationmark.triangle.fill",
                            gradient: [AppTheme.warning, AppTheme.danger]
                        )
                    }
                }
            }
        }
    }

    private func trendBadge(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var overviewFeedingText: String {
        guard let baby = selectedBaby else { return "等待记录" }
        let data = getFeedingData(for: baby)
        return averageFeedingText(from: data)
    }

    private var overviewSleepText: String {
        guard let baby = selectedBaby else { return "等待记录" }
        let data = getSleepData(for: baby)
        return averageSleepText(from: data)
    }

    private var overviewVaccineText: String {
        guard let baby = selectedBaby else { return "等待记录" }
        let data = getVaccinationProgress(for: baby)
        return String(format: "%.0f%%", data.completionRate * 100)
    }

    private func averageFeedingText(from data: [ChartData]) -> String {
        let total = data.reduce(0) { $0 + $1.count }
        return String(format: "日均 %.1f 次", Double(total) / Double(max(data.count, 1)))
    }

    private func averageSleepText(from data: [ChartData]) -> String {
        let total = data.reduce(0.0) { $0 + $1.hours }
        return String(format: "日均 %.1f 小时", total / Double(max(data.count, 1)))
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
        let records = sleepRecords.filter { $0.babyId == baby.id }

        let startDate: Date
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        case .all:
            startDate = baby.birthday
        }

        let referenceNow = Date.now
        var dataDict: [Date: TimeInterval] = [:]

        for record in records {
            let intervalEnd = record.endTime ?? referenceNow
            guard intervalEnd > startDate, record.startTime < referenceNow else { continue }

            let effectiveStart = max(record.startTime, startDate)
            var dayStart = calendar.startOfDay(for: effectiveStart)

            while dayStart < intervalEnd {
                let overlap = record.duration(overlapping: dayStart, calendar: calendar, now: referenceNow)
                if overlap > 0 {
                    dataDict[dayStart, default: 0] += overlap
                }

                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else { break }
                dayStart = nextDay
            }
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

    private func getVaccinationProgress(for baby: Baby) -> VaccinationProgressData {
        let babyRecords = vaccinationRecords.filter { $0.babyId == baby.id }
        let selectedTrack = VaccinationSchedule.storedTrack(for: baby.id)
        let dueMilestones = VaccinationSchedule.dueMilestones(
            for: baby,
            records: babyRecords,
            track: selectedTrack
        )
        let completed = dueMilestones.filter { $0.isCompleted }.count
        let dueCount = dueMilestones.count

        return VaccinationProgressData(
            dueCount: dueCount,
            completedCount: completed,
            overdueCount: dueMilestones.filter { !$0.isCompleted }.count,
            completionRate: dueCount == 0 ? 1 : Double(completed) / Double(dueCount)
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

struct VaccinationProgressData {
    let dueCount: Int
    let completedCount: Int
    let overdueCount: Int
    let completionRate: Double
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self, VaccinationRecord.self])
}
