import AppKit

final class FocusableWindow: NSWindow {

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
