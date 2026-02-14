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
            Form {
                Section("测量日期") {
                    DatePicker("日期时间", selection: $recordDate)
                }

                Section("生长数据") {
                    HStack {
                        Text("⚖️ 体重")
                        Spacer()
                        TextField("5.8", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }

                    HStack {
                        Text("📏 身高")
                        Spacer()
                        TextField("62.5", text: $height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                    }

                    HStack {
                        Text("⭕️ 头围")
                        Spacer()
                        TextField("42.0", text: $headCircumference)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                    }

                    HStack {
                        Text("🌡️ 体温")
                        Spacer()
                        TextField("36.8", text: $temperature)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("°C")
                    }
                }

                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                }
            }
            .navigationTitle("生长记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(!hasValidInput)
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

    private var hasValidInput: Bool {
        !weight.isEmpty || !height.isEmpty || !headCircumference.isEmpty || !temperature.isEmpty
    }

    private func saveRecord() {
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

        if let weightValue {
            let record = GrowthRecord(baby: baby, weight: weightValue, timestamp: recordDate)
            if !notes.isEmpty { record.notes = notes }
            modelContext.insert(record)
        }

        if let heightValue {
            let record = GrowthRecord(baby: baby, height: heightValue, timestamp: recordDate)
            if !notes.isEmpty { record.notes = notes }
            modelContext.insert(record)
        }

        if let headValue {
            let record = GrowthRecord(baby: baby, headCircumference: headValue, timestamp: recordDate)
            if !notes.isEmpty { record.notes = notes }
            modelContext.insert(record)
        }

        if let tempValue {
            let record = GrowthRecord(baby: baby, temperature: tempValue, timestamp: recordDate)
            if !notes.isEmpty { record.notes = notes }
            modelContext.insert(record)
        }

        try? modelContext.save()
        HapticManager.shared.success()
        showingSaveSuccess = true
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
