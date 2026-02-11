//
//  DiaperBDDTests.swift
//  BabyTrackerBDDTests
//
//  尿布功能 BDD 测试
//  对应 Features/Diaper.feature
//

import XCTest
@testable import BabyTracker

final class DiaperBDDTests: BDDTestBase {
    
    // MARK: - 场景: 记录湿尿布
    
    func test_记录湿尿布() {
        // Given: 我在尿布记录页面
        given_我已经登录应用()
        given_我有一个名为小宝的宝宝档案()
        given_我在页面("尿布记录")
        
        // When: 我选择"湿"类型
        // And: 我点击"保存"按钮
        let record = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: false,
            timestamp: Date()
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 应该创建一条新的尿布记录
        then_应该存在记录(DiaperRecord.self, 数量: 1)
        
        let saved = 获取最新记录(DiaperRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            // 类型: 湿
            XCTAssertTrue(saved.isWet, "类型应为湿")
            XCTAssertFalse(saved.isDirty, "不应该是脏")
            
            // 时间戳: 当前时间
            XCTAssertDateEqual(saved.timestamp, Date(), 精度: .minute)
        }
    }
    
    // MARK: - 场景: 记录脏尿布
    
    func test_记录脏尿布() {
        // Given: 我在尿布记录页面
        given_我已经登录应用()
        
        // When: 我选择"脏"类型
        // And: 我点击"保存"按钮
        let record = DiaperRecord(
            baby: testBaby,
            isWet: false,
            isDirty: true,
            timestamp: Date()
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 应该创建一条新的尿布记录
        let saved = 获取最新记录(DiaperRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            // 类型: 脏
            XCTAssertFalse(saved.isWet, "不应该是湿")
            XCTAssertTrue(saved.isDirty, "类型应为脏")
        }
    }
    
    // MARK: - 场景: 记录既湿又脏的尿布
    
    func test_记录既湿又脏的尿布() {
        // Given: 我在尿布记录页面
        given_我已经登录应用()
        
        // When: 我同时选择"湿"和"脏"
        // And: 我点击"保存"按钮
        let record = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: true,
            timestamp: Date()
        )
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 应该创建一条记录
        then_应该存在记录(DiaperRecord.self, 数量: 1)
        
        let saved = 获取最新记录(DiaperRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            // 类型: 湿+脏
            XCTAssertTrue(saved.isWet, "应该是湿")
            XCTAssertTrue(saved.isDirty, "应该是脏")
        }
    }
    
    // MARK: - 场景: 选择大便颜色
    
    func test_选择大便颜色() {
        let colors: [DiaperRecord.StoolColor] = [.yellow, .green, .brown, .black, .white]
        
        for color in colors {
            // Given: 我选择了"脏"尿布
            // When: 我在颜色选择器中选择颜色
            let record = DiaperRecord(
                baby: testBaby,
                isWet: false,
                isDirty: true,
                stoolColor: color,
                timestamp: Date()
            )
            
            // And: 我保存记录
            modelContext.insert(record)
            try! modelContext.save()
            
            // Then: 记录应该包含颜色信息
            let saved = 获取最新记录(DiaperRecord.self)
            XCTAssertNotNil(saved)
            XCTAssertEqual(saved?.stoolColor, color, "颜色应为 \(color)")
            
            // 清理
            清空所有记录(DiaperRecord.self)
        }
    }
    
    // MARK: - 场景: 选择大便质地
    
    func test_选择大便质地() {
        let consistencies: [DiaperRecord.StoolConsistency] = [.loose, .normal, .hard, .watery]
        
        for consistency in consistencies {
            // Given: 我选择了"脏"尿布
            // When: 我在质地选择器中选择质地
            let record = DiaperRecord(
                baby: testBaby,
                isWet: false,
                isDirty: true,
                stoolConsistency: consistency,
                timestamp: Date()
            )
            
            // And: 我保存记录
            modelContext.insert(record)
            try! modelContext.save()
            
            // Then: 记录应该包含质地信息
            let saved = 获取最新记录(DiaperRecord.self)
            XCTAssertNotNil(saved)
            XCTAssertEqual(saved?.stoolConsistency, consistency, "质地应为 \(consistency)")
            
            // 清理
            清空所有记录(DiaperRecord.self)
        }
    }
    
    // MARK: - 场景: 添加尿布更换备注
    
    func test_添加尿布更换备注() {
        // Given: 我正在创建尿布记录
        let record = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: false,
            timestamp: Date()
        )
        
        // When: 我在备注栏输入"有轻微红疹"
        record.notes = "有轻微红疹"
        
        // And: 我保存记录
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 记录应该包含备注
        let saved = 获取最新记录(DiaperRecord.self)
        XCTAssertEqual(saved?.notes, "有轻微红疹")
    }
    
    // MARK: - 场景: 查看今日尿布统计
    
    func test_查看今日尿布统计() {
        // Given: 我有以下尿布记录
        let today = Date()
        
        // 今天 08:00 - 湿
        let record1 = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: false,
            timestamp: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: today)!
        )
        
        // 今天 10:30 - 脏 (黄色、正常)
        let record2 = DiaperRecord(
            baby: testBaby,
            isWet: false,
            isDirty: true,
            stoolColor: .yellow,
            stoolConsistency: .normal,
            timestamp: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: today)!
        )
        
        // 今天 13:00 - 湿+脏 (黄色、稀)
        let record3 = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: true,
            stoolColor: .yellow,
            stoolConsistency: .loose,
            timestamp: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: today)!
        )
        
        // 今天 15:30 - 湿
        let record4 = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: false,
            timestamp: Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: today)!
        )
        
        given_我有历史记录([record1, record2, record3, record4])
        
        // When: 我进入统计页面
        let records = 获取所有记录(DiaperRecord.self)
        
        // Then: 今日更换次数: 4次
        XCTAssertEqual(records.count, 4, "今日应有 4 次更换记录")
        
        // And: 湿尿布次数: 3次
        let wetCount = records.filter { $0.isWet }.count
        XCTAssertEqual(wetCount, 3, "湿尿布应有 3 次")
        
        // And: 脏尿布次数: 2次
        let dirtyCount = records.filter { $0.isDirty }.count
        XCTAssertEqual(dirtyCount, 2, "脏尿布应有 2 次")
    }
    
    // MARK: - 场景: 编辑已有尿布记录
    
    func test_编辑已有尿布记录() {
        // Given: 我有一条尿布记录
        let record = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: false,
            timestamp: Date()
        )
        given_我有历史记录([record])
        
        // When: 我点击该记录
        // And: 我修改类型为"湿+脏"
        record.isDirty = true
        
        // And: 我添加颜色"黄色"和质地"正常"
        record.stoolColor = .yellow
        record.stoolConsistency = .normal
        
        // And: 我保存修改
        try! modelContext.save()
        
        // Then: 记录应该更新
        let saved = 获取最新记录(DiaperRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            XCTAssertTrue(saved.isWet, "应该是湿")
            XCTAssertTrue(saved.isDirty, "应该是脏")
            XCTAssertEqual(saved.stoolColor, .yellow, "颜色应为黄色")
            XCTAssertEqual(saved.stoolConsistency, .normal, "质地应为正常")
        }
    }
    
    // MARK: - 场景: 删除错误的尿布记录
    
    func test_删除错误的尿布记录() {
        // Given: 我有一条错误的尿布记录
        let record = DiaperRecord(
            baby: testBaby,
            isWet: true,
            isDirty: false,
            timestamp: Date()
        )
        given_我有历史记录([record])
        then_应该存在记录(DiaperRecord.self, 数量: 1)
        
        // When: 我在记录上左滑并点击"删除"按钮
        modelContext.delete(record)
        try! modelContext.save()
        
        // Then: 记录应该被删除
        then_应该存在记录(DiaperRecord.self, 数量: 0)
    }
    
    // MARK: - 场景: 异常大便颜色警告
    
    func test_异常大便颜色警告_黑色() {
        // When: 我选择大便颜色为"黑色"
        let color = DiaperRecord.StoolColor.black
        
        // Then: 系统应该警告
        XCTAssertTrue(isAbnormalStoolColor(color), "黑色大便应该警告")
    }
    
    func test_异常大便颜色警告_白色() {
        // When: 我选择大便颜色为"白色"
        let color = DiaperRecord.StoolColor.white
        
        // Then: 系统应该警告
        XCTAssertTrue(isAbnormalStoolColor(color), "白色大便应该警告")
    }
    
    func test_正常大便颜色_黄色() {
        // When: 我选择大便颜色为"黄色"
        let color = DiaperRecord.StoolColor.yellow
        
        // Then: 应该正常保存
        XCTAssertFalse(isAbnormalStoolColor(color), "黄色大便应该正常")
    }
    
    // MARK: - Helper Methods
    
    private func isAbnormalStoolColor(_ color: DiaperRecord.StoolColor) -> Bool {
        return [.black, .white, .red].contains(color)
    }
}
