import SwiftUI

enum Theme {
    static let sidebarWidth: CGFloat = 200
    static let inspectorWidth: CGFloat = 300
    static let minWindowWidth: CGFloat = 900
    static let minWindowHeight: CGFloat = 600
    static let tokenBarHeight: CGFloat = 24
    static let statusBarHeight: CGFloat = 20

    static let streamingAnimation: Animation = .default
    static let tokenBarAnimation: Animation = .spring(response: 0.3)
}
