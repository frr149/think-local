import SwiftUI

// MARK: - Temperature description helper

private func temperatureDescription(_ value: Double) -> String {
    switch value {
    case 0.0:         return "deterministic"
    case 0.1...0.4:   return "precise"
    case 0.5...0.8:   return "varied responses"
    case 0.9...1.2:   return "creative"
    default:          return "experimental"
    }
}

// MARK: - Preset matching

private enum Preset: String, CaseIterable {
    case creative, precise, balanced, deterministic

    var parameters: GenerationParameters {
        switch self {
        case .creative:     return .creative
        case .precise:      return .precise
        case .balanced:     return .balanced
        case .deterministic: return .deterministic
        }
    }

    var label: String { rawValue.capitalized }
}

private func matchingPreset(for params: GenerationParameters) -> Preset? {
    Preset.allCases.first { preset in
        let p = preset.parameters
        return p.temperature == params.temperature
            && p.samplingMode == params.samplingMode
            && p.maxTokens == params.maxTokens
    }
}

// MARK: - ParameterTunerView

struct ParameterTunerView: View {
    @Binding var parameters: GenerationParameters

    /// Tracks whether the temperature or maxTokens numeric label is being edited inline
    @State private var editingTemperature: Bool = false
    @State private var editingMaxTokens: Bool = false
    @State private var temperatureText: String = ""
    @State private var maxTokensText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            temperatureSection
            Divider()
            samplingSection
            Divider()
            maxTokensSection
            Divider()
            presetsSection
        }
    }

    // MARK: Temperature

    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Temperature")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                Spacer()
                // Tapping the numeric value enables inline editing
                if editingTemperature {
                    TextField("", text: $temperatureText)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 48)
                        .onSubmit { commitTemperature() }
                        .onExitCommand { editingTemperature = false }
                } else {
                    Text(String(format: "%.1f", parameters.temperature))
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                        .onTapGesture {
                            temperatureText = String(format: "%.1f", parameters.temperature)
                            editingTemperature = true
                        }
                }
            }

            Slider(value: $parameters.temperature, in: 0...2, step: 0.1)
                .accentColor(.amberGold)

            Text(temperatureDescription(parameters.temperature))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private func commitTemperature() {
        if let value = Double(temperatureText) {
            parameters.temperature = min(2.0, max(0.0, value))
        }
        editingTemperature = false
    }

    // MARK: Sampling mode

    /// UI-only enum for the segmented picker (associated values prevent CaseIterable on SamplingMode).
    private enum SamplingModeSelection: String, CaseIterable {
        case greedy, topK, topP
        var label: String {
            switch self {
            case .greedy: "greedy"
            case .topK:   "top-k"
            case .topP:   "top-p"
            }
        }
    }

    private var modeSelection: Binding<SamplingModeSelection> {
        Binding(
            get: {
                switch parameters.samplingMode {
                case .greedy: .greedy
                case .topK:   .topK
                case .topP:   .topP
                }
            },
            set: { newMode in
                switch newMode {
                case .greedy: parameters.samplingMode = .greedy
                case .topK:   parameters.samplingMode = .topK(k: 40)
                case .topP:   parameters.samplingMode = .topP(p: 0.9)
                }
            }
        )
    }

    private var currentTopK: Binding<Double> {
        Binding(
            get: {
                if case .topK(let k) = parameters.samplingMode { return Double(k) }
                return 40
            },
            set: { parameters.samplingMode = .topK(k: Int($0)) }
        )
    }

    private var currentTopP: Binding<Double> {
        Binding(
            get: {
                if case .topP(let p) = parameters.samplingMode { return p }
                return 0.9
            },
            set: { parameters.samplingMode = .topP(p: $0) }
        )
    }

    private var samplingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sampling")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)

            Picker("", selection: modeSelection) {
                ForEach(SamplingModeSelection.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch parameters.samplingMode {
            case .greedy:
                EmptyView()
            case .topK(let k):
                topKSlider(currentK: k)
            case .topP(let p):
                topPSlider(currentP: p)
            }
        }
    }

    private func topKSlider(currentK: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("k")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("\(currentK)")
                    .font(.system(.body, design: .monospaced))
            }
            Slider(value: currentTopK, in: 1...100, step: 1)
                .accentColor(.amberGold)
        }
    }

    private func topPSlider(currentP: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("p")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(String(format: "%.2f", currentP))
                    .font(.system(.body, design: .monospaced))
            }
            Slider(value: currentTopP, in: 0...1, step: 0.05)
                .accentColor(.amberGold)
        }
    }

    // MARK: Max tokens

    private var maxTokensSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Max tokens")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                Spacer()
                if editingMaxTokens {
                    TextField("", text: $maxTokensText)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 52)
                        .onSubmit { commitMaxTokens() }
                        .onExitCommand { editingMaxTokens = false }
                } else {
                    Text("\(parameters.maxTokens)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                        .onTapGesture {
                            maxTokensText = "\(parameters.maxTokens)"
                            editingMaxTokens = true
                        }
                }
            }

            Slider(
                value: Binding(
                    get: { Double(parameters.maxTokens) },
                    set: { parameters.maxTokens = Int($0) }
                ),
                in: 1...4096,
                step: 1
            )
            .accentColor(.amberGold)
        }
    }

    private func commitMaxTokens() {
        if let value = Int(maxTokensText) {
            parameters.maxTokens = min(4096, max(1, value))
        }
        editingMaxTokens = false
    }

    // MARK: Presets

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Presets")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)

            // 2x2 grid of preset chips
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Preset.allCases, id: \.self) { preset in
                    PresetChip(
                        label: preset.label,
                        isActive: matchingPreset(for: parameters) == preset
                    ) {
                        parameters = preset.parameters
                    }
                }
            }
        }
    }
}

// MARK: - Preset chip button

private struct PresetChip: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isActive ? Color.amberGold : Color.secondary.opacity(0.18))
                .foregroundStyle(isActive ? Color.black : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}
