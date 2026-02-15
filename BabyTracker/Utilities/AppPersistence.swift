//
//  AppPersistence.swift
//  BabyTracker
//
//  Created on 2026-02-15.
//

import Foundation
import SwiftData

enum AppPersistence {
    private static let xctestKey = "XCTestConfigurationFilePath"

    static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment[xctestKey] != nil
    }

    static let schema = Schema([
        Baby.self,
        FeedingRecord.self,
        SleepRecord.self,
        DiaperRecord.self,
        GrowthRecord.self,
        PhotoRecord.self
    ])

    static func makeAppContainer() throws -> ModelContainer {
        let runningTests = isRunningTests
        let configuration = makeConfiguration(
            isStoredInMemoryOnly: runningTests,
            useGroupContainer: !runningTests,
            cloudKitEnabled: !runningTests
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func makeInMemoryTestContainer() throws -> ModelContainer {
        let configuration = makeConfiguration(
            isStoredInMemoryOnly: true,
            useGroupContainer: false,
            cloudKitEnabled: false
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private static func makeConfiguration(
        isStoredInMemoryOnly: Bool,
        useGroupContainer: Bool,
        cloudKitEnabled: Bool
    ) -> ModelConfiguration {
        ModelConfiguration(
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            groupContainer: useGroupContainer ? .automatic : .none,
            cloudKitDatabase: cloudKitEnabled ? .automatic : .none
        )
    }
}
