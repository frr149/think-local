import SwiftUI

struct TokenBarView: View {
    let usage: TokenUsage

    var body: some View {
        VStack(spacing: 2) {
            // Segmented bar
            GeometryReader { geo in
                HStack(spacing: 0) {
                    if usage.system > 0 {
                        Rectangle()
                            .fill(Color.roleSystem)
                            .frame(width: segmentWidth(usage.system, in: geo.size.width))
                    }
                    if usage.user > 0 {
                        Rectangle()
                            .fill(Color.roleUser)
                            .frame(width: segmentWidth(usage.user, in: geo.size.width))
                    }
                    if usage.assistant > 0 {
                        Rectangle()
                            .fill(Color.roleAssistant)
                            .frame(width: segmentWidth(usage.assistant, in: geo.size.width))
                    }
                    Spacer(minLength: 0)
                }
                .background(barBackground)
                .clipShape(.rect(cornerRadius: 3))
            }
            .frame(height: 6)

            // Labels
            HStack {
                HStack(spacing: 8) {
                    legend(color: .roleSystem, label: "sys")
                    legend(color: .roleUser, label: "usr")
                    legend(color: .roleAssistant, label: "ast")
                }

                Spacer()

                Text("\(usage.total) / \(usage.contextSize) tokens")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(usage.isCritical ? Color.tokenCritical :
                        usage.isWarning ? Color.tokenWarning : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(height: Theme.tokenBarHeight)
        .animation(Theme.tokenBarAnimation, value: usage.total)
    }

    private func segmentWidth(_ tokens: Int, in totalWidth: CGFloat) -> CGFloat {
        guard usage.contextSize > 0 else { return 0 }
        return totalWidth * CGFloat(tokens) / CGFloat(usage.contextSize)
    }

    private var barBackground: Color {
        if usage.isCritical { return Color.tokenCritical.opacity(0.15) }
        if usage.isWarning { return Color.tokenWarning.opacity(0.1) }
        return Color(nsColor: .separatorColor)
    }

    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 2) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
    }
}
