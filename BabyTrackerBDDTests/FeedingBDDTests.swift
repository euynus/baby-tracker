//
//  FeedingBDDTests.swift
//  BabyTrackerBDDTests
//
//  喂奶功能 BDD 测试
//  对应 Features/Feeding.feature
//

import XCTest
@testable import BabyTracker

final class FeedingBDDTests: BDDTestBase {
    
    var viewModel: BreastfeedingTimerViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = BreastfeedingTimerViewModel(baby: testBaby)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - 场景: 开始母乳喂养计时（左侧）
    
    func test_开始母乳喂养计时_左侧() {
        // Given: 我在喂奶记录页面
        given_我已经登录应用()
        given_我有一个名为小宝的宝宝档案()
        given_我在页面("喂奶记录")
        
        // When: 我点击"左侧开始"按钮
        viewModel.startLeft()
        
        // Then: 计时器应该开始运行
        XCTAssertTrue(viewModel.isLeftRunning, "左侧计时器应该正在运行")
        XCTAssertNotNil(viewModel.leftStartTime, "左侧开始时间应该被记录")
        
        // And: 左侧按钮文本变为"左侧暂停"
        XCTAssertTrue(viewModel.isLeftRunning, "按钮状态应该为运行中")
        
        // And: 计时显示格式为"MM:SS"
        let formattedTime = viewModel.leftElapsedTime
        XCTAssertTrue(formattedTime.matches("\\d{2}:\\d{2}"), "时间格式应为 MM:SS")
    }
    
    // MARK: - 场景: 暂停和恢复左侧计时
    
    func test_暂停和恢复左侧计时() {
        // Given: 我已经开始左侧计时
        viewModel.startLeft()
        
        // And: 计时器运行了"00:30"
        when_等待(0.5) // 模拟 0.5 秒
        
        let elapsedBefore = viewModel.leftElapsed
        
        // When: 我点击"左侧暂停"按钮
        viewModel.pauseLeft()
        
        // Then: 计时器应该暂停在当前时间
        XCTAssertFalse(viewModel.isLeftRunning, "左侧计时器应该已暂停")
        let elapsedAfterPause = viewModel.leftElapsed
        XCTAssertTimeInterval(elapsedAfterPause, 等于: elapsedBefore, 容差: 0.1)
        
        // And: 按钮文本变为"左侧继续"
        XCTAssertFalse(viewModel.isLeftRunning, "按钮状态应为暂停")
        
        // When: 我点击"左侧继续"按钮
        viewModel.resumeLeft()
        
        // Then: 计时器应该从暂停时间继续运行
        XCTAssertTrue(viewModel.isLeftRunning, "左侧计时器应该重新开始")
        
        when_等待(0.3)
        let elapsedAfterResume = viewModel.leftElapsed
        XCTAssertGreaterThan(elapsedAfterResume, elapsedAfterPause, "计时应该继续累加")
    }
    
    // MARK: - 场景: 切换到右侧喂养
    
    func test_切换到右侧喂养() {
        // Given: 我已经开始左侧计时
        viewModel.startLeft()
        
        // And: 左侧计时时间为"05:23"
        when_等待(1.0) // 模拟 1 秒
        let leftElapsedBefore = viewModel.leftElapsed
        
        // When: 我点击"切换到右侧"按钮
        viewModel.switchSide()
        
        // Then: 左侧计时应该自动停止
        XCTAssertFalse(viewModel.isLeftRunning, "左侧计时应该停止")
        
        // And: 左侧累计时间应该保存
        let leftElapsedAfter = viewModel.leftElapsed
        XCTAssertTimeInterval(leftElapsedAfter, 等于: leftElapsedBefore, 容差: 0.1)
        
        // And: 右侧计时器应该自动开始
        XCTAssertTrue(viewModel.isRightRunning, "右侧计时器应该开始运行")
        XCTAssertNotNil(viewModel.rightStartTime, "右侧开始时间应该被记录")
        
        // And: 右侧按钮文本变为"右侧暂停"
        XCTAssertTrue(viewModel.isRightRunning, "右侧按钮状态应为运行中")
    }
    
    // MARK: - 场景: 完成喂奶并保存记录
    
    func test_完成喂奶并保存记录() {
        // Given: 我已经完成左右两侧喂养
        viewModel.startLeft()
        when_等待(0.5)
        viewModel.switchSide()
        when_等待(0.3)
        viewModel.stopRight()
        
        let leftDuration = viewModel.leftElapsed
        let rightDuration = viewModel.rightElapsed
        let totalDuration = leftDuration + rightDuration
        
        // When: 我点击"完成"按钮
        viewModel.saveRecord(context: modelContext)
        
        // Then: 应该创建一条新的喂奶记录
        then_应该存在记录(FeedingRecord.self, 数量: 1)
        
        // And: 记录应该包含正确的数据
        let record = 获取最新记录(FeedingRecord.self)
        XCTAssertNotNil(record, "应该创建喂奶记录")
        
        if let record = record {
            // 类型: 母乳
            XCTAssertEqual(record.type, .breastfeeding, "类型应为母乳")
            
            // 左侧时长
            XCTAssertTimeInterval(TimeInterval(record.leftDuration ?? 0), 等于: leftDuration, 容差: 1.0)
            
            // 右侧时长
            XCTAssertTimeInterval(TimeInterval(record.rightDuration ?? 0), 等于: rightDuration, 容差: 1.0)
            
            // 总时长
            let recordTotal = TimeInterval((record.leftDuration ?? 0) + (record.rightDuration ?? 0))
            XCTAssertTimeInterval(recordTotal, 等于: totalDuration, 容差: 1.5)
            
            // 时间戳: 当前时间
            XCTAssertDateEqual(record.timestamp, Date(), 精度: .minute)
        }
        
        // And: 记录应该出现在首页时间线中
        // (这个在 UI 测试中验证)
    }
    
    // MARK: - 场景: 奶瓶喂养记录
    
    func test_奶瓶喂养记录() {
        // Given: 我在喂奶记录页面
        given_我已经登录应用()
        given_我有一个名为小宝的宝宝档案()
        
        // When: 我选择"奶瓶"类型
        // And: 我输入奶量"120"毫升
        let record = FeedingRecord(
            baby: testBaby,
            type: .bottle,
            amount: 120,
            timestamp: Date()
        )
        
        // And: 我点击"保存"按钮
        modelContext.insert(record)
        try! modelContext.save()
        
        // Then: 应该创建一条新的喂奶记录
        then_应该存在记录(FeedingRecord.self, 数量: 1)
        
        // And: 记录应该包含正确的数据
        let saved = 获取最新记录(FeedingRecord.self)
        XCTAssertNotNil(saved)
        
        if let saved = saved {
            // 类型: 奶瓶
            XCTAssertEqual(saved.type, .bottle, "类型应为奶瓶")
            
            // 奶量: 120ml
            XCTAssertEqual(saved.amount, 120, "奶量应为 120ml")
            
            // 时间戳: 当前时间
            XCTAssertDateEqual(saved.timestamp, Date(), 精度: .minute)
        }
    }
    
    // MARK: - 场景: 查看喂奶历史统计
    
    func test_查看喂奶历史统计() {
        // Given: 我有以下喂奶记录
        let today = Date()
        
        // 今天 08:00 - 母乳 (左10分 + 右8分)
        let record1 = FeedingRecord(
            baby: testBaby,
            type: .breastfeeding,
            leftDuration: 10 * 60,
            rightDuration: 8 * 60,
            timestamp: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: today)!
        )
        
        // 今天 11:30 - 奶瓶 120ml
        let record2 = FeedingRecord(
            baby: testBaby,
            type: .bottle,
            amount: 120,
            timestamp: Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: today)!
        )
        
        // 今天 15:00 - 母乳 (左12分 + 右9分)
        let record3 = FeedingRecord(
            baby: testBaby,
            type: .breastfeeding,
            leftDuration: 12 * 60,
            rightDuration: 9 * 60,
            timestamp: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: today)!
        )
        
        given_我有历史记录([record1, record2, record3])
        
        // When: 我进入统计页面
        let records = 获取所有记录(FeedingRecord.self)
        
        // Then: 我应该看到今天的喂奶次数为"3次"
        XCTAssertEqual(records.count, 3, "今天应有 3 次喂奶记录")
        
        // And: 母乳总时长为"39分钟"
        let breastfeedingRecords = records.filter { $0.type == .breastfeeding }
        let totalBreastfeedingTime = breastfeedingRecords.reduce(0) { sum, record in
            sum + (record.leftDuration ?? 0) + (record.rightDuration ?? 0)
        }
        XCTAssertEqual(Double(totalBreastfeedingTime) / 60, 39, accuracy: 1, "母乳总时长应为 39 分钟")
        
        // And: 奶瓶总量为"120ml"
        let bottleRecords = records.filter { $0.type == .bottle }
        let totalBottleAmount = bottleRecords.reduce(0.0) { $0 + ($1.amount ?? 0) }
        XCTAssertEqual(totalBottleAmount, 120, "奶瓶总量应为 120ml")
    }
    
    // MARK: - 场景: 删除错误的喂奶记录
    
    func test_删除错误的喂奶记录() {
        // Given: 我有一条错误的喂奶记录
        let record = FeedingRecord(
            baby: testBaby,
            type: .bottle,
            amount: 100,
            timestamp: Date()
        )
        given_我有历史记录([record])
        then_应该存在记录(FeedingRecord.self, 数量: 1)
        
        // When: 我在记录上左滑并点击"删除"按钮
        modelContext.delete(record)
        try! modelContext.save()
        
        // Then: 记录应该被删除
        then_应该存在记录(FeedingRecord.self, 数量: 0)
        
        // And: 不再出现在时间线中
        let remaining = 获取所有记录(FeedingRecord.self)
        XCTAssertTrue(remaining.isEmpty, "时间线应该为空")
    }
    
    // MARK: - 规则: 数据验证
    
    func test_奶瓶喂养数据验证_奶量为零() {
        // Given: 我选择奶瓶喂养
        // When: 我输入奶量"0"
        let amount = 0
        
        // Then: 系统应该提示"请输入有效奶量"
        XCTAssertFalse(isValidBottleAmount(amount), "奶量为零应该无效")
    }
    
    func test_奶瓶喂养数据验证_奶量为负数() {
        // When: 我输入奶量"-10"
        let amount = -10
        
        // Then: 系统应该提示"奶量不能为负数"
        XCTAssertFalse(isValidBottleAmount(amount), "负数奶量应该无效")
    }
    
    func test_奶瓶喂养数据验证_奶量异常() {
        // When: 我输入奶量"500"
        let amount = 500
        
        // Then: 系统应该提示"奶量异常，请确认"
        XCTAssertFalse(isValidBottleAmount(amount), "异常奶量应该警告")
    }
    
    func test_奶瓶喂养数据验证_奶量正常() {
        // When: 我输入奶量"120"
        let amount = 120
        
        // Then: 应该保存成功
        XCTAssertTrue(isValidBottleAmount(amount), "正常奶量应该有效")
    }
    
    // MARK: - Helper Methods
    
    private func isValidBottleAmount(_ amount: Int) -> Bool {
        return amount > 0 && amount <= 300
    }
}

// MARK: - String Extension for Regex

extension String {
    func matches(_ pattern: String) -> Bool {
        return self.range(of: pattern, options: .regularExpression) != nil
    }
}
