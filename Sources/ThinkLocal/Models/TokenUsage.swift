import Foundation

struct TokenUsage: Sendable {
    var system: Int = 0
    var user: Int = 0
    var assistant: Int = 0
    var contextSize: Int = 4096

    var total: Int { system + user + assistant }
    var remaining: Int { max(0, contextSize - total) }
    var percentage: Double {
        guard contextSize > 0 else { return 0 }
        return Double(total) / Double(contextSize)
    }

    var isWarning: Bool { percentage >= 0.75 }
    var isCritical: Bool { percentage >= 0.90 }
}
