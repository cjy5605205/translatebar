import Carbon
import AppKit

final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    var onHotkeyPressed: (() -> Void)?

    // Default: Ctrl+Shift+T
    private let defaultKeyCode: UInt32 = 17   // T
    private let defaultModifiers: UInt32 = UInt32(controlKey | shiftKey)

    func register() {
        let hotkeyID = EventHotKeyID(signature: 0x54524252, id: 1) // "TBRR"

        let status = RegisterEventHotKey(
            defaultKeyCode,
            defaultModifiers,
            hotkeyID,
            GetEventDispatcherTarget(),
            0,
            &hotkeyRef
        )

        guard status == noErr else {
            print("Failed to register hotkey: \(status)")
            return
        }

        // Install event handler
        let eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        let status2 = InstallEventHandler(
            GetEventDispatcherTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.onHotkeyPressed?()
                return noErr
            },
            1,
            [eventSpec],
            selfPtr,
            &eventHandler
        )

        if status2 != noErr {
            print("Failed to install event handler: \(status2)")
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
}
