//
//  CloudKitManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import CloudKit
import SwiftData

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var iCloudAvailable = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    
    private let container = CKContainer(identifier: "iCloud.com.babytracker.app")
    private let privateDatabase: CKDatabase
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    init() {
        self.privateDatabase = container.privateCloudDatabase
        checkiCloudStatus()
    }
    
    func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.iCloudAvailable = (status == .available)
                
                if let error = error {
                    print("iCloud 状态检查失败: \(error)")
                }
            }
        }
    }
    
    // MARK: - Sync Operations
    
    func syncAllData(modelContext: ModelContext) async {
        guard iCloudAvailable else {
            await MainActor.run {
                syncStatus = .error("iCloud 不可用")
            }
            return
        }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            // Fetch from iCloud and update local
            try await fetchFromiCloud(modelContext: modelContext)
            
            // Upload local changes to iCloud
            try await uploadToiCloud(modelContext: modelContext)
            
            await MainActor.run {
                syncStatus = .success
                lastSyncTime = Date()
            }
        } catch {
            await MainActor.run {
                syncStatus = .error(error.localizedDescription)
            }
        }
    }
    
    private func fetchFromiCloud(modelContext: ModelContext) async throws {
        // Fetch babies
        let babyQuery = CKQuery(recordType: "Baby", predicate: NSPredicate(value: true))
        let babyRecords = try await privateDatabase.records(matching: babyQuery)
        
        // Process and insert into SwiftData
        for (_, result) in babyRecords.matchResults {
            let record = try result.get()
            // Convert CKRecord to SwiftData model
            try await processBabyRecord(record, modelContext: modelContext)
        }
    }
    
    private func uploadToiCloud(modelContext: ModelContext) async throws {
        // Get unsynced local records
        let descriptor = FetchDescriptor<Baby>()
        let babies = try modelContext.fetch(descriptor)
        
        for baby in babies {
            let record = CKRecord(recordType: "Baby")
            record["name"] = baby.name as CKRecordValue
            record["birthday"] = baby.birthday as CKRecordValue
            record["gender"] = baby.gender.rawValue as CKRecordValue
            
            if let weight = baby.latestWeight {
                record["latestWeight"] = weight as CKRecordValue
            }
            if let height = baby.latestHeight {
                record["latestHeight"] = height as CKRecordValue
            }
            if let headCircumference = baby.latestHeadCircumference {
                record["latestHeadCircumference"] = headCircumference as CKRecordValue
            }
            
            try await privateDatabase.save(record)
        }
    }
    
    private func processBabyRecord(_ record: CKRecord, modelContext: ModelContext) async throws {
        guard let name = record["name"] as? String,
              let birthday = record["birthday"] as? Date,
              let genderString = record["gender"] as? String,
              let gender = Gender(rawValue: genderString) else {
            return
        }
        
        // Check if already exists locally
        let descriptor = FetchDescriptor<Baby>(
            predicate: #Predicate { $0.name == name && $0.birthday == birthday }
        )
        
        let existingBabies = try modelContext.fetch(descriptor)
        
        if existingBabies.isEmpty {
            // Create new baby
            let baby = Baby(name: name, birthday: birthday, gender: gender)
            
            if let weight = record["latestWeight"] as? Double {
                baby.latestWeight = weight
            }
            if let height = record["latestHeight"] as? Double {
                baby.latestHeight = height
            }
            if let headCircumference = record["latestHeadCircumference"] as? Double {
                baby.latestHeadCircumference = headCircumference
            }
            
            modelContext.insert(baby)
        }
    }
    
    // MARK: - Manual Sync Trigger
    
    func manualSync(modelContext: ModelContext) {
        Task {
            await syncAllData(modelContext: modelContext)
        }
    }
}
