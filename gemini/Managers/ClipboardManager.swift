import AppKit

final class ClipboardManager {

    func readText() -> String? {
        let pasteboard = NSPasteboard.general

        if let text = pasteboard.string(forType: .string),
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return text
        }

        return nil
    }
}
