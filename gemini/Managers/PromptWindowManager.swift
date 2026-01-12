import AppKit
import SwiftUI

final class PromptWindowManager {

    // MARK: - Internal Types

    private final class InputPanel: NSPanel {
        override var canBecomeKey: Bool { true }
        override var canBecomeMain: Bool { true }
    }

    private var window: NSWindow?

    func show(onSubmit: @escaping (String) -> Void) {
        let view = PromptHUDView(
            onSubmit: { text in
                self.hide()
                onSubmit(text)
            },
            onDismiss: {
                self.hide()
            }
        ).id(UUID()) // Força a recriação da View e do State limpo

        let hosting = NSHostingView(rootView: view)

        if window == nil {
            let w = InputPanel(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 64),
                styleMask: [.borderless, .nonactivatingPanel], // Adicionado nonactivatingPanel por segurança
                backing: .buffered,
                defer: false
            )

            w.isOpaque = false
            w.backgroundColor = .clear
            w.level = .floating
            w.hasShadow = true
            w.collectionBehavior = [.transient, .canJoinAllSpaces, .fullScreenAuxiliary]
            w.contentView = hosting
            w.center()
            w.isReleasedWhenClosed = false

            window = w
        } else {
            window?.contentView = hosting
        }

        // Ordem crítica para evitar que a Main Window roube o foco ou apareça:
        // 1. Ativar o app primeiro
        NSApp.activate(ignoringOtherApps: true)
        
        // 2. Mostrar a janela do Prompt
        window?.makeKeyAndOrderFront(nil)
        
        // 3. Forçar status de Key Window explicitamente
        window?.makeKey()
    }

    func hide() {
        window?.orderOut(nil)
    }
}
