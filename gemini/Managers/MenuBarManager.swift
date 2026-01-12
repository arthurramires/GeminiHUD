import AppKit

final class MenuBarManager {

    private let statusItem: NSStatusItem
    private let windowManager: WindowManager
    private let webViewManager: WebViewManager
    private let clipboardManager: ClipboardManager
    private let promptWindowManager: PromptWindowManager

    init(
        windowManager: WindowManager,
        webViewManager: WebViewManager,
        clipboardManager: ClipboardManager,
        promptWindowManager: PromptWindowManager
    ) {
        self.windowManager = windowManager
        self.webViewManager = webViewManager
        self.clipboardManager = clipboardManager
        self.promptWindowManager = promptWindowManager

        self.statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        configureStatusItem()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "sparkles",
                accessibilityDescription: "Gemini HUD"
            )
        }

        let menu = NSMenu()

        let newPromptItem = NSMenuItem(
            title: "New Prompt",
            action: #selector(showPrompt),
            keyEquivalent: "p"
        )

        let quitItem = NSMenuItem(
            title: "Quit Gemini HUD",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )

        newPromptItem.target = self
        quitItem.target = self

        menu.addItem(newPromptItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func showPrompt() {
        promptWindowManager.show { [weak self] prompt in
            guard let self = self else { return }

            self.windowManager.showWindowIfNeeded()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.webViewManager.focus()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.webViewManager.submitPromptViaClipboard(prompt)
                }
            }
        }
    }



    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
