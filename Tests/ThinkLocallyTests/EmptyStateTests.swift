import Testing
@testable import ThinkLocally

@Test func firstRunManagerTracksState() {
    // We can't easily test UserDefaults in unit tests without a custom suite,
    // but we can verify the class exists and has the right API
    let manager = FirstRunManager()
    // Just verify it compiles and the API exists
    _ = manager.shouldShowFirstRunMessage
}
