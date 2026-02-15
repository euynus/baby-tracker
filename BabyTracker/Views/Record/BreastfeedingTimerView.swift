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
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if !viewModel.hasStarted {
                        startSelectionView
                    } else if showingCompletion {
                        completionView
                    } else {
                        timerView
                    }
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("母乳喂养")
            .navigationBarTitleDisplayMode(.inline)
            .appPageBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        viewModel.stop()
                        dismiss()
                    }
                }
            }
            .alert("保存失败", isPresented: $showingSaveError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(saveErrorMessage)
            }
        }
    }

    private var startSelectionView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color.white.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("开始母乳喂养计时")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("先选择起始侧别")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(16)
            .gradientCard(AppTheme.feedingGradient)

            HStack(spacing: 12) {
                sideButton(side: .left)
                sideButton(side: .right)
            }
        }
    }

    private func sideButton(side: BreastSide) -> some View {
        let isLeft = side == .left
        return Button(action: { viewModel.start(side: side) }) {
            VStack(spacing: 10) {
                Image(systemName: isLeft ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(AppTheme.secondary)
                Text(isLeft ? "左侧开始" : "右侧开始")
                    .font(.headline)
                Text("点击开始")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .cardStyle()
        }
        .buttonStyle(.plain)
        .scaleButton()
    }

    private var timerView: some View {
        VStack(spacing: 16) {
            statusCard
            sideSummaryCard
            controlButtons
            finishButton
        }
    }

    private var statusCard: some View {
        VStack(spacing: 14) {
            HStack {
                Label(viewModel.isRunning ? "计时中" : "已暂停", systemImage: viewModel.isRunning ? "timer" : "pause.circle")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.isRunning ? Color.green.opacity(0.18) : Color.orange.opacity(0.2))
                    .clipShape(Capsule())
                Spacer()
            }

            VStack(spacing: 6) {
                Text("当前侧别：\(currentSideText)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                Text(viewModel.formattedCurrentTime)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text(timingDescription)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.86))
            }

            HStack {
                Text("总时长")
                    .foregroundStyle(.white.opacity(0.88))
                Spacer()
                Text(viewModel.formattedTotalTime)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
        .padding(16)
        .gradientCard([AppTheme.secondary, AppTheme.brand])
    }

    private var sideSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                sideTimerCard(
                    symbol: "arrow.left.circle",
                    title: "左侧",
                    duration: viewModel.leftDuration,
                    isActive: viewModel.currentSide == .left && viewModel.isRunning
                )
                sideTimerCard(
                    symbol: "arrow.right.circle",
                    title: "右侧",
                    duration: viewModel.rightDuration,
                    isActive: viewModel.currentSide == .right && viewModel.isRunning
                )
            }

            Divider()

            HStack {
                row(symbol: "clock", title: "开始时间", value: viewModel.formattedStartTime)
                Spacer()
                row(symbol: "flag.checkered", title: "预计结束", value: viewModel.formattedEndTime)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private func sideTimerCard(symbol: String, title: String, duration: TimeInterval, isActive: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(formatDuration(duration))
                .font(.title3.weight(.bold))
                .monospacedDigit()

            Text(isActive ? "进行中" : duration > 0 ? "已记录" : "未开始")
                .font(.caption2)
                .foregroundStyle(isActive ? .green : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isActive ? AppTheme.secondary.opacity(0.15) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var controlButtons: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.switchSide() }) {
                Label(
                    viewModel.currentSide == .left ? "切到右侧" : "切到左侧",
                    systemImage: "arrow.left.arrow.right"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(AppTheme.secondary.opacity(0.18))
                .foregroundStyle(AppTheme.ink)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            }
            .scaleButton()

            Button(action: { viewModel.togglePause() }) {
                Label(
                    viewModel.isRunning ? "暂停" : "继续",
                    systemImage: viewModel.isRunning ? "pause.fill" : "play.fill"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    viewModel.isRunning
                        ? Color.orange.opacity(0.86)
                        : Color.green.opacity(0.86)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            }
            .scaleButton()
        }
    }

    private var finishButton: some View {
        Button(action: {
            viewModel.stop()
            showingCompletion = true
        }) {
            Label("结束并填写记录", systemImage: "checkmark")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppTheme.brand, Color.red.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(.white)
                .font(.headline)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        }
        .scaleButton()
    }

    private func row(symbol: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)
                Text("喂养完成")
                    .font(.title3.weight(.bold))
                Text("请补充可选信息后保存")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .cardStyle()

            VStack(alignment: .leading, spacing: 10) {
                Text("时间记录")
                    .font(.headline)
                completionRow(symbol: "clock", title: "开始", value: viewModel.formattedStartTime)
                completionRow(symbol: "clock.arrow.trianglehead.counterclockwise.rotate.90", title: "结束", value: viewModel.formattedEndTime)
                completionRow(symbol: "hourglass", title: "总时长", value: viewModel.formattedTotalTime)
            }
            .padding(14)
            .cardStyle()

            VStack(alignment: .leading, spacing: 10) {
                Text("奶量估算（可选）")
                    .font(.headline)
                HStack {
                    TextField("例如 120", text: $estimatedAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Text("ml")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .cardStyle()

            VStack(alignment: .leading, spacing: 10) {
                Text("备注")
                    .font(.headline)
                TextEditor(text: $notes)
                    .frame(height: 88)
                    .padding(6)
                    .background(AppTheme.feedingGradient[0].opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(14)
            .cardStyle()

            Button(action: saveRecord) {
                Text("保存记录")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: AppTheme.feedingGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .font(.headline)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            }
            .scaleButton()
        }
    }

    private func completionRow(symbol: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondary)
                .frame(width: 28, height: 28)
                .background(AppTheme.secondary.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
    }

    private var currentSideText: String {
        viewModel.currentSide == .left ? "左侧" : "右侧"
    }

    private var timingDescription: String {
        viewModel.isRunning ? "\(currentSideText)进行中" : "已暂停，可继续或切换侧别"
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
            timestamp: viewModel.startTime ?? Date(),
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

        do {
            try modelContext.insertAndSave(record)
            HapticManager.shared.success()
            onComplete()
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
}

#Preview {
    BreastfeedingTimerView(baby: Baby(name: "小宝", birthday: Date(), gender: .male), onComplete: {})
        .modelContainer(for: [FeedingRecord.self])
}
