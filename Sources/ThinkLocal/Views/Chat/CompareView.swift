import SwiftUI

struct CompareView: View {
    @Binding var parameters: GenerationParameters
    @Binding var systemPrompt: String

    @State private var leftParams: GenerationParameters = .precise
    @State private var rightParams: GenerationParameters = .creative
    @State private var sharedPrompt = ""
    // Note: Compare Mode uses independent ModelService instances.
    // Resource Monitor in toolbar does not track these — shows "Idle" during compare.
    @State private var leftService = ModelService()
    @State private var rightService = ModelService()
    @State private var leftMessages: [ChatMessage] = []
    @State private var rightMessages: [ChatMessage] = []
    @State private var leftStreaming = ""
    @State private var rightStreaming = ""
    @State private var leftGenerating = false
    @State private var rightGenerating = false

    private var isGenerating: Bool { leftGenerating || rightGenerating }

    var body: some View {
        VStack(spacing: 0) {
            // Shared prompt input spanning full width
            sharedInputBar

            Divider()

            // Two panels side by side
            HSplitView {
                ComparePanel(
                    title: "Left",
                    params: $leftParams,
                    messages: leftMessages,
                    streamingContent: leftStreaming,
                    tokenUsage: leftService.tokenUsage
                )

                ComparePanel(
                    title: "Right",
                    params: $rightParams,
                    messages: rightMessages,
                    streamingContent: rightStreaming,
                    tokenUsage: rightService.tokenUsage
                )
            }
        }
        .onAppear {
            leftService.checkAvailability()
            rightService.checkAvailability()
            leftService.createSession(systemPrompt: systemPrompt)
            rightService.createSession(systemPrompt: systemPrompt)
        }
    }

    // MARK: - Shared input bar

    private var sharedInputBar: some View {
        HStack(spacing: 8) {
            TextField("Same prompt, different parameters…", text: $sharedPrompt)
                .textFieldStyle(.plain)
                .onSubmit { sendToBot() }

            Button("Compare") { sendToBot() }
                .buttonStyle(.borderedProminent)
                .tint(Color.amberGold)
                .disabled(sharedPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(12)
        .background(.bar)
    }

    // MARK: - Generation

    private func sendToBot() {
        let prompt = sharedPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isGenerating else { return }

        let userMsg = ChatMessage(role: .user, content: prompt)
        leftMessages.append(userMsg)
        rightMessages.append(userMsg)
        sharedPrompt = ""
        leftGenerating = true
        rightGenerating = true
        leftStreaming = ""
        rightStreaming = ""

        // Left side
        Task { @MainActor in
            defer { leftGenerating = false }
            do {
                let stream = leftService.generateStream(prompt: prompt, with: leftParams)
                var full = ""
                for try await delta in stream {
                    full += delta
                    leftStreaming = full
                }
                leftMessages.append(ChatMessage(role: .assistant, content: full))
                leftStreaming = ""
            } catch {
                leftMessages.append(ChatMessage(role: .system, content: "Error: \(error.localizedDescription)"))
                leftStreaming = ""
            }
        }

        // Right side
        Task { @MainActor in
            defer { rightGenerating = false }
            do {
                let stream = rightService.generateStream(prompt: prompt, with: rightParams)
                var full = ""
                for try await delta in stream {
                    full += delta
                    rightStreaming = full
                }
                rightMessages.append(ChatMessage(role: .assistant, content: full))
                rightStreaming = ""
            } catch {
                rightMessages.append(ChatMessage(role: .system, content: "Error: \(error.localizedDescription)"))
                rightStreaming = ""
            }
        }
    }
}
