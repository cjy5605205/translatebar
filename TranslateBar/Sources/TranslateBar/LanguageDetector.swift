import Foundation

enum LanguageDetector {
    enum DetectedLanguage: Equatable {
        case chinese
        case english
    }

    private static func isEnglishAlphabetic(_ scalar: UnicodeScalar) -> Bool {
        // A–Z (0x41–0x5A) and a–z (0x61–0x7A)
        return (scalar.value >= 0x41 && scalar.value <= 0x5A)
            || (scalar.value >= 0x61 && scalar.value <= 0x7A)
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
            } else if isEnglishAlphabetic(scalar) {
                meaningfulCount += 1
            }
            // Punctuation, spaces, symbols are ignored from meaningfulCount
        }

        guard meaningfulCount > 0 else { return nil }

        let ratio = Double(cjkCount) / Double(meaningfulCount)
        return ratio > 0.30 ? .chinese : .english
    }
}
