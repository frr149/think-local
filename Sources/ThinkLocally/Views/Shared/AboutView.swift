import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            // App icon placeholder (will be replaced with real icon)
            Image(systemName: "cube.transparent")
                .font(.system(size: 64))
                .foregroundStyle(Color.amberGold)

            Text("Think Locally")
                .font(.title.bold())

            Text("Your mind. Your machine. No cloud required.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Divider()
                .frame(width: 200)

            Text("© 2026 Fernando Rodríguez")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Text("MIT License")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .frame(width: 300)
    }
}
