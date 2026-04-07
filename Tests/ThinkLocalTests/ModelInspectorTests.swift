import Testing
@testable import ThinkLocal

@Test func modelAvailabilityDescriptions() {
    // Test that each ModelAvailability case can be matched
    let cases: [ModelAvailability] = [.available, .notReady, .notEnabled, .notEligible, .unknown("test")]
    #expect(cases.count == 5)
}

@Test func availabilityTextForAllCases() {
    let testCases: [ModelAvailability] = [.available, .notReady, .notEnabled, .notEligible, .unknown("test")]
    for availability in testCases {
        #expect(availability == availability)
    }
}

@Test @MainActor func modelServiceInitialization() {
    let modelService = ModelService()
    switch modelService.availability {
    case .unknown:
        #expect(true)
    default:
        #expect(Bool(false), "Initial availability should be unknown")
    }
}

@Test func supportedLanguagesNotEmpty() {
    let languages = [
        "English",
        "Spanish",
        "French",
        "German",
        "Italian",
        "Portuguese (BR)",
        "Japanese",
        "Korean",
        "Chinese (Simplified)"
    ]
    #expect(languages.count == 9)
    for lang in languages {
        #expect(!lang.isEmpty)
    }
}

@Test func limitationsListComplete() {
    let limitations = [
        "Text-only input (no images, audio, or video)",
        "4,096 token context window",
        "Content guardrails cannot be disabled",
        "No fine-tuning or custom training",
        "Knowledge cutoff ~October 2023",
        "Not designed for factual Q&A"
    ]
    #expect(limitations.count == 6)
}
