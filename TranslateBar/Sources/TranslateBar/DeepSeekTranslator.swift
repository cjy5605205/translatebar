import Foundation

enum DeepSeekTranslator {
    private static let baseURL = "https://api.deepseek.com/v1/chat/completions"
    private static let model = "deepseek-chat"
    private static let timeout: TimeInterval = 10

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

    enum TranslateError: LocalizedError {
        case noAPIKey
        case invalidResponse
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .noAPIKey: return "未配置 API Key"
            case .invalidResponse: return "服务器返回异常"
            case .httpError(let code): return "HTTP 错误 (\(code))"
            }
        }
    }

    /// Translate `text` to `targetLang` ("Chinese" or "English") using DeepSeek API.
    static func translate(_ text: String, to targetLang: String) async throws -> String {
        guard let apiKey = KeychainManager.load("deepseek_api_key") else {
            throw TranslateError.noAPIKey
        }

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

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslateError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw TranslateError.httpError(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let translatedText = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
              !translatedText.isEmpty else {
            throw TranslateError.invalidResponse
        }

        return translatedText
    }
}
