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
                        Text("喂养记录")
                        Spacer()
                        Text("\(feedingRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("睡眠记录")
                        Spacer()
                        Text("\(sleepRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("尿布记录")
                        Spacer()
                        Text("\(diaperRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("生长记录")
                        Spacer()
                        Text("\(growthRecords.filter { $0.babyId == baby.id }.count)条")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section {
                Button(action: exportData) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("导出数据")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.blue)
                }
                .disabled(selectedBaby == nil)
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
        
        if let url = url {
            exportedFileURL = url
            showShareSheet = true
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
