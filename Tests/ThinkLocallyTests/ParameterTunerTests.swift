import Testing
@testable import ThinkLocally

// MARK: - Temperature description helper (mirrors ParameterTunerView logic)

private func temperatureDescription(_ value: Double) -> String {
    switch value {
    case 0.0:       return "deterministic"
    case 0.1...0.4: return "precise"
    case 0.5...0.8: return "varied responses"
    case 0.9...1.2: return "creative"
    default:        return "experimental"
    }
}

// MARK: - Tests

@Test func temperatureDescriptionChanges() {
    #expect(temperatureDescription(0.0) == "deterministic")
    #expect(temperatureDescription(0.3) == "precise")
    #expect(temperatureDescription(0.7) == "varied responses")
    #expect(temperatureDescription(1.0) == "creative")
    #expect(temperatureDescription(1.5) == "experimental")
}

@Test func presetsApplyCorrectValues() {
    var params = GenerationParameters.balanced

    params = .creative
    #expect(params.temperature == 1.2)
    if case .topP(let p) = params.samplingMode { #expect(p == 0.95) } else { Issue.record("Expected .topP") }

    params = .deterministic
    #expect(params.temperature == 0.0)
    #expect(params.samplingMode == .greedy)

    params = .precise
    #expect(params.temperature == 0.1)
    #expect(params.samplingMode == .greedy)

    params = .balanced
    #expect(params.temperature == 0.7)
    if case .topK(let k) = params.samplingMode { #expect(k == 40) } else { Issue.record("Expected .topK(k: 40)") }
}

@Test func parametersSummaryString() {
    let topK = GenerationParameters(temperature: 0.7, samplingMode: .topK(k: 40), maxTokens: 1024)
    #expect(topK.summary == "T:0.7 · top-k:40 · 1024")

    let topP = GenerationParameters(temperature: 1.2, samplingMode: .topP(p: 0.95), maxTokens: 2048)
    #expect(topP.summary == "T:1.2 · top-p:0.95 · 2048")

    let greedy = GenerationParameters(temperature: 0.0, samplingMode: .greedy, maxTokens: 512)
    #expect(greedy.summary == "T:0.0 · greedy · 512")
}
