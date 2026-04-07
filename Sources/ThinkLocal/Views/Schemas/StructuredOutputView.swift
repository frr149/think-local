import SwiftUI

struct StructuredOutputView: View {
    @Bindable var modelService: ModelService
    @Binding var parameters: GenerationParameters

    @State private var schema = SchemaDefinition.weatherExample
    @State private var promptContext = "A sunny day in Madrid"
    @State private var results: [SchemaRunResult] = []
    @State private var selectedRun = 0
    @State private var isGenerating = false
    @State private var runCount = 1
    @State private var autoRun = false

    var body: some View {
        HSplitView {
            // Left: Schema editor + prompt
            VStack(spacing: 0) {
                ScrollView {
                    SchemaEditorView(schema: $schema)
                }

                Divider()

                // Prompt context
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prompt Context")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)

                    TextField("Describe what to generate…", text: $promptContext, axis: .vertical)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(2...4)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor), in: .rect(cornerRadius: 6))
                }
                .padding(12)

                Divider()

                // Controls
                HStack {
                    Button {
                        generate()
                    } label: {
                        Label("Generate", systemImage: "play.fill")
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.amberGold)
                    .disabled(isGenerating || schema.fields.isEmpty)

                    Stepper("Runs: \(runCount)", value: $runCount, in: 1...10)
                        .font(.caption)

                    Spacer()

                    Button {
                        exportSwift()
                    } label: {
                        Label("Export Swift", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
                .padding(12)
            }
            .frame(minWidth: 300)

            // Right: Results preview
            VStack(spacing: 0) {
                // Run tabs
                if results.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, _ in
                                Button("Run \(index + 1)") {
                                    selectedRun = index
                                }
                                .buttonStyle(.borderless)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    selectedRun == index ? Color.amberGold.opacity(0.2) : .clear,
                                    in: .capsule
                                )
                                .font(.caption)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .background(.bar)
                    Divider()
                }

                SchemaPreviewView(
                    jsonResults: results,
                    selectedRun: selectedRun,
                    isGenerating: isGenerating
                )
            }
            .frame(minWidth: 250)
        }
    }

    private func generate() {
        guard !isGenerating else { return }

        if modelService.availability != .available {
            modelService.checkAvailability()
        }

        results = []
        selectedRun = 0
        isGenerating = true

        Task {
            defer { isGenerating = false }

            modelService.createSession(systemPrompt: "You are a JSON generator. Always respond with valid JSON only, no markdown, no explanation.")

            for _ in 0..<runCount {
                let prompt = schema.generationPrompt(context: promptContext)
                let startTime = Date()

                do {
                    let content = try await modelService.generate(prompt: prompt, with: parameters)
                    let elapsed = Date().timeIntervalSince(startTime)
                    results.append(SchemaRunResult(
                        rawContent: content,
                        generationTime: elapsed,
                        timestamp: Date()
                    ))
                    selectedRun = results.count - 1
                } catch {
                    results.append(SchemaRunResult(
                        rawContent: "Error: \(error.localizedDescription)",
                        generationTime: 0,
                        timestamp: Date()
                    ))
                }

                // Reset session between runs for independence
                if runCount > 1 {
                    modelService.createSession(systemPrompt: "You are a JSON generator. Always respond with valid JSON only, no markdown, no explanation.")
                }
            }
        }
    }

    private func exportSwift() {
        ExportService.exportSchema(schema)
    }
}
