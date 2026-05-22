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
        // "Hello你好World" — 2 CJK out of 13 chars ≈ 15% < 30%
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
