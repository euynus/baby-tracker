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
    
    @State private var showingWeightAlert = false
    @State private var showingTemperatureAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("测量日期") {
                    DatePicker("日期时间", selection: $recordDate)
                }
                
                Section("生长数据") {
                    HStack {
                        Text("体重")
                        Spacer()
                        TextField("5.8", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }
                    
                    HStack {
                        Text("身高")
                        Spacer()
                        TextField("62.5", text: $height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                    }
                    
                    HStack {
                        Text("头围")
                        Spacer()
                        TextField("42.0", text: $headCircumference)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                    }
                    
                    HStack {
                        Text("体温")
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
            .alert("提示", isPresented: $showingWeightAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .alert("体温提示", isPresented: $showingTemperatureAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var hasValidInput: Bool {
        !weight.isEmpty || !height.isEmpty || !headCircumference.isEmpty || !temperature.isEmpty
    }
    
    private func saveRecord() {
        // 验证体重
        if let weightValue = Double(weight), !weight.isEmpty {
            if isAbnormalWeight(weightValue) {
                alertMessage = weightValue < 1.0 ? "体重异常低，请确认" : "体重异常高，请确认"
                showingWeightAlert = true
                return
            }
        }
        
        // 验证体温
        if let tempValue = Double(temperature), !temperature.isEmpty {
            if let alert = getTemperatureAlert(tempValue) {
                alertMessage = alert
                showingTemperatureAlert = true
                return
            }
        }
        
        // 保存记录
        if let weightValue = Double(weight), !weight.isEmpty {
            let record = GrowthRecord(
                baby: baby,
                weight: weightValue,
                timestamp: recordDate
            )
            if !notes.isEmpty {
                record.notes = notes
            }
            modelContext.insert(record)
        }
        
        if let heightValue = Double(height), !height.isEmpty {
            let record = GrowthRecord(
                baby: baby,
                height: heightValue,
                timestamp: recordDate
            )
            if !notes.isEmpty {
                record.notes = notes
            }
            modelContext.insert(record)
        }
        
        if let headValue = Double(headCircumference), !headCircumference.isEmpty {
            let record = GrowthRecord(
                baby: baby,
                headCircumference: headValue,
                timestamp: recordDate
            )
            if !notes.isEmpty {
                record.notes = notes
            }
            modelContext.insert(record)
        }
        
        if let tempValue = Double(temperature), !temperature.isEmpty {
            let record = GrowthRecord(
                baby: baby,
                temperature: tempValue,
                timestamp: recordDate
            )
            if !notes.isEmpty {
                record.notes = notes
            }
            modelContext.insert(record)
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func isAbnormalWeight(_ weight: Double) -> Bool {
        return weight < 1.0 || weight > 15.0
    }
    
    private func getTemperatureAlert(_ temp: Double) -> String? {
        if temp < 35.5 {
            return "体温偏低，请注意保暖"
        } else if temp >= 38.0 {
            return "发烧，建议就医"
        } else if temp >= 37.5 {
            return "体温略高，请持续监测"
        }
        return nil
    }
}
