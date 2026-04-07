import Testing
import ImagePlayground
@testable import ThinkLocal

@Test func imageGenerationErrorDescriptions() {
    let failed = ImageGenerationError.generationFailed
    #expect(failed.errorDescription?.contains("failed") == true)
    let notSupported = ImageGenerationError.notSupported
    #expect(notSupported.errorDescription?.contains("not available") == true)
}

// Regression test: displayName calls ==, and == used to call displayName → infinite recursion.
// This test crashes with a stack overflow if the bug is reintroduced.
@Test func imagePlaygroundStyleDisplayNameNoRecursion() {
    #expect(ImagePlaygroundStyle.animation.displayName == "Animation")
    #expect(ImagePlaygroundStyle.illustration.displayName == "Illustration")
    #expect(ImagePlaygroundStyle.sketch.displayName == "Sketch")
}

@Test func imagePlaygroundStyleEqualitySameStyle() {
    #expect(ImagePlaygroundStyle.animation == ImagePlaygroundStyle.animation)
    #expect(ImagePlaygroundStyle.illustration == ImagePlaygroundStyle.illustration)
    #expect(ImagePlaygroundStyle.sketch == ImagePlaygroundStyle.sketch)
}

@Test func imagePlaygroundStyleEqualityDifferentStyles() {
    #expect(ImagePlaygroundStyle.animation != ImagePlaygroundStyle.illustration)
    #expect(ImagePlaygroundStyle.animation != ImagePlaygroundStyle.sketch)
    #expect(ImagePlaygroundStyle.illustration != ImagePlaygroundStyle.sketch)
}

@Test func imagePlaygroundStyleUsableAsDictionaryKey() {
    var dict: [ImagePlaygroundStyle: String] = [:]
    dict[.animation] = "anim"
    dict[.illustration] = "illus"
    dict[.sketch] = "sketch"
    #expect(dict[.animation] == "anim")
    #expect(dict[.illustration] == "illus")
    #expect(dict[.sketch] == "sketch")
    #expect(dict.count == 3)
}

@Test func imagePlaygroundStyleUsableInSet() {
    let styles: Set<ImagePlaygroundStyle> = [.animation, .illustration, .sketch, .animation]
    #expect(styles.count == 3)
    #expect(styles.contains(.animation))
    #expect(styles.contains(.sketch))
}

@Test func studioStylesContainsThreeStyles() {
    #expect(ImagePlaygroundStyle.studioStyles.count == 3)
}
