//
//  VaccinationCenterView.swift
//  BabyTracker
//
//  Created on 2026-02-28.
//

import SwiftUI
import SwiftData

struct VaccinationCenterView: View {
    @Query(sort: \VaccinationRecord.administeredAt, order: .reverse) private var records: [VaccinationRecord]

    let baby: Baby

    @State private var selectedTrack: VaccinationTrack = .free
    @State private var selectedMilestone: VaccinationMilestone?
    @State private var selectedDetailMilestone: VaccinationMilestone?

    private var babyRecords: [VaccinationRecord] {
        records.filter { $0.babyId == baby.id }
    }

    private var milestones: [VaccinationMilestone] {
        VaccinationSchedule.milestones(for: baby, records: babyRecords, track: selectedTrack)
    }

    private var pendingMilestones: [VaccinationMilestone] {
        milestones.filter { !$0.isCompleted }
    }

    private var completedMilestones: [VaccinationMilestone] {
        milestones.filter { $0.isCompleted }
    }

    private var overdueCount: Int {
        pendingMilestones.filter { $0.isOverdue }.count
    }

    private var nextMilestone: VaccinationMilestone? {
        VaccinationSchedule.nextPendingMilestone(for: baby, records: babyRecords, track: selectedTrack)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                heroCard
                trackSelectorCard

                if pendingMilestones.isEmpty {
                    completedCard
                } else {
                    pendingSection
                }

                completedSection
                notesSection
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("疫苗")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .sheet(item: $selectedMilestone) { milestone in
            VaccinationRecordEntryView(baby: baby, milestone: milestone, selectedTrack: selectedTrack)
        }
        .sheet(item: $selectedDetailMilestone) { milestone in
            VaccinationMilestoneDetailView(
                milestone: milestone,
                selectedTrack: selectedTrack,
                onRegister: { target in
                    selectedDetailMilestone = nil
                    DispatchQueue.main.async {
                        selectedMilestone = target
                    }
                }
            )
        }
        .onAppear {
            selectedTrack = VaccinationSchedule.storedTrack(for: baby.id)
            syncVaccinationReminderIfNeeded()
        }
        .onChange(of: selectedTrack) { _, track in
            VaccinationSchedule.setStoredTrack(track, for: baby.id)
            syncVaccinationReminderIfNeeded()
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("首年免疫进度")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.88))

            Text(selectedTrack.title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())

            Text("\(completedMilestones.count) / \(milestones.count)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if let nextMilestone {
                Text("下次：\(nextMilestone.plan.vaccineName) \(nextMilestone.plan.doseLabel) · \(dateText(nextMilestone.dueDate))")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            } else {
                Text("首年计划已全部登记")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }

            HStack(spacing: 8) {
                metricChip(title: "待接种", value: "\(pendingMilestones.count)")
                metricChip(title: "已逾期", value: "\(overdueCount)")
            }
        }
        .padding(16)
        .gradientCard(AppTheme.vaccineGradient)
    }

    private var trackSelectorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("接种方案")
                .font(.headline)

            Picker("方案", selection: $selectedTrack) {
                ForEach(VaccinationTrack.allCases) { track in
                    Text(track.title).tag(track)
                }
            }
            .pickerStyle(.segmented)
            .minimumTappableSize()

            Text("当前：\(selectedTrack.subtitle)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .cardStyle()
    }

    private var pendingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("待接种")
                    .font(.headline)
                Spacer()
                Text("\(pendingMilestones.count) 项")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(pendingMilestones) { milestone in
                vaccineRow(milestone: milestone, isCompleted: false)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("已登记")
                    .font(.headline)
                Spacer()
                Text("\(completedMilestones.count) 项")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if completedMilestones.isEmpty {
                Text("暂未登记接种记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(completedMilestones) { milestone in
                    vaccineRow(milestone: milestone, isCompleted: true)
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("参考依据", systemImage: "doc.text.magnifyingglass")
                .font(.headline)
            Text(VaccinationSchedule.programVersion(for: selectedTrack))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("各地门诊执行细节可能不同，最终请以属地接种门诊和接种证为准。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .cardStyle()
    }

    private var completedCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 30))
                .foregroundStyle(.green)
            Text("首年免疫计划已全部登记")
                .font(.headline)
            Text("后续加强针可在接种门诊提醒后继续补录。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .cardStyle()
    }

    private func vaccineRow(milestone: VaccinationMilestone, isCompleted: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "syringe.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isCompleted ? .green : AppTheme.secondary)
                .frame(width: 28, height: 28)
                .background((isCompleted ? Color.green : AppTheme.secondary).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(milestone.plan.vaccineName) · \(milestone.plan.doseLabel)")
                    .font(.subheadline.weight(.semibold))
                Text(isCompleted ? completedSubtitle(milestone) : pendingSubtitle(milestone))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.green)
            } else {
                Button("登记") {
                    selectedMilestone = milestone
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(milestone.isOverdue ? .red : AppTheme.brand)
                .minimumTappableSize()
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedDetailMilestone = milestone
        }
        .padding(12)
        .background(Color.white.opacity(0.001))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func metricChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.88))
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func pendingSubtitle(_ milestone: VaccinationMilestone) -> String {
        let due = dateText(milestone.dueDate)
        if milestone.isOverdue {
            return "应种：\(milestone.plan.ageDescription)（已逾期）"
        }
        return "应种：\(milestone.plan.ageDescription) · 建议日期：\(due)"
    }

    private func completedSubtitle(_ milestone: VaccinationMilestone) -> String {
        guard let record = milestone.record else { return "" }
        return "已于 \(dateText(record.administeredAt)) 登记"
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func syncVaccinationReminderIfNeeded() {
        let defaults = UserDefaults.standard
        let enabledKey = "vaccineReminderEnabled.\(baby.id.uuidString)"
        let daysAheadKey = "vaccineDaysAhead.\(baby.id.uuidString)"
        let isEnabled = defaults.object(forKey: enabledKey) as? Bool ?? false
        guard isEnabled else { return }

        let daysAhead = defaults.object(forKey: daysAheadKey) as? Int ?? 1
        NotificationManager.shared.scheduleVaccinationReminder(
            baby: baby,
            records: babyRecords,
            track: selectedTrack,
            daysAhead: daysAhead
        )
    }
}

private struct VaccinationMilestoneDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let milestone: VaccinationMilestone
    let selectedTrack: VaccinationTrack
    let onRegister: (VaccinationMilestone) -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    planCard
                    if milestone.isCompleted {
                        completedRecordCard
                    } else {
                        pendingStatusCard
                        registerButton
                    }
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("疫苗详情")
            .navigationBarTitleDisplayMode(.inline)
            .appPageBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(milestone.plan.vaccineName) · \(milestone.plan.doseLabel)")
                .font(.headline)

            detailRow(title: "接种方案", value: selectedTrack.title)
            detailRow(title: "推荐月龄", value: milestone.plan.ageDescription)
            detailRow(title: "建议日期", value: dateText(milestone.dueDate))
            detailRow(title: "参考依据", value: milestone.plan.referenceNote)
        }
        .padding(14)
        .cardStyle()
    }

    private var pendingStatusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("当前状态")
                .font(.headline)

            Text(milestone.isOverdue ? "已逾期，建议尽快咨询门诊并完成接种。" : "尚未登记接种记录。")
                .font(.subheadline)
                .foregroundStyle(milestone.isOverdue ? .red : .secondary)
        }
        .padding(14)
        .cardStyle()
    }

    private var completedRecordCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("登记记录")
                .font(.headline)

            if let record = milestone.record {
                detailRow(title: "接种时间", value: dateTimeText(record.administeredAt))
                detailRow(title: "接种机构", value: record.institution ?? "未填写")
                detailRow(title: "疫苗批号", value: record.batchNumber ?? "未填写")
                detailRow(title: "不良反应", value: record.hasAdverseReaction ? "有" : "无")
                if record.hasAdverseReaction {
                    detailRow(title: "反应记录", value: record.reactionNotes ?? "未填写")
                }
                detailRow(title: "备注", value: record.notes ?? "未填写")
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var registerButton: some View {
        Button("登记接种") {
            onRegister(milestone)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(milestone.isOverdue ? .red : AppTheme.brand)
        .font(.headline)
        .minimumTappableSize()
        .scaleButton(scale: 0.98)
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func dateTimeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

private struct VaccinationRecordEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let baby: Baby
    let milestone: VaccinationMilestone
    let selectedTrack: VaccinationTrack

    @State private var administeredAt = Date()
    @State private var institution = ""
    @State private var batchNumber = ""
    @State private var hasAdverseReaction = false
    @State private var reactionNotes = ""
    @State private var notes = ""

    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""
    @State private var showingSaveSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    planCard
                    entryCard
                    safetyCard
                    saveButton
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("登记接种")
            .navigationBarTitleDisplayMode(.inline)
            .appPageBackground()
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
            .saveSuccessOverlay(
                isPresented: $showingSaveSuccess,
                title: "接种记录已保存",
                subtitle: "接种进度和提醒计划已同步更新。"
            ) {
                dismiss()
            }
        }
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("接种项目")
                .font(.headline)
            Text("\(milestone.plan.vaccineName) · \(milestone.plan.doseLabel)")
                .font(.subheadline.weight(.semibold))
            Text("推荐：\(milestone.plan.ageDescription)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("参考日期：\(dateText(milestone.dueDate))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("方案：\(selectedTrack.title)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .cardStyle()
    }

    private var entryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("接种信息")
                .font(.headline)

            DatePicker("接种时间", selection: $administeredAt, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .minimumTappableSize()

            TextField("接种机构（可选）", text: $institution)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            TextField("疫苗批号（可选）", text: $batchNumber)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            TextEditor(text: $notes)
                .frame(height: 86)
                .padding(4)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("备注（可选）")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)
                            .padding(.leading, 10)
                    }
                }
        }
        .padding(14)
        .cardStyle()
    }

    private var safetyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("是否出现不良反应", isOn: $hasAdverseReaction)
                .font(.headline)

            if hasAdverseReaction {
                TextEditor(text: $reactionNotes)
                    .frame(height: 80)
                    .padding(4)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if reactionNotes.isEmpty {
                            Text("记录症状与处理（可选）")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 12)
                                .padding(.leading, 10)
                        }
                    }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var saveButton: some View {
        Button("保存登记") {
            saveRecord()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(AppTheme.brand)
        .font(.headline)
        .minimumTappableSize()
        .scaleButton(scale: 0.98)
    }

    private func saveRecord() {
        if administeredAt > Date.now.addingTimeInterval(60) {
            saveErrorMessage = "接种时间不能晚于当前时间"
            showingSaveError = true
            return
        }

        do {
            let existing = try fetchExistingRecord()
            let record = existing ?? VaccinationRecord(
                babyId: baby.id,
                vaccineCode: milestone.plan.code,
                vaccineName: milestone.plan.vaccineName,
                doseLabel: milestone.plan.doseLabel,
                recommendedAgeDescription: milestone.plan.ageDescription,
                dueDate: milestone.dueDate,
                administeredAt: administeredAt,
                track: selectedTrack
            )

            record.track = selectedTrack
            record.vaccineName = milestone.plan.vaccineName
            record.doseLabel = milestone.plan.doseLabel
            record.recommendedAgeDescription = milestone.plan.ageDescription
            record.dueDate = milestone.dueDate
            record.administeredAt = administeredAt
            record.institution = trimmedOrNil(institution)
            record.batchNumber = trimmedOrNil(batchNumber)
            record.hasAdverseReaction = hasAdverseReaction
            record.reactionNotes = hasAdverseReaction ? trimmedOrNil(reactionNotes) : nil
            record.notes = trimmedOrNil(notes)

            if existing == nil {
                modelContext.insert(record)
            }

            try modelContext.saveIfNeeded()
            try rescheduleVaccinationReminderIfNeeded()
            HapticManager.shared.success()
            showingSaveSuccess = true
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }

    private func fetchExistingRecord() throws -> VaccinationRecord? {
        let babyId = baby.id
        let vaccineCode = milestone.plan.code
        let trackRaw = selectedTrack.rawValue
        let descriptor = FetchDescriptor<VaccinationRecord>(
            predicate: #Predicate { record in
                record.babyId == babyId && record.vaccineCode == vaccineCode && record.trackRaw == trackRaw
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    private func trimmedOrNil(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func rescheduleVaccinationReminderIfNeeded() throws {
        let defaults = UserDefaults.standard
        let enabledKey = "vaccineReminderEnabled.\(baby.id.uuidString)"
        let daysAheadKey = "vaccineDaysAhead.\(baby.id.uuidString)"
        let isEnabled = defaults.object(forKey: enabledKey) as? Bool ?? false
        guard isEnabled else { return }

        let daysAhead = defaults.object(forKey: daysAheadKey) as? Int ?? 1
        let babyId = baby.id
        let descriptor = FetchDescriptor<VaccinationRecord>(predicate: #Predicate { $0.babyId == babyId })
        let allRecords = try modelContext.fetch(descriptor)

        NotificationManager.shared.scheduleVaccinationReminder(
            baby: baby,
            records: allRecords,
            track: selectedTrack,
            daysAhead: daysAhead
        )
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        VaccinationCenterView(baby: Baby(name: "小宝", birthday: Date(), gender: .male))
    }
    .modelContainer(for: [Baby.self, VaccinationRecord.self])
}
