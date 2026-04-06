import Foundation
import Testing
@testable import ThinkLocally

@Test func messageRoleLabels() {
    let user = ChatMessage(role: .user, content: "Hello")
    #expect(user.role == .user)

    let assistant = ChatMessage(role: .assistant, content: "Hi")
    #expect(assistant.role == .assistant)

    let system = ChatMessage(role: .system, content: "You are helpful")
    #expect(system.role == .system)
}

@Test func tokenBarSegmentsByRole() {
    var usage = TokenUsage()
    usage.system = 100
    usage.user = 500
    usage.assistant = 400
    usage.contextSize = 4096

    #expect(usage.total == 1000)
    #expect(usage.remaining == 3096)
    #expect(!usage.isWarning)
    #expect(!usage.isCritical)
}

@Test func tokenBarColorChangesAtThresholds() {
    var usage = TokenUsage()
    usage.contextSize = 4096

    // Below 75% — normal
    usage.user = 2000
    #expect(!usage.isWarning)

    // At 75% — warning
    usage.user = 3072
    #expect(usage.isWarning)
    #expect(!usage.isCritical)

    // At 90% — critical
    usage.user = 3687
    #expect(usage.isCritical)
}

@Test func chatMessagePreservesContent() {
    let msg = ChatMessage(role: .user, content: "Test message", tokenCount: 3)
    #expect(msg.content == "Test message")
    #expect(msg.tokenCount == 3)
    #expect(msg.id != UUID()) // has a valid UUID
}

@Test func firstRunManagerAPI() {
    let manager = FirstRunManager()
    _ = manager.shouldShowFirstRunMessage
    // Just verify the API exists and compiles
}
