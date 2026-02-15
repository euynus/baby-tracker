//
//  ProfileView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    
    @State private var showingAddBaby = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(babies) { baby in
                        NavigationLink {
                            BabyDetailView(baby: baby)
                        } label: {
                            BabyRow(baby: baby)
                        }
                    }
                    .onDelete(perform: deleteBabies)
                    
                    Button(action: { showingAddBaby = true }) {
                        Label("添加新宝宝", systemImage: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text("我的宝宝")
                }
                
                if let baby = babies.first {
                    Section("快速访问") {
                        NavigationLink {
                            PhotoGalleryView(baby: baby)
                        } label: {
                            Label("照片", systemImage: "photo.on.rectangle")
                        }
                    }
                }
                
                Section {
                    if let baby = babies.first {
                        NavigationLink {
                            ReminderSettingsView(baby: baby)
                        } label: {
                            Label("提醒设置", systemImage: "bell.badge")
                        }
                        
                        NavigationLink {
                            GrowthChartView(baby: baby)
                        } label: {
                            Label("生长曲线", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    }
                    
                    NavigationLink {
                        iCloudSyncView()
                    } label: {
                        Label("iCloud 同步", systemImage: "icloud")
                    }
                    
                    NavigationLink {
                        SecuritySettingsView()
                    } label: {
                        Label("安全设置", systemImage: "lock.shield")
                    }
                    
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Label("外观设置", systemImage: "paintbrush")
                    }
                    
                    NavigationLink {
                        ExportView()
                    } label: {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                    }
                    
                    NavigationLink {
                        Text("帮助与反馈")
                    } label: {
                        Label("帮助与反馈", systemImage: "questionmark.circle")
                    }
                } header: {
                    Text("其他")
                }
                
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showingAddBaby) {
                AddBabyView()
            }
        }
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
            // Keep this non-fatal but visible in debug logs.
            print("删除宝宝保存失败: \(error.localizedDescription)")
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

            feeding.forEach { modelContext.delete($0) }
            sleep.forEach { modelContext.delete($0) }
            diaper.forEach { modelContext.delete($0) }
            growth.forEach { modelContext.delete($0) }
            photos.forEach { modelContext.delete($0) }
        } catch {
            print("删除宝宝关联记录失败: \(error.localizedDescription)")
        }
    }
}

struct BabyRow: View {
    let baby: Baby
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text("👶")
                    .font(.largeTitle)
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
        .padding(.vertical, 4)
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
        Form {
            Section("基本信息") {
                TextField("姓名", text: $name)
                
                DatePicker("出生日期", selection: $birthday, displayedComponents: .date)
                
                Picker("性别", selection: $gender) {
                    Text("男").tag(Gender.male)
                    Text("女").tag(Gender.female)
                    Text("其他").tag(Gender.other)
                }
            }
            
            Section("最新测量") {
                HStack {
                    TextField("体重", text: $weight)
                        .keyboardType(.decimalPad)
                    Text("g")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    TextField("身高", text: $height)
                        .keyboardType(.decimalPad)
                    Text("cm")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    TextField("头围", text: $headCircumference)
                        .keyboardType(.decimalPad)
                    Text("cm")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Button("保存") {
                    saveBaby()
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
            }
        }
        .navigationTitle("宝宝资料")
        .navigationBarTitleDisplayMode(.inline)
        .alert("保存失败", isPresented: $showingSaveError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
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
            print("更新宝宝信息保存失败: \(error.localizedDescription)")
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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("姓名", text: $name)
                    
                    DatePicker("出生日期", selection: $birthday, displayedComponents: .date)
                    
                    Picker("性别", selection: $gender) {
                        Text("男").tag(Gender.male)
                        Text("女").tag(Gender.female)
                        Text("其他").tag(Gender.other)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("添加宝宝")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        addBaby()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            print("新增宝宝保存失败: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Baby.self])
}
