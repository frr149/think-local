import SwiftUI
import FoundationModels

struct ModelInspectorView: View {
    @Bindable var modelService: ModelService
    @State private var benchmarkResult: Double?
    @State private var isRunningBenchmark = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Status section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Model").font(.headline)
                    Divider()

                    InfoRow(label: "Status", value: availabilityText, color: availabilityColor)
                    InfoRow(label: "Parameters", value: "~3B")
                    InfoRow(label: "Context Window", value: "4,096 tokens")
                    InfoRow(label: "Neural Engine", value: "Required")
                }

                // Languages section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Supported Languages").font(.headline)
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(supportedLanguages, id: \.self) { lang in
                            Text(lang)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.quaternary, in: .capsule)
                        }
                    }
                }

                // Benchmark section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Performance").font(.headline)
                    Divider()

                    if let result = benchmarkResult {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Throughput").font(.caption).foregroundStyle(.secondary)
                                Text("\(result, specifier: "%.1f") tok/s")
                                    .metricValueStyle()
                            }
                            Spacer()
                            Button("Run Again") { Task { await runBenchmark() } }
                                .disabled(isRunningBenchmark)
                        }
                    } else {
                        Button(action: { Task { await runBenchmark() } }) {
                            HStack {
                                Image(systemName: "play.circle")
                                Text("Run Benchmark")
                            }
                        }
                        .disabled(isRunningBenchmark)
                    }

                    if isRunningBenchmark {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8, anchor: .leading)
                            Text("Running benchmark...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }

                // Known Limitations section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Known Limitations").font(.headline)
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        LimitationRow("Text-only input (no images, audio, or video)")
                        LimitationRow("4,096 token context window")
                        LimitationRow("Content guardrails cannot be disabled")
                        LimitationRow("No fine-tuning or custom training")
                        LimitationRow("Knowledge cutoff ~October 2023")
                        LimitationRow("Not designed for factual Q&A")
                    }
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { modelService.checkAvailability() }
    }

    private var availabilityText: String {
        switch modelService.availability {
        case .available: "Available"
        case .notReady: "Downloading..."
        case .notEnabled: "Not Enabled"
        case .notEligible: "Not Supported"
        case .unknown(let msg): msg
        }
    }

    private var availabilityColor: Color {
        modelService.availability == .available ? .green : .orange
    }

    private var supportedLanguages: [String] {
        [
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
    }

    private func runBenchmark() async {
        isRunningBenchmark = true
        defer { isRunningBenchmark = false }

        modelService.createSession(systemPrompt: "You are a helpful assistant.")
        let start = Date()
        _ = try? await modelService.generate(
            prompt: "Write a short paragraph about the weather today.",
            with: .balanced
        )
        let elapsed = Date().timeIntervalSince(start)
        if elapsed > 0 {
            benchmarkResult = modelService.tokensPerSecond
        }
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let label: String
    let value: String
    var color: Color?

    var body: some View {
        HStack {
            Text(label)
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 8) {
                if let color {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
                Text(value)
                    .font(.callout)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LimitationRow: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
                .frame(width: 16)

            Text(text)
                .font(.callout)
                .lineLimit(nil)
        }
    }
}

#Preview {
    ModelInspectorView(modelService: ModelService())
}
