//
//  CalendarView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @Query private var feedingRecords: [FeedingRecord]
    @Query private var sleepRecords: [SleepRecord]
    @Query private var diaperRecords: [DiaperRecord]
    
    @State private var selectedBaby: Baby?
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Baby selector
                babySelector
                
                // Month selector
                monthSelector
                
                // Calendar grid
                calendarGrid
                
                // Selected date details
                if let baby = selectedBaby {
                    dateDetails(for: baby)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("日历")
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
    
    private var monthSelector: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            Text(monthTitle)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .cardStyle()
    }

    private var calendarGrid: some View {
        VStack(spacing: 12) {
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func dayCell(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(selectedDate, inSameDayAs: date)
        let hasRecords = dateHasRecords(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        
        return Button(action: { selectedDate = date }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isCurrentMonth ? .primary : .secondary)
                
                if hasRecords {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func dateDetails(for baby: Baby) -> some View {
        let feedingCount = feedingRecords.filter {
            $0.babyId == baby.id && calendar.isDate($0.timestamp, inSameDayAs: selectedDate)
        }.count
        
        let sleeps = sleepRecords.filter {
            $0.babyId == baby.id && calendar.isDate($0.startTime, inSameDayAs: selectedDate) && $0.endTime != nil
        }
        
        let diaperCount = diaperRecords.filter {
            $0.babyId == baby.id && calendar.isDate($0.timestamp, inSameDayAs: selectedDate)
        }.count
        
        let totalSleepHours = sleeps.reduce(0.0) { $0 + $1.duration } / 3600
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(formatSelectedDate)
                .font(.headline)
            
            VStack(spacing: 8) {
                summaryRow(icon: "🍼", label: "喂奶", value: "\(feedingCount)次")
                summaryRow(icon: "💩", label: "换尿布", value: "\(diaperCount)次")
                summaryRow(icon: "💤", label: "睡眠", value: String(format: "%.1f小时", totalSleepHours))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Text(icon)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Helpers
    
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
        
        // Fill remaining week
        let remainder = 7 - (days.count % 7)
        if remainder < 7 {
            days.append(contentsOf: Array(repeating: nil, count: remainder))
        }
        
        return days
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: currentMonth)
    }
    
    private var formatSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 记录"
        return formatter.string(from: selectedDate)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func dateHasRecords(_ date: Date) -> Bool {
        guard let baby = selectedBaby else { return false }
        
        let hasFeeding = feedingRecords.contains {
            $0.babyId == baby.id && calendar.isDate($0.timestamp, inSameDayAs: date)
        }
        
        let hasSleep = sleepRecords.contains {
            $0.babyId == baby.id && calendar.isDate($0.startTime, inSameDayAs: date)
        }
        
        let hasDiaper = diaperRecords.contains {
            $0.babyId == baby.id && calendar.isDate($0.timestamp, inSameDayAs: date)
        }
        
        return hasFeeding || hasSleep || hasDiaper
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self])
}
