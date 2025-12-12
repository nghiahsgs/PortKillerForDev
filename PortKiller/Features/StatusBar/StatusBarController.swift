import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var eventMonitor: Any?

    init(popover: NSPopover) {
        self.popover = popover
        self.statusBar = NSStatusBar.system
        self.statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        setupStatusBarButton()
        setupPopoverCloseOnClickOutside()
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func setupStatusBarButton() {
        guard let button = statusItem.button else { return }

        // Use SF Symbol for menu bar icon
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        if let image = NSImage(systemSymbolName: "network", accessibilityDescription: "PortKiller") {
            let configuredImage = image.withSymbolConfiguration(config)
            configuredImage?.isTemplate = true
            button.image = configuredImage
        }

        button.action = #selector(togglePopover(_:))
        button.target = self
    }

    private func setupPopoverCloseOnClickOutside() {
        // Close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.popover.performClose(nil)
            }
        }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            guard let button = statusItem.button else { return }

            // Position popover below the status bar button
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Make popover the key window
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func showPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    func hidePopover() {
        popover.performClose(nil)
    }
}
