# Baby Tracker

一个专为新生儿护理设计的 iOS 应用，帮助父母轻松记录和追踪宝宝的日常护理数据。

## 功能特性

### 核心功能
- 🍼 **喂养记录** - 支持母乳实时计时（左右侧独立计时）、奶粉记录
- 💤 **睡眠追踪** - 睡眠计时器，自动统计睡眠时长
- 💩 **尿布记录** - 快速记录大小便情况
- 🌡️ **体温监测** - 体温记录与趋势
- 📏 **生长追踪** - 体重、身高、头围记录

### 数据分析
- 📊 **统计图表** - 使用 Swift Charts 展示喂养、睡眠趋势
- 📅 **日历视图** - 快速查看历史记录
- 📈 **生长曲线** - 对比 WHO 标准

### 实用工具
- ⏰ **智能提醒** - 喂奶、换尿布定时提醒
- 👶 **多宝宝管理** - 支持记录多个孩子
- ☁️ **iCloud 同步** - 家庭成员数据共享
- 🔒 **隐私保护** - Face ID / 密码保护
- 📤 **数据导出** - 导出 PDF/Excel，便于医生查看

## 技术栈

- **最低系统要求**: iOS 16.0+
- **UI 框架**: SwiftUI
- **数据持久化**: SwiftData
- **图表**: Swift Charts
- **云同步**: CloudKit
- **认证**: LocalAuthentication (Face ID / Touch ID)

## 项目结构

```
BabyTracker/
├── App/
│   ├── BabyTrackerApp.swift          # App 入口
│   └── ContentView.swift             # 主视图容器
├── Models/
│   ├── Baby.swift                    # 宝宝实体
│   ├── Record.swift                  # 记录基类
│   ├── FeedingRecord.swift           # 喂养记录
│   ├── SleepRecord.swift             # 睡眠记录
│   ├── DiaperRecord.swift            # 尿布记录
│   └── GrowthRecord.swift            # 生长记录
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift            # 首页
│   │   ├── QuickActionButton.swift   # 快捷操作按钮
│   │   └── TimelineView.swift        # 时间轴列表
│   ├── Record/
│   │   ├── FeedingRecordView.swift   # 喂养记录表单
│   │   ├── BreastfeedingTimer.swift  # 母乳计时器
│   │   ├── SleepTimerView.swift      # 睡眠计时器
│   │   └── DiaperRecordView.swift    # 尿布记录
│   ├── Statistics/
│   │   ├── StatisticsView.swift      # 统计主页
│   │   └── Charts/                   # 图表组件
│   ├── Calendar/
│   │   └── CalendarView.swift        # 日历视图
│   └── Profile/
│       ├── BabyProfileView.swift     # 宝宝资料
│       └── SettingsView.swift        # 设置
├── ViewModels/
│   ├── FeedingTimerViewModel.swift   # 喂养计时器逻辑
│   └── RecordViewModel.swift         # 记录管理
└── Utilities/
    ├── Extensions/                   # Swift 扩展
    ├── Helpers/                      # 辅助工具
    └── Constants.swift               # 常量定义
```

## 开发计划

### Phase 1: MVP (最小可用版本)
- [x] 项目初始化
- [ ] 数据模型实现
- [ ] 主界面框架（TabView）
- [ ] 喂养记录（含母乳计时器）
- [ ] 时间轴列表
- [ ] 基础数据持久化

### Phase 2: 完善功能
- [x] 睡眠计时器
- [x] 尿布记录
- [x] 统计图表
- [x] 日历视图
- [x] 多宝宝管理

### Phase 3: 高级功能
- [x] Face ID / 密码保护
- [x] 提醒功能（喂奶/换尿布）
- [x] 数据导出（CSV/PDF）
- [x] 照片记录
- [x] 生长曲线（WHO 标准对比）
- [x] 完整单元测试

## 设计原则

- **快速录入优先** - 一键开始计时，减少操作步骤
- **清晰直观** - 简约现代的设计语言
- **夜间友好** - 深夜喂奶时保护眼睛
- **智能预填** - 根据历史数据推荐常用值

## 原型设计

查看完整的高保真原型设计：
- [初始版本](../baby-tracker-prototype.html)
- [母乳计时增强版](../baby-tracker-prototype-v2.html)

## 开发环境

```bash
# 克隆仓库
git clone https://github.com/euynus/baby-tracker.git

# 使用 Xcode 打开项目
open BabyTracker.xcodeproj
```

## License

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

---

**开发中** 🚧 持续更新...
