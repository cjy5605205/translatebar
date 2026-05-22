import AppKit

final class MenuBarController {
    private var statusItem: NSStatusItem!

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
            button.title = "译"
            button.font = NSFont.systemFont(ofSize: 14)
        }

        let menu = NSMenu()
        let prefItem = NSMenuItem(title: "偏好设置...", action: #selector(openPreferences), keyEquivalent: ",")
        prefItem.target = self
        menu.addItem(prefItem)
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "退出 TranslateBar", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    func setStatus(_ status: Status) {
        DispatchQueue.main.async {
            switch status {
            case .idle:
                self.statusItem.button?.title = "译"
                self.statusItem.button?.attributedTitle = NSAttributedString(string: "译")
            case .translating:
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
        NSApp.sendAction(#selector(AppDelegate.showSettingsWindow(_:)), to: nil, from: nil)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
