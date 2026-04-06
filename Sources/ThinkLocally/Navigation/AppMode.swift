import SwiftUI

enum AppMode: String, CaseIterable, Identifiable {
    case chat
    case imageStudio
    case schemas
    case toolsLab
    case modelInfo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: "Chat"
        case .imageStudio: "Image Studio"
        case .schemas: "Schemas"
        case .toolsLab: "Tools Lab"
        case .modelInfo: "Model Info"
        }
    }

    var icon: String {
        switch self {
        case .chat: "brain"
        case .imageStudio: "paintpalette"
        case .schemas: "curlybraces"
        case .toolsLab: "wrench.and.screwdriver"
        case .modelInfo: "cpu"
        }
    }

    var group: Int {
        switch self {
        case .chat, .imageStudio: 0
        case .schemas, .toolsLab: 1
        case .modelInfo: 2
        }
    }
}
