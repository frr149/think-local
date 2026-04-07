import Testing
@testable import ThinkLocal

@Test func sidebarShowsFiveModes() {
    #expect(AppMode.allCases.count == 5)
}

@Test func allModesHaveTitleAndIcon() {
    for mode in AppMode.allCases {
        #expect(!mode.title.isEmpty)
        #expect(!mode.icon.isEmpty)
    }
}

@Test func modesGroupedCorrectly() {
    let groups = Dictionary(grouping: AppMode.allCases, by: \.group)
    #expect(groups.count == 3)
    #expect(groups[0]?.count == 2)
    #expect(groups[1]?.count == 2)
    #expect(groups[2]?.count == 1)
}

@Test func defaultModeIsChat() {
    #expect(AppMode.allCases.first == .chat)
}
