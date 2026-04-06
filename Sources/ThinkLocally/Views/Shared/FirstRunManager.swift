import SwiftUI

@Observable
class FirstRunManager {
    private static let firstResponseKey = "hasShownFirstRunMessage"

    var shouldShowFirstRunMessage: Bool {
        !UserDefaults.standard.bool(forKey: Self.firstResponseKey)
    }

    func markFirstRunShown() {
        UserDefaults.standard.set(true, forKey: Self.firstResponseKey)
    }
}
