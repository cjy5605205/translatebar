import Foundation

enum OllamaTranslator {
    private static let baseURL = "http://localhost:11434/api/generate"
    private static let defaultModel = "qwen2.5:3b"
    private static let timeout: TimeInterval = 30

    struct RequestBody: Encodable {
        let model: String
        let prompt: String
        let stream: Bool
    }

    struct ResponseBody: Decodable {
        let response: String
    }

    enum TranslateError: Error {
        case notRunning
        case invalidResponse
    }

    static func translate(_ text: String, to targetLang: String) async throws -> String {
        let modelName = UserDefaults.standard.string(forKey: "ollama_model") ?? defaultModel
        let prompt = """
        Translate the following text to natural, conversational \(targetLang). \
        Do NOT translate word-for-word. Return only the translation, no explanation.

        \(text)
        """

        let body = RequestBody(model: modelName, prompt: prompt, stream: false)

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw TranslateError.invalidResponse
            }
            let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
            let result = decoded.response.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !result.isEmpty else { throw TranslateError.invalidResponse }
            return result
        } catch let error as URLError where error.errorCode == NSURLErrorCannotConnectToHost {
            throw TranslateError.notRunning
        }
    }
}
