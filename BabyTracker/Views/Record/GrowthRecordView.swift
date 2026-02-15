//
//  GrowthRecordView.swift
//  BabyTracker
//
//  Created for BDD tests: 2026-02-11
//

import SwiftUI
import SwiftData

struct GrowthRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let baby: Baby

    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var headCircumference: String = ""
    @State private var temperature: String = ""
    @State private var notes: String = ""
    @State private var recordDate = Date()

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSaveSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    dateCard
                    measurementCard
                    notesCard
                    saveButton
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("生长记录")
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
            .saveSuccessOverlay(isPresented: $showingSaveSuccess) {
                dismiss()
            }
        }
    }

    private var dateCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("测量日期")
                .font(.headline)
            DatePicker("日期时间", selection: $recordDate)
        }
        .padding(14)
        .cardStyle()
    }

    private var measurementCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("生长数据")
                .font(.headline)

            measurementRow(symbol: "scalemass.fill", title: "体重", placeholder: "5.8", unit: "kg", text: $weight)
            measurementRow(symbol: "ruler.fill", title: "身高", placeholder: "62.5", unit: "cm", text: $height)
            measurementRow(symbol: "circle.dashed", title: "头围", placeholder: "42.0", unit: "cm", text: $headCircumference)
            measurementRow(symbol: "thermometer.medium", title: "体温", placeholder: "36.8", unit: "°C", text: $temperature)
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
                .background(AppTheme.growthGradient[0].opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(14)
        .cardStyle()
    }

    private var saveButton: some View {
        Button("保存") {
            saveRecord()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
                LinearGradient(
                colors: hasValidInput ? AppTheme.growthGradient : AppTheme.disabledGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .font(.headline)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        .disabled(!hasValidInput)
        .scaleButton()
    }

    private func measurementRow(symbol: String, title: String, placeholder: String, unit: String, text: Binding<String>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
                .frame(width: 28, height: 28)
                .background(AppTheme.secondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.subheadline)

            Spacer()

            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)

            Text(unit)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var hasValidInput: Bool {
        !weight.isEmpty || !height.isEmpty || !headCircumference.isEmpty || !temperature.isEmpty
    }

    private func saveRecord() {
        showingAlert = false

        if recordDate > Date() {
            alertMessage = "记录时间不能晚于当前时间"
            showingAlert = true
            return
        }

        let weightValue = parse(weight, validate: { (1.0...30.0).contains($0) }, message: "体重应在 1~30kg 之间")
        if showingAlert { return }
        let heightValue = parse(height, validate: { (30.0...150.0).contains($0) }, message: "身高应在 30~150cm 之间")
        if showingAlert { return }
        let headValue = parse(headCircumference, validate: { (25.0...60.0).contains($0) }, message: "头围应在 25~60cm 之间")
        if showingAlert { return }
        let tempValue = parse(temperature, validate: { (34.0...42.0).contains($0) }, message: "体温应在 34~42°C 之间")
        if showingAlert { return }

        guard weightValue != nil || heightValue != nil || headValue != nil || tempValue != nil else {
            alertMessage = "请至少输入一项有效测量数据"
            showingAlert = true
            return
        }

        let record = GrowthRecord(babyId: baby.id, timestamp: recordDate)
        if let weightValue {
            record.weight = weightValue * 1000
        }
        record.height = heightValue
        record.headCircumference = headValue
        record.temperature = tempValue
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

    private func validate(_ value: Double, with rule: (Double) -> Bool, message: String) -> Bool {
        if !rule(value) {
            alertMessage = message
            showingAlert = true
            return false
        }
        return true
    }

    private func parse(_ input: String, validate rule: (Double) -> Bool, message: String) -> Double? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let value = Double(trimmed) else {
            alertMessage = "请输入有效数字"
            showingAlert = true
            return nil
        }
        guard validate(value, with: rule, message: message) else { return nil }
        return value
    }
}
