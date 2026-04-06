import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    var messages: [ChatMessage]
    var parameters: GenerationParameters
    var systemPrompt: String
    let createdAt: Date
    var updatedAt: Date

    var title: String {
        messages.first(where: { $0.role == .user })?.content.prefix(50).description ?? "New Session"
    }

    var lastMessagePreview: String {
        messages.last?.content.prefix(80).description ?? ""
    }

    init(
        messages: [ChatMessage] = [],
        parameters: GenerationParameters = .balanced,
        systemPrompt: String = "You are a helpful assistant."
    ) {
        self.id = UUID()
        self.messages = messages
        self.parameters = parameters
        self.systemPrompt = systemPrompt
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
