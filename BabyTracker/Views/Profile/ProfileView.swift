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

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        sort: [
            SortDescriptor(\Baby.birthday, order: .reverse),
            SortDescriptor(\Baby.name, order: .forward)
        ]
    ) private var babies: [Baby]

    @State private var showingAddBaby = false
    @State private var quickAccessBabyId: UUID?
    @State private var pendingDeletion: Baby?
    @State private var selectedBabyForDetail: Baby?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHero

                    if babies.isEmpty {
                        AppEmptyStateCard(
                            symbol: "person.crop.circle.badge.plus",
                            title: "还没有宝宝档案",
                            message: "先创建第一个宝宝档案，照片、提醒、疫苗和成长曲线才会有内容。"
                        )
                    } else {
                        if babies.count > 1 {
                            quickAccessBabySelector
                        }

                        familyOverview
                        babyProfilesSection

                        if let baby = quickAccessBaby {
                            quickToolsSection(for: baby)
                        }

                        settingsSection
                        versionCard
                    }
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.top, 12)
                .padding(.bottom, 22)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Baby Tracker")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.brand)
                        Text("我的")
                            .font(.headline.weight(.bold))
                    }
                }
            }
            .appPageBackground()
            .sheet(isPresented: $showingAddBaby) {
                AddBabyView()
            }
            .sheet(item: $selectedBabyForDetail) { baby in
                NavigationStack {
                    BabyDetailView(baby: baby)
                }
            }
            .confirmationDialog(
                "删除宝宝档案后，相关记录也会一并移除。",
                isPresented: Binding(
                    get: { pendingDeletion != nil },
                    set: { if !$0 { pendingDeletion = nil } }
                ),
                titleVisibility: .visible
            ) {
                if let pendingDeletion {
                    Button("删除 \(pendingDeletion.name)", role: .destructive) {
                        deleteBaby(pendingDeletion)
                    }
                }
                Button("取消", role: .cancel) {
                    pendingDeletion = nil
                }
            }
            .onAppear {
                if quickAccessBabyId == nil {
                    quickAccessBabyId = babies.first?.id
                }
            }
            .onChange(of: babies) { _, newBabies in
                guard let currentId = quickAccessBabyId else {
                    quickAccessBabyId = newBabies.first?.id
                    return
                }
                if !newBabies.contains(where: { $0.id == currentId }) {
                    quickAccessBabyId = newBabies.first?.id
                }
            }
        }
    }

    private var quickAccessBaby: Baby? {
        guard let quickAccessBabyId else { return babies.first }
        return babies.first(where: { $0.id == quickAccessBabyId }) ?? babies.first
    }

    private var profileHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("家庭中心")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text("照护与成长")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(heroSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.90))
                }

                Spacer()

                AppIconBadge(symbol: "heart.text.square.fill", colors: AppTheme.mintHeroGradient, size: 54)
            }

            HStack(spacing: 10) {
                AppStatusChip(title: "宝宝档案", value: "\(babies.count) 个")
                AppStatusChip(title: "快捷对象", value: quickAccessBaby?.name ?? "未设置")
                AppStatusChip(title: "下一步", value: babies.isEmpty ? "添加档案" : "维护资料")
            }
        }
        .padding(20)
        .gradientCard(AppTheme.heroGradient)
    }

    private var quickAccessBabySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Focus",
                title: "当前快捷对象",
                subtitle: "照片、疫苗、提醒和成长曲线会默认使用这里选中的宝宝。"
            )

            Menu {
                ForEach(babies) { baby in
                    Button(baby.name) {
                        quickAccessBabyId = baby.id
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    AppIconBadge(symbol: "person.crop.circle.badge.checkmark", colors: AppTheme.mintHeroGradient, size: 42)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("快捷访问对象")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(quickAccessBaby?.name ?? "选择宝宝")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .cardStyle()
            }
        }
    }

    private var familyOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Overview",
                title: "家庭概况",
                subtitle: "把当前最常看的档案信息提到设置页前面。"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AppMetricTile(
                    title: "当前宝宝",
                    value: quickAccessBaby?.name ?? "未设置",
                    detail: quickAccessBaby?.age ?? "添加档案后可查看年龄",
                    symbol: "figure.and.child.holdinghands",
                    gradient: AppTheme.heroGradient,
                    emphasized: true
                )

                AppMetricTile(
                    title: "最近体重",
                    value: latestWeightText(for: quickAccessBaby),
                    detail: "来自宝宝资料中的最新测量",
                    symbol: "scalemass.fill",
                    gradient: AppTheme.sleepGradient,
                    emphasized: true
                )

                AppMetricTile(
                    title: "身高",
                    value: latestHeightText(for: quickAccessBaby),
                    detail: "用于成长曲线和资料页",
                    symbol: "ruler.fill",
                    gradient: AppTheme.growthGradient
                )

                AppMetricTile(
                    title: "头围",
                    value: latestHeadText(for: quickAccessBaby),
                    detail: "保持资料连续更新",
                    symbol: "circle.dotted.circle",
                    gradient: AppTheme.vaccineGradient
                )
            }
        }
    }

    private var babyProfilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Profiles",
                title: "宝宝档案",
                subtitle: "管理资料时先看卡片，再进入详情编辑。"
            )

            ForEach(babies) { baby in
                profileCard(for: baby)
            }

            Button {
                showingAddBaby = true
            } label: {
                HStack(spacing: 14) {
                    AppIconBadge(symbol: "plus", colors: AppTheme.mintHeroGradient, size: 42)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("添加新宝宝")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                        Text("创建档案后即可开始记录和统计。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(16)
                .cardStyle()
            }
            .buttonStyle(.plain)
            .scaleButton(scale: 0.98)
        }
    }

    private func profileCard(for baby: Baby) -> some View {
        HStack(spacing: 14) {
            Button {
                selectedBabyForDetail = baby
            } label: {
                HStack(spacing: 14) {
                    AppIconBadge(symbol: "figure.and.child.holdinghands", colors: AppTheme.heroGradient, size: 52)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(baby.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.ink)

                        Text(baby.age)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            profilePill("体重", value: latestWeightText(for: baby))
                            profilePill("身高", value: latestHeightText(for: baby))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Menu {
                Button("编辑资料") {
                    selectedBabyForDetail = baby
                }

                Button("设为快捷对象") {
                    quickAccessBabyId = baby.id
                }

                Button("删除档案", role: .destructive) {
                    pendingDeletion = baby
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 40, height: 40)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .cardStyle()
    }

    private func quickToolsSection(for baby: Baby) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Tools",
                title: "快捷工具",
                subtitle: "围绕 \(baby.name) 直接进入最常用的资料和计划页面。"
            )

            NavigationLink {
                PhotoGalleryView(baby: baby)
            } label: {
                AppActionRow(icon: "photo.on.rectangle.angled", title: "照片", subtitle: "查看成长照片与影像记录", tint: AppTheme.heroGradient[1])
            }
            .buttonStyle(.plain)

            NavigationLink {
                VaccinationCenterView(baby: baby)
            } label: {
                AppActionRow(icon: "syringe.fill", title: "疫苗", subtitle: "查看接种计划和已登记记录", tint: AppTheme.vaccine)
            }
            .buttonStyle(.plain)

            NavigationLink {
                ReminderSettingsView(baby: baby)
            } label: {
                AppActionRow(icon: "bell.badge.fill", title: "提醒设置", subtitle: "定制喂养、睡眠和照护提醒", tint: AppTheme.warning)
            }
            .buttonStyle(.plain)

            NavigationLink {
                GrowthChartView(baby: baby)
            } label: {
                AppActionRow(icon: "chart.line.uptrend.xyaxis", title: "生长曲线", subtitle: "查看体重、身高和头围趋势", tint: AppTheme.growth)
            }
            .buttonStyle(.plain)
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionTitle(
                eyebrow: "Settings",
                title: "应用设置",
                subtitle: "同步、安全、主题和导出保持在同一区域。"
            )

            NavigationLink {
                iCloudSyncView()
            } label: {
                AppActionRow(icon: "icloud", title: "iCloud 同步", subtitle: "检查同步状态和备份策略", tint: AppTheme.secondary)
            }
            .buttonStyle(.plain)

            NavigationLink {
                SecuritySettingsView()
            } label: {
                AppActionRow(icon: "lock.shield", title: "安全设置", subtitle: "Face ID、密码和隐私保护", tint: AppTheme.danger)
            }
            .buttonStyle(.plain)

            NavigationLink {
                AppearanceSettingsView()
            } label: {
                AppActionRow(icon: "paintbrush.pointed", title: "外观设置", subtitle: "调整主题和视觉风格", tint: AppTheme.brand)
            }
            .buttonStyle(.plain)

            NavigationLink {
                ExportView()
            } label: {
                AppActionRow(icon: "square.and.arrow.up", title: "导出数据", subtitle: "导出记录以便留档或分享", tint: AppTheme.accent)
            }
            .buttonStyle(.plain)

            NavigationLink {
                Text("帮助与反馈")
                    .navigationTitle("帮助与反馈")
            } label: {
                AppActionRow(icon: "questionmark.circle", title: "帮助与反馈", subtitle: "查看常见问题和反馈入口", tint: AppTheme.mutedInk)
            }
            .buttonStyle(.plain)
        }
    }

    private var versionCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Baby Tracker")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text("当前版本")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("1.0.0")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.brand)
        }
        .padding(16)
        .cardStyle()
    }

    private var heroSubtitle: String {
        if let quickAccessBaby {
            return "围绕 \(quickAccessBaby.name) 管理档案、提醒、照片和成长资料。"
        }
        return "集中管理宝宝档案、提醒、同步和导出设置。"
    }

    private func latestWeightText(for baby: Baby?) -> String {
        guard let weight = baby?.latestWeight else { return "--" }
        return String(format: "%.1f kg", weight / 1000)
    }

    private func latestHeightText(for baby: Baby?) -> String {
        guard let height = baby?.latestHeight else { return "--" }
        return String(format: "%.1f cm", height)
    }

    private func latestHeadText(for baby: Baby?) -> String {
        guard let head = baby?.latestHeadCircumference else { return "--" }
        return String(format: "%.1f cm", head)
    }

    private func profilePill(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func deleteBaby(_ baby: Baby) {
        deleteRelatedRecords(for: baby.id)
        modelContext.delete(baby)
        do {
            try modelContext.saveIfNeeded()
            if quickAccessBabyId == baby.id {
                quickAccessBabyId = babies.first(where: { $0.id != baby.id })?.id
            }
        } catch {
            profileLogger.error("删除宝宝保存失败: \(error.localizedDescription, privacy: .public)")
        }
        pendingDeletion = nil
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

struct BabyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
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
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("宝宝资料")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text(baby.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("更新基础信息和最新测量，首页与资料页会同步反映。")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.90))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .gradientCard(AppTheme.mintHeroGradient)

                VStack(alignment: .leading, spacing: 14) {
                    AppSectionTitle(eyebrow: "Basic", title: "基本信息", subtitle: "保持姓名、生日和性别资料准确。")

                    TextField("姓名", text: $name)
                        .appInputFieldStyle()

                    DatePicker("出生日期", selection: $birthday, displayedComponents: .date)
                        .padding(14)
                        .appInputFieldStyle()

                    Picker("性别", selection: $gender) {
                        Text("男").tag(Gender.male)
                        Text("女").tag(Gender.female)
                        Text("其他").tag(Gender.other)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(18)
                .cardStyle()

                VStack(alignment: .leading, spacing: 14) {
                    AppSectionTitle(eyebrow: "Metrics", title: "最新测量", subtitle: "这些值会被生长曲线和资料概览直接使用。")

                    measurementField(title: "体重", unit: "g", text: $weight, placeholder: "例如 6200")
                    measurementField(title: "身高", unit: "cm", text: $height, placeholder: "例如 63.5")
                    measurementField(title: "头围", unit: "cm", text: $headCircumference, placeholder: "例如 40.2")
                }
                .padding(18)
                .cardStyle()

                Button("保存更改") {
                    saveBaby()
                }
                .buttonStyle(AppPrimaryButtonStyle())
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.top, 16)
            .padding(.bottom, 24)
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

    private func measurementField(title: String, unit: String, text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text("选填")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 110)

            Text(unit)
                .foregroundStyle(.secondary)
        }
        .appInputFieldStyle()
    }

    private func saveBaby() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            saveErrorMessage = "姓名不能为空"
            showingSaveError = true
            return
        }

        let parsedWeight = parseOptionalMeasurement(weight, field: "体重")
        guard parsedWeight.isValid else { return }
        let parsedHeight = parseOptionalMeasurement(height, field: "身高")
        guard parsedHeight.isValid else { return }
        let parsedHead = parseOptionalMeasurement(headCircumference, field: "头围")
        guard parsedHead.isValid else { return }

        baby.name = trimmedName
        baby.birthday = birthday
        baby.gender = gender
        baby.latestWeight = parsedWeight.value
        baby.latestHeight = parsedHeight.value
        baby.latestHeadCircumference = parsedHead.value

        do {
            try modelContext.saveIfNeeded()
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
            profileLogger.error("更新宝宝信息保存失败: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func parseOptionalMeasurement(_ input: String, field: String) -> (isValid: Bool, value: Double?) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return (true, nil) }
        guard let value = Double(trimmed) else {
            saveErrorMessage = "\(field)请输入有效数字"
            showingSaveError = true
            return (false, nil)
        }
        return (true, value)
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

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("新建档案")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.82))

                        Text("添加宝宝")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("先录入基础资料，后续记录、日历和统计都会自动建立。")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.90))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .gradientCard(AppTheme.heroGradient)

                    VStack(alignment: .leading, spacing: 14) {
                        AppSectionTitle(eyebrow: "Basic", title: "基本信息", subtitle: "先录入最必要的资料，保持表单简单。")

                        TextField("姓名", text: $name)
                            .appInputFieldStyle()

                        DatePicker("出生日期", selection: $birthday, displayedComponents: .date)
                            .padding(14)
                            .appInputFieldStyle()

                        Picker("性别", selection: $gender) {
                            Text("男").tag(Gender.male)
                            Text("女").tag(Gender.female)
                            Text("其他").tag(Gender.other)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(18)
                    .cardStyle()

                    Button("保存档案") {
                        addBaby()
                    }
                    .buttonStyle(AppPrimaryButtonStyle(gradient: canSave ? AppTheme.heroGradient : AppTheme.disabledGradient))
                    .disabled(!canSave)
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.top, 16)
                .padding(.bottom, 24)
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
