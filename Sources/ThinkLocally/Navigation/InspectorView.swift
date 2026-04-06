import SwiftUI

struct InspectorView: View {
    let mode: AppMode
    @Binding var parameters: GenerationParameters
    var systemPrompt: Binding<String>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Parameters section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Parameters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    ParameterTunerView(parameters: $parameters)
                }
                .padding()

                Divider()

                // System prompt (chat mode only)
                if mode == .chat, let systemPrompt {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("System Prompt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        TextEditor(text: systemPrompt)
                            .font(.system(.caption, design: .monospaced))
                            .frame(minHeight: 60, maxHeight: 120)
                            .scrollContentBackground(.hidden)
                            .padding(6)
                            .background(Color(nsColor: .controlBackgroundColor), in: .rect(cornerRadius: 6))
                    }
                    .padding()

                    Divider()
                }

                // Contextual info section
                VStack(alignment: .leading, spacing: 8) {
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
                .padding()

                Spacer(minLength: 0)
            }
        }
        .frame(width: Theme.inspectorWidth, alignment: .leading)
    }

    private var contextualInfo: String {
        switch mode {
        case .chat:         return "Adjust temperature and sampling to control response creativity and diversity."
        case .imageStudio:  return "Temperature affects variation in generated descriptions and prompts."
        case .schemas:      return "Lower temperature recommended for structured output accuracy."
        case .toolsLab:     return "Greedy sampling ensures deterministic tool call selection."
        case .modelInfo:    return "Parameters shown here will apply to any test generations."
        }
    }
}
