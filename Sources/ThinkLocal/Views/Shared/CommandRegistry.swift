import SwiftUI

struct Command: Identifiable {
    let title: String
    let icon: String  // SF Symbol name
    let shortcut: String?  // display string like "⌘1"
    let category: CommandCategory
    let action: @MainActor () -> Void

    var id: String { title }

    enum CommandCategory: String {
        case navigation = "Navigation"
        case action = "Actions"
        case template = "Templates"
    }
}

@Observable
class CommandRegistry {
    var commands: [Command] = []

    func search(_ query: String) -> [Command] {
        if query.isEmpty { return commands }
        let lowered = query.lowercased()
        return commands.filter { $0.title.lowercased().contains(lowered) }
    }
}
