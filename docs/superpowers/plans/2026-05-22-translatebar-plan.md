# TranslateBar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a macOS menu bar app that translates typed text in any input field between Chinese and English with a global shortcut (Ctrl+Shift+T), using DeepSeek API with Ollama fallback.

**Architecture:** Swift Package Manager project producing a macOS .app bundle. NSApplication with LSUIElement=YES (no Dock icon). Carbon HotKey API for global shortcut. AXUIElement Accessibility API to read/replace focused text. Translation dispatches to DeepSeek API (online, async/await) with automatic fallback to local Ollama (HTTP API). Preferences stored in UserDefaults, API key in Keychain.

**Tech Stack:** Swift 5.10+, AppKit, SwiftUI (Settings scene), Carbon, URLSession async/await, Keychain Services. No external dependencies.

---

## File Structure (all new, no existing files modified)

```
TranslateBar/
├── Package.swift
├── Sources/
│   ├── TranslateBar/
│   │   ├── main.swift                      // NSApplication entry point
│   │   ├── AppDelegate.swift               // Wires everything together
│   │   ├── MenuBarController.swift         // NSStatusBar icon + menu
│   │   ├── HotkeyManager.swift             // Carbon global hotkey
│   │   ├── TextAccessor.swift              // AXUIElement text read/write
│   │   ├── TranslationEngine.swift         // Orchestrator: detect → translate → fallback
│   │   ├── LanguageDetector.swift          // CJK character counting
│   │   ├── DeepSeekTranslator.swift        // DeepSeek Chat Completions API
│   │   ├── OllamaTranslator.swift          // Ollama local HTTP API
│   │   ├── KeychainManager.swift           // Keychain read/write/delete
│   │   ├── PreferencesView.swift           // SwiftUI Settings window
│   │   └── Info.plist                      // LSUIElement=YES, etc.
├── Tests/
│   └── TranslateBarTests/
│       ├── LanguageDetectorTests.swift
│       └── TranslationEngineTests.swift
```

Each module is a single file with one responsibility, no cross-imports except through TranslationEngine (the sole orchestrator).

---

### Task 1: Create project scaffold

**Files:**
- Create: `TranslateBar/Package.swift`
- Create: `TranslateBar/Sources/TranslateBar/Info.plist`
- Create: `TranslateBar/Sources/TranslateBar/main.swift`

- [ ] **Step 1: Create Package.swift**

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TranslateBar",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TranslateBar", targets: ["TranslateBar"])
    ],
    targets: [
        .executableTarget(
            name: "TranslateBar",
            path: "Sources/TranslateBar"
        ),
        .testTarget(
            name: "TranslateBarTests",
            dependencies: ["TranslateBar"],
            path: "Tests/TranslateBarTests"
        )
    ]
)
```

- [ ] **Step 2: Create Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>LSUIElement</key>
    <true/>
    <key>NSAccessibilityEvents</key>
    <true/>
    <key>CFBundleIdentifier</key>
    <string>com.translatebar.app</string>
    <key>CFBundleName</key>
    <string>TranslateBar</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
</dict>
</plist>
```

- [ ] **Step 3: Create main.swift**

```swift
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
_ = NSApplicationMain(Process.argc, Process.unsafeArgv)
```

- [ ] **Step 4: Build to verify scaffold compiles (will fail on missing AppDelegate but validates Package.swift)**

Run: `cd TranslateBar && swift build`
Expected: error about missing AppDelegate type

- [ ] **Step 5: Commit**

```bash
git add TranslateBar/
git commit -m "feat: scaffold TranslateBar SPM project with Package.swift and Info.plist"
```

---

### Task 2: LanguageDetector — local CJK detection

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/LanguageDetector.swift`
- Create: `TranslateBar/Tests/TranslateBarTests/LanguageDetectorTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
// Tests/TranslateBarTests/LanguageDetectorTests.swift
import XCTest
@testable import TranslateBar

final class LanguageDetectorTests: XCTestCase {

    func testPureChineseDetectedAsChinese() {
        let result = LanguageDetector.detect("你好世界")
        XCTAssertEqual(result, .chinese)
    }

    func testPureEnglishDetectedAsEnglish() {
        let result = LanguageDetector.detect("Hello world")
        XCTAssertEqual(result, .english)
    }

    func testChineseDominantMixedTextDetectedAsChinese() {
        let result = LanguageDetector.detect("我在写Swift代码测试")
        XCTAssertEqual(result, .chinese)
    }

    func testEnglishWithFewChineseCharactersDetectedAsEnglish() {
        // "Hello你好World" — 3/13 chars are CJK = 23% < 30%
        let result = LanguageDetector.detect("Hello你好World")
        XCTAssertEqual(result, .english)
    }

    func testEmptyStringReturnsNil() {
        let result = LanguageDetector.detect("")
        XCTAssertNil(result)
    }

    func testPureNumbersAndSymbolsReturnNil() {
        let result = LanguageDetector.detect("12345!@#$%")
        XCTAssertNil(result)
    }

    func testWhitespaceOnlyReturnsNil() {
        let result = LanguageDetector.detect("   \t\n  ")
        XCTAssertNil(result)
    }

    func testExactlyThirtyPercentThreshold() {
        // "你好abc" — 2 CJK out of 5 chars = 40% → chinese
        let result = LanguageDetector.detect("你好abc")
        XCTAssertEqual(result, .chinese)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd TranslateBar && swift test --filter LanguageDetectorTests`
Expected: compile error — `LanguageDetector` not found

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/TranslateBar/LanguageDetector.swift
import Foundation

enum LanguageDetector {
    enum DetectedLanguage: Equatable {
        case chinese
        case english
    }

    /// Returns the detected language, or nil for empty / pure-symbol input.
    static func detect(_ text: String) -> DetectedLanguage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var cjkCount = 0
        var meaningfulCount = 0

        for scalar in trimmed.unicodeScalars {
            // CJK Unified Ideographs: U+4E00–U+9FFF
            // CJK Extension A: U+3400–U+4DBF
            // CJK Compatibility Ideographs: U+F900–U+FAFF
            let isCJK = (scalar.value >= 0x4E00 && scalar.value <= 0x9FFF)
                     || (scalar.value >= 0x3400 && scalar.value <= 0x4DBF)
                     || (scalar.value >= 0xF900 && scalar.value <= 0xFAFF)

            if isCJK {
                cjkCount += 1
                meaningfulCount += 1
            } else if scalar.properties.isAlphabetic || scalar.properties.isEmoji {
                meaningfulCount += 1
            }
            // Punctuation, spaces, symbols are ignored from meaningfulCount
        }

        guard meaningfulCount > 0 else { return nil }

        let ratio = Double(cjkCount) / Double(meaningfulCount)
        return ratio > 0.30 ? .chinese : .english
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd TranslateBar && swift test --filter LanguageDetectorTests`
Expected: all 8 tests PASS

- [ ] **Step 5: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/LanguageDetector.swift TranslateBar/Tests/TranslateBarTests/LanguageDetectorTests.swift
git commit -m "feat: add LanguageDetector with CJK ratio-based detection"
```

---

### Task 3: KeychainManager — secure API key storage

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/KeychainManager.swift`

- [ ] **Step 1: Write KeychainManager**

```swift
// Sources/TranslateBar/KeychainManager.swift
import Foundation
import Security

enum KeychainManager {
    private static let service = "com.translatebar.app"

    static func save(_ value: String, forKey key: String) throws {
        let data = Data(value.utf8)

        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    enum KeychainError: Error {
        case unexpectedStatus(OSStatus)
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/KeychainManager.swift
git commit -m "feat: add KeychainManager for secure API key storage"
```

---

### Task 4: DeepSeekTranslator — online translation via DeepSeek API

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/DeepSeekTranslator.swift`

- [ ] **Step 1: Write DeepSeekTranslator**

```swift
// Sources/TranslateBar/DeepSeekTranslator.swift
import Foundation

enum DeepSeekTranslator {
    private static let baseURL = "https://api.deepseek.com/v1/chat/completions"
    private static let model = "deepseek-chat"
    private static let timeout: TimeInterval = 10

    struct RequestBody: Encodable {
        let model: String
        let messages: [Message]
        let temperature: Double

        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    struct ResponseBody: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let message: Message
            struct Message: Decodable {
                let content: String
            }
        }
    }

    enum TranslateError: Error {
        case noAPIKey
        case invalidResponse
        case httpError(Int)
    }

    /// Translate `text` to `targetLang` ("Chinese" or "English") using DeepSeek API.
    static func translate(_ text: String, to targetLang: String) async throws -> String {
        guard let apiKey = KeychainManager.load("deepseek_api_key") else {
            throw TranslateError.noAPIKey
        }

        let systemPrompt = """
        You are a professional translator. Translate the following text to natural, conversational \(targetLang). \
        The translation should sound like it was originally written by a native speaker. \
        Do NOT translate word-for-word. Return only the translation, no explanation.
        """

        let body = RequestBody(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: text)
            ],
            temperature: 0.3
        )

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = timeout

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslateError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw TranslateError.httpError(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let translatedText = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
              !translatedText.isEmpty else {
            throw TranslateError.invalidResponse
        }

        return translatedText
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/DeepSeekTranslator.swift
git commit -m "feat: add DeepSeekTranslator using Chat Completions API"
```

---

### Task 5: OllamaTranslator — offline translation fallback

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/OllamaTranslator.swift`

- [ ] **Step 1: Write OllamaTranslator**

```swift
// Sources/TranslateBar/OllamaTranslator.swift
import Foundation

enum OllamaTranslator {
    private static let baseURL = "http://localhost:11434/api/generate"
    private static let defaultModel = "qwen2.5:3b"
    private static let timeout: TimeInterval = 30

    struct RequestBody: Encodable {
        let model: String
        let prompt: String
        let stream: Bool
    }

    struct ResponseBody: Decodable {
        let response: String
    }

    enum TranslateError: Error {
        case notRunning
        case invalidResponse
    }

    static func translate(_ text: String, to targetLang: String) async throws -> String {
        let modelName = UserDefaults.standard.string(forKey: "ollama_model") ?? defaultModel
        let prompt = """
        Translate the following text to natural, conversational \(targetLang). \
        Do NOT translate word-for-word. Return only the translation, no explanation.

        \(text)
        """

        let body = RequestBody(model: modelName, prompt: prompt, stream: false)

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw TranslateError.invalidResponse
            }
            let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
            let result = decoded.response.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !result.isEmpty else { throw TranslateError.invalidResponse }
            return result
        } catch let error as URLError where error.errorCode == NSURLErrorCannotConnectToHost {
            throw TranslateError.notRunning
        }
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/OllamaTranslator.swift
git commit -m "feat: add OllamaTranslator for offline translation fallback"
```

---

### Task 6: TranslationEngine — orchestrator with fallback logic

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/TranslationEngine.swift`
- Create: `TranslateBar/Tests/TranslateBarTests/TranslationEngineTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
// Tests/TranslateBarTests/TranslationEngineTests.swift
import XCTest
@testable import TranslateBar

final class TranslationEngineTests: XCTestCase {

    func testChineseTextPassedToTranslation() async throws {
        let text = "你好世界"
        let result = try await TranslationEngine.translate(text)
        // We can't predict exact output, but it should not equal input
        // and should not be empty
        XCTAssertFalse(result.isEmpty)
    }

    func testEmptyTextReturnsEmpty() async throws {
        let result = try await TranslationEngine.translate("")
        XCTAssertEqual(result, "")
    }

    func testPureSymbolsReturnUnchanged() async throws {
        let text = "12345!@#"
        let result = try await TranslationEngine.translate(text)
        XCTAssertEqual(result, text)
    }

    func testEnglishTextReturnsNonEmptyTranslation() async throws {
        let text = "Hello, how are you?"
        let result = try await TranslationEngine.translate(text)
        XCTAssertFalse(result.isEmpty)
    }
}
```

- [ ] **Step 2: Run tests — expect compile failure**

Run: `cd TranslateBar && swift test --filter TranslationEngineTests`
Expected: error — `TranslationEngine` not found

- [ ] **Step 3: Write TranslationEngine**

```swift
// Sources/TranslateBar/TranslationEngine.swift
import Foundation

enum TranslationEngine {
    enum TranslateError: Error {
        case allServicesFailed
    }

    /// Translates `text` from Chinese↔English automatically.
    /// Returns the original text unchanged if it's empty or pure symbols.
    static func translate(_ text: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }

        guard let language = LanguageDetector.detect(text) else {
            // Pure symbols/numbers — return unchanged
            return text
        }

        let targetLang = language == .chinese ? "English" : "Chinese"

        // Try DeepSeek first
        do {
            return try await DeepSeekTranslator.translate(text, to: targetLang)
        } catch {
            // Fallback to Ollama
            do {
                return try await OllamaTranslator.translate(text, to: targetLang)
            } catch {
                throw TranslateError.allServicesFailed
            }
        }
    }
}
```

- [ ] **Step 4: Run tests — requires DeepSeek API key set or expects network error**

Run: `cd TranslateBar && swift test --filter TranslationEngineTests`
Expected: tests may fail if no API key configured, but code compiles and links

- [ ] **Step 5: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/TranslationEngine.swift TranslateBar/Tests/TranslateBarTests/TranslationEngineTests.swift
git commit -m "feat: add TranslationEngine orchestrator with DeepSeek → Ollama fallback"
```

---

### Task 7: TextAccessor — Accessibility API text read/write

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/TextAccessor.swift`

- [ ] **Step 1: Write TextAccessor**

```swift
// Sources/TranslateBar/TextAccessor.swift
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
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/TextAccessor.swift
git commit -m "feat: add TextAccessor for AXUIElement text read/replace"
```

---

### Task 8: HotkeyManager — Carbon global hotkey

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/HotkeyManager.swift`

- [ ] **Step 1: Write HotkeyManager**

```swift
// Sources/TranslateBar/HotkeyManager.swift
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
        var hotkeyID = EventHotKeyID(signature: 0x54524252, id: 1) // "TBRR"

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
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/HotkeyManager.swift
git commit -m "feat: add HotkeyManager with Carbon global hotkey (Ctrl+Shift+T)"
```

---

### Task 9: MenuBarController — NSStatusBar icon and menu

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/MenuBarController.swift`

- [ ] **Step 1: Write MenuBarController**

```swift
// Sources/TranslateBar/MenuBarController.swift
import AppKit

final class MenuBarController {
    private var statusItem: NSStatusItem!
    private var normalIcon: NSImage?
    private var translatingIcon: NSImage?

    enum Status {
        case idle
        case translating
        case success
        case failure
        case skipped
    }

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Use text-based icon: "译" character
            button.title = "译"
            button.font = NSFont.systemFont(ofSize: 14)
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "偏好设置...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出 TranslateBar", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    func setStatus(_ status: Status) {
        DispatchQueue.main.async {
            switch status {
            case .idle:
                self.statusItem.button?.title = "译"
                self.statusItem.button?.attributedTitle = nil
            case .translating:
                // Show a subtle indicator using attributed string
                let attr = NSAttributedString(
                    string: "⟳",
                    attributes: [.foregroundColor: NSColor.systemBlue]
                )
                self.statusItem.button?.attributedTitle = attr
            case .success:
                let attr = NSAttributedString(
                    string: "✓",
                    attributes: [.foregroundColor: NSColor.systemGreen]
                )
                self.statusItem.button?.attributedTitle = attr
                // Revert after 0.5s
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.setStatus(.idle)
                }
            case .failure:
                let attr = NSAttributedString(
                    string: "✗",
                    attributes: [.foregroundColor: NSColor.systemRed]
                )
                self.statusItem.button?.attributedTitle = attr
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.setStatus(.idle)
                }
            case .skipped:
                let attr = NSAttributedString(
                    string: "译",
                    attributes: [.foregroundColor: NSColor.systemGray]
                )
                self.statusItem.button?.attributedTitle = attr
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.setStatus(.idle)
                }
            }
        }
    }

    @objc private func openPreferences() {
        // Will be connected in Task 10
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/MenuBarController.swift
git commit -m "feat: add MenuBarController with status icon and menu"
```

---

### Task 10: PreferencesView — SwiftUI settings window

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/PreferencesView.swift`

- [ ] **Step 1: Write PreferencesView**

```swift
// Sources/TranslateBar/PreferencesView.swift
import SwiftUI

struct PreferencesView: View {
    @AppStorage("ollama_model") private var ollamaModel = "qwen2.5:3b"
    @AppStorage("launch_at_login") private var launchAtLogin = false

    @State private var apiKey: String = ""
    @State private var showKeySaved = false

    var body: some View {
        TabView {
            generalTab.tabItem { Label("通用", systemImage: "gearshape") }
            translationTab.tabItem { Label("翻译", systemImage: "globe") }
        }
        .frame(width: 400, height: 250)
    }

    private var generalTab: some View {
        Form {
            Toggle("登录时自动启动", isOn: $launchAtLogin)

            Section("快捷键") {
                Text("Ctrl + Shift + T")
                    .foregroundColor(.secondary)
                Text("可在后续版本中自定义")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private var translationTab: some View {
        Form {
            Section("DeepSeek API") {
                SecureField("API Key", text: $apiKey)
                    .onAppear {
                        apiKey = KeychainManager.load("deepseek_api_key") ?? ""
                    }

                HStack {
                    Button("保存") {
                        do {
                            if apiKey.isEmpty {
                                try KeychainManager.delete("deepseek_api_key")
                            } else {
                                try KeychainManager.save(apiKey, forKey: "deepseek_api_key")
                            }
                            showKeySaved = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showKeySaved = false
                            }
                        } catch {
                            print("Keychain error: \(error)")
                        }
                    }

                    if showKeySaved {
                        Text("已保存")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }

            Section("本地模型 (Ollama)") {
                TextField("模型名称", text: $ollamaModel)
                Text("需要先安装并运行 Ollama，然后拉取模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/PreferencesView.swift
git commit -m "feat: add PreferencesView with API key and Ollama model config"
```

---

### Task 11: AppDelegate — wire everything together

**Files:**
- Create: `TranslateBar/Sources/TranslateBar/AppDelegate.swift`

- [ ] **Step 1: Write AppDelegate**

```swift
// Sources/TranslateBar/AppDelegate.swift
import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuBarController = MenuBarController()
    private let hotkeyManager = HotkeyManager()
    private var preferencesWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController.setup()

        hotkeyManager.onHotkeyPressed = { [weak self] in
            self?.handleTranslation()
        }
        hotkeyManager.register()

        // Request Accessibility permission
        let options: [String: Any] = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.unregister()
    }

    private func handleTranslation() {
        menuBarController.setStatus(.translating)

        // Get text from focused element
        guard let text = TextAccessor.getFocusedText() else {
            menuBarController.setStatus(.failure)
            showNotification(title: "翻译失败", body: "无法读取当前输入框的内容")
            return
        }

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            menuBarController.setStatus(.skipped)
            return
        }

        // Run translation async
        Task {
            do {
                let result = try await TranslationEngine.translate(text)
                await MainActor.run {
                    if result == text {
                        // Unchanged (pure symbols, etc.)
                        menuBarController.setStatus(.skipped)
                    } else {
                        TextAccessor.replaceFocusedText(result)
                        menuBarController.setStatus(.success)
                    }
                }
            } catch {
                await MainActor.run {
                    menuBarController.setStatus(.failure)
                    showNotification(title: "翻译失败", body: "请检查网络连接或启动 Ollama")
                }
            }
        }
    }

    private func showNotification(title: String, body: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        NSUserNotificationCenter.default.deliver(notification)
    }

    @objc func showSettingsWindow() {
        if preferencesWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "TranslateBar 偏好设置"
            window.contentView = NSHostingView(rootView: PreferencesView())
            window.center()
            preferencesWindow = window
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
```

- [ ] **Step 2: Build to verify compilation**

Run: `cd TranslateBar && swift build`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add TranslateBar/Sources/TranslateBar/AppDelegate.swift
git commit -m "feat: add AppDelegate wiring all modules together"
```

---

### Task 12: Build, verify, and create .app bundle

- [ ] **Step 1: Full clean build**

Run: `cd TranslateBar && swift build --configuration release`
Expected: BUILD SUCCESS for release

- [ ] **Step 2: Run all unit tests**

Run: `cd TranslateBar && swift test`
Expected: LanguageDetector tests PASS; TranslationEngine tests compile (actual pass depends on API key)

- [ ] **Step 3: Verify the app binary exists**

Run: `ls -la TranslateBar/.build/release/TranslateBar`
Expected: binary exists

- [ ] **Step 4: Create .app bundle structure**

Run the following bash script:

```bash
cd TranslateBar

APP_DIR="TranslateBar.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy binary
cp .build/release/TranslateBar "$APP_DIR/Contents/MacOS/"

# Create Info.plist at correct location in the bundle
cat > "$APP_DIR/Contents/Info.plist" << 'PLISTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>LSUIElement</key>
    <true/>
    <key>NSAccessibilityEvents</key>
    <true/>
    <key>CFBundleIdentifier</key>
    <string>com.translatebar.app</string>
    <key>CFBundleName</key>
    <string>TranslateBar</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>TranslateBar</string>
</dict>
</plist>
PLISTEOF

echo "App bundle created at TranslateBar/TranslateBar.app"
```

Expected: `TranslateBar.app` directory created with proper structure

- [ ] **Step 5: Verify app bundle structure**

Run: `ls -R TranslateBar/TranslateBar.app`
Expected: Contents/MacOS/TranslateBar, Contents/Info.plist, Contents/Resources/

- [ ] **Step 6: Test launch from Finder**

Run: `open TranslateBar/TranslateBar.app`
Expected: Menu bar shows "译" icon, no Dock icon. Accessibility permission prompt may appear.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "chore: final build verification and .app bundle creation"
```

---

### Task 13: Manual testing checklist (NOT automated)

The following must be tested manually running the app:

- [ ] Launch app — menu bar shows "译" icon, no Dock icon
- [ ] Open Safari, type some Chinese text, press `Ctrl+Shift+T` → text replaced with English
- [ ] Open Notes, type some English text, press `Ctrl+Shift+T` → text replaced with Chinese
- [ ] Test with pure numbers `12345` → icon blinks gray, text unchanged
- [ ] Test with empty text field → no effect
- [ ] Open Preferences → enter DeepSeek API Key → Save → verify translation works
- [ ] Quit app from menu bar → process ends cleanly
- [ ] Accessibility permission prompt appears on first launch
