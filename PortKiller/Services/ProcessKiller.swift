import Foundation
import AppKit

enum ProcessKillerError: Error, LocalizedError {
    case processNotFound
    case permissionDenied
    case killFailed(String)

    var errorDescription: String? {
        switch self {
        case .processNotFound: return "Process not found"
        case .permissionDenied: return "Permission denied. Cannot kill system process."
        case .killFailed(let message): return "Failed to kill process: \(message)"
        }
    }
}

actor ProcessKiller {
    static let shared = ProcessKiller()

    private init() {}

    /// Kill a process by PID
    /// First tries SIGTERM (graceful), then SIGKILL (force) after delay
    func kill(pid: pid_t) async throws {
        // First try using NSRunningApplication for GUI apps
        if let app = NSRunningApplication(processIdentifier: pid) {
            if app.forceTerminate() {
                // Wait a moment and verify
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                if !isProcessRunning(pid: pid) {
                    return
                }
            }
        }

        // Fall back to Unix signals
        try await killWithSignal(pid: pid)
    }

    private func killWithSignal(pid: pid_t) async throws {
        // Send SIGTERM first (graceful shutdown)
        let termResult = Darwin.kill(pid, SIGTERM)
        let termErrno = Darwin.errno  // Capture errno immediately to avoid race condition

        if termResult != 0 {
            if termErrno == EPERM {
                throw ProcessKillerError.permissionDenied
            } else if termErrno == ESRCH {
                throw ProcessKillerError.processNotFound
            } else {
                throw ProcessKillerError.killFailed("SIGTERM failed with errno: \(termErrno)")
            }
        }

        // Wait 500ms for graceful shutdown
        try await Task.sleep(nanoseconds: 500_000_000)

        // Check if process is still running
        if isProcessRunning(pid: pid) {
            // Force kill with SIGKILL
            let killResult = Darwin.kill(pid, SIGKILL)
            let killErrno = Darwin.errno  // Capture errno immediately

            if killResult != 0 {
                if killErrno != ESRCH { // ESRCH means process already dead - that's OK
                    throw ProcessKillerError.killFailed("SIGKILL failed with errno: \(killErrno)")
                }
            }

            // Final verification
            try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            if isProcessRunning(pid: pid) {
                throw ProcessKillerError.killFailed("Process still running after SIGKILL")
            }
        }
    }

    private func isProcessRunning(pid: pid_t) -> Bool {
        // kill with signal 0 checks if process exists without killing it
        return Darwin.kill(pid, 0) == 0
    }

    /// Kill all processes on a specific port
    func killPort(_ port: Int) async throws {
        let processes = try await PortScanner.shared.scanPort(port)
        for process in processes {
            try await kill(pid: process.pid)
        }
    }

    /// Kill multiple processes
    func killAll(_ pids: [pid_t]) async throws {
        for pid in pids {
            try await kill(pid: pid)
        }
    }
}
