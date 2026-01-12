import SwiftUI
import Combine

struct ContentView: View {

    let webViewManager: WebViewManager
    let windowManager: WindowManager

    @StateObject private var clipboardState = ClipboardStateManager()

    private let clipboardTimer =
        Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {

            GeminiWebView(webView: webViewManager.webView)
                .onAppear {
                    webViewManager.loadGeminiIfNeeded()
                    clipboardState.refresh()
                }

            if clipboardState.hasClipboardText {
                ClipboardOverlayView {
                    clipboardState.clear()
                }
                .padding(.bottom, 20)
                .transition(.clipboardOverlay)
            }
        }
        .animation(
            .spring(response: 0.32, dampingFraction: 0.88),
            value: clipboardState.hasClipboardText
        )
        .onReceive(clipboardTimer) { _ in
            clipboardState.checkForChanges()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .geminiWindowDidBecomeVisible
            )
        ) { _ in
            clipboardState.refresh()
            webViewManager.focus()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .geminiRequestWebViewFocus
            )
        ) { _ in
            webViewManager.focus()
        }
    }
}
