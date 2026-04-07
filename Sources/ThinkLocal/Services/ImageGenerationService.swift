import CoreGraphics
import Foundation
import ImagePlayground
import Observation

// MARK: - Errors

enum ImageGenerationError: Error, LocalizedError {
    case generationFailed
    case notSupported

    var errorDescription: String? {
        switch self {
        case .generationFailed: "Image generation failed."
        case .notSupported: "Image generation is not available on this device."
        }
    }
}

// MARK: - Service

@Observable
@MainActor
final class ImageGenerationService {
    private(set) var isGenerating = false
    private(set) var error: ImageGenerationError?

    struct GeneratedImage: Identifiable {
        let id = UUID()
        let image: CGImage
        let style: ImagePlaygroundStyle
        let prompt: String
        let generationTime: TimeInterval
        let timestamp: Date
    }

    func setError(_ error: ImageGenerationError?) {
        self.error = error
    }

    func generate(prompt: String, style: ImagePlaygroundStyle) async throws -> GeneratedImage {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        let startTime = Date()
        let creator = try await ImageCreator()
        let concepts: [ImagePlaygroundConcept] = [.text(prompt)]

        var result: CGImage?
        for try await createdImage in creator.images(for: concepts, style: style, limit: 1) {
            result = createdImage.cgImage
            break
        }

        guard let cgImage = result else {
            throw ImageGenerationError.generationFailed
        }

        let elapsed = Date().timeIntervalSince(startTime)
        return GeneratedImage(
            image: cgImage,
            style: style,
            prompt: prompt,
            generationTime: elapsed,
            timestamp: Date()
        )
    }
}
