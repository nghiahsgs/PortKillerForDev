# PortKiller MVP - Implementation Plan

**Date:** Dec 11, 2025 | **Status:** In Progress

## Overview
Native macOS menu bar app to detect and kill processes using localhost ports. Built with Swift/SwiftUI, distributed as notarized DMG.

## Target Specs
- **Name:** PortKiller
- **Tech:** Swift 5.9 + SwiftUI + AppKit
- **Target:** macOS 13.0+ (Ventura)
- **Distribution:** Direct (Notarized DMG)
- **Features:** Core + Smart Icon Detection

## Phases

| Phase | Name | Status | Link |
|-------|------|--------|------|
| 01 | Project Setup | Pending | [phase-01-project-setup.md](./phase-01-project-setup.md) |
| 02 | Core Port Detection | Pending | [phase-02-port-detection.md](./phase-02-port-detection.md) |
| 03 | Menu Bar UI | Pending | [phase-03-menubar-ui.md](./phase-03-menubar-ui.md) |
| 04 | Smart Icons | Pending | [phase-04-smart-icons.md](./phase-04-smart-icons.md) |
| 05 | Polish & Ship | Pending | [phase-05-polish-ship.md](./phase-05-polish-ship.md) |

## Architecture

```
PortKiller/
├── App/
│   ├── PortKillerApp.swift        # @main entry
│   └── AppDelegate.swift          # NSApplicationDelegate
├── Features/
│   ├── StatusBar/
│   │   └── StatusBarController.swift
│   ├── PortList/
│   │   ├── PortListView.swift
│   │   └── PortRowView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Services/
│   ├── PortScanner.swift          # lsof wrapper
│   ├── ProcessKiller.swift        # kill process
│   └── ProcessIconProvider.swift  # icon resolution
├── Models/
│   └── ProcessInfo.swift
├── Resources/
│   └── Assets.xcassets            # App icons + Process icons
└── Info.plist
```

## Key Decisions
1. **AppKit + SwiftUI hybrid** - NSStatusItem for menu bar, SwiftUI for popover content
2. **lsof over libproc** - Simpler, no C bridging needed
3. **Bundled icons** - Ship 10 common dev tool icons (~100KB)
4. **No sandbox** - Required for process management

## Success Criteria
- [ ] App shows in menu bar (no dock icon)
- [ ] Lists all listening ports with process names
- [ ] One-click kill works
- [ ] Smart icons for Node/Python/Docker/Postgres/Redis
- [ ] App notarized and runs on fresh Mac

## References
- [Research: Menu Bar Apps](../reports/researcher-251211-macos-menubar-app.md)
- [Research: Market Analysis](../../researcher-251211-port-killer-market-analysis.md)
- [Research: Process Icons](../reports/researcher-251211-process-icons-macos.md)
