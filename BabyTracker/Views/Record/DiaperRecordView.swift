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
    
    private let colors = ["黄色", "绿色", "棕色", "黑色", "其他"]
    private let consistencies = ["糊状", "稀水", "成形", "干硬"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("类型") {
                    Toggle("小便", isOn: $hasWet)
                    Toggle("大便", isOn: $hasDirty)
                }
                
                if hasDirty {
                    Section("大便详情") {
                        Picker("颜色", selection: $color) {
                            Text("请选择").tag("")
                            ForEach(colors, id: \.self) { color in
                                Text(color).tag(color)
                            }
                        }
                        
                        Picker("性状", selection: $consistency) {
                            Text("请选择").tag("")
                            ForEach(consistencies, id: \.self) { consistency in
                                Text(consistency).tag(consistency)
                            }
                        }
                    }
                }
                
                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                Section {
                    Button("保存记录") {
                        saveRecord()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.blue)
                    .disabled(!hasWet && !hasDirty)
                }
            }
            .navigationTitle("尿布记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
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
        
        modelContext.insert(record)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    DiaperRecordView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
        .modelContainer(for: [DiaperRecord.self])
}
