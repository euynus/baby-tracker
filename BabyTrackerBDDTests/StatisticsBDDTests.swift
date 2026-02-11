//
//  StatisticsBDDTests.swift
//  BabyTrackerBDDTests
//
//  统计功能 BDD 测试
//  对应 Features/Statistics.feature
//

import XCTest
@testable import BabyTracker

final class StatisticsBDDTests: BDDTestBase {
    
    // MARK: - 场景: 查看今日概览
    
    func test_查看今日概览() {
        // Given: 今天有以下记录
        let today = Date()
        
        // 喂奶: 6次 (母乳4次 + 奶瓶2次)
        let feeding1 = FeedingRecord(baby: testBaby, type: .breastfeeding, leftDuration: 600, rightDuration: 480, timestamp: today)
        let feeding2 = FeedingRecord(baby: testBaby, type: .breastfeeding, leftDuration: 540, rightDuration: 420, timestamp: today)
        let feeding3 = FeedingRecord(baby: testBaby, type: .breastfeeding, leftDuration: 660, rightDuration: 480, timestamp: today)
        let feeding4 = FeedingRecord(baby: testBaby, type: .breastfeeding, leftDuration: 600, rightDuration: 540, timestamp: today)
        let feeding5 = FeedingRecord(baby: testBaby, type: .bottle, amount: 120, timestamp: today)
        let feeding6 = FeedingRecord(baby: testBaby, type: .bottle, amount: 100, timestamp: today)
        
        // 睡眠: 3次，总计8小时
        let sleep1 = SleepRecord(baby: testBaby, startTime: 创建日期(小时偏移: -8), endTime: 创建日期(小时偏移: -5))
        let sleep2 = SleepRecord(baby: testBaby, startTime: 创建日期(小时偏移: -4), endTime: 创建日期(小时偏移: -2))
        let sleep3 = SleepRecord(baby: testBaby, startTime: 创建日期(小时偏移: -3), endTime: today)
        
        // 尿布: 8次 (湿5次 + 脏3次)
        let diapers = (1...8).map { i in
            DiaperRecord(
                baby: testBaby,
                isWet: i <= 5,
                isDirty: i > 5 || i == 3,
                timestamp: 创建日期(小时偏移: -i)
            )
        }
        
        // 体重: 5.8kg
        let growth = GrowthRecord(baby: testBaby, weight: 5.8, timestamp: today)
        
        given_我有历史记录([feeding1, feeding2, feeding3, feeding4, feeding5, feeding6])
        given_我有历史记录([sleep1, sleep2, sleep3])
        given_我有历史记录(diapers)
        given_我有历史记录([growth])
        
        // When: 我进入统计页面
        let feedingRecords = 获取所有记录(FeedingRecord.self)
        let sleepRecords = 获取所有记录(SleepRecord.self)
        let diaperRecords = 获取所有记录(DiaperRecord.self)
        let growthRecords = 获取所有记录(GrowthRecord.self)
        
        // Then: 我应该看到今日概览卡片
        
        // 喂奶次数: 6次
        XCTAssertEqual(feedingRecords.count, 6, "喂奶次数应为 6")
        
        // 母乳次数: 4次
        let breastfeedingCount = feedingRecords.filter { $0.type == .breastfeeding }.count
        XCTAssertEqual(breastfeedingCount, 4, "母乳次数应为 4")
        
        // 奶瓶次数: 2次
        let bottleCount = feedingRecords.filter { $0.type == .bottle }.count
        XCTAssertEqual(bottleCount, 2, "奶瓶次数应为 2")
        
        // 睡眠次数: 3次
        XCTAssertEqual(sleepRecords.count, 3, "睡眠次数应为 3")
        
        // 睡眠总时长: 8小时
        let totalSleep = sleepRecords.reduce(0.0) { $0 + $1.duration }
        XCTAssertEqual(totalSleep / 3600, 8, accuracy: 0.5, "睡眠总时长应约为 8 小时")
        
        // 尿布次数: 8次
        XCTAssertEqual(diaperRecords.count, 8, "尿布次数应为 8")
        
        // 湿尿布: 5次
        let wetCount = diaperRecords.filter { $0.isWet }.count
        XCTAssertGreaterThanOrEqual(wetCount, 5, "湿尿布至少 5 次")
        
        // 脏尿布: 3次
        let dirtyCount = diaperRecords.filter { $0.isDirty }.count
        XCTAssertGreaterThanOrEqual(dirtyCount, 3, "脏尿布至少 3 次")
        
        // 体重: 5.8kg
        XCTAssertEqual(growthRecords.first?.weight, 5.8, accuracy: 0.01, "体重应为 5.8kg")
    }
    
    // MARK: - 场景: 查看喂奶统计图表
    
    func test_查看喂奶统计图表() {
        // Given: 我有过去7天的喂奶记录
        for day in 0..<7 {
            let date = 创建日期(天数偏移: -day)
            
            // 每天3次母乳 + 1次奶瓶
            for _ in 0..<3 {
                let feeding = FeedingRecord(
                    baby: testBaby,
                    type: .breastfeeding,
                    leftDuration: 600,
                    rightDuration: 480,
                    timestamp: date
                )
                modelContext.insert(feeding)
            }
            
            let bottle = FeedingRecord(
                baby: testBaby,
                type: .bottle,
                amount: 120,
                timestamp: date
            )
            modelContext.insert(bottle)
        }
        try! modelContext.save()
        
        // When: 我进入统计页面并选择"喂奶"标签
        let records = 获取所有记录(FeedingRecord.self)
        
        // Then: 我应该看到图表数据
        
        // 总次数统计
        XCTAssertEqual(records.count, 28, "7天应有 28 次喂奶记录")
        
        // 母乳 vs 奶瓶占比
        let breastfeedingCount = records.filter { $0.type == .breastfeeding }.count
        let bottleCount = records.filter { $0.type == .bottle }.count
        XCTAssertEqual(breastfeedingCount, 21, "母乳应有 21 次")
        XCTAssertEqual(bottleCount, 7, "奶瓶应有 7 次")
        
        // 母乳总时长趋势
        let totalBreastfeedingTime = records
            .filter { $0.type == .breastfeeding }
            .reduce(0.0) { $0 + ($1.leftDuration ?? 0) + ($1.rightDuration ?? 0) }
        XCTAssertGreaterThan(totalBreastfeedingTime, 0, "母乳总时长应大于 0")
    }
    
    // MARK: - 场景: 查看睡眠统计图表
    
    func test_查看睡眠统计图表() {
        // Given: 我有过去7天的睡眠记录
        for day in 0..<7 {
            let baseDate = 创建日期(天数偏移: -day)
            
            // 每天3次睡眠
            for i in 0..<3 {
                let startTime = Calendar.current.date(
                    byAdding: .hour,
                    value: -(i * 4),
                    to: baseDate
                )!
                let endTime = Calendar.current.date(
                    byAdding: .hour,
                    value: 2,
                    to: startTime
                )!
                
                let sleep = SleepRecord(
                    baby: testBaby,
                    startTime: startTime,
                    endTime: endTime
                )
                modelContext.insert(sleep)
            }
        }
        try! modelContext.save()
        
        // When: 我进入统计页面并选择"睡眠"标签
        let records = 获取所有记录(SleepRecord.self)
        
        // Then: 我应该看到图表数据
        
        // 总次数
        XCTAssertEqual(records.count, 21, "7天应有 21 次睡眠记录")
        
        // 平均睡眠时长
        let totalDuration = records.reduce(0.0) { $0 + $1.duration }
        let avgDuration = totalDuration / Double(records.count)
        XCTAssertEqual(avgDuration / 3600, 2, accuracy: 0.5, "平均睡眠时长应约 2 小时")
    }
    
    // MARK: - 场景: 空数据状态
    
    func test_空数据状态() {
        // Given: 选定时间范围内没有数据
        清空所有记录(FeedingRecord.self)
        清空所有记录(SleepRecord.self)
        清空所有记录(DiaperRecord.self)
        清空所有记录(GrowthRecord.self)
        
        // When: 我查看统计页面
        let feedingRecords = 获取所有记录(FeedingRecord.self)
        let sleepRecords = 获取所有记录(SleepRecord.self)
        let diaperRecords = 获取所有记录(DiaperRecord.self)
        let growthRecords = 获取所有记录(GrowthRecord.self)
        
        // Then: 应该显示友好的空状态提示
        XCTAssertTrue(feedingRecords.isEmpty, "喂奶记录应为空")
        XCTAssertTrue(sleepRecords.isEmpty, "睡眠记录应为空")
        XCTAssertTrue(diaperRecords.isEmpty, "尿布记录应为空")
        XCTAssertTrue(growthRecords.isEmpty, "生长记录应为空")
    }
}
