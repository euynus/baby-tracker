//
//  BreastfeedingTimerView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct BreastfeedingTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let baby: Baby
    let onComplete: () -> Void
    
    @StateObject private var viewModel: BreastfeedingTimerViewModel
    
    init(baby: Baby, onComplete: @escaping () -> Void) {
        self.baby = baby
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: BreastfeedingTimerViewModel(baby: baby))
    }
    @State private var estimatedAmount: String = ""
    @State private var notes: String = ""
    @State private var showingCompletion = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !viewModel.hasStarted {
                        startSelectionView
                    } else if showingCompletion {
                        completionView
                    } else {
                        timerView
                    }
                }
                .padding()
            }
            .navigationTitle("母乳喂养")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        viewModel.stop()
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Start Selection View
    
    private var startSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "timer")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            
            Text("选择侧别开始计时")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                sideButton(side: .left, icon: "⬅️", title: "左侧开始")
                sideButton(side: .right, icon: "➡️", title: "右侧开始")
            }
            
            Spacer()
        }
    }
    
    private func sideButton(side: BreastSide, icon: String, title: String) -> some View {
        Button(action: { viewModel.start(side: side) }) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 40))
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Timer View
    
    private var timerView: some View {
        VStack(spacing: 24) {
            // Status badge
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isRunning ? "timer" : "pause.circle")
                    Text(viewModel.isRunning ? "计时中" : "已暂停")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    viewModel.isRunning ? 
                    Color.blue.opacity(0.2) : Color.orange.opacity(0.2)
                )
                .cornerRadius(20)
            }
            
            // Main timer display
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Text(currentSideIcon)
                        .font(.system(size: 48))
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                }
                
                Text("当前侧别：\(currentSideText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(viewModel.formattedCurrentTime)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .monospacedDigit()
                
                Text(timingDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            
            // Side timers
            HStack(spacing: 12) {
                sideTimerCard(
                    icon: "⬅️",
                    title: "左侧",
                    duration: viewModel.leftDuration,
                    isActive: viewModel.currentSide == .left && viewModel.isRunning
                )
                
                sideTimerCard(
                    icon: "➡️",
                    title: "右侧",
                    duration: viewModel.rightDuration,
                    isActive: viewModel.currentSide == .right && viewModel.isRunning
                )
            }
            
            // Summary card
            VStack(spacing: 12) {
                summaryRow(label: "总时长", value: viewModel.formattedTotalTime, highlight: true)
                Divider()
                summaryRow(label: "开始时间", value: viewModel.formattedStartTime)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Control buttons
            HStack(spacing: 12) {
                Button(action: { viewModel.switchSide() }) {
                    Label(
                        viewModel.currentSide == .left ? "切换到右侧" : "切换到左侧",
                        systemImage: "arrow.left.arrow.right"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(12)
                }
                
                Button(action: { viewModel.togglePause() }) {
                    Label(
                        viewModel.isRunning ? "暂停" : "继续",
                        systemImage: viewModel.isRunning ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isRunning ? Color.orange : Color.green)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(12)
                }
            }
            
            // Finish button
            Button(action: { 
                viewModel.stop()
                showingCompletion = true
            }) {
                Text("✓ 结束喂养")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(12)
            }
        }
    }
    
    private func sideTimerCard(icon: String, title: String, duration: TimeInterval, isActive: Bool) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(formatDuration(duration))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .monospacedDigit()
            if isActive {
                Text("⏱️ 进行中")
                    .font(.caption2)
                    .foregroundStyle(.cyan)
            } else if duration > 0 {
                Text("✓ 已完成")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isActive ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.cyan : Color.clear, lineWidth: 2)
        )
    }
    
    private func summaryRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(highlight ? .bold : .semibold)
                .foregroundStyle(highlight ? .blue : .primary)
                .font(highlight ? .title3 : .body)
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 24) {
            // Success indicator
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
                Text("喂养完成")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // Time summary
            VStack(alignment: .leading, spacing: 12) {
                Text("时间记录")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    summaryRow(label: "开始时间", value: viewModel.formattedStartTime)
                    summaryRow(label: "结束时间", value: viewModel.formattedEndTime)
                    Divider()
                    summaryRow(label: "总时长", value: viewModel.formattedTotalTime, highlight: true)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Side breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("各侧时长")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Text("⬅️")
                            .font(.largeTitle)
                        Text("左侧")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatDuration(viewModel.leftDuration))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        Text("➡️")
                            .font(.largeTitle)
                        Text("右侧")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatDuration(viewModel.rightDuration))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            // Optional fields
            VStack(alignment: .leading, spacing: 12) {
                Text("奶量（可选估算）")
                    .font(.headline)
                
                HStack {
                    TextField("估算奶量", text: $estimatedAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Text("ml")
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("备注")
                    .font(.headline)
                
                TextEditor(text: $notes)
                    .frame(height: 80)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Save button
            Button(action: saveRecord) {
                Text("保存记录")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var currentSideIcon: String {
        viewModel.currentSide == .left ? "⬅️" : "➡️"
    }
    
    private var currentSideText: String {
        viewModel.currentSide == .left ? "左侧" : "右侧"
    }
    
    private var timingDescription: String {
        if viewModel.isRunning {
            return "\(currentSideText)进行中"
        } else {
            return "已暂停，可以继续或切换侧别"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func saveRecord() {
        let record = FeedingRecord(
            babyId: baby.id,
            timestamp: viewModel.startTime,
            method: .breastfeeding
        )
        
        record.leftDuration = Int(viewModel.leftDuration)
        record.rightDuration = Int(viewModel.rightDuration)
        
        if let amount = Double(estimatedAmount), amount > 0 {
            record.amount = amount
        }
        
        if !notes.isEmpty {
            record.notes = notes
        }
        
        modelContext.insert(record)
        
        onComplete()
    }
}

#Preview {
    BreastfeedingTimerView(baby: Baby(name: "小宝", birthday: Date(), gender: .male), onComplete: {})
        .modelContainer(for: [FeedingRecord.self])
}
