# Phase 02: Core Port Detection

**Status:** Pending | **Priority:** High

## Context
Implement port scanning using `lsof` to detect listening processes.

## Requirements
- List all TCP ports with LISTEN state
- Get PID, process name, port number
- Parse lsof output reliably
- Handle errors gracefully

## Architecture

```swift
// Models/ProcessInfo.swift
struct ProcessInfo: Identifiable {
    let id = UUID()
    let pid: pid_t
    let name: String
    let port: Int
    let command: String
}

// Services/PortScanner.swift
class PortScanner {
    func scanAllPorts() async throws -> [ProcessInfo]
    func scanPort(_ port: Int) async throws -> ProcessInfo?
}
```

## Implementation Steps

### 1. Create ProcessInfo Model
- [ ] Define ProcessInfo struct with pid, name, port, command
- [ ] Make it Identifiable for SwiftUI List

### 2. Create PortScanner Service
- [ ] Implement `lsof -iTCP -sTCP:LISTEN -n -P` command
- [ ] Parse output line by line
- [ ] Extract PID, NAME, PORT from each line
- [ ] Return array of ProcessInfo

### 3. lsof Output Format
```
COMMAND   PID   USER   FD   TYPE   DEVICE   SIZE/OFF   NODE   NAME
node     1234  user   23u  IPv4   0x1234   0t0        TCP    *:3000 (LISTEN)
```

### 4. Parsing Logic
```swift
func parseLsofOutput(_ output: String) -> [ProcessInfo] {
    let lines = output.split(separator: "\n").dropFirst() // Skip header
    return lines.compactMap { line in
        let parts = line.split(whereSeparator: \.isWhitespace)
        guard parts.count >= 9 else { return nil }
        let command = String(parts[0])
        let pid = Int32(parts[1]) ?? 0
        // Extract port from "*:3000" format
        let portString = String(parts[8])
        let port = extractPort(from: portString)
        return ProcessInfo(pid: pid, name: command, port: port, command: command)
    }
}
```

### 5. Create ProcessKiller Service
- [ ] Implement kill function using SIGTERM then SIGKILL
- [ ] Handle permission errors
- [ ] Return success/failure status

## Success Criteria
- [ ] Can list all listening ports
- [ ] Correct PID and process name extracted
- [ ] Kill process works for user-owned processes

## Files Changed
- `Models/ProcessInfo.swift`
- `Services/PortScanner.swift`
- `Services/ProcessKiller.swift`
