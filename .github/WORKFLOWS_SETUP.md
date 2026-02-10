# GitHub Actions Workflows Setup

由于 GitHub Personal Access Token 需要 `workflow` 权限才能创建/更新 workflow 文件，这些文件需要手动添加或使用具有正确权限的 token。

## Workflow 文件

以下 workflow 文件已创建在 `.github/workflows/` 目录：

### 1. ios-ci.yml
- **功能**: 持续集成构建和测试
- **触发**: Push 到 main/develop 分支，Pull Request
- **包含任务**:
  - 构建项目
  - 运行单元测试
  - SwiftLint 代码检查
  - 代码覆盖率报告

### 2. release.yml
- **功能**: 发布构建
- **触发**: 推送 tag (v*.*.*)
- **包含任务**:
  - 证书导入
  - Archive 构建
  - IPA 导出
  - GitHub Release 创建

### 3. pr-title-lint.yml
- **功能**: PR 标题格式检查
- **触发**: Pull Request 打开/编辑/同步
- **检查**: Conventional Commits 规范

## 手动添加方法

### 方法 1: 通过 GitHub 网页界面
1. 访问 https://github.com/euynus/baby-tracker
2. 进入 `.github/workflows/` 目录
3. 点击 "Add file" → "Create new file"
4. 粘贴对应的 workflow 内容
5. Commit 更改

### 方法 2: 本地添加并推送
```bash
# 1. 确保 workflows 文件存在
cd /root/.openclaw/workspace/baby-tracker
ls .github/workflows/

# 2. 使用具有 workflow 权限的 token
git remote set-url origin https://<TOKEN_WITH_WORKFLOW>@github.com/euynus/baby-tracker.git

# 3. 添加并推送
git add .github/workflows/
git commit -m "ci: add GitHub Actions CI/CD workflows"
git push
```

### 方法 3: GitHub CLI
```bash
gh auth login --scopes workflow
git add .github/workflows/
git commit -m "ci: add GitHub Actions CI/CD workflows"
git push
```

## 配置 Secrets

在 GitHub 仓库设置中添加以下 Secrets（Settings → Secrets and variables → Actions）：

### Release Build 需要
- `DISTRIBUTION_CERTIFICATE_P12`: Distribution 证书的 Base64 编码
- `CERTIFICATE_PASSWORD`: 证书密码
- `KEYCHAIN_PASSWORD`: 临时 keychain 密码
- `PROVISIONING_PROFILE`: Provisioning Profile 的 Base64 编码

### 代码覆盖率（可选）
- `CODECOV_TOKEN`: Codecov 上传 token

## 验证

Workflows 添加后，可以在以下位置查看：
- https://github.com/euynus/baby-tracker/actions

## SwiftLint

SwiftLint 配置文件 `.swiftlint.yml` 已包含在项目中，CI 会自动运行检查。

本地运行 SwiftLint:
```bash
brew install swiftlint
cd /root/.openclaw/workspace/baby-tracker
swiftlint
```

## 注意事项

1. **首次运行**: 第一次运行 CI 可能需要较长时间，因为需要下载 Xcode 和依赖
2. **模拟器版本**: 根据你的 Xcode 版本调整 workflow 中的模拟器版本
3. **并发限制**: GitHub Free 账户有并发限制，可能需要排队
4. **构建时间**: iOS 项目构建通常需要 5-15 分钟

## 状态徽章

在 workflows 运行后，README.md 中的徽章会自动显示构建状态。
