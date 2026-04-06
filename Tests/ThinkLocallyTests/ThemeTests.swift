import Testing
import SwiftUI
@testable import ThinkLocally

@Test func colorsResolve() {
    let amber = Color.amberGold
    let user = Color.roleUser
    let assistant = Color.roleAssistant
    let system = Color.roleSystem
    let warning = Color.tokenWarning
    let critical = Color.tokenCritical
    #expect(amber != Color.clear)
    #expect(user != Color.clear)
    #expect(assistant != Color.clear)
    #expect(system != Color.clear)
    #expect(warning != Color.clear)
    #expect(critical != Color.clear)
}

@Test func themeConstantsAreReasonable() {
    #expect(Theme.sidebarWidth > 0)
    #expect(Theme.inspectorWidth > 0)
    #expect(Theme.minWindowWidth >= 900)
    #expect(Theme.minWindowHeight >= 600)
}
