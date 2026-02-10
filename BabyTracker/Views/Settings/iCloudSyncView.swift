//
//  iCloudSyncView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct iCloudSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var cloudManager = CloudKitManager.shared
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("iCloud 状态")
                    Spacer()
                    if cloudManager.iCloudAvailable {
                        Label("可用", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Label("不可用", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
                
                if let lastSync = cloudManager.lastSyncTime {
                    HStack {
                        Text("上次同步")
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("同步状态")
            } footer: {
                Text("开启 iCloud 后，数据会自动在你的所有设备间同步")
            }
            
            Section {
                syncStatusRow
                
                Button(action: { cloudManager.manualSync(modelContext: modelContext) }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("立即同步")
                    }
                }
                .disabled(!cloudManager.iCloudAvailable || cloudManager.syncStatus == .syncing)
            } header: {
                Text("操作")
            }
            
            Section {
                NavigationLink {
                    Text("iCloud 设置说明")
                        .navigationTitle("帮助")
                } label: {
                    Label("iCloud 设置帮助", systemImage: "questionmark.circle")
                }
            }
        }
        .navigationTitle("iCloud 同步")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            cloudManager.checkiCloudStatus()
        }
    }
    
    @ViewBuilder
    private var syncStatusRow: some View {
        switch cloudManager.syncStatus {
        case .idle:
            HStack {
                Text("同步状态")
                Spacer()
                Text("就绪")
                    .foregroundStyle(.secondary)
            }
            
        case .syncing:
            HStack {
                Text("同步状态")
                Spacer()
                ProgressView()
                Text("同步中...")
                    .foregroundStyle(.secondary)
            }
            
        case .success:
            HStack {
                Text("同步状态")
                Spacer()
                Label("成功", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            
        case .error(let message):
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("同步状态")
                    Spacer()
                    Label("失败", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        iCloudSyncView()
    }
}
