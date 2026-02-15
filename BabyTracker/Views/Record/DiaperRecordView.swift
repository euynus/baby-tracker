//
//  DiaperRecordView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct DiaperRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let baby: Baby

    @State private var hasWet = false
    @State private var hasDirty = false
    @State private var color: String = ""
    @State private var consistency: String = ""
    @State private var notes: String = ""
    @State private var showingSaveSuccess = false
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""

    private let colors = ["黄色", "绿色", "棕色", "黑色", "其他"]
    private let consistencies = ["糊状", "稀水", "成形", "干硬"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    typeCardSection

                    if hasDirty {
                        dirtyDetailSection
                    }

                    notesSection
                    saveButton
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .animation(.smooth, value: hasDirty)
            .navigationTitle("尿布记录")
            .navigationBarTitleDisplayMode(.inline)
            .appPageBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("保存失败", isPresented: $showingSaveError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(saveErrorMessage)
            }
            .saveSuccessOverlay(isPresented: $showingSaveSuccess) {
                dismiss()
            }
        }
    }

    private var typeCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("类型")
                .font(.headline)

            HStack(spacing: 12) {
                typeCard(
                    symbol: "drop.fill",
                    title: "小便",
                    isSelected: hasWet,
                    color: .cyan
                ) {
                    hasWet.toggle()
                    HapticManager.shared.light()
                }

                typeCard(
                    symbol: "sparkles.rectangle.stack.fill",
                    title: "大便",
                    isSelected: hasDirty,
                    color: .orange
                ) {
                    hasDirty.toggle()
                    HapticManager.shared.light()
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var dirtyDetailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("大便详情")
                .font(.headline)

            Picker("颜色", selection: $color) {
                Text("请选择").tag("")
                ForEach(colors, id: \.self) { color in
                    Text(color).tag(color)
                }
            }

            Divider()

            Picker("性状", selection: $consistency) {
                Text("请选择").tag("")
                ForEach(consistencies, id: \.self) { consistency in
                    Text(consistency).tag(consistency)
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("备注")
                .font(.headline)

            TextEditor(text: $notes)
                .frame(height: 90)
                .padding(4)
                .background(AppTheme.diaperGradient[0].opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(14)
        .cardStyle()
    }

    private var saveButton: some View {
        Button(action: saveRecord) {
            Text("保存记录")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: (hasWet || hasDirty) ? AppTheme.diaperGradient : AppTheme.disabledGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        }
        .disabled(!hasWet && !hasDirty)
        .buttonStyle(.plain)
        .scaleButton()
    }

    private func typeCard(symbol: String, title: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? .white : color)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? color : color.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(title)
                    .font(.headline)
                    .foregroundStyle(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? color.opacity(0.14) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                    .stroke(isSelected ? color : color.opacity(0.2), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func saveRecord() {
        let record = DiaperRecord(
            babyId: baby.id,
            timestamp: Date(),
            hasWet: hasWet,
            hasDirty: hasDirty
        )

        if hasDirty {
            if !color.isEmpty {
                record.color = color
            }
            if !consistency.isEmpty {
                record.consistency = consistency
            }
        }

        if !notes.isEmpty {
            record.notes = notes
        }

        do {
            try modelContext.insertAndSave(record)
            HapticManager.shared.success()
            showingSaveSuccess = true
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
}

#Preview {
    DiaperRecordView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
        .modelContainer(for: [DiaperRecord.self])
}
