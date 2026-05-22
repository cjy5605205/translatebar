import AppKit
import SwiftUI
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuBarController = MenuBarController()
    private let hotkeyManager = HotkeyManager()
    private var preferencesWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("[TranslateBar] App launched, bundle=\(Bundle.main.bundleIdentifier ?? "nil")")
        setupMainMenu()
        menuBarController.setup()

        hotkeyManager.onHotkeyPressed = { [weak self] in
            self?.handleTranslation()
        }
        hotkeyManager.register()

        let options: [String: Any] = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.unregister()
    }

    /// Set up NSApp.mainMenu so that Cmd+Q, Cmd+V, Cmd+C etc. work in all windows.
    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenu = NSMenu()
        let quitItem = NSMenuItem(
            title: "退出 TranslateBar",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenu.addItem(quitItem)

        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // Edit menu (enables Cmd+V, Cmd+C, Cmd+X, Cmd+A)
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(NSMenuItem(title: "剪切", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "复制", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "粘贴", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))

        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    func reregisterHotkey() {
        hotkeyManager.reregister()
    }

    private func handleTranslation() {
        menuBarController.setStatus(.translating)

        guard let text = TextAccessor.getFocusedText() else {
            menuBarController.setStatus(.failure)
            showNotification(title: "翻译失败", body: "无法读取当前输入框的内容")
            return
        }

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("[TranslateBar] Text empty after trim, skipping")
            menuBarController.setStatus(.skipped)
            return
        }

        Task {
            do {
                let result = try await TranslationEngine.translate(text)
                await MainActor.run {
                    if result == text {
                        print("[TranslateBar] Result unchanged, skipping (text=\(text.prefix(30)))")
                        menuBarController.setStatus(.skipped)
                    } else {
                        TextAccessor.replaceFocusedText(result)
                        menuBarController.setStatus(.success)
                    }
                }
            } catch {
                await MainActor.run {
                    menuBarController.setStatus(.failure)
                    let msg = "\(error)"
                    print("[TranslateBar] Translation failed: \(msg)")
                    showNotification(title: "翻译失败", body: msg)
                }
            }
        }
    }

    private func showNotification(title: String, body: String) {
        // UNUserNotificationCenter requires a proper .app bundle — fall back gracefully
        if Bundle.main.bundleIdentifier != nil {
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
        // If no bundle (e.g. running from SPM build dir), rely on status bar icon for feedback
    }

    @objc func showSettingsWindow(_ sender: Any?) {
        if preferencesWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 320),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "TranslateBar 偏好设置"
            window.contentView = NSHostingView(rootView: PreferencesView(appDelegate: self))
            window.center()
            preferencesWindow = window
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
