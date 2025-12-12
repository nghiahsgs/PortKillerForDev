import SwiftUI

struct PortRowView: View {
    let process: ProcessInfo
    let isKilling: Bool
    let onKill: () async -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            // Process icon
            ProcessIcon(process: process, size: 24)

            // Process info
            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.system(.body, design: .default, weight: .medium))
                    .lineLimit(1)

                Text(process.processType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Port number
            Text(":\(process.port)")
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)

            // Kill button
            Button(action: {
                Task { await onKill() }
            }) {
                if isKilling {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(isHovering ? .red : .secondary)
                }
            }
            .buttonStyle(.plain)
            .disabled(isKilling)
            .help("Kill process (PID: \(process.pid))")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .background(isHovering ? Color.primary.opacity(0.05) : Color.clear)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        PortRowView(
            process: ProcessInfo(
                pid: 1234,
                name: "node",
                port: 3000,
                command: "node",
                processType: .nodejs
            ),
            isKilling: false,
            onKill: {}
        )

        Divider()

        PortRowView(
            process: ProcessInfo(
                pid: 5678,
                name: "python3",
                port: 8000,
                command: "python3",
                processType: .python
            ),
            isKilling: true,
            onKill: {}
        )

        Divider()

        PortRowView(
            process: ProcessInfo(
                pid: 9012,
                name: "postgres",
                port: 5432,
                command: "postgres",
                processType: .postgres
            ),
            isKilling: false,
            onKill: {}
        )
    }
    .frame(width: 320)
}
