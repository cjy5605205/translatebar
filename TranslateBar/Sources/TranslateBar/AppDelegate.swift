import AppKit
import SwiftUI
import UserNotifications

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
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
        }
    }

    @objc func showSettingsWindow(_ sender: Any?) {
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
