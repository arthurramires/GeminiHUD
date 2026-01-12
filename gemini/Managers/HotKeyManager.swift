import AppKit
import Carbon

final class HotKeyManager {

    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(
        signature: OSType(UInt32(truncatingIfNeeded: "GEMI".hashValue)),
        id: 1
    )

    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
        registerHotKey()
        installHandler()
    }

    deinit {
        unregisterHotKey()
    }

    // MARK: - Registration

    private func registerHotKey() {
        let keyCode = UInt32(kVK_ANSI_G)
        let modifiers = UInt32(optionKey)

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }


    private func unregisterHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }

    // MARK: - Event handling

    private func installHandler() {
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                let manager = Unmanaged<HotKeyManager>
                    .fromOpaque(userData!)
                    .takeUnretainedValue()

                DispatchQueue.main.async {
                    manager.handler()
                }

                return noErr
            },
            1,
            &eventSpec,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            nil
        )
    }
}
