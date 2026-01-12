import AppKit
import SwiftUI
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Managers

    let webViewManager = WebViewManager()
    let windowManager = WindowManager()
    let clipboardManager = ClipboardManager()
    let promptWindowManager = PromptWindowManager()

    var hotKeyManager: HotKeyManager?
    var menuBarManager: MenuBarManager?

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        createMainWindow()

        hotKeyManager = HotKeyManager()

        // ⌥ + G → Toggle Gemini window
        hotKeyManager?.register(
            keyCode: UInt32(kVK_ANSI_G),
            modifiers: UInt32(optionKey),
            handler: { [weak self] in
                guard let self = self else { return }

                self.windowManager.toggleVisibility()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(
                        name: .geminiWindowDidBecomeVisible,
                        object: nil
                    )
                }
            }
        )

        // ⌥ + ⇧ + G → Open Prompt HUD
        hotKeyManager?.register(
            keyCode: UInt32(kVK_ANSI_G),
            modifiers: UInt32(optionKey | shiftKey),
            handler: { [weak self] in
                guard let self = self else { return }

                self.promptWindowManager.show { [weak self] prompt in
                    guard let self = self else { return }

                    // 1. Garantir que a janela principal esteja visível
                    self.windowManager.showWindowIfNeeded()

                    // 2. Aguardar ativação/foco
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.webViewManager.submitPromptViaClipboard(prompt)
                    }
                }
            }
        )

        // Menu bar
        menuBarManager = MenuBarManager(
            windowManager: windowManager,
            webViewManager: webViewManager,
            clipboardManager: clipboardManager,
            promptWindowManager: promptWindowManager
        )
    }

    // MARK: - Main Window

    private func createMainWindow() {
        let contentView = ContentView(
            webViewManager: webViewManager,
            windowManager: windowManager
        )

        let hostingView = NSHostingView(rootView: contentView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.center()
        window.title = "Gemini HUD"
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        windowManager.setWindow(window)
    }
}
