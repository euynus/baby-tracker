//
//  ExportView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct ExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @Query private var feedingRecords: [FeedingRecord]
    @Query private var sleepRecords: [SleepRecord]
    @Query private var diaperRecords: [DiaperRecord]
    @Query private var growthRecords: [GrowthRecord]

    @State private var selectedBaby: Baby?
    @State private var exportFormat: ExportFormat = .csv
    @State private var showShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var isExporting = false

    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case pdf = "PDF"
    }

    var body: some View {
        Form {
            Section("选择宝宝") {
                Picker("宝宝", selection: $selectedBaby) {
                    Text("请选择").tag(nil as Baby?)
                    ForEach(babies) { baby in
                        Text(baby.name).tag(baby as Baby?)
                    }
                }
            }

            Section("导出格式") {
                Picker("格式", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
            }

            if let baby = selectedBaby {
                Section("数据预览") {
                    HStack {
                        Text("🍼 喂养记录")
                        Spacer()
                        Text("\(feedingRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("💤 睡眠记录")
                        Spacer()
                        Text("\(sleepRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("💩 尿布记录")
                        Spacer()
                        Text("\(diaperRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("📏 生长记录")
                        Spacer()
                        Text("\(growthRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button(action: exportData) {
                    if isExporting {
                        HStack {
                            Spacer()
                            LoadingDotsView()
                            Spacer()
                        }
                    } else {
                        Text("导出数据")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .listRowBackground(
                    LinearGradient(
                        colors: selectedBaby != nil
                            ? [Color.blue.opacity(0.8), Color.blue]
                            : [Color.gray.opacity(0.3), Color.gray.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                )
                .disabled(selectedBaby == nil || isExporting)
            }
        }
        .navigationTitle("导出数据")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func exportData() {
        guard let baby = selectedBaby else { return }

        isExporting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let url: URL?

            switch exportFormat {
            case .csv:
                url = ExportManager.exportToCSV(
                    baby: baby,
                    feedingRecords: feedingRecords,
                    sleepRecords: sleepRecords,
                    diaperRecords: diaperRecords,
                    growthRecords: growthRecords
                )
            case .pdf:
                url = ExportManager.exportToPDF(
                    baby: baby,
                    feedingRecords: feedingRecords,
                    sleepRecords: sleepRecords,
                    diaperRecords: diaperRecords,
                    growthRecords: growthRecords
                )
            }

            isExporting = false

            if let url = url {
                exportedFileURL = url
                showShareSheet = true
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ExportView()
    }
    .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self, GrowthRecord.self])
}
