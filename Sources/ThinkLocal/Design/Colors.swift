import SwiftUI

extension Color {
    // MARK: - Accent
    static let amberGold = Color(red: 212 / 255, green: 168 / 255, blue: 85 / 255)

    // MARK: - Roles
    static let roleUser = Color.blue.opacity(0.35)
    static let roleAssistant = Color.indigo.opacity(0.35)
    static let roleSystem = Color.gray.opacity(0.35)

    // MARK: - Token bar warnings
    static let tokenWarning = Color.orange
    static let tokenCritical = Color.red

    // MARK: - Backgrounds
    static let messageEven = Color(nsColor: .windowBackgroundColor)
    static let messageOdd = Color(nsColor: .windowBackgroundColor).opacity(0.85)
}
