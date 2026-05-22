# TranslateBar — Mac 输入法增强翻译工具

## 概述

一款 macOS 菜单栏常驻工具。用户在任何 App 的文本输入框中输入文字后，按快捷键（默认 `Ctrl+Shift+T`），自动将输入的中文翻译为英文、或将英文翻译为中文，并用翻译结果替换原文本。

## 核心功能

1. **一键翻译替换** — 按快捷键读取当前焦点输入框的内容，翻译后替换回原输入框
2. **自动语言检测** — 统计 CJK 汉字占比，>30% 视为中文→英文，否则英文→中文
3. **混合翻译引擎** — 主用 DeepL API，网络不可用时降级到 Ollama 本地模型
4. **菜单栏常驻** — 仅菜单栏图标，无 Dock 图标，内存占用极低
5. **翻译质量** — 要求翻译自然、地道，符合日常表达习惯，不死板直译

## 架构

```
macOS 系统（任意 App 文本框）
      │
      │  AXUIElement (Accessibility API)
      ▼
┌──────────────────────────────────┐
│       TranslateBar.app           │
│                                  │
│   MenuBarController              │
│   ├─ 状态栏图标 (翻译中/成功/失败) │
│   └─ 菜单 (偏好设置/退出)         │
│                                  │
│   HotkeyManager                  │
│   └─ CGEvent 全局快捷键监听       │
│                                  │
│   TextAccessor                   │
│   ├─ 获取焦点元素                 │
│   ├─ 读取/选中文本                │
│   └─ 替换文本                     │
│                                  │
│   TranslationEngine              │
│   ├─ LanguageDetector (本地判断)  │
│   ├─ DeepLTranslator (在线)      │
│   └─ OllamaTranslator (离线降级)  │
│                                  │
│   Preferences (UserDefaults)     │
│   ├─ API Key (Keychain 存储)    │
│   ├─ 自定义快捷键                 │
│   └─ 本地模型配置                  │
└──────────────────────────────────┘
```

## 模块设计

### 1. MenuBarController
- 菜单栏图标：默认 🀄 或自定义 icon
- 状态变化：翻译中的加载动画、成功短暂变色、失败红色闪烁
- 菜单项：偏好设置、检查更新、退出

### 2. HotkeyManager
- 基于 Carbon `RegisterEventHotKey` 注册系统级快捷键
- 默认 `Ctrl+Shift+T`，可在偏好设置中重新录制
- 仅在有焦点文本框时触发翻译，否则忽略

### 3. TextAccessor
- 使用 `AXUIElementCopyAttributeValue` 获取 `kAXFocusedUIElementAttribute`
- 优先读取 `kAXSelectedTextAttribute`，为空则全选 (`Cmd+A` → 读取)
- 翻译完成后通过 `AXUIElementSetAttributeValue` 写入译文
- 无焦点元素时静默忽略

### 4. TranslationEngine

**语言检测 (LanguageDetector)**
- 纯本地算法，零延迟
- 统计输入字符串中 Unicode CJK Unified Ideographs (U+4E00–U+9FFF) 占比
- 汉字占比 >30% → 中译英；否则 → 英译中
- 纯数字/符号 → 直接返回原文，不调用翻译

**在线翻译 (DeepLTranslator)**
- 调用 DeepL API v2 `/translate` 端点
- API Key 存储在 macOS Keychain
- 免费版额度：50 万字符/月
- 超时 5 秒，超时或网络错误自动降级到本地模型
- Prompt 引导（如 target_lang 参数）保证翻译自然流畅

**本地翻译 (OllamaTranslator)**
- 通过 Ollama 本地 HTTP API (http://localhost:11434) 调用
- 使用 qwen2.5:3b 模型（约 2GB，中英双语能力强）
- Prompt 模板：`"Translate the following text to natural, conversational ${targetLang}. Do NOT translate word-for-word. Return only the translation, no explanation.\n\n${text}"`
- 如 Ollama 未运行，显示错误通知

### 5. Preferences
- 窗口使用 SwiftUI `Settings` 场景
- 快捷键录制控件
- DeepL API Key 输入框（写入 Keychain）
- 本地模型名称配置（默认 qwen2.5:3b）
- 开机启动选项（Login Item）

## 数据流

```
([1] 用户按快捷键)
       │
HotkeyManager ──▶ TextAccessor ──▶ 获取焦点文本框 & 选中/全部文本
       │                                    │
       │                                    ▼
       │                            LanguageDetector (统计 CJK 占比)
       │                                    │
       │                         ┌──────────┴──────────┐
       │                         ▼                      ▼
       │                   中文→英文              英文→中文
       │                         │                      │
       │                         └──────────┬───────────┘
       │                                    ▼
       │                            DeepLTranslator (在线)
       │                              │         │
       │                          成功 │        │ 失败/超时
       │                              ▼         ▼
       │                         译文返回    OllamaTranslator
       │                              │         │
       │                              └────┬────┘
       │                                   ▼
       └─────────────────────────── TextAccessor ──────▶ 替换文本框原文
                                          │
                                          ▼
                                  MenuBarController
                                  (图标闪烁/通知反馈)
```

## 错误处理

| 场景 | 处理 |
|------|------|
| 无焦点文本框 | 静默忽略，不提示 |
| 选中文本为空 | 尝试模拟 Cmd+A 全选后再读取 |
| DeepL API 超时/错误 | 自动降级到 Ollama 本地模型 |
| Ollama 不可用 | 系统通知 "翻译失败：请检查网络或启动 Ollama" |
| 翻译结果与原文相同 | 仍替换（可能是专有名词，用户无感） |
| 纯数字/标点符号 | 不翻译，菜单栏图标闪烁 0.3 秒提示 |

## 技术选型

| 层级 | 技术 |
|------|------|
| 语言 | Swift 5.10+ |
| UI 框架 | SwiftUI (Settings) + AppKit (MenuBar) |
| 系统交互 | Carbon HotKey API, Accessibility API (AXUIElement) |
| 网络 | URLSession (async/await) |
| 安全存储 | Keychain Services |
| 包管理 | Swift Package Manager |
| 最低系统 | macOS 14.0 (Sonoma) |
| 打包分发 | .app bundle，DMG 分发，可选 Homebrew Cask |

## 文件结构

```
TranslateBar/
├── Sources/
│   ├── App/
│   │   ├── TranslateBarApp.swift        // @main 入口
│   │   └── AppDelegate.swift            // NSApplicationDelegate
│   ├── MenuBar/
│   │   └── MenuBarController.swift      // 菜单栏图标与菜单
│   ├── Hotkey/
│   │   └── HotkeyManager.swift          // 全局快捷键注册与监听
│   ├── TextAccess/
│   │   └── TextAccessor.swift           // Accessibility 文本读写
│   ├── Translation/
│   │   ├── TranslationEngine.swift      // 翻译调度（主入口）
│   │   ├── LanguageDetector.swift       // 本地语言检测
│   │   ├── DeepLTranslator.swift        // DeepL API 翻译
│   │   └── OllamaTranslator.swift       // 本地 Ollama 翻译
│   ├── Preferences/
│   │   └── PreferencesView.swift        // SwiftUI 设置界面
│   └── Utilities/
│       ├── KeychainManager.swift        // Keychain 读写
│       └── Extensions.swift             // String/Codable 扩展
├── Resources/
│   ├── Assets.xcassets                  // App 图标
│   └── Info.plist
└── Package.swift
```

## 测试策略

- **单元测试**：LanguageDetector 各种输入（纯中文、纯英文、混合、边界值）
- **集成测试**：TranslationEngine 翻译调度流程（Mock API）
- **手动测试**：在 Safari / Notes / VS Code / 微信 中实测文本替换
- **不测试**: UI 渲染、系统级 Accessibility 交互（需手动验证）
