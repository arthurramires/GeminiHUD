import AppKit

// MARK: - Notifications

extension Notification.Name {
    static let windowDidBecomeVisible =
        Notification.Name("windowDidBecomeVisible")
}

// MARK: - WindowManager

final class WindowManager: NSObject, NSWindowDelegate {

    private var window: NSWindow?
    private let stateKey = "GeminiWindowState"

    // MARK: - Public

    func setWindow(_ window: NSWindow) {
        self.window = window
        window.delegate = self

        restoreStateIfNeeded()
    }

    func toggleVisibility() {
        guard let window else { return }

        if window.isVisible {
            window.orderOut(nil)
            saveState()
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)

            NotificationCenter.default.post(
                name: .geminiWindowDidBecomeVisible,
                object: nil
            )

            saveState()
        }
    }

    func showWindowIfNeeded() {
        guard let window else { return }

        if !window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)

            NotificationCenter.default.post(
                name: .geminiWindowDidBecomeVisible,
                object: nil
            )

            saveState()
        }
    }

    func hideWindowIfNeeded() {
        guard let window else { return }

        if window.isVisible {
            window.orderOut(nil)
            saveState()
        }
    }

    func setFloating(_ enabled: Bool) {
        guard let window else { return }

        window.level = enabled ? .floating : .normal
        window.collectionBehavior = enabled
            ? [.canJoinAllSpaces, .fullScreenAuxiliary]
            : []

        saveState()
    }

    func toggleFloating() {
        guard let window else { return }
        setFloating(window.level != .floating)
    }

    // MARK: - Persistence

    private func saveState() {
        guard let window else { return }

        let frame = window.frame
        let state = WindowState(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.size.width,
            height: frame.size.height,
            isVisible: window.isVisible,
            isFloating: window.level == .floating
        )

        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: stateKey)
        }
    }

    private func restoreStateIfNeeded() {
        guard
            let data = UserDefaults.standard.data(forKey: stateKey),
            let state = try? JSONDecoder().decode(WindowState.self, from: data),
            let window
        else { return }

        let frame = NSRect(
            x: state.x,
            y: state.y,
            width: state.width,
            height: state.height
        )

        window.setFrame(frame, display: true)

        if state.isFloating {
            setFloating(true)
        }

        if state.isVisible {
            window.makeKeyAndOrderFront(nil)
        } else {
            window.orderOut(nil)
        }
    }

    // MARK: - NSWindowDelegate

    func windowDidMove(_ notification: Notification) {
        saveState()
    }

    func windowDidResize(_ notification: Notification) {
        saveState()
    }

    func windowWillClose(_ notification: Notification) {
        saveState()
    }
}
