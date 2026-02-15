//
//  ModelContext+Persistence.swift
//  BabyTracker
//
//  Created on 2026-02-15.
//

import SwiftData

extension ModelContext {
    /// Save only when there are pending changes.
    @discardableResult
    func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }

    /// Insert and persist a model atomically for UI flows.
    /// If save fails, the inserted model is rolled back from this context.
    func insertAndSave<T: PersistentModel>(_ model: T) throws {
        insert(model)
        do {
            try saveIfNeeded()
        } catch {
            delete(model)
            throw error
        }
    }
}
