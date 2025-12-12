import AppKit
import SwiftUI

class ProcessIconProvider {
    static let shared = ProcessIconProvider()

    private var iconCache: [ProcessType: NSImage] = [:]

    private init() {
        preloadIcons()
    }

    private lazy var fallbackIcon: NSImage = {
        NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: "Process") ?? NSImage()
    }()

    private func preloadIcons() {
        // Preload all bundled icons into cache
        for type in ProcessType.allCases where type != .unknown {
            if let image = NSImage(named: type.iconName) {
                iconCache[type] = image
            } else {
                #if DEBUG
                print("⚠️ Missing icon asset: \(type.iconName)")
                #endif
                // Cache fallback to avoid repeated lookups
                iconCache[type] = fallbackIcon
            }
        }
    }

    /// Get icon for a process
    func getIcon(for process: ProcessInfo) -> NSImage {
        // 1. Try to get icon from running application (works for GUI apps)
        if let app = NSRunningApplication(processIdentifier: process.pid),
           let icon = app.icon {
            return icon
        }

        // 2. Try cached icon (includes fallback if asset was missing)
        if let cachedIcon = iconCache[process.processType] {
            return cachedIcon
        }

        // 3. Try to load bundled icon
        if let bundledIcon = NSImage(named: process.processType.iconName) {
            iconCache[process.processType] = bundledIcon
            return bundledIcon
        }

        // 4. Cache and return fallback
        if process.processType != .unknown {
            iconCache[process.processType] = fallbackIcon
        }
        return fallbackIcon
    }

    /// Get SwiftUI Image for a process
    func getSwiftUIIcon(for process: ProcessInfo) -> Image {
        // Try bundled icon first
        if process.processType != .unknown {
            return Image(process.processType.iconName)
        }

        // Fallback to SF Symbol
        return Image(systemName: "gearshape.fill")
    }
}

// MARK: - SwiftUI View Extension
struct ProcessIcon: View {
    let process: ProcessInfo
    let size: CGFloat

    init(process: ProcessInfo, size: CGFloat = 20) {
        self.process = process
        self.size = size
    }

    var body: some View {
        Group {
            if process.processType != .unknown {
                Image(process.processType.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}
