import Foundation

enum SamplingMode: Codable, Sendable, Equatable {
    case greedy
    case topK(k: Int)
    case topP(p: Double)
}

struct GenerationParameters: Codable, Sendable {
    var temperature: Double = 0.7
    var samplingMode: SamplingMode = .topK(k: 40)
    var maxTokens: Int = 4096

    static let creative = GenerationParameters(temperature: 1.2, samplingMode: .topP(p: 0.95))
    static let precise = GenerationParameters(temperature: 0.1, samplingMode: .greedy)
    static let balanced = GenerationParameters(temperature: 0.7, samplingMode: .topK(k: 40))
    static let deterministic = GenerationParameters(temperature: 0.0, samplingMode: .greedy)

    /// Condensed one-line summary for the status bar, e.g. "T:0.7 · top-k:40 · 1024"
    var summary: String {
        let t = String(format: "T:%.1f", temperature)
        let sampling: String
        switch samplingMode {
        case .greedy:        sampling = "greedy"
        case .topK(let k):   sampling = "top-k:\(k)"
        case .topP(let p):   sampling = String(format: "top-p:%.2f", p)
        }
        return "\(t) · \(sampling) · \(maxTokens)"
    }
}
