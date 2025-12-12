import SwiftUI

struct PortListView: View {
    @State private var processes: [ProcessInfo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var killingPid: pid_t?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Content
            if isLoading && processes.isEmpty {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if processes.isEmpty {
                emptyStateView
            } else {
                processListView
            }

            Divider()

            // Footer
            footerView
        }
        .frame(width: 320)
        .task {
            await refreshProcesses()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("PortKiller")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button(action: {
                Task { await refreshProcesses() }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Process List

    private var processListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(processes) { process in
                    PortRowView(
                        process: process,
                        isKilling: killingPid == process.pid,
                        onKill: { await killProcess(process) }
                    )

                    if process.id != processes.last?.id {
                        Divider()
                            .padding(.leading, 48)
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Scanning ports...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task { await refreshProcesses() }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.largeTitle)
                .foregroundStyle(.green)

            Text("No listening ports")
                .font(.headline)

            Text("All clear! No processes are listening on any ports.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Text("\(processes.count) process\(processes.count == 1 ? "" : "es")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    @MainActor
    private func refreshProcesses() async {
        isLoading = true
        errorMessage = nil

        do {
            processes = try await PortScanner.shared.scanAllPorts()
        } catch {
            errorMessage = "Failed to scan ports: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    private func killProcess(_ process: ProcessInfo) async {
        killingPid = process.pid

        do {
            try await ProcessKiller.shared.kill(pid: process.pid)
            // Remove from list with animation
            withAnimation(.easeOut(duration: 0.2)) {
                processes.removeAll { $0.id == process.id }
            }
        } catch {
            // Show error briefly
            errorMessage = "Failed to kill \(process.name): \(error.localizedDescription)"
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run { errorMessage = nil }
            }
        }

        killingPid = nil
    }
}

#Preview {
    PortListView()
        .frame(width: 320, height: 400)
}
