import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    let webViewManager = WebViewManager()
    let windowManager = WindowManager()
    let clipboardManager = ClipboardManager()

    var hotKeyManager: HotKeyManager?
    var menuBarManager: MenuBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        createMainWindow()

        hotKeyManager = HotKeyManager {
            self.windowManager.toggleVisibility()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // força atualização visual
                NotificationCenter.default.post(
                    name: Notification.Name("RefreshClipboardState"),
                    object: nil
                )
            }
        }


        menuBarManager = MenuBarManager(
            windowManager: windowManager,
            webViewManager: webViewManager,
            clipboardManager: clipboardManager
        )
    }

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
        window.title = "Gemini"
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        windowManager.setWindow(window)
    }
}
