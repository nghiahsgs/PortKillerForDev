# Phase 01: Project Setup

**Status:** Pending | **Priority:** High

## Context
Set up Xcode project structure for a menu bar only macOS app.

## Requirements
- Xcode project with SwiftUI lifecycle
- No dock icon (LSUIElement)
- Target macOS 13.0+
- App Sandbox disabled (for process management)
- Code signing for notarization

## Implementation Steps

### 1. Create Xcode Project
- [ ] Create new macOS App project named "PortKiller"
- [ ] Set Organization Identifier: `com.yourname.portkiller`
- [ ] Interface: SwiftUI
- [ ] Language: Swift
- [ ] Uncheck "Include Tests" for MVP

### 2. Configure Info.plist
- [ ] Add `LSUIElement = true` (hide dock icon)
- [ ] Set minimum deployment target to macOS 13.0
- [ ] Add app name and version

### 3. Configure Entitlements
- [ ] Disable App Sandbox
- [ ] Enable Hardened Runtime (for notarization)

### 4. Project Structure
```
PortKiller/
├── PortKillerApp.swift
├── AppDelegate.swift
├── Features/
├── Services/
├── Models/
├── Resources/
│   └── Assets.xcassets
├── Info.plist
└── PortKiller.entitlements
```

### 5. Create Basic App Entry
- [ ] Create PortKillerApp.swift with @main
- [ ] Create AppDelegate.swift with NSApplicationDelegate
- [ ] Set activation policy to .accessory

## Success Criteria
- [ ] Project builds without errors
- [ ] App runs with no dock icon
- [ ] Basic empty menu bar icon appears

## Files Changed
- `PortKiller.xcodeproj`
- `PortKillerApp.swift`
- `AppDelegate.swift`
- `Info.plist`
- `PortKiller.entitlements`
