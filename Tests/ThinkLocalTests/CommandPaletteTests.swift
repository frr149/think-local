import Testing
@testable import ThinkLocal

@Test func commandRegistrySearchFilters() {
    let registry = CommandRegistry()
    registry.commands = [
        Command(title: "Go to Chat", icon: "brain", shortcut: "⌘1", category: .navigation, action: {}),
        Command(title: "Go to Image Studio", icon: "paintpalette", shortcut: "⌘2", category: .navigation, action: {}),
        Command(title: "/classify", icon: "tag", shortcut: nil, category: .template, action: {}),
    ]

    let all = registry.search("")
    #expect(all.count == 3)

    let chatResults = registry.search("chat")
    #expect(chatResults.count == 1)
    #expect(chatResults.first?.title == "Go to Chat")

    let noResults = registry.search("zzzzz")
    #expect(noResults.isEmpty)
}

@Test func commandRegistrySearchCaseInsensitive() {
    let registry = CommandRegistry()
    registry.commands = [
        Command(title: "Go to Chat", icon: "brain", shortcut: "⌘1", category: .navigation, action: {}),
        Command(title: "Toggle Inspector", icon: "sidebar.right", shortcut: "⌘⇧I", category: .action, action: {}),
    ]

    let upperResults = registry.search("CHAT")
    #expect(upperResults.count == 1)
    #expect(upperResults.first?.title == "Go to Chat")

    let mixedResults = registry.search("InSpEcToR")
    #expect(mixedResults.count == 1)
    #expect(mixedResults.first?.title == "Toggle Inspector")
}

@Test func commandRegistrySearchPartialMatches() {
    let registry = CommandRegistry()
    registry.commands = [
        Command(title: "Go to Chat", icon: "brain", shortcut: "⌘1", category: .navigation, action: {}),
        Command(title: "Go to Image Studio", icon: "paintpalette", shortcut: "⌘2", category: .navigation, action: {}),
        Command(title: "Go to Schemas", icon: "curlybraces", shortcut: "⌘3", category: .navigation, action: {}),
    ]

    let goResults = registry.search("go")
    #expect(goResults.count == 3)

    let toResults = registry.search("to")
    #expect(toResults.count == 3)

    let studioResults = registry.search("studio")
    #expect(studioResults.count == 1)
}
