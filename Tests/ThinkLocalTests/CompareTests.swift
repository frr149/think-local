import Testing
@testable import ThinkLocal

@Test func compareModeUsesIndependentParameters() {
    let left = GenerationParameters.precise
    let right = GenerationParameters.creative
    #expect(left.temperature != right.temperature)
    #expect(left.samplingMode != right.samplingMode)
}
