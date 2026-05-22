import Foundation

enum TranslationEngine {
    enum TranslateError: Error, CustomStringConvertible {
        case allServicesFailed(deepSeekError: String, ollamaError: String)

        var description: String {
            switch self {
            case .allServicesFailed(let deepSeek, let ollama):
                return "DeepSeek: \(deepSeek)\nOllama: \(ollama)"
            }
        }
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
        let deepSeekError: String
        do {
            return try await DeepSeekTranslator.translate(text, to: targetLang)
        } catch {
            deepSeekError = error.localizedDescription
        }

        // Fallback to Ollama
        let ollamaError: String
        do {
            return try await OllamaTranslator.translate(text, to: targetLang)
        } catch {
            ollamaError = error.localizedDescription
        }

        throw TranslateError.allServicesFailed(deepSeekError: deepSeekError, ollamaError: ollamaError)
    }
}
