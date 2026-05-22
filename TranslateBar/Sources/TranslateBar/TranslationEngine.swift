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
