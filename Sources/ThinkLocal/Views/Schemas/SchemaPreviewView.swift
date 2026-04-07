import SwiftUI

struct SchemaPreviewView: View {
    let jsonResults: [SchemaRunResult]
    let selectedRun: Int
    let isGenerating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if jsonResults.isEmpty && !isGenerating {
                emptyState
            } else if isGenerating && jsonResults.isEmpty {
                loadingState
            } else {
                resultView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.right.circle")
                .font(.title)
                .foregroundStyle(.tertiary)
            Text("Press ⌘R to generate")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingState: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text("Generating…")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var resultView: some View {
        if selectedRun < jsonResults.count {
            let result = jsonResults[selectedRun]

            // Status header
            HStack {
                if result.isValid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Valid JSON")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                    Text("Invalid JSON")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()

                Text(String(format: "%.1fs", result.generationTime))
                    .metricValueStyle()
            }

            Divider()

            // JSON content
            ScrollView {
                Text(result.formattedJSON)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct SchemaRunResult: Identifiable {
    let id = UUID()
    let rawContent: String
    let generationTime: TimeInterval
    let timestamp: Date
    let isValid: Bool
    let formattedJSON: String

    init(rawContent: String, generationTime: TimeInterval, timestamp: Date) {
        self.rawContent = rawContent
        self.generationTime = generationTime
        self.timestamp = timestamp

        if let data = rawContent.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: pretty, encoding: .utf8) {
            self.isValid = true
            self.formattedJSON = str
        } else {
            self.isValid = false
            self.formattedJSON = rawContent
        }
    }
}
