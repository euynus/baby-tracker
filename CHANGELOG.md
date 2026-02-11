# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD workflows
- SwiftLint configuration
- Conventional Commits guidelines

## [0.3.0] - 2026-02-10

### Added
- iCloud sync with CloudKitManager
- Haptic feedback system (7 feedback types)
- Rich animations (ScaleButton, Shake, Pulse, SlideIn, FadeIn)
- Home screen Widget (Small & Medium sizes)
- Dark mode optimization with AppTheme system
- Appearance settings view

### Changed
- Enhanced QuickActionButton with press animations
- Improved user experience with tactile feedback

## [0.2.0] - 2026-02-10

### Added
- Face ID / Passcode authentication
- Smart reminders (feeding & diaper changes)
- Growth charts with WHO standard percentiles
- Data export to CSV & PDF formats
- Photo gallery with captions
- Security settings view
- Reminder configuration per baby

### Changed
- Enhanced profile view with quick access
- Improved navigation structure

## [0.1.0] - 2026-02-10

### Added
- Complete Xcode project structure
- SwiftData models: Baby, FeedingRecord, SleepRecord, DiaperRecord, GrowthRecord
- Breastfeeding timer with left/right side independent tracking
- Sleep timer with real-time duration tracking
- Diaper record form with color/consistency options
- Statistics view with Swift Charts integration
- Calendar view with monthly grid and daily summaries
- Profile view with baby management
- HomeView with QuickActionButton grid and TimelineItemView
- TabView navigation structure
- 30+ unit tests

### Technical
- iOS 17+ minimum requirement
- SwiftUI + SwiftData architecture
- Swift Charts integration
- LocalAuthentication integration
- UserNotifications scheduling
- PDFKit for report generation
- PhotosPicker for image import

## [0.0.1] - 2026-02-10

### Added
- Initial project setup
- Basic SwiftData models
- Breastfeeding timer prototype
- Home view framework
- Navigation structure

[Unreleased]: https://github.com/euynus/baby-tracker/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/euynus/baby-tracker/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/euynus/baby-tracker/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/euynus/baby-tracker/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/euynus/baby-tracker/releases/tag/v0.0.1
