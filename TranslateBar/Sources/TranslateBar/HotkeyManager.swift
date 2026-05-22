import Carbon
import AppKit

final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    var onHotkeyPressed: (() -> Void)?

    init() {
        let hasCustomShortcut = UserDefaults.standard.bool(forKey: "hotkey_customized")
        if !hasCustomShortcut {
            UserDefaults.standard.set(17, forKey: "hotkey_keyCode")                         // T
            UserDefaults.standard.set(Int(cmdKey | optionKey | shiftKey), forKey: "hotkey_modifiers") // ⌘⌥⇧T
        }
    }

    func register() {
        let keyCode = UInt32(UserDefaults.standard.integer(forKey: "hotkey_keyCode"))
        let modifiers = UInt32(UserDefaults.standard.integer(forKey: "hotkey_modifiers"))

        let hotkeyID = EventHotKeyID(signature: 0x54524252, id: 1)

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotkeyID,
            GetEventDispatcherTarget(),
            0,
            &hotkeyRef
        )

        guard status == noErr else {
            print("Failed to register hotkey: \(status)")
            return
        }

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

    func reregister() {
        unregister()
        register()
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

    /// Returns a human-readable string for the current hotkey, e.g. "⌃⇧T"
    static func currentHotkeyDisplayString() -> String {
        let keyCode = UInt32(UserDefaults.standard.integer(forKey: "hotkey_keyCode"))
        let modifiers = UInt32(UserDefaults.standard.integer(forKey: "hotkey_modifiers"))

        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(shiftKey) != 0   { parts.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0     { parts.append("⌘") }
        if modifiers & UInt32(optionKey) != 0  { parts.append("⌥") }

        parts.append(keyCodeToChar(keyCode))
        return parts.joined()
    }

    private static func keyCodeToChar(_ keyCode: UInt32) -> String {
        switch keyCode {
        case 0: return "A"; case 1: return "S"; case 2: return "D"; case 3: return "F"
        case 4: return "H"; case 5: return "G"; case 6: return "Z"; case 7: return "X"
        case 8: return "C"; case 9: return "V"; case 11: return "B"
        case 12: return "Q"; case 13: return "W"; case 14: return "E"; case 15: return "R"
        case 16: return "Y"; case 17: return "T"
        case 31: return "O"; case 32: return "U"; case 34: return "I"; case 35: return "P"
        case 37: return "L"; case 38: return "J"; case 40: return "K"
        case 45: return "N"; case 46: return "M"
        case 49: return "Space"
        case 36: return "↩"
        case 48: return "⇥"
        case 51: return "⌫"
        case 53: return "⎋"
        case 122: return "F1"; case 120: return "F2"
        case 123: return "←"; case 124: return "→"; case 125: return "↓"; case 126: return "↑"
        default: return "[\(keyCode)]"
        }
    }
}
