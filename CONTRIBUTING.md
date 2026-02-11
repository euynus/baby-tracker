# Contributing to Baby Tracker

感谢你考虑为 Baby Tracker 做出贡献！以下是参与贡献的指南。

## 行为准则

本项目遵循 [Contributor Covenant](https://www.contributor-covenant.org/) 行为准则。参与此项目即表示你同意遵守其条款。

## 如何贡献

### 报告 Bug

在创建 bug 报告之前：
1. 检查 [Issues](https://github.com/euynus/baby-tracker/issues) 确认问题是否已被报告
2. 尽可能提供详细的重现步骤
3. 说明你的环境（iOS 版本、设备型号等）

Bug 报告应包含：
- 清晰的标题和描述
- 重现步骤
- 期望行为
- 实际行为
- 截图（如果适用）
- 设备和系统信息

### 提出新功能

在提出新功能前：
1. 检查 [Issues](https://github.com/euynus/baby-tracker/issues) 确认功能未被提出
2. 解释为什么这个功能对项目有用
3. 提供详细的使用场景

### Pull Request 流程

1. **Fork 仓库**
   ```bash
   git clone https://github.com/YOUR_USERNAME/baby-tracker.git
   cd baby-tracker
   ```

2. **创建特性分支**
   ```bash
   git checkout -b feat/your-feature-name
   ```

3. **进行更改**
   - 遵循项目的代码风格
   - 添加适当的注释
   - 更新相关文档
   - 添加单元测试

4. **提交更改**
   
   使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：
   
   ```bash
   git commit -m "feat(timer): add pause functionality
   
   - Implement pause button in timer view
   - Save elapsed time when paused
   - Add unit tests for pause/resume"
   ```
   
   **提交类型**：
   - `feat`: 新功能
   - `fix`: Bug 修复
   - `docs`: 文档更新
   - `style`: 代码格式（不影响功能）
   - `refactor`: 重构
   - `perf`: 性能优化
   - `test`: 测试相关
   - `chore`: 构建/工具配置

5. **推送到 Fork**
   ```bash
   git push origin feat/your-feature-name
   ```

6. **创建 Pull Request**
   - 使用清晰的标题和描述
   - 链接相关的 Issue
   - 等待代码审查

### 代码风格

- 使用 SwiftLint 保持代码一致性
- 遵循 Swift API 设计指南
- 命名清晰、有意义
- 添加必要的注释
- 函数保持简短专一

### 测试

- 为新功能添加单元测试
- 确保所有测试通过
- 保持测试覆盖率在 70% 以上

运行测试：
```bash
xcodebuild test \
  -project BabyTracker.xcodeproj \
  -scheme BabyTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 文档

更新或添加文档时：
- README.md - 项目概述和快速开始
- CHANGELOG.md - 记录所有更改
- 代码注释 - 解释复杂逻辑
- API 文档 - 公共接口说明

## 开发设置

### 环境要求

- macOS 14+
- Xcode 15+
- iOS 17+ SDK
- SwiftLint (可选但推荐)

### 安装依赖

```bash
# 安装 SwiftLint
brew install swiftlint

# 打开项目
open BabyTracker.xcodeproj
```

### 项目结构

```
BabyTracker/
├── App/              # 应用入口
├── Models/           # 数据模型
├── Views/            # 视图组件
├── ViewModels/       # 视图逻辑
├── Utilities/        # 工具类
└── Resources/        # 资源文件
```

## 审查流程

1. 自动化测试必须通过
2. SwiftLint 检查必须通过
3. 至少一位维护者审查代码
4. 所有反馈必须得到解决

## 社区

- 通过 [Issues](https://github.com/euynus/baby-tracker/issues) 提问
- 在 [Discussions](https://github.com/euynus/baby-tracker/discussions) 参与讨论

## 许可证

通过贡献代码，你同意你的贡献将采用 MIT 许可证。

---

再次感谢你的贡献！🎉
