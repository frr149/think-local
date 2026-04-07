import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    let isEven: Bool
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(roleLabel)
                    .roleLabelStyle()
                    .foregroundStyle(roleColor)

                Spacer()

                if isHovering {
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(message.content, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .transition(.opacity)
                }

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
            }

            Text(message.content)
                .font(message.role == .assistant
                    ? .system(.body, design: .monospaced)
                    : .system(.body, design: .default))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isEven ? Color.messageEven : Color.messageOdd)
        .onHover { isHovering = $0 }
    }

    private var roleLabel: String {
        switch message.role {
        case .user: "USER"
        case .assistant: "ASSISTANT"
        case .system: "SYSTEM"
        }
    }

    private var roleColor: Color {
        switch message.role {
        case .user: .roleUser
        case .assistant: .roleAssistant
        case .system: .roleSystem
        }
    }
}
