import SwiftUI

/// A single panel inside CompareView — shows its own header, message list, and token bar.
struct ComparePanel: View {
    let title: String
    @Binding var params: GenerationParameters
    let messages: [ChatMessage]
    let streamingContent: String
    let tokenUsage: TokenUsage

    @State private var showParamPopover = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Message list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            MessageView(message: message, isEven: index.isMultiple(of: 2))
                        }

                        // Streaming bubble
                        if !streamingContent.isEmpty {
                            streamingView(isEven: messages.count.isMultiple(of: 2))
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                }
                .onChange(of: messages.count) {
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
                .onChange(of: streamingContent) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }

            Divider()

            // Token bar
            TokenBarView(usage: tokenUsage)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Spacer()

            // Param summary chip — tapping opens popover
            Button {
                showParamPopover = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape")
                        .font(.caption2)
                    Text(params.summary)
                        .font(.system(.caption2, design: .monospaced))
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .popover(isPresented: $showParamPopover, arrowEdge: .bottom) {
                ScrollView {
                    ParameterTunerView(parameters: $params)
                        .padding(16)
                }
                .frame(width: 280, height: 400)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    // MARK: - Streaming view

    private func streamingView(isEven: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ASSISTANT")
                .roleLabelStyle()
                .foregroundStyle(Color.roleAssistant)

            HStack(alignment: .top, spacing: 4) {
                Text(streamingContent)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Blinking cursor
                Rectangle()
                    .fill(Color.amberGold)
                    .frame(width: 2, height: 16)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: streamingContent.isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isEven ? Color.messageEven : Color.messageOdd)
    }
}
