import Foundation
import FoundationModels
import Observation

// MARK: - ToolDefinition

struct ToolDefinition: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var argumentsDescription: String  // Descripción legible de los argumentos esperados
    var mockResponse: String          // Lo que devuelve cuando el tool es invocado

    init(
        name: String = "",
        description: String = "",
        argumentsDescription: String = "",
        mockResponse: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.argumentsDescription = argumentsDescription
        self.mockResponse = mockResponse
    }

    static let weatherExample = ToolDefinition(
        name: "getWeather",
        description: "Gets current weather for a city",
        argumentsDescription: "city: String — The city name",
        mockResponse: "Sunny, 22°C in Madrid"
    )
}

// MARK: - ToolInvocation

struct ToolInvocation: Identifiable {
    let id = UUID()
    let toolName: String
    let arguments: String
    let response: String
    let timestamp: Date
}

// MARK: - ToolCallingService

@Observable
@MainActor
final class ToolCallingService {
    var definitions: [ToolDefinition] = [.weatherExample]
    private(set) var invocations: [ToolInvocation] = []
    private(set) var messages: [ChatMessage] = []
    private(set) var isGenerating = false
    private(set) var sessionReady = false

    private var session: LanguageModelSession?

    // MARK: - Session

    func createSession(with tools: [ToolDefinition]) {
        let toolDescriptions = tools
            .map { "Tool: \($0.name) — \($0.description). Args: \($0.argumentsDescription)" }
            .joined(separator: "\n")

        let instructions = """
        You have access to the following tools:
        \(toolDescriptions)

        When you need to use a tool, respond with: [TOOL_CALL: toolName(args)]
        After receiving the tool result, incorporate it into your response.
        """
        session = LanguageModelSession(instructions: instructions)
        sessionReady = true
        messages = []
        invocations = []
    }

    // MARK: - Messaging

    func send(message: String, parameters: GenerationParameters) async {
        guard let session else { return }
        isGenerating = true
        defer { isGenerating = false }

        messages.append(ChatMessage(role: .user, content: message))

        let options = GenerationOptions(
            sampling: samplingMode(from: parameters),
            temperature: parameters.temperature,
            maximumResponseTokens: parameters.maxTokens
        )

        do {
            let response = try await session.respond(to: message, options: options)
            let content = response.content

            // Detectar tool call simulado en la respuesta
            if let toolCall = parseToolCall(content) {
                let definition = definitions.first(where: { $0.name == toolCall.name })
                let mockResponse = definition?.mockResponse ?? "No mock response configured"

                let invocation = ToolInvocation(
                    toolName: toolCall.name,
                    arguments: toolCall.args,
                    response: mockResponse,
                    timestamp: Date()
                )
                invocations.append(invocation)

                // Añadir el tool call al log de mensajes
                messages.append(ChatMessage(role: .assistant, content: content))

                // Enviar el resultado al modelo
                let toolResultPrompt = "Tool \(toolCall.name) returned: \(mockResponse)"
                messages.append(ChatMessage(role: .system, content: toolResultPrompt))

                let followUp = try await session.respond(to: toolResultPrompt)
                messages.append(ChatMessage(role: .assistant, content: followUp.content))
            } else {
                messages.append(ChatMessage(role: .assistant, content: content))
            }
        } catch {
            messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
        }
    }

    func reset() {
        messages = []
        invocations = []
        session = nil
        sessionReady = false
    }

    // MARK: - Helpers

    private func samplingMode(from parameters: GenerationParameters) -> GenerationOptions.SamplingMode? {
        switch parameters.samplingMode {
        case .greedy:       return .greedy
        case .topK(let k):  return .random(top: k)
        case .topP(let p):  return .random(probabilityThreshold: p)
        }
    }

    private func parseToolCall(_ text: String) -> (name: String, args: String)? {
        let pattern = #"\[TOOL_CALL:\s*(\w+)\((.*?)\)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let result = regex.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let nameRange = Range(result.range(at: 1), in: text),
              let argsRange = Range(result.range(at: 2), in: text)
        else {
            return nil
        }
        return (String(text[nameRange]), String(text[argsRange]))
    }
}
