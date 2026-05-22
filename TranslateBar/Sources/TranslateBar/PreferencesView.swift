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
