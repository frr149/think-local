import Testing
@testable import ThinkLocally

@Test func tokenUsageTracking() {
    var usage = TokenUsage()
    usage.system = 100
    usage.user = 200
    usage.assistant = 300
    usage.contextSize = 4096
    #expect(usage.total == 600)
    #expect(usage.remaining == 3496)
    #expect(!usage.isWarning)
    #expect(!usage.isCritical)
}

@Test func tokenUsageWarningThresholds() {
    var usage = TokenUsage()
    usage.contextSize = 4096
    usage.user = 3072
    #expect(usage.isWarning)
    #expect(!usage.isCritical)
    usage.user = 3687
    #expect(usage.isCritical)
}

@Test func generationParametersPresets() {
    let creative = GenerationParameters.creative
    #expect(creative.temperature == 1.2)
    if case .topP(let p) = creative.samplingMode { #expect(p == 0.95) } else { Issue.record("Expected .topP") }
    let precise = GenerationParameters.precise
    #expect(precise.temperature == 0.1)
    #expect(precise.samplingMode == .greedy)
    let deterministic = GenerationParameters.deterministic
    #expect(deterministic.temperature == 0.0)
}

@Test func modelAvailabilityEquatable() {
    #expect(ModelAvailability.available == ModelAvailability.available)
    #expect(ModelAvailability.notReady == ModelAvailability.notReady)
    #expect(ModelAvailability.available != ModelAvailability.notEligible)
}

@Test func chatMessageCreation() {
    let msg = ChatMessage(role: .user, content: "Hello", tokenCount: 5)
    #expect(msg.role == .user)
    #expect(msg.content == "Hello")
    #expect(msg.tokenCount == 5)
}

@Test func modelErrorDescriptions() {
    let unavailable = ModelError.unavailable(.notEnabled)
    #expect(unavailable.errorDescription?.contains("System Settings") == true)
    let guardrail = ModelError.guardrailViolation
    #expect(guardrail.errorDescription?.contains("content guidelines") == true)
    let overflow = ModelError.contextOverflow
    #expect(overflow.errorDescription?.contains("4,096") == true)
}
