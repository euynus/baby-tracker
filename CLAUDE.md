# CLAUDE.md — BabyTracker (宝宝日记)

## Project Overview

Native iOS baby tracking app built with SwiftUI + SwiftData. All UI text is in Simplified Chinese. Targets iOS 17+.

## Architecture

- **Entry point**: `BabyTracker/App/BabyTrackerApp.swift` — auth gate then `ContentView` with 4-tab layout
- **Pattern**: SwiftUI views with inline logic; only `BreastfeedingTimerViewModel` uses a dedicated ViewModel
- **Data**: SwiftData `@Model` classes. Records link to `Baby` via manual `babyId: UUID` (not `@Relationship`)
- **Singletons**: `CloudKitManager.shared`, `NotificationManager.shared`, `HapticManager.shared`

## Directory Structure

```
BabyTracker/
  App/           — App entry point + root ContentView
  Models/        — SwiftData @Model classes (Baby, FeedingRecord, SleepRecord, DiaperRecord, GrowthRecord, PhotoRecord)
  ViewModels/    — Observable view models (currently only BreastfeedingTimerViewModel)
  Views/         — SwiftUI views organized by feature (Home/, Record/, Statistics/, Calendar/, Profile/, Settings/, etc.)
  Utilities/     — Managers and helpers (Auth, CloudKit, Export, Notification, Haptic, Theme, Animation)
BabyTrackerWidget/    — WidgetKit extension
BabyTrackerTests/     — Unit tests
BabyTrackerBDDTests/  — BDD-style tests with Chinese Given/When/Then
```

## Conventions

### Swift / SwiftUI
- Use SwiftUI and SwiftData APIs (iOS 17+). No UIKit unless required (e.g., PDF export, haptics behind `#if canImport(UIKit)`)
- Views use `@Environment(\.modelContext)`, `@Query`, and `@State` for data access
- Record forms are presented as `.sheet()` modals
- Always call `try? modelContext.save()` explicitly after insert/update/delete
- Use `@AppStorage` for simple preferences (appearance, auth toggles)
- Design tokens live in `Utilities/Theme.swift` (`AppTheme` struct) — use them for colors, spacing, corner radii, shadows

### Naming
- Swift files: PascalCase matching the primary type (`FeedingRecord.swift`, `HomeView.swift`)
- All user-facing strings: Simplified Chinese
- BDD test methods use Chinese names (`given_我有一个名为小宝的宝宝档案`)
- Enums use camelCase raw values (`FeedingMethod.breastfeeding`)

### Data Models
- Each record type has `id: UUID`, `babyId: UUID`, and a timestamp field
- Relationships are manual UUID-based, not SwiftData `@Relationship`
- Filter records by `babyId` match at the view level

### Testing
- BDD tests extend `BDDTestBase` which sets up an in-memory `ModelContainer`
- Test target uses SPM (`Package.swift`) — platform-specific files (Auth, CloudKit, Notifications) are excluded
- Test baby: `Baby(name: "小宝", birthday: 3 months ago, gender: .male)`

### Linting
- SwiftLint configured via `.swiftlint.yml`
- Disabled: `trailing_whitespace`, `line_length`, `file_length`
- Function body limit: 50 warning / 100 error
- Type body limit: 300 warning / 400 error

## Build & Run

- Open `BabyTracker.xcodeproj` in Xcode
- BDD tests can also run via `swift test` (SPM)

## Key Dependencies

All Apple-native, no third-party packages:
- SwiftUI, SwiftData, Swift Charts, WidgetKit
- LocalAuthentication, CloudKit, UserNotifications, PDFKit
