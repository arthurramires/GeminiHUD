import AppKit
import WebKit

final class WebViewManager {

    let webView: WKWebView

    init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        webView = WKWebView(frame: .zero, configuration: config)
    }

    func loadGeminiIfNeeded() {
        guard webView.url == nil else { return }
        webView.load(URLRequest(url: URL(string: "https://gemini.google.com")!))
    }

    // MARK: - Real prompt submission (clipboard-based)

    func submitPromptViaClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        focus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Cmd+V
            let paste = NSEvent.keyEvent(
                with: .keyDown,
                location: .zero,
                modifierFlags: [.command],
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                characters: "v",
                charactersIgnoringModifiers: "v",
                isARepeat: false,
                keyCode: 9 // V
            )

            NSApp.postEvent(paste!, atStart: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                // Enter
                let enter = NSEvent.keyEvent(
                    with: .keyDown,
                    location: .zero,
                    modifierFlags: [.command], // Cmd+Enter força o envio
                    timestamp: 0,
                    windowNumber: 0,
                    context: nil,
                    characters: "\r",
                    charactersIgnoringModifiers: "\r",
                    isARepeat: false,
                    keyCode: 36
                )
                NSApp.postEvent(enter!, atStart: false)
            }
        }
    }

    func focus() {
        guard let window = webView.window else { return }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(webView)
    }
}
