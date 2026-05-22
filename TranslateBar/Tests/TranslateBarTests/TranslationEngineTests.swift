import XCTest
@testable import TranslateBar

final class TranslationEngineTests: XCTestCase {

    func testEmptyTextReturnsEmpty() async throws {
        let result = try await TranslationEngine.translate("")
        XCTAssertEqual(result, "")
    }

    func testPureSymbolsReturnUnchanged() async throws {
        let text = "12345!@#"
        let result = try await TranslationEngine.translate(text)
        XCTAssertEqual(result, text)
    }
}
