import SwiftUI

// Actions that can be triggered from menus/shortcuts
enum AppAction {
    case switchMode(Int)
    case toggleInspector
    case toggleCommandPalette
    case newSession
    case exportCurrentMode
}

// FocusedValue key for dispatching actions
struct AppActionKey: FocusedValueKey {
    typealias Value = (AppAction) -> Void
}

extension FocusedValues {
    var appAction: ((AppAction) -> Void)? {
        get { self[AppActionKey.self] }
        set { self[AppActionKey.self] = newValue }
    }
}
