//
//  ProfileView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData
import OSLog

private let profileLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.babytracker.app",
    category: "Profile"
)
private let profileRowInsets = EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
private let profileCardPadding: CGFloat = 14

private extension View {
    func profileListRow() -> some View {
        self
            .listRowInsets(profileRowInsets)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        sort: [
            SortDescriptor(\Baby.birthday, order: .reverse),
            SortDescriptor(\Baby.name, order: .forward)
        ]
    ) private var babies: [Baby]
    
    @State private var showingAddBaby = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    profileHero
                        .profileListRow()
                }

                Section {
                    ForEach(babies) { baby in
                        NavigationLink {
                            BabyDetailView(baby: baby)
                        } label: {
                            BabyRow(baby: baby)
                        }
                        .profileListRow()
                    }
                    .onDelete(perform: deleteBabies)
                    
                    Button(action: { showingAddBaby = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppTheme.brand)
                            Text("添加新宝宝")
                                .foregroundStyle(AppTheme.brand)
                            Spacer()
                        }
                        .padding(profileCardPadding)
                        .cardStyle()
                    }
                    .profileListRow()
                } header: {
                    sectionHeader("我的宝宝")
                }
                
                if let baby = babies.first {
                    Section {
                        NavigationLink {
                            PhotoGalleryView(baby: baby)
                        } label: {
                            settingsRow(icon: "photo.on.rectangle.angled", title: "照片")
                        }
                        .profileListRow()

                        NavigationLink {
                            VaccinationCenterView(baby: baby)
                        } label: {
                            settingsRow(icon: "syringe.fill", title: "疫苗")
                        }
                        .profileListRow()
                    } header: {
                        sectionHeader("快速访问")
                    }
                }
                
                Section {
                    if let baby = babies.first {
                        NavigationLink {
                            ReminderSettingsView(baby: baby)
                        } label: {
                            settingsRow(icon: "bell.badge", title: "提醒设置")
                        }
                        .profileListRow()
                        
                        NavigationLink {
                            GrowthChartView(baby: baby)
                        } label: {
                            settingsRow(icon: "chart.line.uptrend.xyaxis", title: "生长曲线")
                        }
                        .profileListRow()
                    }
                    
                    NavigationLink {
                        iCloudSyncView()
                    } label: {
                        settingsRow(icon: "icloud", title: "iCloud 同步")
                    }
                    .profileListRow()
                    
                    NavigationLink {
                        SecuritySettingsView()
                    } label: {
                        settingsRow(icon: "lock.shield", title: "安全设置")
                    }
                    .profileListRow()
                    
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        settingsRow(icon: "paintbrush", title: "外观设置")
                    }
                    .profileListRow()
                    
                    NavigationLink {
                        ExportView()
                    } label: {
                        settingsRow(icon: "square.and.arrow.up", title: "导出数据")
                    }
                    .profileListRow()
                    
                    NavigationLink {
                        Text("帮助与反馈")
                    } label: {
                        settingsRow(icon: "questionmark.circle", title: "帮助与反馈")
                    }
                    .profileListRow()
                } header: {
                    sectionHeader("其他")
                }
                
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    .padding(profileCardPadding)
                    .cardStyle()
                    .profileListRow()
                }
            }
            .navigationTitle("我的")
            .listStyle(.insetGrouped)
            .listSectionSeparator(.hidden)
            .listSectionSpacing(14)
            .listRowSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .appPageBackground()
            .sheet(isPresented: $showingAddBaby) {
                AddBabyView()
            }
        }
    }

    private var profileHero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("家庭中心")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.88))
            Text("照护与成长")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("\(babies.count) 个宝宝档案")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .gradientCard(AppTheme.heroGradient)
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.brand)
                .frame(width: 28, height: 28)
                .background(AppTheme.brand.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(profileCardPadding)
        .cardStyle()
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(nil)
    }
    
    private func deleteBabies(at offsets: IndexSet) {
        for index in offsets {
            let baby = babies[index]
            deleteRelatedRecords(for: baby.id)
            modelContext.delete(baby)
        }
        do {
            try modelContext.saveIfNeeded()
        } catch {
            profileLogger.error("删除宝宝保存失败: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func deleteRelatedRecords(for babyId: UUID) {
        do {
            let feeding = try modelContext.fetch(
                FetchDescriptor<FeedingRecord>(predicate: #Predicate { $0.babyId == babyId })
            )
            let sleep = try modelContext.fetch(
                FetchDescriptor<SleepRecord>(predicate: #Predicate { $0.babyId == babyId })
            )
            let diaper = try modelContext.fetch(
                FetchDescriptor<DiaperRecord>(predicate: #Predicate { $0.babyId == babyId })
            )
            let growth = try modelContext.fetch(
                FetchDescriptor<GrowthRecord>(predicate: #Predicate { $0.babyId == babyId })
            )
            let photos = try modelContext.fetch(
                FetchDescriptor<PhotoRecord>(predicate: #Predicate { $0.babyId == babyId })
            )
            let vaccinations = try modelContext.fetch(
                FetchDescriptor<VaccinationRecord>(predicate: #Predicate { $0.babyId == babyId })
            )

            feeding.forEach { modelContext.delete($0) }
            sleep.forEach { modelContext.delete($0) }
            diaper.forEach { modelContext.delete($0) }
            growth.forEach { modelContext.delete($0) }
            photos.forEach { modelContext.delete($0) }
            vaccinations.forEach { modelContext.delete($0) }
        } catch {
            profileLogger.error("删除宝宝关联记录失败: \(error.localizedDescription, privacy: .public)")
        }
    }
}

struct BabyRow: View {
    let baby: Baby
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: AppTheme.heroGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "figure.and.child.holdinghands")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(baby.name)
                    .font(.headline)
                
                Text(baby.age)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let weight = baby.latestWeight {
                    Text("体重: \(String(format: "%.1f", weight / 1000))kg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(profileCardPadding)
        .cardStyle()
    }
}

struct BabyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let baby: Baby
    
    @State private var name: String
    @State private var birthday: Date
    @State private var gender: Gender
    @State private var weight: String
    @State private var height: String
    @State private var headCircumference: String
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""
    
    init(baby: Baby) {
        self.baby = baby
        _name = State(initialValue: baby.name)
        _birthday = State(initialValue: baby.birthday)
        _gender = State(initialValue: baby.gender)
        _weight = State(initialValue: baby.latestWeight.map { String(format: "%.0f", $0) } ?? "")
        _height = State(initialValue: baby.latestHeight.map { String(format: "%.1f", $0) } ?? "")
        _headCircumference = State(initialValue: baby.latestHeadCircumference.map { String(format: "%.1f", $0) } ?? "")
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("基本信息")
                        .font(.headline)

                    TextField("姓名", text: $name)
                        .textFieldStyle(.roundedBorder)

                    DatePicker("出生日期", selection: $birthday, displayedComponents: .date)

                    Picker("性别", selection: $gender) {
                        Text("男").tag(Gender.male)
                        Text("女").tag(Gender.female)
                        Text("其他").tag(Gender.other)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(14)
                .cardStyle()

                VStack(alignment: .leading, spacing: 10) {
                    Text("最新测量")
                        .font(.headline)

                    measurementRow(title: "体重", unit: "g", text: $weight)
                    measurementRow(title: "身高", unit: "cm", text: $height)
                    measurementRow(title: "头围", unit: "cm", text: $headCircumference)
                }
                .padding(14)
                .cardStyle()

                Button("保存") {
                    saveBaby()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: AppTheme.heroGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundStyle(.white)
                .font(.headline)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
                .scaleButton()
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("宝宝资料")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .alert("保存失败", isPresented: $showingSaveError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
        }
    }

    private func measurementRow(title: String, unit: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            TextField("-", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
            Text(unit)
                .foregroundStyle(.secondary)
        }
    }
    
    private func saveBaby() {
        baby.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        baby.birthday = birthday
        baby.gender = gender
        
        if let weightValue = Double(weight) {
            baby.latestWeight = weightValue
        }
        
        if let heightValue = Double(height) {
            baby.latestHeight = heightValue
        }
        
        if let headValue = Double(headCircumference) {
            baby.latestHeadCircumference = headValue
        }
        
        do {
            try modelContext.saveIfNeeded()
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
            profileLogger.error("更新宝宝信息保存失败: \(error.localizedDescription, privacy: .public)")
        }
    }
}

struct AddBabyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var birthday = Date()
    @State private var gender = Gender.male
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("基本信息")
                            .font(.headline)

                        TextField("姓名", text: $name)
                            .textFieldStyle(.roundedBorder)

                        DatePicker("出生日期", selection: $birthday, displayedComponents: .date)

                        Picker("性别", selection: $gender) {
                            Text("男").tag(Gender.male)
                            Text("女").tag(Gender.female)
                            Text("其他").tag(Gender.other)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(14)
                    .cardStyle()

                    Button("保存") {
                        addBaby()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: canSave ? AppTheme.heroGradient : AppTheme.disabledGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .font(.headline)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
                    .disabled(!canSave)
                    .scaleButton()
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("添加宝宝")
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
        }
    }
    
    private func addBaby() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let baby = Baby(name: trimmedName, birthday: birthday, gender: gender)
        do {
            try modelContext.insertAndSave(baby)
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
            profileLogger.error("新增宝宝保存失败: \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Baby.self, FeedingRecord.self, SleepRecord.self, DiaperRecord.self, GrowthRecord.self, PhotoRecord.self, VaccinationRecord.self])
}
