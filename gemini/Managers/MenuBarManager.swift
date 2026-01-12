import AppKit

final class MenuBarManager {

    private let statusItem: NSStatusItem
    private let windowManager: WindowManager
    private let webViewManager: WebViewManager
    private let clipboardManager: ClipboardManager

    init(
        windowManager: WindowManager,
        webViewManager: WebViewManager,
        clipboardManager: ClipboardManager
    ) {
        self.windowManager = windowManager
        self.webViewManager = webViewManager
        self.clipboardManager = clipboardManager

        self.statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        configureStatusItem()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "sparkles",
                accessibilityDescription: "Gemini"
            )
        }

        let menu = NSMenu()

        let toggleWindowItem = NSMenuItem(
            title: "Show / Hide Gemini",
            action: #selector(toggleWindow),
            keyEquivalent: ""
        )

        let toggleFloatingItem = NSMenuItem(
            title: "Toggle Floating",
            action: #selector(toggleFloating),
            keyEquivalent: ""
        )

        let sendClipboardItem = NSMenuItem(
            title: "Send Clipboard to Gemini",
            action: #selector(sendClipboard),
            keyEquivalent: ""
        )

        let quitItem = NSMenuItem(
            title: "Quit Gemini",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )

        toggleWindowItem.target = self
        toggleFloatingItem.target = self
        sendClipboardItem.target = self
        quitItem.target = self

        menu.addItem(toggleWindowItem)
        menu.addItem(toggleFloatingItem)
        menu.addItem(sendClipboardItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Actions

    @objc private func toggleWindow() {
        windowManager.toggleVisibility()
    }

    @objc private func toggleFloating() {
        windowManager.toggleFloating()
    }

    @objc private func sendClipboard() {
        guard let text = clipboardManager.readText() else { return }

        // 1. Garanta que a janela esteja visível
        windowManager.showWindowIfNeeded()

        // 2. Aguarde o WebView estar ativo no ciclo de UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.webViewManager.injectTextIntoGemini(text)
        }
    }


    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
