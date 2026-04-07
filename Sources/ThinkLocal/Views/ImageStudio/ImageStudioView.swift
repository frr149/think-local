import SwiftUI
import ImagePlayground

// MARK: - ImageStudioView

struct ImageStudioView: View {
    @State var service: ImageGenerationService

    @State private var prompt: String = ""
    @State private var generatedImages: [ImagePlaygroundStyle: ImageGenerationService.GeneratedImage] = [:]
    @State private var history: [ImageGenerationService.GeneratedImage] = []
    @State private var generationTask: Task<Void, Never>?
    @State private var generatingStyles: Set<ImagePlaygroundStyle> = []
    @State private var generationStart: Date?

    private var isGenerating: Bool { !generatingStyles.isEmpty }
    @State private var elapsedTime: TimeInterval = 0
    @State private var elapsedTimer: Timer?

    private let styles = ImagePlaygroundStyle.studioStyles
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 0) {
            canvasArea
            if !history.isEmpty {
                Divider()
                historyBar
            }
            Divider()
            promptBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Prompt bar

    private var promptBar: some View {
        HStack(spacing: 12) {
            TextField("Describe the image you want to create…", text: $prompt)
                .textFieldStyle(.plain)
                .font(.body)
                .onSubmit { generate() }

            if isGenerating {
                Button("Cancel", role: .cancel) { cancelGeneration() }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
            }

            generateButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var generateButton: some View {
        Button(action: generate) {
            Label("Generate", systemImage: "sparkles")
                .font(.body.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.amberGold, in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.black)
        }
        .buttonStyle(.plain)
        .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
        .keyboardShortcut("r", modifiers: .command)
    }

    // MARK: - Canvas

    @ViewBuilder
    private var canvasArea: some View {
        if generatedImages.isEmpty && !isGenerating {
            emptyState
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(styles, id: \.self) { style in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(style.displayName)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 4)

                            ImageCardView(
                                generated: generatedImages[style],
                                style: style,
                                isGenerating: generatingStyles.contains(style),
                                elapsedTime: elapsedTime
                            )
                        }
                    }
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintpalette")
                .font(.system(size: 52))
                .foregroundStyle(Color.amberGold.opacity(0.7))

            Text("Three styles. Infinite ideas.\nEverything stays on your Mac.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - History bar

    private var historyBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(history.reversed()) { item in
                    historyThumbnail(item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: 80)
    }

    private func historyThumbnail(_ item: ImageGenerationService.GeneratedImage) -> some View {
        Image(item.image, scale: 1, label: Text(item.prompt))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.amberGold.opacity(0.4), lineWidth: 1)
            )
            .help("\(item.style.displayName) — \(item.prompt)")
    }

    // MARK: - Generation

    private func generate() {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }
        generatedImages = [:]
        generatingStyles = Set(styles)
        startElapsedTimer()

        for style in styles {
            Task { @MainActor in
                defer {
                    generatingStyles.remove(style)
                    if generatingStyles.isEmpty {
                        stopElapsedTimer()
                    }
                }
                do {
                    let img = try await service.generate(prompt: trimmed, style: style)
                    generatedImages[style] = img
                    history.append(img)
                    if history.count > 50 { history.removeFirst(history.count - 50) }
                } catch {
                    // Skip failed style
                }
            }
        }
    }

    private func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
        generatingStyles = []
        stopElapsedTimer()
    }

    private func startElapsedTimer() {
        elapsedTime = 0
        generationStart = Date()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                elapsedTime = Date().timeIntervalSince(generationStart ?? Date())
            }
        }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }
}

