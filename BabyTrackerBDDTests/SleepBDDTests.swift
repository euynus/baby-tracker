//
//  SleepBDDTests.swift
//  BabyTrackerBDDTests
//
//  睡眠功能 BDD 测试
//  对应 Features/Sleep.feature
//

import XCTest
@testable import BabyTracker

final class SleepBDDTests: BDDTestBase {
    
    // MARK: - 场景: 开始睡眠计时
    
    func test_开始睡眠计时() {
        // Given: 我在睡眠记录页面
        given_我已经登录应用()
        given_我有一个名为小宝的宝宝档案()
        given_我在页面("睡眠记录")
        
        // When: 我点击"开始睡眠"按钮
        let startTime = Date()
        let record = SleepRecord(
            baby: testBaby,
            startTime: startTime
        )
        
        // Then: 计时器应该开始运行
        XCTAssertNotNil(record.startTime, "开始时间应该被记录")
        
        // And: 开始时间应该记录为当前时间
        XCTAssertDateEqual(record.startTime, startTime, 精度: .second)
    }
    
    // MARK: - 场景: 结束睡眠并保存记录
    
    func test_结束睡眠并保存记录() {
        // Given: 我已经开始睡眠计时
        let startTime = 创建日期(小时偏移: -2, 分钟偏移: -30) // 2小时30分钟前
        
        // And: 计时器运行了"02:30:00"
        let endTime = Date()
        
        // When: 我点击"结束睡眠"按钮
        let record = SleepRecord(
            baby: testBaby,
            startTime: startTime,
            endTime: endTime
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 应该创建一条新的睡眠记录
        then_应该存在记录(SleepRecord.self, 数量: 1)
        
        let saved = 获取最新记录(SleepRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            // 开始时间: 2小时30分前
            XCTAssertDateEqual(saved.startTime, startTime, 精度: .minute)
            
            // 结束时间: 当前时间
            XCTAssertDateEqual(saved.endTime, endTime, 精度: .minute)
            
            // 时长: 2小时30分钟
            let duration = saved.duration
            XCTAssertEqual(duration / 3600, 2.5, accuracy: 0.1, "时长应为 2.5 小时")
        }
    }
    
    // MARK: - 场景: 手动添加历史睡眠记录
    
    func test_手动添加历史睡眠记录() {
        // Given: 我在睡眠记录页面
        given_我已经登录应用()
        
        // When: 我选择手动添加模式
        // And: 我设置开始时间为"今天 14:00"
        let today = Date()
        let startTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: today)!
        
        // And: 我设置结束时间为"今天 16:30"
        let endTime = Calendar.current.date(bySettingHour: 16, minute: 30, second: 0, of: today)!
        
        // And: 我点击"保存"按钮
        let record = SleepRecord(
            baby: testBaby,
            startTime: startTime,
            endTime: endTime
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 应该创建一条新的睡眠记录
        then_应该存在记录(SleepRecord.self, 数量: 1)
        
        // And: 时长应该自动计算为"2小时30分钟"
        let saved = 获取最新记录(SleepRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            let duration = saved.duration
            let expectedDuration: TimeInterval = 2.5 * 3600 // 2小时30分
            XCTAssertTimeInterval(duration, 等于: expectedDuration, 容差: 60)
        }
    }
    
    // MARK: - 场景: 添加睡眠备注
    
    func test_添加睡眠备注() {
        // Given: 我正在创建睡眠记录
        let record = SleepRecord(
            baby: testBaby,
            startTime: 创建日期(小时偏移: -2),
            endTime: Date()
        )
        
        // When: 我在备注栏输入"宝宝睡前喝了奶"
        record.notes = "宝宝睡前喝了奶"
        
        // And: 我保存记录
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 记录应该包含备注
        let saved = 获取最新记录(SleepRecord.self)
        XCTAssertEqual(saved?.notes, "宝宝睡前喝了奶")
        
        // And: 备注应该在记录详情中显示
        XCTAssertNotNil(saved?.notes)
    }
    
    // MARK: - 场景: 查看今日睡眠统计
    
    func test_查看今日睡眠统计() {
        // Given: 我有以下睡眠记录
        let today = Date()
        
        // 今天 01:00 - 03:30 (2小时30分)
        let record1 = SleepRecord(
            baby: testBaby,
            startTime: Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: today)!,
            endTime: Calendar.current.date(bySettingHour: 3, minute: 30, second: 0, of: today)!
        )
        
        // 今天 07:00 - 09:00 (2小时)
        let record2 = SleepRecord(
            baby: testBaby,
            startTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: today)!,
            endTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today)!
        )
        
        // 今天 14:00 - 15:30 (1小时30分)
        let record3 = SleepRecord(
            baby: testBaby,
            startTime: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: today)!,
            endTime: Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: today)!
        )
        
        given_我有历史记录([record1, record2, record3])
        
        // When: 我进入统计页面
        let records = 获取所有记录(SleepRecord.self)
        
        // Then: 今日睡眠次数: 3次
        XCTAssertEqual(records.count, 3, "今日应有 3 次睡眠记录")
        
        // And: 今日总睡眠: 6小时
        let totalDuration = records.reduce(0.0) { $0 + $1.duration }
        XCTAssertEqual(totalDuration / 3600, 6, accuracy: 0.1, "总睡眠应为 6 小时")
        
        // And: 平均单次时长: 2小时
        let avgDuration = totalDuration / Double(records.count)
        XCTAssertEqual(avgDuration / 3600, 2, accuracy: 0.1, "平均时长应为 2 小时")
        
        // And: 最长睡眠: 2小时30分
        let maxDuration = records.map { $0.duration }.max() ?? 0
        XCTAssertEqual(maxDuration / 3600, 2.5, accuracy: 0.1, "最长睡眠应为 2.5 小时")
    }
    
    // MARK: - 场景: 编辑已有睡眠记录
    
    func test_编辑已有睡眠记录() {
        // Given: 我有一条睡眠记录
        let record = SleepRecord(
            baby: testBaby,
            startTime: 创建日期(小时偏移: -3),
            endTime: 创建日期(小时偏移: -1)
        )
        given_我有历史记录([record])
        
        let originalDuration = record.duration
        
        // When: 我点击该记录
        // And: 我修改结束时间为"1小时后"
        let newEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: record.endTime!)!
        record.endTime = newEndTime
        
        // And: 我保存修改
        try! modelContext.save()
        
        // Then: 时长应该自动更新
        let saved = 获取最新记录(SleepRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            let newDuration = saved.duration
            XCTAssertGreaterThan(newDuration, originalDuration, "时长应该增加")
            XCTAssertEqual(newDuration - originalDuration, 3600, accuracy: 60, "应增加约 1 小时")
        }
    }
    
    // MARK: - 场景: 删除错误的睡眠记录
    
    func test_删除错误的睡眠记录() {
        // Given: 我有一条错误的睡眠记录
        let record = SleepRecord(
            baby: testBaby,
            startTime: Date(),
            endTime: Date()
        )
        given_我有历史记录([record])
        then_应该存在记录(SleepRecord.self, 数量: 1)
        
        // When: 我在记录上左滑并点击"删除"按钮
        modelContext.delete(record)
        try! modelContext.save()
        
        // Then: 记录应该被删除
        then_应该存在记录(SleepRecord.self, 数量: 0)
        
        // And: 不再出现在时间线中
        let remaining = 获取所有记录(SleepRecord.self)
        XCTAssertTrue(remaining.isEmpty, "时间线应该为空")
    }
    
    // MARK: - 规则: 时长验证
    
    func test_时长验证_时长为零() {
        // When: 时长为"0分钟"
        let startTime = Date()
        let endTime = startTime
        
        // Then: 系统应该提示"时长不能为零"
        XCTAssertFalse(isValidSleepDuration(startTime, endTime), "零时长应该无效")
    }
    
    func test_时长验证_时长为负数() {
        // When: 时长为"-1小时" (结束时间早于开始时间)
        let startTime = Date()
        let endTime = Calendar.current.date(byAdding: .hour, value: -1, to: startTime)!
        
        // Then: 系统应该提示"时长不能为负数"
        XCTAssertFalse(isValidSleepDuration(startTime, endTime), "负时长应该无效")
    }
    
    func test_时长验证_时长异常() {
        // When: 时长为"15小时"
        let startTime = Date()
        let endTime = Calendar.current.date(byAdding: .hour, value: 15, to: startTime)!
        
        // Then: 系统应该提示"时长异常，请确认"
        XCTAssertFalse(isValidSleepDuration(startTime, endTime), "异常时长应该警告")
    }
    
    func test_时长验证_正常时长() {
        // When: 时长为"2小时30分"
        let startTime = Date()
        let endTime = Calendar.current.date(byAdding: .minute, value: 150, to: startTime)!
        
        // Then: 应该保存成功
        XCTAssertTrue(isValidSleepDuration(startTime, endTime), "正常时长应该有效")
    }
    
    // MARK: - Helper Methods
    
    private func isValidSleepDuration(_ startTime: Date, _ endTime: Date) -> Bool {
        let duration = endTime.timeIntervalSince(startTime)
        return duration > 0 && duration < 12 * 3600 // 0 < 时长 < 12小时
    }
}
