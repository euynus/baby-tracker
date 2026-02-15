//
//  SleepTimerView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct SleepTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let baby: Baby
    
    @Query private var sleepRecords: [SleepRecord]
    @State private var notes: String = ""
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""
    
    private var activeSleep: SleepRecord? {
        sleepRecords.first(where: { $0.babyId == baby.id && $0.isActive })
    }
    
    @State private var currentTime = Date()
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let sleep = activeSleep {
                        activeTimerView(sleep: sleep)
                    } else {
                        startView
                    }
                }
                .padding()
            }
            .navigationTitle("睡眠记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .alert("保存失败", isPresented: $showingSaveError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(saveErrorMessage)
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    // MARK: - Start View
    
    private var startView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple)
            
            Text("记录睡眠")
                .font(.title2)
                .fontWeight(.semibold)
            
            Button(action: startSleep) {
                Text("开始睡眠")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.8), Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(16)
            }
            .scaleButton()
            
            Spacer()
        }
    }
    
    // MARK: - Active Timer View
    
    private func activeTimerView(sleep: SleepRecord) -> some View {
        VStack(spacing: 24) {
            // Status badge
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                    Text("睡眠中")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.2))
                .cornerRadius(20)
                .pulse()
            }
            
            // Timer display
            VStack(spacing: 16) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.purple)
                
                Text("已睡时长")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(formatDuration(sleep.duration))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)
                    .monospacedDigit()
                
                Text("睡得香甜...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            
            // Info card
            VStack(spacing: 12) {
                HStack {
                    Text("开始时间")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formatTime(sleep.startTime))
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Text("已睡")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formatDuration(sleep.duration))
                        .fontWeight(.semibold)
                        .foregroundStyle(.purple)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Notes
            VStack(alignment: .leading, spacing: 12) {
                Text("备注")
                    .font(.headline)
                
                TextEditor(text: $notes)
                    .frame(height: 80)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // End button
            Button(action: { endSleep(sleep) }) {
                Text("✓ 结束睡眠")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(12)
            }
            .scaleButton()
        }
    }
    
    // MARK: - Actions
    
    private func startSleep() {
        let sleep = SleepRecord(babyId: baby.id, startTime: Date())
        modelContext.insert(sleep)
        do {
            try modelContext.save()
            HapticManager.shared.medium()
        } catch {
            modelContext.delete(sleep)
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }

    private func endSleep(_ sleep: SleepRecord) {
        sleep.endTime = Date()
        if !notes.isEmpty {
            sleep.notes = notes
        }
        do {
            try modelContext.save()
            HapticManager.shared.medium()
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Formatters
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    SleepTimerView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
        .modelContainer(for: [SleepRecord.self])
}
