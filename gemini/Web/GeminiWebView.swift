import SwiftUI
import WebKit

struct GeminiWebView: NSViewRepresentable {

    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Nada aqui por enquanto
    }
}
