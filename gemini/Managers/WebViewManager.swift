import AppKit
import WebKit

final class WebViewManager {

    let webView: WKWebView

    init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()

        self.webView = WKWebView(
            frame: .zero,
            configuration: config
        )

        self.webView.allowsBackForwardNavigationGestures = true
    }

    func loadGeminiIfNeeded() {
        guard webView.url == nil else { return }
        let url = URL(string: "https://gemini.google.com")!
        webView.load(URLRequest(url: url))
    }

    func injectTextIntoGemini(_ text: String) {
        let escapedText = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")

        let js = """
        (function() {
            const textarea = document.querySelector('textarea');
            if (!textarea) return;

            textarea.focus();
            textarea.value = "\(escapedText)";
            textarea.dispatchEvent(new Event('input', { bubbles: true }));
        })();
        """

        webView.evaluateJavaScript(js)
    }

    /// 🔑 Foco correto para permitir Paste fora do Xcode
    func focus() {
        guard let window = webView.window else { return }

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(webView)
    }
}
