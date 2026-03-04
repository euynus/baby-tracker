# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Native iOS baby tracking app (宝宝日记) built with SwiftUI + SwiftData. All UI text is in Simplified Chinese. Targets iOS 17+. Zero third-party dependencies — uses SwiftUI, SwiftData, Swift Charts, WidgetKit, LocalAuthentication, CloudKit, UserNotifications, PDFKit.

## Build & Run Commands

```bash
# Build (Xcode)
xcodebuild build -project BabyTracker.xcodeproj -scheme BabyTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO

# Run all tests (Xcode)
xcodebuild test -project BabyTracker.xcodeproj -scheme BabyTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run BDD tests only (SPM — faster, no simulator needed for compilation)
swift test

# Lint
swiftlint --config .swiftlint.yml

# Open in Xcode
open BabyTracker.xcodeproj
```

SPM test target (`Package.swift`) excludes platform-specific files (Auth, CloudKit, Notifications, Security/iCloud/Reminder settings views) so BDD tests compile without simulator frameworks.

## Architecture

- **Entry point**: `BabyTracker/App/BabyTrackerApp.swift` — auth gate via `AuthenticationManager`, then `ContentView` with 4-tab layout (Home/Statistics/Calendar/Profile)
- **Pattern**: SwiftUI views with inline logic; only `BreastfeedingTimerViewModel` uses a dedicated ViewModel
- **Data**: SwiftData `@Model` classes linked to `Baby` via manual `babyId: UUID` (not `@Relationship`). Filter records by `babyId` at the view level
- **Persistence**: `AppPersistence.makeResilientAppContainer()` provides a fallback chain: CloudKit-backed → local file → in-memory. Detects test environment automatically
- **Singletons**: `CloudKitManager.shared`, `NotificationManager.shared`, `HapticManager.shared`

### Data Access Patterns

Views use `@Query` with sort descriptors, then filter by `babyId` manually:
```swift
@Query(sort: \FeedingRecord.timestamp, order: .reverse) private var feedingRecords: [FeedingRecord]
let filtered = feedingRecords.filter { $0.babyId == selectedBaby.id }
```

Always call `try? modelContext.save()` explicitly after insert/update/delete. The `ModelContext+Persistence.swift` extension provides `saveIfNeeded()` and `insertAndSave()` helpers.

### Record Form Pattern

Record forms are `.sheet()` modals with `@Environment(\.dismiss)`. They validate input, insert the model, save, and dismiss.

## Directory Structure

```
BabyTracker/
  App/           — App entry point + ContentView (4-tab TabView)
  Models/        — SwiftData @Model classes (Baby, FeedingRecord, SleepRecord, DiaperRecord, GrowthRecord, VaccinationRecord, PhotoRecord)
  ViewModels/    — Only BreastfeedingTimerViewModel
  Views/         — Organized by feature: Home/, Record/, Statistics/, Calendar/, Profile/, Settings/, Authentication/, Growth/, Photo/, Export/
  Utilities/     — Theme, AppPersistence, Managers (Auth, CloudKit, Notification, Haptic, Keychain, Export), VaccinationSchedule, AnimationExtensions
BabyTrackerWidget/    — WidgetKit extension
BabyTrackerBDDTests/  — BDD-style tests with Chinese Given/When/Then
```

## Conventions

### Swift / SwiftUI
- Use SwiftUI and SwiftData APIs (iOS 17+). No UIKit unless required (e.g., PDF export, haptics behind `#if canImport(UIKit)`)
- Views use `@Environment(\.modelContext)`, `@Query`, and `@State` for data access
- Use `@AppStorage` for simple preferences (appearance, auth toggles)

### Design Tokens (AppTheme)

All styling goes through `Utilities/Theme.swift`:
- **Colors**: `AppTheme.brand` (coral), `.secondary` (teal), `.accent` (mint), `.ink` (dark text), plus per-record-type colors (`.feeding`, `.sleep`, `.diaper`, `.growth`, `.vaccine`)
- **Spacing**: `.paddingSmall` (8), `.paddingMedium` (16), `.paddingLarge` (24)
- **Corners**: `.cornerRadiusSmall` (8), `.cornerRadiusMedium` (16), `.cornerRadiusLarge` (24)
- **Typography**: `.largeTitle`, `.title`, `.headline` (rounded design font), `.body`, `.caption`
- **View modifiers**: `.cardStyle()`, `.appPageBackground()`, `.gradientCard(colors:)`

### Naming
- Swift files: PascalCase matching the primary type (`FeedingRecord.swift`, `HomeView.swift`)
- All user-facing strings: Simplified Chinese
- BDD test methods use Chinese names (`given_我有一个名为小宝的宝宝档案`)
- Enums use camelCase raw values (`FeedingMethod.breastfeeding`)

### Data Models
- Each record type has `id: UUID`, `babyId: UUID`, and a timestamp field
- Models have convenience initializers accepting a `Baby` object
- Some models include backward-compatible alias properties (e.g., `type` → `method`)

### Testing
- BDD tests extend `BDDTestBase` which sets up an in-memory `ModelContainer` and a test baby (`Baby(name: "小宝", birthday: 3 months ago, gender: .male)`)
- Base class provides Chinese-named helpers: `given_*`, `when_*`, `then_*` methods, plus `获取最新记录()`, `获取所有记录()`, `清空所有记录()`, `创建日期()`

### Linting (SwiftLint)
- Disabled: `trailing_whitespace`, `line_length`, `file_length`
- Opt-in: `empty_count`, `force_unwrapping`, `implicitly_unwrapped_optional`, `unused_optional_binding`
- Function body: 50 warning / 100 error
- Type body: 300 warning / 400 error
- Cyclomatic complexity: 10 warning / 20 error

### Commit Messages
Conventional Commits format: `<type>(<scope>): <subject>`
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

## CI (GitHub Actions)

- **ios-ci.yml**: Triggers on push to main/develop and all PRs. Runs on macos-14 with Xcode 15.2
  - `build-xcode` job: builds for iPhone 15 simulator, no code signing
  - `lint` job: SwiftLint with `--lenient`, continues on error
