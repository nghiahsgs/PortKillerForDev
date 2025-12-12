# Phase 04: Smart Process Icons

**Status:** Pending | **Priority:** Medium

## Context
Display recognizable icons for common dev tools instead of generic process icons.

## Requirements
- Detect process type from name/path
- Bundle icons for: Node.js, Python, Docker, Postgres, Redis, Go, Java, Ruby, Nginx
- Fallback to generic icon for unknown processes
- Use NSRunningApplication icon for GUI apps

## Architecture

```swift
// Services/ProcessIconProvider.swift
class ProcessIconProvider {
    static func getIcon(for process: ProcessInfo) -> NSImage
    static func getProcessType(_ processName: String) -> ProcessType
}

enum ProcessType {
    case nodejs, python, docker, postgres, redis, go, java, ruby, nginx, unknown
}
```

## Implementation Steps

### 1. Create ProcessType Enum
- [ ] Define all supported process types
- [ ] Map process names to types
- [ ] Handle variations (python3, python3.11, etc.)

### 2. Create Icon Assets
- [ ] Download/create 16x16 and 32x32 icons for each type
- [ ] Add to Assets.xcassets
- [ ] Use template images where appropriate

### 3. Process Name Patterns
```swift
let patterns: [String: ProcessType] = [
    "node": .nodejs,
    "python": .python,
    "python3": .python,
    "docker": .docker,
    "postgres": .postgres,
    "pg_": .postgres,
    "redis-server": .redis,
    "redis": .redis,
    "go": .go,
    "java": .java,
    "ruby": .ruby,
    "nginx": .nginx
]
```

### 4. Icon Resolution Flow
1. Check if GUI app -> use NSRunningApplication.icon
2. Match process name to known type -> use bundled icon
3. Fallback -> use generic process icon (SF Symbol)

### 5. Port Hints (Optional)
Use port number as hint when process name ambiguous:
- 3000, 5173, 4200 -> likely Node.js
- 8000, 5000, 8888 -> likely Python
- 5432 -> Postgres
- 6379 -> Redis

## Success Criteria
- [ ] Node.js processes show Node icon
- [ ] Python processes show Python icon
- [ ] Docker shows Docker whale
- [ ] Unknown processes show generic icon
- [ ] GUI apps show their actual icon

## Files Changed
- `Services/ProcessIconProvider.swift`
- `Models/ProcessType.swift`
- `Resources/Assets.xcassets/ProcessIcons/`
- `Features/PortList/PortRowView.swift` (update to use icons)

## Icon Sources (Free/MIT)
- [Simple Icons](https://simpleicons.org/) - Tech brand icons
- [Devicon](https://devicon.dev/) - Developer tool icons
- SF Symbols for generic fallbacks
