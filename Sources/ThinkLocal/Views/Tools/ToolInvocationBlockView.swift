import SwiftUI

// MARK: - ToolInvocationBlockView

/// Bloque expandible que muestra una invocación de tool registrada.
struct ToolInvocationBlockView: View {
    let invocation: ToolInvocation
    @State private var isExpanded = false

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: invocation.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabecera
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "wrench.fill")
                        .font(.caption)
                        .foregroundStyle(Color.amberGold)

                    Text("Tool Call: \(invocation.toolName)")
                        .font(.system(.caption, design: .monospaced).smallCaps())
                        .foregroundStyle(Color.amberGold)

                    Spacer()

                    Text(formattedTime)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
            }
            .buttonStyle(.plain)

            // Cuerpo expandido
            if isExpanded {
                Divider()
                    .opacity(0.5)

                VStack(alignment: .leading, spacing: 8) {
                    // Argumentos
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Arguments")
                            .roleLabelStyle()
                        Text(invocation.arguments.isEmpty ? "(none)" : invocation.arguments)
                            .consoleOutputStyle()
                            .foregroundStyle(.primary)
                    }

                    // Respuesta
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mock Response")
                            .roleLabelStyle()
                        Text(invocation.response)
                            .consoleOutputStyle()
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
        .background(Color.amberGold.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.amberGold.opacity(0.25), lineWidth: 1)
        )
    }
}
