import Foundation

enum MessageRole: String, Codable, Sendable {
    case system
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable, Sendable {
    let id: UUID
    let role: MessageRole
    var content: String
    let timestamp: Date
    var tokenCount: Int

    init(role: MessageRole, content: String, tokenCount: Int = 0) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.tokenCount = tokenCount
    }
}
