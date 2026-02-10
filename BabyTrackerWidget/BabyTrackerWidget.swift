//
//  BabyTrackerWidget.swift
//  BabyTrackerWidget
//
//  Created on 2026-02-10.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), babyName: "小宝", lastFeeding: "2小时前", todayCount: 8)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), babyName: "小宝", lastFeeding: "2小时前", todayCount: 8)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, babyName: "小宝", lastFeeding: "\(hourOffset)小时前", todayCount: 8)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let babyName: String
    let lastFeeding: String
    let todayCount: Int
}

struct BabyTrackerWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("👶")
                    .font(.title2)
                Text(entry.babyName)
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("上次喂奶: \(entry.lastFeeding)")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("今日: \(entry.todayCount)次")
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct BabyTrackerWidget: Widget {
    let kind: String = "BabyTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BabyTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("宝宝日记")
        .description("快速查看喂养记录")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    BabyTrackerWidget()
} timeline: {
    SimpleEntry(date: .now, babyName: "小宝", lastFeeding: "2小时前", todayCount: 8)
}
