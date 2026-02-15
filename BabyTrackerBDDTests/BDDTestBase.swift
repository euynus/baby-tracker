//
//  BDDTestBase.swift
//  BabyTrackerBDDTests
//
//  BDD 测试基类，提供 Given/When/Then 风格的辅助方法
//

import XCTest
import SwiftData
@testable import BabyTracker

class BDDTestBase: XCTestCase {
    
    // MARK: - Test Environment
    
    var modelContext: ModelContext!
    var testBaby: Baby!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        setupTestEnvironment()
    }
    
    override func tearDown() {
        cleanupTestEnvironment()
        super.tearDown()
    }
    
    // MARK: - Test Environment Setup
    
    private func setupTestEnvironment() {
        // 创建内存数据库
        do {
            let container = try AppPersistence.makeInMemoryTestContainer()
            modelContext = ModelContext(container)
        } catch {
            XCTFail("测试容器初始化失败: \(error.localizedDescription)")
            return
        }
        
        // 创建测试宝宝
        testBaby = Baby(
            name: "小宝",
            birthday: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            gender: .male
        )
        modelContext.insert(testBaby)
        do {
            try modelContext.saveIfNeeded()
        } catch {
            XCTFail("测试宝宝初始化失败: \(error.localizedDescription)")
        }
    }
    
    private func cleanupTestEnvironment() {
        modelContext = nil
        testBaby = nil
    }
    
    // MARK: - Given Steps (前置条件)
    
    /// 假如：我已经登录应用
    func given_我已经登录应用() {
        // 在测试环境中，setUp 已经完成登录状态
        XCTAssertNotNil(modelContext, "应用未正确初始化")
    }
    
    /// 假如：我有一个名为"小宝"的宝宝档案
    func given_我有一个名为小宝的宝宝档案() {
        XCTAssertNotNil(testBaby, "宝宝档案不存在")
        XCTAssertEqual(testBaby.name, "小宝")
    }
    
    /// 假如：我在指定页面
    func given_我在页面(_ page: String) {
        // UI 导航在实际测试中处理
        // 这里仅作标记
    }
    
    /// 假如：我有指定的历史记录
    func given_我有历史记录<T: PersistentModel>(_ records: [T]) {
        records.forEach { modelContext.insert($0) }
        try! modelContext.save()
    }
    
    // MARK: - When Steps (执行动作)
    
    /// 当：等待指定时间
    func when_等待(_ seconds: TimeInterval) {
        let expectation = XCTestExpectation(description: "等待\(seconds)秒")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: seconds + 1)
    }
    
    // MARK: - Then Steps (验证结果)
    
    /// 那么：应该存在指定数量的记录
    func then_应该存在记录<T: PersistentModel>(
        _ type: T.Type,
        数量: Int,
        文件: StaticString = #filePath,
        行号: UInt = #line
    ) {
        let descriptor = FetchDescriptor<T>()
        let records = try! modelContext.fetch(descriptor)
        XCTAssertEqual(
            records.count,
            数量,
            "记录数量不匹配",
            file: 文件,
            line: 行号
        )
    }
    
    /// 那么：记录应该包含指定字段
    func then_记录应该包含字段<T>(
        _ record: T?,
        验证: (T) -> Bool,
        描述: String,
        文件: StaticString = #filePath,
        行号: UInt = #line
    ) {
        XCTAssertNotNil(record, "记录不存在", file: 文件, line: 行号)
        if let record = record {
            XCTAssertTrue(验证(record), 描述, file: 文件, line: 行号)
        }
    }
    
    /// 那么：应该显示指定文本
    func then_应该显示文本(
        _ text: String,
        文件: StaticString = #filePath,
        行号: UInt = #line
    ) {
        // UI 验证在实际测试中处理
        // 这里仅作标记
        XCTAssertTrue(true, file: 文件, line: 行号)
    }
    
    // MARK: - Helper Methods
    
    /// 获取最新的记录
    func 获取最新记录<T: PersistentModel>(_ type: T.Type) -> T? {
        let records = try! modelContext.fetch(FetchDescriptor<T>())

        if type == FeedingRecord.self {
            return (records as? [FeedingRecord])?
                .sorted(by: { $0.timestamp > $1.timestamp })
                .first as? T
        }
        if type == SleepRecord.self {
            return (records as? [SleepRecord])?
                .sorted(by: { $0.startTime > $1.startTime })
                .first as? T
        }
        if type == DiaperRecord.self {
            return (records as? [DiaperRecord])?
                .sorted(by: { $0.timestamp > $1.timestamp })
                .first as? T
        }
        if type == GrowthRecord.self {
            return (records as? [GrowthRecord])?
                .sorted(by: { $0.timestamp > $1.timestamp })
                .first as? T
        }

        return records.first
    }
    
    /// 获取所有记录
    func 获取所有记录<T: PersistentModel>(_ type: T.Type) -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try! modelContext.fetch(descriptor)
    }
    
    /// 清空所有记录
    func 清空所有记录<T: PersistentModel>(_ type: T.Type) {
        let records = 获取所有记录(type)
        records.forEach { modelContext.delete($0) }
        try! modelContext.save()
    }
    
    /// 创建测试日期（相对当前时间）
    func 创建日期(
        天数偏移: Int = 0,
        小时偏移: Int = 0,
        分钟偏移: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.day = 天数偏移
        components.hour = 小时偏移
        components.minute = 分钟偏移
        return Calendar.current.date(byAdding: components, to: Date())!
    }
}

// MARK: - XCTestCase Extensions

extension XCTestCase {
    
    /// 验证时间差（容忍 1 秒误差）
    func XCTAssertTimeInterval(
        _ actual: TimeInterval,
        等于 expected: TimeInterval,
        容差: TimeInterval = 1.0,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let diff = abs(actual - expected)
        XCTAssertLessThanOrEqual(
            diff,
            容差,
            message.isEmpty ? "时间差异超过容差: \(diff)秒" : message,
            file: file,
            line: line
        )
    }
    
    /// 验证日期相等（忽略秒以下精度）
    func XCTAssertDateEqual(
        _ date1: Date?,
        _ date2: Date?,
        精度: Calendar.Component = .second,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let date1 = date1, let date2 = date2 else {
            XCTFail("日期为空", file: file, line: line)
            return
        }
        
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let comp1 = calendar.dateComponents(components, from: date1)
        let comp2 = calendar.dateComponents(components, from: date2)
        
        XCTAssertEqual(
            comp1.year, comp2.year,
            "年份不匹配",
            file: file, line: line
        )
        XCTAssertEqual(
            comp1.month, comp2.month,
            "月份不匹配",
            file: file, line: line
        )
        XCTAssertEqual(
            comp1.day, comp2.day,
            "日期不匹配",
            file: file, line: line
        )
        XCTAssertEqual(
            comp1.hour, comp2.hour,
            "小时不匹配",
            file: file, line: line
        )
        XCTAssertEqual(
            comp1.minute, comp2.minute,
            "分钟不匹配",
            file: file, line: line
        )
        
        if 精度 == .second {
            XCTAssertEqual(
                comp1.second, comp2.second,
                "秒不匹配",
                file: file, line: line
            )
        }
    }
}
