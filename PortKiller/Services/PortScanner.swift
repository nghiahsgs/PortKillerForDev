import Foundation

enum PortScannerError: Error, LocalizedError {
    case lsofFailed(String)
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .lsofFailed(let message): return "Failed to scan ports: \(message)"
        case .parseError(let message): return "Failed to parse output: \(message)"
        }
    }
}

actor PortScanner {
    static let shared = PortScanner()

    /// System processes to hide (not useful for devs)
    private let systemProcessBlacklist: Set<String> = [
        "ControlCe",    // macOS Control Center
        "rapportd",     // AirDrop/Handoff
        "sharingd",     // macOS Sharing
        "WiFiAgent",    // WiFi
        "bluetoothd",   // Bluetooth
        "airportd",     // Airport
        "identityservicesd",
        "UserEventAgent",
        "mDNSResponder",
        "netbiosd",
    ]

    /// App helper processes (internal IPC, not useful)
    private let helperProcessPatterns: [String] = [
        "Code\\x20H",   // VS Code Helper
        "Electron",     // Electron helpers
        "Helper",       // Generic helpers
    ]

    private init() {}

    /// Scan all listening TCP ports
    func scanAllPorts() async throws -> [ProcessInfo] {
        let output = try await runLsof(arguments: ["-iTCP", "-sTCP:LISTEN", "-n", "-P"])
        var processes = parseLsofOutput(output)

        // Filter out system/helper processes
        processes = processes.filter { !isSystemProcess($0.name) }

        // Fetch additional details for each process (working directory)
        for i in processes.indices {
            let details = await getProcessDetails(pid: processes[i].pid)
            processes[i].workingDirectory = details.cwd
            processes[i].fullCommand = details.command
        }

        // Filter out processes running from root "/" (likely system)
        processes = processes.filter { process in
            // Keep if no cwd info (can't determine)
            guard let cwd = process.workingDirectory else { return true }
            // Keep if cwd is in user directory or common dev paths
            return cwd.hasPrefix("/Users/") ||
                   cwd.hasPrefix("/opt/") ||
                   cwd.hasPrefix("/usr/local/") ||
                   cwd.contains("homebrew")
        }

        return processes
    }

    /// Check if process is a system/helper process
    private func isSystemProcess(_ name: String) -> Bool {
        // Check blacklist
        if systemProcessBlacklist.contains(name) {
            return true
        }

        // Check helper patterns
        for pattern in helperProcessPatterns {
            if name.contains(pattern) || name.hasPrefix(pattern) {
                return true
            }
        }

        return false
    }

    /// Scan a specific port
    func scanPort(_ port: Int) async throws -> [ProcessInfo] {
        let output = try await runLsof(arguments: ["-i", ":\(port)", "-n", "-P"])
        return parseLsofOutput(output)
    }

    private func runLsof(arguments: [String]) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
            task.arguments = arguments

            let pipe = Pipe()
            let errorPipe = Pipe()
            task.standardOutput = pipe
            task.standardError = errorPipe

            do {
                try task.run()
            } catch {
                continuation.resume(throwing: PortScannerError.lsofFailed(error.localizedDescription))
                return
            }

            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            // lsof returns exit code 1 if no matching files found - that's OK
            if task.terminationStatus != 0 && task.terminationStatus != 1 {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                continuation.resume(throwing: PortScannerError.lsofFailed(errorOutput))
                return
            }

            continuation.resume(returning: output)
        }
    }

    private func parseLsofOutput(_ output: String) -> [ProcessInfo] {
        var processes: [ProcessInfo] = []
        var seenPorts = Set<Int>()

        let lines = output.components(separatedBy: "\n")

        // Skip header line
        for line in lines.dropFirst() {
            guard !line.isEmpty else { continue }

            // Split by whitespace, handling variable spacing
            let parts = line.split(whereSeparator: { $0.isWhitespace })
            guard parts.count >= 9 else { continue }

            let command = String(parts[0])
            guard let pid = Int32(parts[1]) else { continue }

            // NAME field is the last one, format: "*:PORT (LISTEN)" or "127.0.0.1:PORT"
            let nameField = String(parts[parts.count - 1])

            // Skip if not LISTEN state (should be filtered by lsof args, but double check)
            guard nameField.contains("LISTEN") || parts.count >= 10 else { continue }

            // Extract port from format like "*:3000" or "127.0.0.1:3000"
            let addressPart = String(parts[parts.count - 2])
            guard let port = extractPort(from: addressPart) else { continue }

            // Avoid duplicates (same port can appear multiple times for IPv4/IPv6)
            guard !seenPorts.contains(port) else { continue }
            seenPorts.insert(port)

            let processType = ProcessType(processName: command)
            let processInfo = ProcessInfo(
                pid: pid,
                name: command,
                port: port,
                command: command,
                processType: processType
            )
            processes.append(processInfo)
        }

        // Sort by port number
        return processes.sorted { $0.port < $1.port }
    }

    private func extractPort(from addressString: String) -> Int? {
        // Format: "*:3000" or "127.0.0.1:3000" or "[::1]:3000"
        let components = addressString.components(separatedBy: ":")
        guard let lastComponent = components.last else { return nil }

        // Remove any trailing text like "(LISTEN)"
        let portString = lastComponent.replacingOccurrences(of: "(LISTEN)", with: "").trimmingCharacters(in: .whitespaces)

        return Int(portString)
    }

    // MARK: - Process Details

    private func getProcessDetails(pid: pid_t) async -> (cwd: String?, command: String?) {
        async let cwd = getWorkingDirectory(pid: pid)
        async let cmd = getFullCommand(pid: pid)
        return await (cwd, cmd)
    }

    /// Get working directory of a process using lsof
    private func getWorkingDirectory(pid: pid_t) async -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        task.arguments = ["-p", "\(pid)"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            // Find line with "cwd" (current working directory)
            for line in output.components(separatedBy: "\n") {
                if line.contains(" cwd ") {
                    // Format: "node    12345 user  cwd    DIR  1,4  ... /path/to/dir"
                    let parts = line.split(whereSeparator: { $0.isWhitespace })
                    if let lastPart = parts.last {
                        return String(lastPart)
                    }
                }
            }
        } catch {
            // Silently fail - cwd is optional
        }

        return nil
    }

    /// Get full command line using ps
    private func getFullCommand(pid: pid_t) async -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-p", "\(pid)", "-o", "command="]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return output?.isEmpty == true ? nil : output
        } catch {
            return nil
        }
    }
}
