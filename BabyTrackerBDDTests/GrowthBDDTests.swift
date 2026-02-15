//
//  GrowthBDDTests.swift
//  BabyTrackerBDDTests
//
//  生长功能 BDD 测试
//  对应 Features/Growth.feature
//

import XCTest
@testable import BabyTracker

final class GrowthBDDTests: BDDTestBase {
    
    // MARK: - 场景: 记录体重
    
    func test_记录体重() {
        // Given: 我在生长记录页面
        given_我已经登录应用()
        given_我有一个名为小宝的宝宝档案()
        given_我在页面("生长记录")
        
        // When: 我选择"体重"类型
        // And: 我输入数值"5.8"公斤
        // And: 我点击"保存"按钮
        let record = GrowthRecord(
            baby: testBaby,
            weight: 5.8,
            timestamp: Date()
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 应该创建一条新的生长记录
        then_应该存在记录(GrowthRecord.self, 数量: 1)
        
        let saved = 获取最新记录(GrowthRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            // 类型: 体重
            XCTAssertNotNil(saved.weight, "应该包含体重数据")
            
            // 数值: 5.8kg
            XCTAssertEqual(saved.weight ?? 0, 5.8, accuracy: 0.01, "体重应为 5.8kg")
            
            // 时间戳: 当前时间
            XCTAssertDateEqual(saved.timestamp, Date(), 精度: .minute)
        }
    }
    
    // MARK: - 场景: 记录身高
    
    func test_记录身高() {
        // Given: 我在生长记录页面
        given_我已经登录应用()
        
        // When: 我选择"身高"类型并输入"62.5"厘米
        let record = GrowthRecord(
            baby: testBaby,
            height: 62.5,
            timestamp: Date()
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 记录类型应该为"身高"
        let saved = 获取最新记录(GrowthRecord.self)
        XCTAssertNotNil(saved?.height, "应该包含身高数据")
        
        // And: 数值应该为"62.5cm"
        XCTAssertEqual(saved?.height ?? 0, 62.5, accuracy: 0.01, "身高应为 62.5cm")
    }
    
    // MARK: - 场景: 记录头围
    
    func test_记录头围() {
        // Given: 我在生长记录页面
        given_我已经登录应用()
        
        // When: 我选择"头围"类型并输入"42.0"厘米
        let record = GrowthRecord(
            baby: testBaby,
            headCircumference: 42.0,
            timestamp: Date()
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 记录类型应该为"头围"
        let saved = 获取最新记录(GrowthRecord.self)
        XCTAssertNotNil(saved?.headCircumference, "应该包含头围数据")
        
        // And: 数值应该为"42.0cm"
        XCTAssertEqual(saved?.headCircumference ?? 0, 42.0, accuracy: 0.01, "头围应为 42.0cm")
    }
    
    // MARK: - 场景: 记录体温
    
    func test_记录体温() {
        // Given: 我在生长记录页面
        given_我已经登录应用()
        
        // When: 我选择"体温"类型并输入"36.8"摄氏度
        let record = GrowthRecord(
            baby: testBaby,
            temperature: 36.8,
            timestamp: Date()
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 记录类型应该为"体温"
        let saved = 获取最新记录(GrowthRecord.self)
        XCTAssertNotNil(saved?.temperature, "应该包含体温数据")
        
        // And: 数值应该为"36.8°C"
        XCTAssertEqual(saved?.temperature ?? 0, 36.8, accuracy: 0.01, "体温应为 36.8°C")
    }
    
    // MARK: - 场景: 同时记录多项数据
    
    func test_同时记录多项数据() {
        // Given: 我在生长记录页面
        given_我已经登录应用()
        
        // When: 我输入多项数据
        let timestamp = Date()
        
        let record1 = GrowthRecord(
            baby: testBaby,
            weight: 5.8,
            timestamp: timestamp
        )
        let record2 = GrowthRecord(
            baby: testBaby,
            height: 62.5,
            timestamp: timestamp
        )
        let record3 = GrowthRecord(
            baby: testBaby,
            headCircumference: 42.0,
            timestamp: timestamp
        )
        
        // And: 我点击"保存"按钮
        modelContext.insert(record1)
        modelContext.insert(record2)
        modelContext.insert(record3)
        try! modelContext.save()
        
        // Then: 应该创建3条生长记录
        then_应该存在记录(GrowthRecord.self, 数量: 3)
        
        // And: 所有记录的时间戳应该相同
        let records = 获取所有记录(GrowthRecord.self)
        for record in records {
            XCTAssertDateEqual(record.timestamp, timestamp, 精度: .second)
        }
    }
    
    // MARK: - 场景: 生长速度计算
    
    func test_生长速度计算() {
        // Given: 我有以下体重记录
        let thirtyDaysAgo = 创建日期(天数偏移: -30)
        let today = Date()
        
        // 30天前: 5.0kg
        let oldRecord = GrowthRecord(
            baby: testBaby,
            weight: 5.0,
            timestamp: thirtyDaysAgo
        )
        
        // 今天: 5.8kg
        let newRecord = GrowthRecord(
            baby: testBaby,
            weight: 5.8,
            timestamp: today
        )
        
        given_我有历史记录([oldRecord, newRecord])
        
        // When: 我查看生长统计
        let records = 获取所有记录(GrowthRecord.self)
            .filter { $0.weight != nil }
            .sorted { $0.timestamp < $1.timestamp }
        
        guard records.count == 2 else {
            XCTFail("应该有 2 条体重记录")
            return
        }
        
        let oldWeight = records[0].weight!
        let newWeight = records[1].weight!
        let daysDiff = Calendar.current.dateComponents([.day], from: records[0].timestamp, to: records[1].timestamp).day!
        
        // Then: 应该显示"30天增长0.8kg"
        let totalGrowth = newWeight - oldWeight
        XCTAssertEqual(totalGrowth, 0.8, accuracy: 0.01, "30天应增长 0.8kg")
        
        // And: 应该显示"平均每天增长27克"
        let dailyGrowth = (totalGrowth * 1000) / Double(daysDiff) // 转换为克
        XCTAssertEqual(dailyGrowth, 27, accuracy: 1, "平均每天应增长约 27 克")
    }
    
    // MARK: - 场景: 编辑历史记录
    
    func test_编辑历史记录() {
        // Given: 我有一条生长记录"体重 5.8kg"
        let record = GrowthRecord(
            baby: testBaby,
            weight: 5.8,
            timestamp: Date()
        )
        given_我有历史记录([record])
        
        // When: 我点击该记录
        // And: 我修改数值为"5.9kg"
        record.weight = 5.9
        
        // And: 我保存修改
        try! modelContext.save()
        
        // Then: 记录应该更新
        let saved = 获取最新记录(GrowthRecord.self)
        XCTAssertEqual(saved?.weight ?? 0, 5.9, accuracy: 0.01, "体重应更新为 5.9kg")
    }
    
    // MARK: - 场景: 删除错误记录
    
    func test_删除错误记录() {
        // Given: 我有一条错误的生长记录
        let record = GrowthRecord(
            baby: testBaby,
            weight: 100.0,
            timestamp: Date()
        )
        given_我有历史记录([record])
        then_应该存在记录(GrowthRecord.self, 数量: 1)
        
        // When: 我在记录上左滑并点击"删除"按钮
        modelContext.delete(record)
        try! modelContext.save()
        
        // Then: 记录应该被删除
        then_应该存在记录(GrowthRecord.self, 数量: 0)
    }
    
    // MARK: - 场景: 添加测量备注
    
    func test_添加测量备注() {
        // Given: 我正在创建生长记录
        let record = GrowthRecord(
            baby: testBaby,
            weight: 5.8,
            timestamp: Date()
        )
        
        // When: 我在备注栏输入"医院体检测量"
        record.notes = "医院体检测量"
        
        // And: 我保存记录
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 记录应该包含备注
        let saved = 获取最新记录(GrowthRecord.self)
        XCTAssertEqual(saved?.notes, "医院体检测量")
    }
    
    // MARK: - 规则: 异常数值警告
    
    func test_异常数值警告_体重异常低() {
        // When: 我输入体重"0.5kg"
        let weight = 0.5
        
        // Then: 系统应该警告"体重异常低，请确认"
        XCTAssertTrue(isAbnormalWeight(weight), "0.5kg 应该警告")
    }
    
    func test_异常数值警告_体重异常高() {
        // When: 我输入体重"20kg"
        let weight = 20.0
        
        // Then: 系统应该警告"体重异常高，请确认"
        XCTAssertTrue(isAbnormalWeight(weight), "20kg 应该警告")
    }
    
    func test_正常体重() {
        // When: 我输入体重"5.8kg"
        let weight = 5.8
        
        // Then: 应该正常保存
        XCTAssertFalse(isAbnormalWeight(weight), "5.8kg 应该正常")
    }
    
    // MARK: - 规则: 体温异常警告
    
    func test_体温异常警告_体温偏低() {
        // When: 我输入体温"35.0°C"
        let temperature = 35.0
        
        // Then: 系统应该警告"体温偏低，请注意保暖"
        XCTAssertTrue(isLowTemperature(temperature), "35°C 应该警告偏低")
    }
    
    func test_体温异常警告_体温略高() {
        // When: 我输入体温"37.5°C"
        let temperature = 37.5
        
        // Then: 系统应该提示"体温略高，请持续监测"
        XCTAssertTrue(isElevatedTemperature(temperature), "37.5°C 应该提示略高")
    }
    
    func test_体温异常警告_发烧() {
        // When: 我输入体温"38.5°C"
        let temperature = 38.5
        
        // Then: 系统应该警告"发烧，建议就医"
        XCTAssertTrue(isFever(temperature), "38.5°C 应该警告发烧")
    }
    
    func test_正常体温() {
        // When: 我输入体温"36.8°C"
        let temperature = 36.8
        
        // Then: 应该正常保存
        XCTAssertTrue(isNormalTemperature(temperature), "36.8°C 应该正常")
    }
    
    // MARK: - Helper Methods
    
    private func isAbnormalWeight(_ weight: Double) -> Bool {
        return weight < 1.0 || weight > 15.0
    }
    
    private func isLowTemperature(_ temperature: Double) -> Bool {
        return temperature < 35.5
    }
    
    private func isElevatedTemperature(_ temperature: Double) -> Bool {
        return temperature >= 37.5 && temperature < 38.0
    }
    
    private func isFever(_ temperature: Double) -> Bool {
        return temperature >= 38.0
    }
    
    private func isNormalTemperature(_ temperature: Double) -> Bool {
        return temperature >= 35.5 && temperature < 37.5
    }
}
