import SwiftUI

struct GuardrailBannerView: View {
    let message: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundStyle(.orange)
                Text("Content filtered")
                    .font(.callout.weight(.medium))
                Spacer()
                Button(isExpanded ? "Hide" : "Why?") {
                    withAnimation { isExpanded.toggle() }
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }

            if isExpanded {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(Color.tokenWarning.opacity(0.08), in: .rect(cornerRadius: 8))
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
