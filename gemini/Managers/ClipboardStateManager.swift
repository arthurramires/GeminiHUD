import AppKit
import Combine

final class ClipboardStateManager: ObservableObject {

    @Published var hasClipboardText: Bool = false

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int

    init() {
        self.lastChangeCount = pasteboard.changeCount
    }

    func checkForChanges() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            refresh()
        }
    }

    func refresh() {
        if let text = pasteboard.string(forType: .string),
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hasClipboardText = true
        } else {
            hasClipboardText = false
        }
    }

    func clear() {
        hasClipboardText = false
    }
}
