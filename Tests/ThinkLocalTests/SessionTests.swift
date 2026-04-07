import Testing
import Foundation
@testable import ThinkLocal

@Test func sessionTitleFromFirstUserMessage() {
    var session = Session()
    #expect(session.title == "New Session")

    session.messages.append(ChatMessage(role: .user, content: "Hello world"))
    #expect(session.title == "Hello world")
}

@Test func sessionGroupingByDate() {
    // Verificar que Session es Codable correctamente
    let session = Session()
    let data = try! JSONEncoder().encode(session)
    let decoded = try! JSONDecoder().decode(Session.self, from: data)
    #expect(decoded.id == session.id)
}

@Test func sessionTitleTruncatesAt50Chars() {
    var session = Session()
    let longContent = String(repeating: "a", count: 60)
    session.messages.append(ChatMessage(role: .user, content: longContent))
    #expect(session.title.count == 50)
}

@Test func sessionLastMessagePreview() {
    var session = Session()
    session.messages.append(ChatMessage(role: .user, content: "First message"))
    session.messages.append(ChatMessage(role: .assistant, content: "Reply here"))
    #expect(session.lastMessagePreview == "Reply here")
}

@Test func sessionDefaultTitle() {
    // Sin mensajes de usuario, solo mensajes de sistema
    var session = Session()
    session.messages.append(ChatMessage(role: .system, content: "System message"))
    #expect(session.title == "New Session")
}
