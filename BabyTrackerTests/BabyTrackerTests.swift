//
//  BabyTrackerTests.swift
//  BabyTrackerTests
//
//  Created on 2026-02-10.
//

import XCTest
import SwiftData
@testable import BabyTracker

final class BabyModelTests: XCTestCase {
    
    func testBabyCreation() {
        let baby = Baby(name: "测试宝宝", birthday: Date(), gender: .male)
        
        XCTAssertEqual(baby.name, "测试宝宝")
        XCTAssertEqual(baby.gender, .male)
        XCTAssertNotNil(baby.id)
    }
    
    func testBabyAge() {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let baby = Baby(name: "测试宝宝", birthday: sevenDaysAgo, gender: .male)
        
        XCTAssertTrue(baby.age.contains("天"))
    }
    
    func testBabyAgeInMonths() {
        let calendar = Calendar.current
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: Date())!
        let baby = Baby(name: "测试宝宝", birthday: twoMonthsAgo, gender: .male)
        
        XCTAssertTrue(baby.age.contains("个月"))
    }
}

final class BabyPersistenceTests: XCTestCase {
    
    func testInsertAndSaveBaby() throws {
        let container = try AppPersistence.makeInMemoryTestContainer()
        let context = ModelContext(container)
        
        let baby = Baby(name: "测试宝宝", birthday: Date(), gender: .female)
        context.insert(baby)
        try context.save()
        
        let babies = try context.fetch(FetchDescriptor<Baby>())
        XCTAssertEqual(babies.count, 1)
        XCTAssertEqual(babies.first?.name, "测试宝宝")
    }
}

final class FeedingRecordTests: XCTestCase {
    
    func testFeedingRecordCreation() {
        let babyId = UUID()
        let record = FeedingRecord(babyId: babyId, timestamp: Date(), method: .breastfeeding)
        
        XCTAssertEqual(record.babyId, babyId)
        XCTAssertEqual(record.method, .breastfeeding)
        XCTAssertNotNil(record.id)
    }
    
    func testBreastfeedingDuration() {
        let record = FeedingRecord(babyId: UUID(), timestamp: Date(), method: .breastfeeding)
        record.leftDuration = 300  // 5 minutes
        record.rightDuration = 420 // 7 minutes
        
        XCTAssertEqual(record.totalDuration, 720) // 12 minutes
        XCTAssertEqual(record.durationText, "12:00")
    }
    
    func testBottleFeedingAmount() {
        let record = FeedingRecord(babyId: UUID(), timestamp: Date(), method: .bottle)
        record.amount = 120.0
        
        XCTAssertEqual(record.amount, 120.0)
    }
}

final class SleepRecordTests: XCTestCase {
    
    func testSleepRecordCreation() {
        let babyId = UUID()
        let startTime = Date()
        let record = SleepRecord(babyId: babyId, startTime: startTime)
        
        XCTAssertEqual(record.babyId, babyId)
        XCTAssertEqual(record.startTime, startTime)
        XCTAssertNil(record.endTime)
        XCTAssertTrue(record.isActive)
    }
    
    func testSleepDuration() {
        let startTime = Date().addingTimeInterval(-3600) // 1 hour ago
        let endTime = Date()
        let record = SleepRecord(babyId: UUID(), startTime: startTime)
        record.endTime = endTime
        
        XCTAssertFalse(record.isActive)
        XCTAssertEqual(record.duration, 3600, accuracy: 1)
    }
    
    func testSleepDurationFormatting() {
        let record = SleepRecord(babyId: UUID(), startTime: Date().addingTimeInterval(-7320))
        record.endTime = Date()
        
        XCTAssertEqual(record.durationText, "2:02")
    }
}

final class DiaperRecordTests: XCTestCase {
    
    func testDiaperRecordCreation() {
        let babyId = UUID()
        let record = DiaperRecord(babyId: babyId, timestamp: Date(), hasWet: true, hasDirty: false)
        
        XCTAssertEqual(record.babyId, babyId)
        XCTAssertTrue(record.hasWet)
        XCTAssertFalse(record.hasDirty)
    }
    
    func testDiaperTypeDescription() {
        let wetOnly = DiaperRecord(babyId: UUID(), timestamp: Date(), hasWet: true, hasDirty: false)
        XCTAssertEqual(wetOnly.typeDescription, "小便")
        
        let dirtyOnly = DiaperRecord(babyId: UUID(), timestamp: Date(), hasWet: false, hasDirty: true)
        XCTAssertEqual(dirtyOnly.typeDescription, "大便")
        
        let both = DiaperRecord(babyId: UUID(), timestamp: Date(), hasWet: true, hasDirty: true)
        XCTAssertEqual(both.typeDescription, "大便 + 小便")
    }
}

final class BreastfeedingTimerViewModelTests: XCTestCase {
    
    var viewModel: BreastfeedingTimerViewModel!
    var baby: Baby!
    
    override func setUp() {
        super.setUp()
        baby = Baby(name: "测试宝宝", birthday: Date(), gender: .male)
        viewModel = BreastfeedingTimerViewModel(baby: baby)
    }
    
    override func tearDown() {
        viewModel = nil
        baby = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(viewModel.hasStarted)
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.leftDuration, 0)
        XCTAssertEqual(viewModel.rightDuration, 0)
    }
    
    func testStartTimer() {
        viewModel.start(side: .left)
        
        XCTAssertTrue(viewModel.hasStarted)
        XCTAssertTrue(viewModel.isRunning)
        XCTAssertEqual(viewModel.currentSide, .left)
    }
    
    func testSwitchSide() {
        viewModel.start(side: .left)
        let initialSide = viewModel.currentSide
        
        viewModel.switchSide()
        
        XCTAssertNotEqual(viewModel.currentSide, initialSide)
    }
    
    func testPauseResume() {
        viewModel.start(side: .left)
        XCTAssertTrue(viewModel.isRunning)
        
        viewModel.togglePause()
        XCTAssertFalse(viewModel.isRunning)
        
        viewModel.togglePause()
        XCTAssertTrue(viewModel.isRunning)
    }
    
    func testTotalDuration() {
        viewModel.leftDuration = 300
        viewModel.rightDuration = 420
        
        XCTAssertEqual(viewModel.totalDuration, 720)
    }
    
    func testTimeFormatting() {
        viewModel.leftDuration = 125 // 2:05
        
        XCTAssertEqual(viewModel.formattedCurrentTime, "02:05")
    }
}
