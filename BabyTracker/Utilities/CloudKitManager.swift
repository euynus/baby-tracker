//
//  CloudKitManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import CloudKit
import SwiftData

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var iCloudAvailable = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    
    private let container = CKContainer(identifier: "iCloud.com.babytracker.app")
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    init() {
        checkiCloudStatus()
    }
    
    func checkiCloudStatus() {
        container.accountStatus { status, error in
            Task { @MainActor in
                self.iCloudAvailable = (status == .available)

                if let error = error {
                    print("iCloud 状态检查失败: \(error)")
                }
            }
        }
    }
    
    // MARK: - Sync Operations

    func syncAllData(modelContext: ModelContext) async {
        guard iCloudAvailable else {
            syncStatus = .error("iCloud 不可用")
            return
        }

        syncStatus = .syncing

        do {
            // SwiftData + CloudKit sync is managed by the persistent store.
            // Manually saving pending local changes is enough to trigger upload.
            if modelContext.hasChanges {
                try modelContext.saveIfNeeded()
            }
            syncStatus = .success
            lastSyncTime = Date()
        } catch {
            syncStatus = .error(error.localizedDescription)
        }
    }

    // MARK: - Manual Sync Trigger
    
    func manualSync(modelContext: ModelContext) {
        Task {
            await syncAllData(modelContext: modelContext)
        }
    }
}
