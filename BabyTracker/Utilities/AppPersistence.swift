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
    typealias ContainerFactory = (Schema, [ModelConfiguration]) throws -> ModelContainer

    static var isRunningTests: Bool {
        let environmentIndicatesTests = ProcessInfo.processInfo.environment[xctestKey] != nil
        let runtimeIncludesXCTest = NSClassFromString("XCTestCase") != nil
        return environmentIndicatesTests || runtimeIncludesXCTest
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
        return try makeContainer(with: [configuration])
    }

    static func makeInMemoryTestContainer() throws -> ModelContainer {
        let configuration = makeConfiguration(
            isStoredInMemoryOnly: true,
            useGroupContainer: false,
            cloudKitEnabled: false
        )
        return try makeContainer(with: [configuration])
    }

    static func makeResilientAppContainer(
        containerFactory: ContainerFactory = defaultContainerFactory,
        onFailure: ((Error) -> Void)? = nil
    ) -> ModelContainer {
        let runningTests = isRunningTests
        let primary = makeConfiguration(
            isStoredInMemoryOnly: runningTests,
            useGroupContainer: !runningTests,
            cloudKitEnabled: !runningTests
        )
        do {
            return try makeContainer(with: [primary], using: containerFactory)
        } catch {
            onFailure?(error)
        }

        let localFallback = makeConfiguration(
            isStoredInMemoryOnly: false,
            useGroupContainer: false,
            cloudKitEnabled: false
        )
        do {
            return try makeContainer(with: [localFallback], using: containerFactory)
        } catch {
            onFailure?(error)
        }

        let inMemoryFallback = makeConfiguration(
            isStoredInMemoryOnly: true,
            useGroupContainer: false,
            cloudKitEnabled: false
        )
        do {
            return try makeContainer(with: [inMemoryFallback], using: containerFactory)
        } catch {
            onFailure?(error)
            fatalError("ModelContainer 初始化失败，所有降级策略均不可用: \(error)")
        }
    }

    private static let defaultContainerFactory: ContainerFactory = { schema, configurations in
        try ModelContainer(for: schema, configurations: configurations)
    }

    private static func makeContainer(
        with configurations: [ModelConfiguration],
        using factory: ContainerFactory = defaultContainerFactory
    ) throws -> ModelContainer {
        try factory(schema, configurations)
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
