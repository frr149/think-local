import SwiftUI

struct StatusBarView: View {
    let mode: AppMode
    var showParams: Bool = false
    var parameters: GenerationParameters = .balanced

    var body: some View {
        HStack {
            // Left: model status indicator
            HStack(spacing: 5) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text("Model: on-device 3B")
                    .statusTextStyle()
            }

            Spacer()

            // Center: current mode title
            Text(mode.title)
                .statusTextStyle()

            Spacer()

            // Right: platform info or condensed parameters when inspector is hidden
            if showParams {
                Text(parameters.summary)
                    .statusTextStyle()
            } else {
                Text("macOS 26 · Apple Silicon")
                    .statusTextStyle()
            }
        }
        .padding(.horizontal, 12)
        // Theme.statusBarHeight = 20
        .frame(height: Theme.statusBarHeight)
        .background(.bar)
    }
}
