# Xcode 本地构建指南

## ❌ 当前错误

```
Build input files cannot be found: '/Users/yuesun/Projects/baby-tracker/PhotoGalleryView.swift'...
```

这个错误说明 Xcode 在项目根目录查找文件，而不是在 `BabyTracker/` 子目录中。

## ✅ 解决方案

### 方法 1: Clean Build（推荐）

1. 在 Xcode 中按 `Shift + Cmd + K` 清理构建
2. 或者菜单: Product → Clean Build Folder
3. 然后重新构建 `Cmd + B`

### 方法 2: 删除 Derived Data

```bash
# 关闭 Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData/BabyTracker-*

# 重新打开项目
open BabyTracker.xcodeproj
```

### 方法 3: 重新克隆仓库

```bash
cd ~/Projects
rm -rf baby-tracker
git clone https://github.com/euynus/baby-tracker.git
cd baby-tracker
open BabyTracker.xcodeproj
```

## 🔍 验证项目结构

在 Xcode 中，左侧导航器应该显示：

```
BabyTracker
├── BabyTracker (蓝色文件夹图标)
│   ├── App
│   │   ├── BabyTrackerApp.swift
│   │   └── ContentView.swift
│   ├── Models
│   │   ├── Baby.swift
│   │   ├── FeedingRecord.swift
│   │   ├── SleepRecord.swift
│   │   ├── DiaperRecord.swift
│   │   ├── GrowthRecord.swift
│   │   └── PhotoRecord.swift
│   ├── Views
│   │   ├── Home
│   │   ├── Record
│   │   ├── Statistics
│   │   ├── Calendar
│   │   ├── Profile
│   │   ├── Settings
│   │   ├── Authentication
│   │   ├── Export
│   │   ├── Growth
│   │   └── Photo
│   ├── ViewModels
│   ├── Utilities (7 个文件)
│   ├── Assets.xcassets
│   └── Preview Content
└── Products
    └── BabyTracker.app
```

## ⚙️ 项目设置检查

1. **选择 BabyTracker target**
2. **Build Settings**
3. **搜索 "Source Root"**
4. 确保 `SRCROOT` 指向项目根目录

## 🛠️ 命令行构建（验证）

```bash
cd /path/to/baby-tracker

# 清理
xcodebuild clean \
  -project BabyTracker.xcodeproj \
  -scheme BabyTracker

# 构建
xcodebuild build \
  -project BabyTracker.xcodeproj \
  -scheme BabyTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  CODE_SIGNING_ALLOWED=NO
```

如果命令行构建成功，说明项目配置正确，Xcode 需要清理缓存。

## 📝 注意事项

- ✅ 项目文件路径都是相对路径
- ✅ 所有文件都在 `BabyTracker/` 子目录中
- ✅ 项目配置正确
- ⚠️ Xcode 的 DerivedData 可能缓存了旧的路径信息

## 🚑 最后的手段

如果以上方法都不行，手动重新添加文件：

1. 在 Xcode 中，选中所有有错误的文件
2. 右键 → Delete → Remove Reference
3. 右键 BabyTracker 文件夹 → Add Files to "BabyTracker"
4. 选择缺失的文件夹 (Utilities, Settings, 等)
5. 确保勾选：
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: BabyTracker

---

**最可能的原因**: Xcode 的 DerivedData 缓存问题

**最快的解决**: Clean Build Folder (`Shift + Cmd + K`)
