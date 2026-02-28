//
//  FeedingRecordView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct FeedingRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let baby: Baby

    @State private var feedingMethod: FeedingMethod = .breastfeeding
    @State private var showBreastfeedingTimer = false
    @State private var amount: String = ""
    @State private var notes: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSaveSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    methodCard

                    if feedingMethod == .breastfeeding {
                        breastfeedingCard
                    } else {
                        amountCard
                    }

                    notesCard

                    if feedingMethod != .breastfeeding {
                        saveButton
                    }
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("喂养记录")
            .navigationBarTitleDisplayMode(.inline)
            .appPageBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showBreastfeedingTimer) {
                BreastfeedingTimerView(baby: baby) {
                    dismiss()
                }
            }
            .saveSuccessOverlay(isPresented: $showingSaveSuccess) {
                dismiss()
            }
        }
    }

    private var methodCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("喂养方式")
                .font(.headline)
            Picker("方式", selection: $feedingMethod) {
                Text("母乳").tag(FeedingMethod.breastfeeding)
                Text("奶粉").tag(FeedingMethod.bottle)
                Text("混合").tag(FeedingMethod.mixed)
            }
            .pickerStyle(.segmented)
        }
        .padding(14)
        .cardStyle()
    }

    private var breastfeedingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "timer")
                    .foregroundStyle(AppTheme.brand)
                Text("母乳计时")
                    .font(.headline)
            }

            Button(action: { showBreastfeedingTimer = true }) {
                Label("开始母乳计时", systemImage: "play.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppTheme.brand)
            .minimumTappableSize()

            Text("点击开始计时，可记录左右侧时长。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .cardStyle()
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("奶量")
                .font(.headline)
            HStack {
                TextField("例如 90", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                Text("ml")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(uiColor: .tertiarySystemFill))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(14)
        .cardStyle()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("备注")
                .font(.headline)
            TextEditor(text: $notes)
                .frame(height: 90)
                .padding(4)
                .background(Color(uiColor: .tertiarySystemFill))
                .overlay(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("可填写喂养状态、精神情况等")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)
                            .padding(.leading, 10)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(14)
        .cardStyle()
    }

    private var saveButton: some View {
        Button("保存记录") {
            saveQuickRecord()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(AppTheme.brand)
        .font(.headline)
        .minimumTappableSize()
        .scaleButton(scale: 0.98)
    }

    private func saveQuickRecord() {
        let record = FeedingRecord(babyId: baby.id, timestamp: Date(), method: feedingMethod)

        let trimmedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedAmount.isEmpty {
            guard let amountValue = Double(trimmedAmount) else {
                alertMessage = "请输入有效奶量"
                showingAlert = true
                return
            }
            guard amountValue > 0, amountValue <= 500 else {
                alertMessage = "奶量应在 1~500ml 之间"
                showingAlert = true
                return
            }
            record.amount = amountValue
        }

        if !notes.isEmpty {
            record.notes = notes
        }

        do {
            try modelContext.insertAndSave(record)
            HapticManager.shared.success()
            showingSaveSuccess = true
        } catch {
            alertMessage = "保存失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    FeedingRecordView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
        .modelContainer(for: [FeedingRecord.self])
}
