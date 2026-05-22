import AppKit
import ApplicationServices

enum TextAccessor {

    /// Returns the currently selected text in the focused UI element,
    /// or all text if nothing is selected.
    static func getFocusedText() -> String? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }

        let pid = app.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)

        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard result == .success, let element = focusedElement else { return nil }

        let axElement = element as! AXUIElement

        // Try selected text first
        var selectedText: CFTypeRef?
        let selectedResult = AXUIElementCopyAttributeValue(axElement, kAXSelectedTextAttribute as CFString, &selectedText)
        if selectedResult == .success,
           let text = selectedText as? String,
           !text.isEmpty {
            return text
        }

        // Fallback: try to get all text via kAXValueAttribute (works on AXTextField, AXTextArea)
        var allText: CFTypeRef?
        let valueResult = AXUIElementCopyAttributeValue(axElement, kAXValueAttribute as CFString, &allText)
        if valueResult == .success, let text = allText as? String, !text.isEmpty {
            return text
        }

        return nil
    }

    /// Replaces the entire content of the focused text element with `newText`.
    static func replaceFocusedText(_ newText: String) {
        guard let app = NSWorkspace.shared.frontmostApplication else { return }

        let pid = app.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)

        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard result == .success, let element = focusedElement else { return }

        let axElement = element as! AXUIElement

        // Set the full value of the text field
        AXUIElementSetAttributeValue(axElement, kAXValueAttribute as CFString, newText as CFTypeRef)
    }
}
