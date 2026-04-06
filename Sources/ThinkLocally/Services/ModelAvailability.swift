import Foundation

enum ModelAvailability: Equatable, Sendable {
    case available
    case notReady
    case notEnabled
    case notEligible
    case unknown(String)
}
