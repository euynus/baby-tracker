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
                
                Section {
                    NavigationLink {
                        Text("设置页面")
                    } label: {
                        Label("设置", systemImage: "gearshape")
                    }
                    
                    NavigationLink {
                        Text("导出数据")
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
            modelContext.delete(babies[index])
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
    
    init(baby: Baby) {
        self.baby = baby
        _name = State(initialValue: baby.name)
        _birthday = State(initialValue: baby.birthday)
        _gender = State(initialValue: baby.gender)
        _weight = State(initialValue: baby.latestWeight != nil ? String(format: "%.0f", baby.latestWeight!) : "")
        _height = State(initialValue: baby.latestHeight != nil ? String(format: "%.1f", baby.latestHeight!) : "")
        _headCircumference = State(initialValue: baby.latestHeadCircumference != nil ? String(format: "%.1f", baby.latestHeadCircumference!) : "")
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
    }
    
    private func saveBaby() {
        baby.name = name
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
    }
}

struct AddBabyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var birthday = Date()
    @State private var gender = Gender.male
    
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
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addBaby() {
        let baby = Baby(name: name, birthday: birthday, gender: gender)
        modelContext.insert(baby)
        dismiss()
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Baby.self])
}
