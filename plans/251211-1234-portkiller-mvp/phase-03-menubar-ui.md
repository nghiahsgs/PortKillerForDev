# Phase 03: Menu Bar UI

**Status:** Pending | **Priority:** High

## Context
Build the menu bar icon and popover UI using NSStatusItem + SwiftUI.

## Requirements
- Menu bar icon (SF Symbol: network or antenna.radiowaves.left.and.right)
- Popover with port list
- Kill button per port
- Refresh button
- Auto-dismiss on click outside

## Architecture

```swift
// Features/StatusBar/StatusBarController.swift
class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    func togglePopover()
}

// Features/PortList/PortListView.swift
struct PortListView: View {
    @State var processes: [ProcessInfo]
    func refresh()
    func killProcess(_ process: ProcessInfo)
}
```

## Implementation Steps

### 1. Create StatusBarController
- [ ] Initialize NSStatusItem with fixed width
- [ ] Set SF Symbol icon (template image)
- [ ] Create NSPopover with transient behavior
- [ ] Connect click action to toggle popover

### 2. Create PortListView
- [ ] Header with app name + refresh button
- [ ] ScrollView with List of ports
- [ ] Empty state when no ports found
- [ ] Each row: icon + process name + port + kill button

### 3. Create PortRowView
- [ ] Process icon (16x16)
- [ ] Process name (bold)
- [ ] Port number (monospace)
- [ ] Kill button (red, destructive)

### 4. UI Specs
```
┌─────────────────────────────┐
│ PortKiller        [Refresh] │
├─────────────────────────────┤
│ 🟢 node        :3000  [Kill]│
│ 🐍 python      :8000  [Kill]│
│ 🐘 postgres    :5432  [Kill]│
│ 🐳 docker      :8080  [Kill]│
├─────────────────────────────┤
│ 4 processes listening       │
└─────────────────────────────┘
Width: 300px, Height: dynamic (max 400px)
```

### 5. Wire Up AppDelegate
- [ ] Create popover with PortListView as content
- [ ] Pass popover to StatusBarController
- [ ] Handle click outside to dismiss

## Success Criteria
- [ ] Menu bar icon visible
- [ ] Click opens popover below icon
- [ ] Port list displays correctly
- [ ] Kill button terminates process
- [ ] Click outside dismisses popover

## Files Changed
- `Features/StatusBar/StatusBarController.swift`
- `Features/PortList/PortListView.swift`
- `Features/PortList/PortRowView.swift`
- `AppDelegate.swift`
