//
//  CalendarView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var babies: [Baby]
    @Query private var feedingRecords: [FeedingRecord]
    @Query private var sleepRecords: [SleepRecord]
    @Query private var diaperRecords: [DiaperRecord]
    @Query private var vaccinationRecords: [VaccinationRecord]

    @State private var selectedBaby: Baby?
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroSection

                    if babies.isEmpty {
                        AppEmptyStateCard(
                            symbol: "calendar.badge.clock",
                            title: "日历暂时为空",
                            message: "先添加宝宝并开始记录，日历才会出现每日活动和节奏分布。"
                        )
                    } else {
                        babySelector
                        monthSelector
                        monthlySnapshot
                        calendarGrid

                        if let baby = selectedBaby {
                            dateDetails(for: baby)
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
                        Text("日历")
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
                    Text("照护日程")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text(selectedBaby?.name ?? "日历视图")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(formatHeaderDate(selectedDate))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.90))
                }

                Spacer()

                AppIconBadge(symbol: "calendar.badge.clock", colors: AppTheme.sleepGradient, size: 52)
            }

            HStack(spacing: 10) {
                AppStatusChip(title: "本月活跃日", value: "\(activeDaysThisMonth)")
                AppStatusChip(title: "选中日期", value: formatSelectedDayChip)
                AppStatusChip(title: "记录总量", value: "\(recordCountOnSelectedDate)")
            }
        }
        .padding(20)
        .gradientCard(AppTheme.sleepGradient)
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
                    Text("查看对象")
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
    }

    private var monthSelector: some View {
        HStack(spacing: 12) {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.brand)
                    .frame(width: 42, height: 42)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            VStack(spacing: 4) {
                Text(monthTitle)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text("切换月份查看记录密度")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("回到今天") {
                selectedDate = Date()
                currentMonth = Date()
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(AppTheme.brand)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.primary.opacity(0.05))
            .clipShape(Capsule())

            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.brand)
                    .frame(width: 42, height: 42)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .cardStyle()
    }

    private var monthlySnapshot: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Month",
                title: "月份概况",
                subtitle: "先看本月活跃密度，再下钻到具体日期。"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AppMetricTile(
                    title: "活跃日",
                    value: "\(activeDaysThisMonth) 天",
                    detail: "这个月有记录的日期",
                    symbol: "calendar",
                    gradient: AppTheme.sleepGradient
                )

                AppMetricTile(
                    title: "最高日记录",
                    value: "\(busiestDayRecordCount) 条",
                    detail: "本月单日峰值",
                    symbol: "flame.fill",
                    gradient: AppTheme.heroGradient
                )

                AppMetricTile(
                    title: "今日是否活跃",
                    value: isTodayActive ? "已记录" : "未记录",
                    detail: "快速判断今天是否补齐",
                    symbol: "checkmark.seal.fill",
                    gradient: AppTheme.mintHeroGradient
                )

                AppMetricTile(
                    title: "选中日期",
                    value: "\(recordCountOnSelectedDate) 条",
                    detail: formatSelectedDate,
                    symbol: "sparkles",
                    gradient: AppTheme.vaccineGradient
                )
            }
        }
    }

    private var calendarGrid: some View {
        let recordDates = recordDatesForSelectedBaby

        return VStack(alignment: .leading, spacing: 16) {
            AppSectionTitle(
                eyebrow: "Grid",
                title: "日期分布",
                subtitle: "带圆点的日期代表当天存在照护记录。"
            )

            VStack(spacing: 12) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                        Text(day)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                        if let date {
                            dayCell(
                                for: date,
                                hasRecords: recordDates.contains(calendar.startOfDay(for: date))
                            )
                        } else {
                            Color.clear
                                .frame(height: 50)
                        }
                    }
                }
            }
            .padding(18)
            .cardStyle()
        }
    }

    private func dayCell(for date: Date, hasRecords: Bool) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(selectedDate, inSameDayAs: date)
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)

        return Button(action: { selectedDate = date }) {
            VStack(spacing: 6) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isToday || isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : (isCurrentMonth ? AppTheme.ink : .secondary))

                Circle()
                    .fill(hasRecords ? (isSelected ? .white : AppTheme.brand) : .clear)
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isSelected
                            ? LinearGradient(colors: AppTheme.heroGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.primary.opacity(0.04), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isToday ? AppTheme.brand.opacity(0.75) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func dateDetails(for baby: Baby) -> some View {
        let babyFeedingRecords = feedingRecords.filter { $0.babyId == baby.id }
        let babySleepRecords = sleepRecords.filter { $0.babyId == baby.id }
        let babyDiaperRecords = diaperRecords.filter { $0.babyId == baby.id }
        let babyVaccinationRecords = vaccinationRecords.filter { $0.babyId == baby.id }

        let feedingCount = babyFeedingRecords.filter {
            calendar.isDate($0.timestamp, inSameDayAs: selectedDate)
        }.count

        let sleeps = babySleepRecords.filter {
            $0.duration(overlapping: selectedDate, calendar: calendar) > 0
        }

        let diaperCount = babyDiaperRecords.filter {
            calendar.isDate($0.timestamp, inSameDayAs: selectedDate)
        }.count

        let vaccinationCount = babyVaccinationRecords.filter {
            calendar.isDate($0.administeredAt, inSameDayAs: selectedDate)
        }.count

        let totalSleepHours = sleeps.reduce(0.0) { total, record in
            total + record.duration(overlapping: selectedDate, calendar: calendar)
        } / 3600

        return VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Day Detail",
                title: formatSelectedDate,
                subtitle: "把单日照护拆成四个维度，方便补记和复盘。"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AppMetricTile(
                    title: "喂奶",
                    value: "\(feedingCount) 次",
                    detail: "当天喂养次数",
                    symbol: "drop.fill",
                    gradient: AppTheme.feedingGradient
                )

                AppMetricTile(
                    title: "换尿布",
                    value: "\(diaperCount) 次",
                    detail: "当天更换次数",
                    symbol: "sparkles.rectangle.stack.fill",
                    gradient: AppTheme.diaperGradient
                )

                AppMetricTile(
                    title: "睡眠",
                    value: String(format: "%.1f 小时", totalSleepHours),
                    detail: "当天累计睡眠",
                    symbol: "moon.stars.fill",
                    gradient: AppTheme.sleepGradient
                )

                AppMetricTile(
                    title: "疫苗",
                    value: "\(vaccinationCount) 次",
                    detail: "当天接种登记",
                    symbol: "syringe.fill",
                    gradient: AppTheme.vaccineGradient
                )
            }
        }
    }

    private var activeDaysThisMonth: Int {
        let monthDates = recordDatesForSelectedBaby.filter {
            calendar.isDate($0, equalTo: currentMonth, toGranularity: .month)
        }
        return monthDates.count
    }

    private var busiestDayRecordCount: Int {
        guard let baby = selectedBaby else { return 0 }
        let monthDates = daysInMonth.compactMap { $0 }
        return monthDates.map { recordCount(on: $0, for: baby) }.max() ?? 0
    }

    private var isTodayActive: Bool {
        guard let baby = selectedBaby else { return false }
        return recordCount(on: Date(), for: baby) > 0
    }

    private var recordCountOnSelectedDate: Int {
        guard let baby = selectedBaby else { return 0 }
        return recordCount(on: selectedDate, for: baby)
    }

    private func recordCount(on date: Date, for baby: Baby) -> Int {
        let feedings = feedingRecords.filter { $0.babyId == baby.id && calendar.isDate($0.timestamp, inSameDayAs: date) }.count
        let diapers = diaperRecords.filter { $0.babyId == baby.id && calendar.isDate($0.timestamp, inSameDayAs: date) }.count
        let vaccines = vaccinationRecords.filter { $0.babyId == baby.id && calendar.isDate($0.administeredAt, inSameDayAs: date) }.count
        let sleeps = sleepRecords.filter { $0.babyId == baby.id && $0.duration(overlapping: date, calendar: calendar) > 0 }.count
        return feedings + diapers + vaccines + sleeps
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }

        var days: [Date?] = []
        var date = monthFirstWeek.start

        while date < monthInterval.end {
            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                days.append(date)
            } else {
                days.append(nil)
            }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        let remainder = 7 - (days.count % 7)
        if remainder < 7 {
            days.append(contentsOf: Array(repeating: nil, count: remainder))
        }

        return days
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: currentMonth)
    }

    private var formatSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 记录"
        return formatter.string(from: selectedDate)
    }

    private var formatSelectedDayChip: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: selectedDate)
    }

    private func formatHeaderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月d日 · EEEE"
        return formatter.string(from: date)
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private var recordDatesForSelectedBaby: Set<Date> {
        guard let baby = selectedBaby else { return [] }

        var dates = Set<Date>()

        feedingRecords
            .filter { $0.babyId == baby.id }
            .forEach { dates.insert(calendar.startOfDay(for: $0.timestamp)) }

        sleepRecords
            .filter { $0.babyId == baby.id }
            .forEach { dates.insert(calendar.startOfDay(for: $0.startTime)) }

        diaperRecords
            .filter { $0.babyId == baby.id }
            .forEach { dates.insert(calendar.startOfDay(for: $0.timestamp)) }

        vaccinationRecords
            .filter { $0.babyId == baby.id }
            .forEach { dates.insert(calendar.startOfDay(for: $0.administeredAt)) }

        return dates
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self, VaccinationRecord.self])
}
