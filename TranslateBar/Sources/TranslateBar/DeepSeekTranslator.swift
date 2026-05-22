import Foundation

enum DeepSeekTranslator {
    private static let baseURL = "https://api.deepseek.com/chat/completions"
    private static let model = "deepseek-chat"
    private static let timeout: TimeInterval = 15

    struct RequestBody: Encodable {
        let model: String
        let messages: [Message]
        let temperature: Double

        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    struct ResponseBody: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let message: Message
            struct Message: Decodable {
                let content: String
            }
        }
    }

    struct ErrorBody: Decodable {
        let error: ErrorInfo
        struct ErrorInfo: Decodable {
            let message: String
            let type: String?
        }
    }

    enum TranslateError: LocalizedError {
        case noAPIKey
        case invalidResponse
        case httpError(Int, String)

        var errorDescription: String? {
            switch self {
            case .noAPIKey: return "未配置 API Key"
            case .invalidResponse: return "服务器返回异常"
            case .httpError(let code, let detail): return "HTTP \(code): \(detail)"
            }
        }
    }

    /// Translate `text` to `targetLang` ("Chinese" or "English") using DeepSeek API.
    static func translate(_ text: String, to targetLang: String) async throws -> String {
        guard let apiKey = KeychainManager.load("deepseek_api_key") else {
            throw TranslateError.noAPIKey
        }

        // Mask key for logging
        let maskedKey = String(apiKey.prefix(6)) + "..." + String(apiKey.suffix(4))
        print("[DeepSeek] Translating '\(text)' to \(targetLang), key=\(maskedKey)")

        let systemPrompt = """
        You are a professional translator. Translate the following text to natural, conversational \(targetLang). \
        The translation should sound like it was originally written by a native speaker. \
        Do NOT translate word-for-word. Return only the translation, no explanation.
        """

        let body = RequestBody(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: text)
            ],
            temperature: 0.3
        )

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = timeout

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("[DeepSeek] Network error: \(error.localizedDescription)")
            throw TranslateError.httpError(0, error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[DeepSeek] Invalid response type")
            throw TranslateError.invalidResponse
        }

        print("[DeepSeek] HTTP status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyStr = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("[DeepSeek] Error body: \(bodyStr)")

            // Try to parse error message from DeepSeek
            if let errorBody = try? JSONDecoder().decode(ErrorBody.self, from: data) {
                throw TranslateError.httpError(httpResponse.statusCode, errorBody.error.message)
            }
            throw TranslateError.httpError(httpResponse.statusCode, bodyStr)
        }

        let decoded: ResponseBody
        do {
            decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        } catch {
            let bodyStr = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("[DeepSeek] Decode error: \(error), body: \(bodyStr)")
            throw TranslateError.invalidResponse
        }

        guard let translatedText = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
              !translatedText.isEmpty else {
            print("[DeepSeek] Empty or missing choices in response")
            throw TranslateError.invalidResponse
        }

        print("[DeepSeek] Success: '\(translatedText)'")
        return translatedText
    }
}
