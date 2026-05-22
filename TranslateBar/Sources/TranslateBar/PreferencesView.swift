import SwiftUI
import AppKit

// Carbon modifier key constants
private let kControlKey: Int = 256
private let kShiftKey: Int   = 512
private let kCmdKey: Int     = 1024
private let kOptionKey: Int  = 2048

// MARK: - Shortcut capture view

struct ShortcutCaptureView: NSViewRepresentable {
    @Binding var isRecording: Bool
    var onCaptured: (Int, Int) -> Void

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField(labelWithString: "")
        field.alignment = .center
        field.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        return field
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = isRecording ? "按下快捷键..." : ""
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isRecording: $isRecording, onCaptured: onCaptured)
    }

    class Coordinator: NSResponder {
        var isRecording: Binding<Bool>
        var onCaptured: (Int, Int) -> Void
        private var monitor: Any?

        init(isRecording: Binding<Bool>, onCaptured: @escaping (Int, Int) -> Void) {
            self.isRecording = isRecording
            self.onCaptured = onCaptured
            super.init()
        }

        required init?(coder: NSCoder) { fatalError() }

        func startMonitoring() {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self = self, self.isRecording.wrappedValue else { return event }

                let keyCode = Int(event.keyCode)

                // Map NSEvent modifier flags to Carbon modifier flags
                var carbonModifiers: Int = 0
                if event.modifierFlags.contains(.control) { carbonModifiers |= kControlKey }
                if event.modifierFlags.contains(.shift)   { carbonModifiers |= kShiftKey }
                if event.modifierFlags.contains(.command) { carbonModifiers |= kCmdKey }
                if event.modifierFlags.contains(.option)  { carbonModifiers |= kOptionKey }

                UserDefaults.standard.set(keyCode, forKey: "hotkey_keyCode")
                UserDefaults.standard.set(carbonModifiers, forKey: "hotkey_modifiers")

                DispatchQueue.main.async {
                    self.isRecording.wrappedValue = false
                    self.onCaptured(keyCode, carbonModifiers)
                }
                return nil // consume the event
            }
        }

        func stopMonitoring() {
            if let m = monitor {
                NSEvent.removeMonitor(m)
                monitor = nil
            }
        }

        deinit { stopMonitoring() }
    }
}

// MARK: - Preferences view

struct PreferencesView: View {
    @AppStorage("ollama_model") private var ollamaModel = "qwen2.5:3b"
    @AppStorage("launch_at_login") private var launchAtLogin = false
    @AppStorage("hotkey_keyCode") private var hotkeyKeyCode = 17
    @AppStorage("hotkey_modifiers") private var hotkeyModifiers = kControlKey | kShiftKey

    @State private var apiKey: String = ""
    @State private var showKeySaved = false
    @State private var isRecording = false

    var appDelegate: AppDelegate?

    var body: some View {
        TabView {
            generalTab.tabItem { Label("通用", systemImage: "gearshape") }
            translationTab.tabItem { Label("翻译", systemImage: "globe") }
        }
        .frame(width: 420, height: 320)
    }

    // MARK: General tab

    private var generalTab: some View {
        Form {
            Toggle("登录时自动启动", isOn: $launchAtLogin)

            Section("快捷键") {
                HStack {
                    Text(HotkeyManager.currentHotkeyDisplayString())
                        .font(.title3.monospaced())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)

                    Button(isRecording ? "录制中..." : "录制") {
                        isRecording = true
                    }
                    .disabled(isRecording)
                }

                if isRecording {
                    ShortcutCaptureView(isRecording: $isRecording) { keyCode, modifiers in
                        appDelegate?.reregisterHotkey()
                    }
                    .frame(height: 30)
                }

                Text("录制后将立即生效")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    // MARK: Translation tab

    private var translationTab: some View {
        Form {
            Section("DeepSeek API") {
                TextField("API Key", text: $apiKey)
                    .textContentType(.password)
                    .onAppear {
                        apiKey = KeychainManager.load("deepseek_api_key") ?? ""
                    }

                HStack {
                    Button("保存") {
                        saveAPIKey()
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

    private func saveAPIKey() {
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
}
