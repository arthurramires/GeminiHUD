import AppKit
import Carbon

final class HotKeyManager {

    // MARK: - Types

    private final class HandlerBox {
        let handler: () -> Void
        init(_ handler: @escaping () -> Void) {
            self.handler = handler
        }
    }

    // MARK: - Properties

    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var handlers: [UInt32: HandlerBox] = [:]
    private var nextID: UInt32 = 1

    // MARK: - Init

    init() {
        installGlobalHandler()
    }

    deinit {
        unregisterAll()
    }

    // MARK: - Public API

    func register(
        keyCode: UInt32,
        modifiers: UInt32,
        handler: @escaping () -> Void
    ) {
        var hotKeyRef: EventHotKeyRef?

        let id = nextID
        nextID += 1

        let hotKeyID = EventHotKeyID(
            signature: OSType(UInt32(truncatingIfNeeded: "GEMI".hashValue)),
            id: id
        )

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else { return }

        handlers[id] = HandlerBox(handler)
        hotKeyRefs.append(hotKeyRef)
    }

    // MARK: - Private

    private func installGlobalHandler() {
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event else { return noErr }

                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                let manager = Unmanaged<HotKeyManager>
                    .fromOpaque(userData!)
                    .takeUnretainedValue()

                if let handlerBox = manager.handlers[hotKeyID.id] {
                    DispatchQueue.main.async {
                        handlerBox.handler()
                    }
                }

                return noErr
            },
            1,
            &eventSpec,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            nil
        )
    }

    private func unregisterAll() {
        for ref in hotKeyRefs {
            if let ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotKeyRefs.removeAll()
        handlers.removeAll()
    }
}
