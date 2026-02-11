# BDD 测试套件说明

## 📋 概述

本测试套件采用 BDD (Behavior-Driven Development) 风格，使用 XCTest 框架实现。每个测试用例对应 `Features/` 目录下的 Gherkin 场景。

## 📂 文件结构

```
BabyTrackerBDDTests/
├── BDDTestBase.swift           # 测试基类（Given/When/Then 辅助方法）
├── FeedingBDDTests.swift       # 喂奶功能测试 (14 个测试)
├── SleepBDDTests.swift         # 睡眠功能测试 (9 个测试)
├── DiaperBDDTests.swift        # 尿布功能测试 (12 个测试)
├── GrowthBDDTests.swift        # 生长功能测试 (15 个测试)
└── StatisticsBDDTests.swift    # 统计功能测试 (4 个测试)
```

**总计**: 54 个 BDD 测试用例

---

## 🎯 测试覆盖范围

### 1. 喂奶功能 (FeedingBDDTests)

✅ 核心场景:
- 开始母乳喂养计时（左侧）
- 暂停和恢复左侧计时
- 切换到右侧喂养
- 完成喂奶并保存记录
- 奶瓶喂养记录
- 查看喂奶历史统计
- 删除错误的喂奶记录

✅ 数据验证:
- 奶量为零 / 负数 / 异常值 / 正常值

**对应 Feature**: `Features/Feeding.feature`

---

### 2. 睡眠功能 (SleepBDDTests)

✅ 核心场景:
- 开始睡眠计时
- 结束睡眠并保存记录
- 手动添加历史睡眠记录
- 添加睡眠备注
- 查看今日睡眠统计
- 编辑已有睡眠记录
- 删除错误的睡眠记录

✅ 数据验证:
- 时长为零 / 负数 / 异常 / 正常

**对应 Feature**: `Features/Sleep.feature`

---

### 3. 尿布功能 (DiaperBDDTests)

✅ 核心场景:
- 记录湿尿布
- 记录脏尿布
- 记录既湿又脏的尿布
- 选择大便颜色（黄/绿/棕/黑/白）
- 选择大便质地（稀/正常/干硬/水样）
- 添加尿布更换备注
- 查看今日尿布统计
- 编辑已有尿布记录
- 删除错误的尿布记录

✅ 异常检测:
- 大便颜色异常警告（黑色/白色应警告）

**对应 Feature**: `Features/Diaper.feature`

---

### 4. 生长功能 (GrowthBDDTests)

✅ 核心场景:
- 记录体重
- 记录身高
- 记录头围
- 记录体温
- 同时记录多项数据
- 生长速度计算
- 编辑历史记录
- 删除错误记录
- 添加测量备注

✅ 异常检测:
- 体重异常低 (<1kg) / 高 (>15kg)
- 体温偏低 (<35.5°C)
- 体温略高 (37.5-38°C)
- 发烧 (≥38°C)

**对应 Feature**: `Features/Growth.feature`

---

### 5. 统计功能 (StatisticsBDDTests)

✅ 核心场景:
- 查看今日概览（多类型数据汇总）
- 查看喂奶统计图表（7天数据）
- 查看睡眠统计图表（7天数据）
- 空数据状态处理

**对应 Feature**: `Features/Statistics.feature`

---

## 🛠️ 测试基础设施 (BDDTestBase)

### 测试环境
- **数据库**: 内存数据库（`ModelConfiguration(isStoredInMemoryOnly: true)`）
- **测试宝宝**: 自动创建名为"小宝"的 3 个月大男宝宝
- **数据隔离**: 每个测试独立运行，互不影响

### Given 步骤（前置条件）
```swift
given_我已经登录应用()
given_我有一个名为小宝的宝宝档案()
given_我在页面(_ page: String)
given_我有历史记录<T>(_ records: [T])
```

### When 步骤（执行动作）
```swift
when_等待(_ seconds: TimeInterval)
```

### Then 步骤（验证结果）
```swift
then_应该存在记录<T>(_ type: T.Type, 数量: Int)
then_记录应该包含字段<T>(_ record: T?, 验证: (T) -> Bool, 描述: String)
then_应该显示文本(_ text: String)
```

### 辅助方法
```swift
获取最新记录<T>(_ type: T.Type) -> T?
获取所有记录<T>(_ type: T.Type) -> [T]
清空所有记录<T>(_ type: T.Type)
创建日期(天数偏移: Int, 小时偏移: Int, 分钟偏移: Int) -> Date
```

### 自定义断言
```swift
XCTAssertTimeInterval(_ actual: TimeInterval, 等于 expected: TimeInterval, 容差: TimeInterval)
XCTAssertDateEqual(_ date1: Date?, _ date2: Date?, 精度: Calendar.Component)
```

---

## ▶️ 运行测试

### 1. 命令行运行
```bash
cd baby-tracker

# 运行所有 BDD 测试
xcodebuild test \
  -scheme BabyTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:BabyTrackerBDDTests

# 运行单个测试文件
xcodebuild test \
  -scheme BabyTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:BabyTrackerBDDTests/FeedingBDDTests

# 运行单个测试用例
xcodebuild test \
  -scheme BabyTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:BabyTrackerBDDTests/FeedingBDDTests/test_开始母乳喂养计时_左侧
```

### 2. Xcode 运行
1. 打开 `BabyTracker.xcodeproj`
2. 选择 `BabyTrackerBDDTests` target
3. `Cmd + U` 运行所有测试
4. 或在左侧导航栏点击单个测试方法的 ▶️ 按钮

---

## 📊 测试统计

| 测试文件                   | 测试用例数 | 覆盖场景 |
|---------------------------|-----------|---------|
| FeedingBDDTests.swift     | 14        | 喂奶计时、记录、统计、验证 |
| SleepBDDTests.swift       | 9         | 睡眠计时、记录、统计、验证 |
| DiaperBDDTests.swift      | 12        | 尿布类型、颜色质地、统计 |
| GrowthBDDTests.swift      | 15        | 体重身高头围体温、异常检测 |
| StatisticsBDDTests.swift  | 4         | 多维度统计、图表、空状态 |
| **总计**                  | **54**    | **5 个核心功能** |

---

## 🔍 测试命名规范

所有测试用例使用中文命名，直接对应 Feature 文件中的场景：

```swift
// Feature: 场景: 开始母乳喂养计时（左侧）
func test_开始母乳喂养计时_左侧() { ... }

// Feature: 规则: 数据验证 - 奶量为零
func test_奶瓶喂养数据验证_奶量为零() { ... }
```

**优点**:
- 测试名称即文档，无需额外注释
- 非技术人员可以直接读懂测试内容
- 与 Feature 文件一一对应，易于维护

---

## ✅ 测试通过标准

### 单元测试级别
- ✅ 所有断言通过
- ✅ 数据库操作无异常
- ✅ 时间精度在容差范围内

### 集成测试级别
- ✅ ViewModel 逻辑正确
- ✅ SwiftData 持久化成功
- ✅ 数据计算准确（统计、趋势、平均值）

### 验收测试级别
- ✅ 每个 Feature 场景至少有 1 个测试覆盖
- ✅ 关键业务规则有对应的验证测试
- ✅ 异常情况有警告和错误处理

---

## 🚧 当前限制

### 不包含的测试类型
- ❌ **UI 测试**: 按钮点击、滑动、导航等（需要 XCUITest）
- ❌ **性能测试**: 大数据量、内存占用、启动时间
- ❌ **网络测试**: iCloud 同步、API 调用
- ❌ **动画测试**: 触觉反馈、视觉动画

### 需要手动验证的功能
- 计时器实时更新（需要 UI 测试）
- 图表渲染（需要截图对比）
- 触觉反馈（需要真机测试）
- iCloud 同步（需要网络环境）
- Widget 更新（需要系统测试）

---

## 📝 维护指南

### 添加新测试
1. 在对应的 Feature 文件中添加场景
2. 在对应的 BDDTests 文件中添加测试方法
3. 使用 Given/When/Then 结构
4. 命名遵循 `test_场景描述()` 格式

### 修改现有测试
1. 检查 Feature 文件是否需要同步更新
2. 更新测试逻辑和断言
3. 运行相关测试确保通过
4. 更新本文档的统计数据

### 调试测试失败
1. 查看 XCTest 错误信息（文件 + 行号）
2. 使用断点调试 Given/When/Then 步骤
3. 检查数据库状态（`获取所有记录()` 打印）
4. 验证时间和日期计算逻辑

---

## 🎓 BDD 最佳实践

### ✅ 好的测试
```swift
func test_完成喂奶并保存记录() {
    // Given: 明确的前置条件
    viewModel.startLeft()
    when_等待(0.5)
    viewModel.switchSide()
    when_等待(0.3)
    
    // When: 单一的动作
    viewModel.saveRecord(context: modelContext)
    
    // Then: 清晰的验证
    then_应该存在记录(FeedingRecord.self, 数量: 1)
    let record = 获取最新记录(FeedingRecord.self)
    XCTAssertEqual(record?.type, .breastfeeding)
}
```

### ❌ 差的测试
```swift
func test_喂奶() {
    // 没有 Given/When/Then 结构
    let record = FeedingRecord(baby: testBaby, type: .bottle, amount: 120)
    modelContext.insert(record)
    // 缺少验证
}
```

### 原则
1. **一个测试只验证一个行为**
2. **Given/When/Then 结构清晰**
3. **测试名称描述期望行为，不是实现细节**
4. **使用有意义的断言消息**
5. **避免测试之间的依赖**

---

## 📚 参考资料

- Feature 文件: `Features/*.feature`
- 测试基类: `BabyTrackerBDDTests/BDDTestBase.swift`
- 数据模型: `BabyTracker/Models/*.swift`
- ViewModel: `BabyTracker/ViewModels/*.swift`
- Apple XCTest: https://developer.apple.com/documentation/xctest

---

**最后更新**: 2026-02-11  
**测试覆盖率**: 5 个核心功能 × 54 个测试用例  
**测试风格**: BDD (Behavior-Driven Development)  
**框架**: XCTest + SwiftData
