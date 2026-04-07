import SwiftUI

struct InspectorView: View {
    let mode: AppMode
    @Binding var parameters: GenerationParameters
    var systemPrompt: Binding<String>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Parameters section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Parameters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    ParameterTunerView(parameters: $parameters)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                Divider()

                // System prompt (chat mode only)
                if mode == .chat, let systemPrompt {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("System Prompt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        TextEditor(text: systemPrompt)
                            .font(.system(.caption, design: .monospaced))
                            .frame(minHeight: 72, maxHeight: 140)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor), in: .rect(cornerRadius: 6))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                    Divider()
                }

                // Contextual info section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Context")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text(contextualInfo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                Spacer(minLength: 0)
            }
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity)
    }

    private var contextualInfo: String {
        switch mode {
        case .chat:         return "Temperature: how random the responses are — 0 is deterministic, 2 is chaotic. Sampling: greedy always picks the most likely word; top-k and top-p sample from the top candidates, producing more varied text."
        case .imageStudio:  return "Temperature affects how literally the model follows your prompt. Lower = closer to description, higher = more creative interpretation."
        case .schemas:      return "Use low temperature (0–0.3) for structured output. Higher values risk the model straying from the schema."
        case .toolsLab:     return "Greedy sampling (temperature 0) ensures the model always picks the same tool for the same input — best for testing deterministic tool selection."
        case .modelInfo:    return "Parameters shown here will apply to any test generations."
        }
    }
}
