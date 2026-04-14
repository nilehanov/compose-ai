# Compose: AI Email Draft

A private AI email/message drafter for iOS 26+ that runs entirely on-device using Apple Intelligence.

## Architecture

- **Swift 6.2 / SwiftUI** with strict concurrency
- **Foundation Models** (`LanguageModelSession`, `@Generable`) for on-device AI generation
- **SwiftData** for local draft history persistence
- **XcodeGen** for project file generation

## Structure

```
Compose/
  ComposeApp.swift          - App entry point with TabView
  Theme.swift               - Professional blue theme, light/dark adaptive
  Models/
    DraftTemplate.swift     - 5 template types (Reply, New, Follow-Up, Decline, Complaint)
    EmailDraft.swift        - @Generable struct with subject, greeting, body, closing
    SavedDraft.swift        - SwiftData @Model for persistence
  Services/
    DraftService.swift      - LanguageModelSession wrapper with availability check
  ViewModels/
    ComposeViewModel.swift  - Main compose flow state management
  Views/
    NewDraftView.swift      - Main compose screen with template/tone selection
    DraftListView.swift     - History of saved drafts
    TemplatePickerView.swift - Template selection cards
    TonePickerView.swift    - Horizontal tone chip selector
    DraftResultView.swift   - Generated draft display with copy/share
    PrivacyBannerView.swift - Privacy and availability info banners
```

## Build

```bash
xcodegen generate
xcodebuild build -project Compose.xcodeproj -scheme Compose -destination 'generic/platform=iOS'
```

## Deploy

```bash
xcodebuild archive -project Compose.xcodeproj -scheme Compose \
  -destination 'generic/platform=iOS' -archivePath build/Compose.xcarchive
xcodebuild -exportArchive -archivePath build/Compose.xcarchive \
  -exportPath build/export -exportOptionsPlist ExportOptions.plist
```

## Privacy

All AI processing happens on-device. No data collected, no tracking, no external APIs.
