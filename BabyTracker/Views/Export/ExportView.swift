//
//  ExportView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct ExportView: View {
    @Query private var babies: [Baby]
    @Query private var feedingRecords: [FeedingRecord]
    @Query private var sleepRecords: [SleepRecord]
    @Query private var diaperRecords: [DiaperRecord]
    @Query private var growthRecords: [GrowthRecord]
    @Query private var vaccinationRecords: [VaccinationRecord]

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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                heroCard
                selectionCard
                formatCard

                if let baby = selectedBaby {
                    previewCard(for: baby)
                }

                exportButton
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("导出数据")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
    }

    private var heroCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.and.arrow.up.on.square")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("导出成长数据")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("支持 CSV 与 PDF，一键分享")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
            }

            Spacer()
        }
        .padding(16)
        .gradientCard(AppTheme.heroGradient)
    }

    private var selectionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("选择宝宝")
                .font(.headline)

            if babies.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .foregroundStyle(.secondary)
                    Text("暂无宝宝，先到宝宝管理中添加")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.vertical, 6)
            } else {
                Picker("宝宝", selection: $selectedBaby) {
                    Text("请选择").tag(nil as Baby?)
                    ForEach(babies) { baby in
                        Text(baby.name).tag(baby as Baby?)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var formatCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("导出格式")
                .font(.headline)
            Picker("格式", selection: $exportFormat) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(14)
        .cardStyle()
    }

    private func previewCard(for baby: Baby) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("数据预览")
                .font(.headline)

            previewRow(symbol: "drop.fill", title: "喂养记录", count: feedingCount(for: baby))
            previewRow(symbol: "moon.zzz.fill", title: "睡眠记录", count: sleepCount(for: baby))
            previewRow(symbol: "sparkles", title: "尿布记录", count: diaperCount(for: baby))
            previewRow(symbol: "chart.line.uptrend.xyaxis", title: "生长记录", count: growthCount(for: baby))
            previewRow(symbol: "syringe.fill", title: "疫苗记录", count: vaccinationCount(for: baby))
        }
        .padding(14)
        .cardStyle()
    }

    private func previewRow(symbol: String, title: String, count: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
                .frame(width: 28, height: 28)
                .background(AppTheme.secondary.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.subheadline)

            Spacer()

            Text("\(count) 条")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private var exportButton: some View {
        Button(action: exportData) {
            HStack(spacing: 10) {
                if isExporting {
                    LoadingDotsView()
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                    Text("导出数据")
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: selectedBaby != nil && !isExporting
                        ? [AppTheme.secondary, AppTheme.brand]
                        : AppTheme.disabledGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        }
        .disabled(selectedBaby == nil || isExporting)
        .scaleButton()
    }

    private func feedingCount(for baby: Baby) -> Int {
        feedingRecords.filter { $0.babyId == baby.id }.count
    }

    private func sleepCount(for baby: Baby) -> Int {
        sleepRecords.filter { $0.babyId == baby.id }.count
    }

    private func diaperCount(for baby: Baby) -> Int {
        diaperRecords.filter { $0.babyId == baby.id }.count
    }

    private func growthCount(for baby: Baby) -> Int {
        growthRecords.filter { $0.babyId == baby.id }.count
    }

    private func vaccinationCount(for baby: Baby) -> Int {
        vaccinationRecords.filter { $0.babyId == baby.id }.count
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
                    growthRecords: growthRecords,
                    vaccinationRecords: vaccinationRecords
                )
            case .pdf:
                url = ExportManager.exportToPDF(
                    baby: baby,
                    feedingRecords: feedingRecords,
                    sleepRecords: sleepRecords,
                    diaperRecords: diaperRecords,
                    growthRecords: growthRecords,
                    vaccinationRecords: vaccinationRecords
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
    .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self, GrowthRecord.self, VaccinationRecord.self])
}
