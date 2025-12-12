# PortKiller

A lightweight macOS menu bar app to detect and kill processes listening on localhost ports.

## Features

- **Menu Bar Icon** - Always accessible from your status bar
- **Port Detection** - Scans all listening TCP ports
- **One-Click Kill** - Terminate processes instantly
- **Smart Icons** - Recognizes Node.js, Python, Docker, PostgreSQL, Redis, Go, Java, Ruby, Nginx, Rust, PHP
- **No Dock Icon** - Stays out of your way

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15+ (for building from source)

## Installation

### From Source

```bash
git clone https://github.com/yourusername/kill-port.git
cd kill-port
xcodebuild -project PortKiller.xcodeproj -scheme PortKiller -configuration Release build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/PortKiller-*/Build/Products/Release/PortKiller.app`

### Direct Download

Download the latest `.dmg` from [Releases](https://github.com/yourusername/kill-port/releases).

## Usage

1. Click the network icon in your menu bar
2. View all processes listening on ports
3. Click the X button to kill a process
4. Click "Refresh" to rescan ports

## Architecture

```
PortKiller/
├── App/                    # App entry point & delegate
├── Features/
│   ├── StatusBar/          # Menu bar controller
│   └── PortList/           # Main UI views
├── Services/
│   ├── PortScanner.swift   # lsof wrapper
│   ├── ProcessKiller.swift # Process termination
│   └── ProcessIconProvider.swift
├── Models/
│   └── ProcessInfo.swift
└── Resources/
    └── Assets.xcassets     # App & process icons
```

## Tech Stack

- Swift 5.9
- SwiftUI + AppKit (hybrid)
- macOS 13.0+ deployment target

## License

MIT

## Contributing

PRs welcome! Please ensure code builds without warnings.
