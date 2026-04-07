import Testing
@testable import ThinkLocal

@Test func imageGenerationErrorDescriptions() {
    let failed = ImageGenerationError.generationFailed
    #expect(failed.errorDescription?.contains("failed") == true)
    let notSupported = ImageGenerationError.notSupported
    #expect(notSupported.errorDescription?.contains("not available") == true)
}
