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
            ScrollView {
                VStack(spacing: 20) {
                    // Type selection with icon cards
                    VStack(alignment: .leading, spacing: 12) {
                        Text("类型")
                            .font(.headline)

                        HStack(spacing: 12) {
                            typeCard(
                                icon: "💧",
                                title: "小便",
                                isSelected: hasWet,
                                color: .cyan
                            ) {
                                hasWet.toggle()
                                HapticManager.shared.light()
                            }

                            typeCard(
                                icon: "💩",
                                title: "大便",
                                isSelected: hasDirty,
                                color: .orange
                            ) {
                                hasDirty.toggle()
                                HapticManager.shared.light()
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Dirty details section
                    if hasDirty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("大便详情")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
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
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .padding(.horizontal)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("备注")
                            .font(.headline)
                            .padding(.horizontal)

                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                            .padding(.horizontal)
                    }

                    // Save button
                    Button(action: saveRecord) {
                        Text("保存记录")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: (hasWet || hasDirty)
                                        ? [Color.orange.opacity(0.8), Color.orange]
                                        : [Color.gray.opacity(0.3), Color.gray.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .cornerRadius(AppTheme.cornerRadiusLarge)
                    }
                    .disabled(!hasWet && !hasDirty)
                    .scaleButton()
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .animation(.smooth, value: hasDirty)
            .navigationTitle("尿布记录")
            .navigationBarTitleDisplayMode(.inline)
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

    private func typeCard(icon: String, title: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 40))
                Text(title)
                    .font(.headline)
                    .foregroundStyle(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                isSelected
                    ? color.opacity(0.15)
                    : Color(.systemGray6)
            )
            .cornerRadius(AppTheme.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
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

        modelContext.insert(record)
        do {
            try modelContext.save()
            HapticManager.shared.success()
            showingSaveSuccess = true
        } catch {
            modelContext.delete(record)
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
}

#Preview {
    DiaperRecordView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
        .modelContainer(for: [DiaperRecord.self])
}
