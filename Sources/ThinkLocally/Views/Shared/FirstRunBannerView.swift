import SwiftUI

struct FirstRunBannerView: View {
    @State private var isVisible = true

    var body: some View {
        if isVisible {
            HStack(spacing: 8) {
                Image(systemName: "lock.shield")
                    .foregroundStyle(Color.amberGold)
                Text("Generated entirely on this Mac. Nothing left this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: .capsule)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation { isVisible = false }
                }
            }
        }
    }
}
