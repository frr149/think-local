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
