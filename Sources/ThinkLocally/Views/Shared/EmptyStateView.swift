import SwiftUI

struct EmptyStateView: View {
    let icon: String        // SF Symbol
    let headline: String    // First line — what
    let subheadline: String // Second line — value proposition
    let detail: String      // Third line — differentiator (local/private)
    var action: (() -> Void)?
    var actionTitle: String?
    var actionShortcut: String?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.amberGold)

            VStack(spacing: 8) {
                Text(headline)
                    .font(.title2.weight(.semibold))
                Text(subheadline)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if let action, let actionTitle {
                Button(action: action) {
                    HStack {
                        Text(actionTitle)
                        if let actionShortcut {
                            Text(actionShortcut)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.amberGold)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
