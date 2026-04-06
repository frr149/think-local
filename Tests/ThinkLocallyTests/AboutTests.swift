import Testing
@testable import ThinkLocally

@Test func aboutViewExists() {
    // Verify the AboutView type exists and compiles
    _ = AboutView.self
    #expect(true)
}
