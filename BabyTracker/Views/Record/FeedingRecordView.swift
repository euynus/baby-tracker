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
            Form {
                Section("喂养方式") {
                    Picker("方式", selection: $feedingMethod) {
                        Text("母乳").tag(FeedingMethod.breastfeeding)
                        Text("奶粉").tag(FeedingMethod.bottle)
                        Text("混合").tag(FeedingMethod.mixed)
                    }
                    .pickerStyle(.segmented)
                }
                
                if feedingMethod == .breastfeeding {
                    Section {
                        Button(action: { showBreastfeedingTimer = true }) {
                            HStack {
                                Image(systemName: "timer")
                                Text("开始母乳计时")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text("母乳喂养")
                    } footer: {
                        Text("点击开始计时，可以记录左右侧时长")
                    }
                } else {
                    Section("奶量") {
                        HStack {
                            TextField("奶量", text: $amount)
                                .keyboardType(.decimalPad)
                            Text("ml")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                if feedingMethod != .breastfeeding {
                    Section {
                        Button("保存记录") {
                            saveQuickRecord()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.blue)
                        .scaleButton()
                    }
                }
            }
            .navigationTitle("喂养记录")
            .navigationBarTitleDisplayMode(.inline)
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
        
        modelContext.insert(record)
        do {
            try modelContext.save()
            HapticManager.shared.success()
            showingSaveSuccess = true
        } catch {
            modelContext.delete(record)
            alertMessage = "保存失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    FeedingRecordView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
        .modelContainer(for: [FeedingRecord.self])
}
