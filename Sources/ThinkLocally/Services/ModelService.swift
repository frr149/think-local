import Foundation
import FoundationModels
import Observation

// MARK: - Errors

enum ModelError: Error, LocalizedError {
    case unavailable(ModelAvailability)
    case guardrailViolation
    case contextOverflow
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .unavailable(let reason):
            switch reason {
            case .notReady: "Apple Intelligence model is still downloading."
            case .notEnabled: "Enable Apple Intelligence in System Settings."
            case .notEligible: "This Mac does not support Apple Intelligence."
            case .unknown(let msg): "Model unavailable: \(msg)"
            case .available: nil
            }
        case .guardrailViolation:
            "The model declined this request due to content guidelines."
        case .contextOverflow:
            "Context window full (4,096 tokens). Start a new session."
        case .generationFailed(let msg):
            "Generation failed: \(msg)"
        }
    }
}

// MARK: - ModelService

@Observable
@MainActor
final class ModelService {
    // MARK: - Observable state

    private(set) var availability: ModelAvailability = .unknown("Not checked yet")
    private(set) var isGenerating: Bool = false
    private(set) var tokenUsage: TokenUsage = TokenUsage()
    private(set) var tokensPerSecond: Double = 0

    // MARK: - Private state

    private var session: LanguageModelSession?

    // MARK: - Availability

    func checkAvailability() {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            availability = .available
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                availability = .notEnabled
            case .modelNotReady:
                availability = .notReady
            case .deviceNotEligible:
                availability = .notEligible
            @unknown default:
                availability = .unknown(String(describing: reason))
            }
        @unknown default:
            availability = .unknown("Unknown availability state")
        }
    }

    // MARK: - Session management

    func createSession(systemPrompt: String) {
        session = LanguageModelSession(instructions: systemPrompt)
        tokenUsage = TokenUsage()
        tokensPerSecond = 0
    }

    func resetSession() {
        session = nil
        tokenUsage = TokenUsage()
        tokensPerSecond = 0
    }

    // MARK: - Prewarm

    func prewarm() {
        session?.prewarm()
    }

    // MARK: - Generation

    func generate(prompt: String, with parameters: GenerationParameters = .balanced) async throws -> String {
        guard availability == .available else {
            throw ModelError.unavailable(availability)
        }

        guard let session else {
            throw ModelError.generationFailed("No active session. Call createSession(systemPrompt:) first.")
        }

        isGenerating = true
        defer { isGenerating = false }

        let options = makeOptions(from: parameters)
        let startTime = Date()

        do {
            let response = try await session.respond(to: prompt, options: options)
            let elapsed = Date().timeIntervalSince(startTime)
            let responseContent = response.content

            // Estimate tokens (no tokenCount API available)
            let promptTokens = ModelService.estimateTokens(prompt)
            let responseTokens = ModelService.estimateTokens(responseContent)
            tokenUsage.user += promptTokens
            tokenUsage.assistant += responseTokens

            if elapsed > 0 {
                tokensPerSecond = Double(responseTokens) / elapsed
            }

            return responseContent
        } catch let error as LanguageModelSession.GenerationError {
            throw mapGenerationError(error)
        }
    }

    func generateStream(
        prompt: String,
        with parameters: GenerationParameters = .balanced
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task { @MainActor in
                guard self.availability == .available else {
                    continuation.finish(throwing: ModelError.unavailable(self.availability))
                    return
                }

                guard let session = self.session else {
                    continuation.finish(
                        throwing: ModelError.generationFailed(
                            "No active session. Call createSession(systemPrompt:) first."
                        )
                    )
                    return
                }

                self.isGenerating = true

                let options = self.makeOptions(from: parameters)
                let startTime = Date()

                // Estimate user tokens
                self.tokenUsage.user += ModelService.estimateTokens(prompt)

                var previousContent = ""

                do {
                    let stream = session.streamResponse(to: prompt, options: options)
                    for try await snapshot in stream {
                        // snapshot.content is cumulative — yield only the delta
                        let current = snapshot.content
                        if current.count > previousContent.count {
                            let delta = String(current.dropFirst(previousContent.count))
                            continuation.yield(delta)
                            previousContent = current
                        }
                    }

                    let elapsed = Date().timeIntervalSince(startTime)
                    let assistantTokens = ModelService.estimateTokens(previousContent)
                    self.tokenUsage.assistant += assistantTokens
                    if elapsed > 0 {
                        self.tokensPerSecond = Double(assistantTokens) / elapsed
                    }

                    continuation.finish()
                } catch let error as LanguageModelSession.GenerationError {
                    continuation.finish(throwing: self.mapGenerationError(error))
                } catch {
                    continuation.finish(throwing: ModelError.generationFailed(error.localizedDescription))
                }

                self.isGenerating = false
            }
        }
    }

    // MARK: - Helpers

    private func makeOptions(from parameters: GenerationParameters) -> GenerationOptions {
        var sampling: GenerationOptions.SamplingMode?
        switch parameters.samplingMode {
        case .greedy:
            sampling = .greedy
        case .topK(let k):
            sampling = .random(top: k)
        case .topP(let p):
            sampling = .random(probabilityThreshold: p)
        }

        return GenerationOptions(
            sampling: sampling,
            temperature: parameters.temperature,
            maximumResponseTokens: parameters.maxTokens
        )
    }

    private func mapGenerationError(_ error: LanguageModelSession.GenerationError) -> ModelError {
        switch error {
        case .guardrailViolation:
            .guardrailViolation
        case .exceededContextWindowSize:
            .contextOverflow
        default:
            .generationFailed(error.localizedDescription)
        }
    }

    /// Rough token estimate: ~4 characters per token for English text
    static func estimateTokens(_ text: String) -> Int {
        max(1, text.count / 4)
    }
}
