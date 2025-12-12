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

    private init() {}

    /// Scan all listening TCP ports
    func scanAllPorts() async throws -> [ProcessInfo] {
        let output = try await runLsof(arguments: ["-iTCP", "-sTCP:LISTEN", "-n", "-P"])
        return parseLsofOutput(output)
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
}
