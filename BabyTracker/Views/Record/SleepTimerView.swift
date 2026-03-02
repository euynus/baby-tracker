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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    if let sleep = activeSleep {
                        activeTimerView(sleep: sleep)
                    } else {
                        startView
                    }
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("睡眠记录")
            .navigationBarTitleDisplayMode(.inline)
            .appPageBackground()
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
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("睡眠追踪")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.88))
                Text("准备开始")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("点击开始后将持续计时，醒来再结束。")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .gradientCard(AppTheme.sleepGradient)

            Button(action: startSleep) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                    Text("开始睡眠")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: AppTheme.sleepGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            }
            .buttonStyle(.plain)
            .scaleButton()
        }
    }

    // MARK: - Active Timer View

    private func activeTimerView(sleep: SleepRecord) -> some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                    Text("睡眠中")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(AppTheme.sleepGradient[0].opacity(0.22))
                .clipShape(Capsule())
                .pulse()
            }

            VStack(spacing: 12) {
                Text("已睡时长")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))

                Text(sleep.duration.formatHHMMSS())
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text("开始于 \(formatTime(sleep.startTime))")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
            .gradientCard(AppTheme.sleepGradient)

            VStack(alignment: .leading, spacing: 8) {
                Text("备注")
                    .font(.headline)
                TextEditor(text: $notes)
                    .frame(height: 90)
                    .padding(4)
                    .background(AppTheme.sleepGradient[0].opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(14)
            .cardStyle()

            Button(action: { endSleep(sleep) }) {
                Text("结束睡眠")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: AppTheme.sleepGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            }
            .buttonStyle(.plain)
            .scaleButton()
        }
    }

    // MARK: - Actions

    private func startSleep() {
        let sleep = SleepRecord(babyId: baby.id, startTime: Date())
        do {
            try modelContext.insertAndSave(sleep)
            HapticManager.shared.medium()
        } catch {
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
            try modelContext.saveIfNeeded()
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
