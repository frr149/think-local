import SwiftUI

// MARK: - ToolCallingLabView

struct ToolCallingLabView: View {
    let parameters: GenerationParameters

    @State private var service = ToolCallingService()
    @State private var inputText: String = ""
    @State private var selectedToolID: ToolDefinition.ID?
    @FocusState private var inputFocused: Bool

    var body: some View {
        HSplitView {
            // MARK: Panel izquierdo — editor de tools
            toolsPanel
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 420)

            // MARK: Panel derecho — chat + invocaciones
            chatPanel
                .frame(minWidth: 360, maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Tools Panel

    private var toolsPanel: some View {
        VStack(spacing: 0) {
            // Cabecera
            HStack {
                Text("Tools")
                    .font(.headline)
                Spacer()
                Button {
                    let newTool = ToolDefinition()
                    service.definitions.append(newTool)
                    selectedToolID = newTool.id
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .help("Add tool")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Lista de tools
            if service.definitions.isEmpty {
                Spacer()
                Text("No tools defined")
                    .foregroundStyle(.tertiary)
                    .font(.callout)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach($service.definitions) { $definition in
                            toolRow(definition: $definition)
                        }
                    }
                    .padding(12)
                }
            }

            Divider()

            // Botón "Create Session"
            VStack(spacing: 8) {
                if service.sessionReady {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text("Session active")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    service.createSession(with: service.definitions)
                    inputFocused = true
                } label: {
                    Label("Create Session", systemImage: "play.fill")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.amberGold, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                .disabled(service.definitions.isEmpty)
            }
            .padding(12)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    // MARK: - Tool row

    private func toolRow(definition: Binding<ToolDefinition>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabecera de la fila con nombre y botón de borrar
            HStack {
                Text(definition.wrappedValue.name.isEmpty ? "(unnamed)" : definition.wrappedValue.name)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(definition.wrappedValue.name.isEmpty ? .tertiary : .primary)
                Spacer()
                Button(role: .destructive) {
                    service.definitions.removeAll { $0.id == definition.wrappedValue.id }
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Delete tool")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if selectedToolID == definition.wrappedValue.id {
                        selectedToolID = nil
                    } else {
                        selectedToolID = definition.wrappedValue.id
                    }
                }
            }

            // Editor expandido al seleccionar
            if selectedToolID == definition.wrappedValue.id {
                Divider()
                    .padding(.horizontal, 4)
                ToolDefinitionEditorView(definition: definition)
                    .padding(6)
            }
        }
        .background(
            selectedToolID == definition.wrappedValue.id
                ? Color.amberGold.opacity(0.06)
                : Color(nsColor: .windowBackgroundColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    selectedToolID == definition.wrappedValue.id
                        ? Color.amberGold.opacity(0.3)
                        : Color(nsColor: .separatorColor),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Chat Panel

    private var chatPanel: some View {
        VStack(spacing: 0) {
            // Cabecera del chat
            HStack {
                Text("Conversation")
                    .font(.headline)
                Spacer()
                Button {
                    service.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .disabled(service.messages.isEmpty && service.invocations.isEmpty)
                .help("Clear conversation")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Mensajes
            messagesArea

            Divider()

            // Input
            inputBar
        }
    }

    // MARK: - Messages area

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if service.messages.isEmpty && !service.isGenerating {
                        emptyChatState
                    } else {
                        ForEach(Array(service.messages.enumerated()), id: \.element.id) { index, message in
                            messageRow(message: message, index: index)

                            // Mostrar invocaciones después de mensajes assistant que contienen TOOL_CALL
                            if message.role == .assistant {
                                let relatedInvocations = service.invocations.filter { inv in
                                    message.content.contains(inv.toolName)
                                }
                                ForEach(relatedInvocations) { invocation in
                                    ToolInvocationBlockView(invocation: invocation)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                }
                            }
                        }

                        if service.isGenerating {
                            generatingIndicator
                        }

                        // Anchor para scroll automático
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: service.messages.count) {
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: service.isGenerating) {
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Message row (estilo consola, sin burbujas)

    private func messageRow(message: ChatMessage, index: Int) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Etiqueta de rol
            Text(roleLabel(for: message.role))
                .roleLabelStyle()
                .frame(width: 72, alignment: .trailing)
                .padding(.trailing, 12)
                .padding(.top, 1)

            // Contenido
            Text(message.content)
                .consoleOutputStyle()
                .foregroundStyle(message.role == .system ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(index.isMultiple(of: 2) ? Color.messageEven : Color.messageOdd)
    }

    private func roleLabel(for role: MessageRole) -> String {
        switch role {
        case .user:      "user"
        case .assistant: "assistant"
        case .system:    "system"
        }
    }

    // MARK: - Generating indicator

    private var generatingIndicator: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("assistant")
                .roleLabelStyle()
                .frame(width: 72, alignment: .trailing)
                .padding(.trailing, 12)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 5, height: 5)
                        .opacity(0.6)
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }

    // MARK: - Empty state

    private var emptyChatState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 40))
                .foregroundStyle(Color.amberGold.opacity(0.6))

            if service.sessionReady {
                Text("Session ready. Ask the model to use your tools.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .multilineTextAlignment(.center)
            } else {
                Text("Define tools on the left, then press\nCreate Session to begin.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask the model to use a tool…", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .font(.body)
                .focused($inputFocused)
                .onSubmit {
                    // onSubmit se dispara con Return sin Shift
                    submitMessage()
                }
                .disabled(!service.sessionReady || service.isGenerating)

            Button(action: submitMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        canSubmit ? Color.amberGold : Color.secondary
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var canSubmit: Bool {
        service.sessionReady
            && !service.isGenerating
            && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submitMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, service.sessionReady, !service.isGenerating else { return }
        inputText = ""
        Task {
            await service.send(message: text, parameters: parameters)
        }
    }
}
