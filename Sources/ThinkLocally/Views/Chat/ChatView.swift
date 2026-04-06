import SwiftUI

struct ChatView: View {
    @Bindable var modelService: ModelService
    @Binding var parameters: GenerationParameters
    @Binding var systemPrompt: String
    var sessionStore: SessionStore
    @Binding var sessionID: UUID?

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var streamingContent = ""
    @State private var isStreaming = false
    @State private var scrollTarget: UUID?
    @State private var showContextWarning = false
    @State private var firstRunManager = FirstRunManager()
    @State private var showFirstRunBanner = false

    // ID de la sesión activa en memoria (puede diferir de sessionID mientras no haya mensajes)
    @State private var activeSession: Session?

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            MessageView(message: message, isEven: index.isMultiple(of: 2))
                        }

                        // Streaming message (assistant typing)
                        if isStreaming {
                            streamingMessageView
                        }

                        // Context warning
                        if showContextWarning {
                            contextWarningView
                        }

                        // First run banner
                        if showFirstRunBanner {
                            FirstRunBannerView()
                                .padding(.vertical, 8)
                        }

                        // Scroll anchor
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                }
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: streamingContent) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }

            Divider()

            // Token bar
            TokenBarView(usage: modelService.tokenUsage)

            Divider()

            // Input
            ChatInputView(
                text: $inputText,
                isGenerating: isStreaming,
                onSend: sendMessage
            )
        }
        .onAppear {
            modelService.checkAvailability()
            if modelService.availability == .available {
                modelService.createSession(systemPrompt: systemPrompt)
            }
        }
        // Cargar sesión cuando se selecciona desde el sidebar
        .onChange(of: sessionID) { _, newID in
            loadSession(id: newID)
        }
        // Nueva sesión desde ⌘N o command palette
        .onReceive(NotificationCenter.default.publisher(for: .newSession)) { _ in
            startNewSession()
        }
    }

    // MARK: - Session management

    private func loadSession(id: UUID?) {
        guard let id else {
            startNewSession()
            return
        }
        guard let session = sessionStore.sessions.first(where: { $0.id == id }) else { return }
        activeSession = session
        messages = session.messages
        systemPrompt = session.systemPrompt
        parameters = session.parameters
        showContextWarning = false

        // Re-crear sesión de modelo con el system prompt correcto
        if modelService.availability == .available {
            modelService.createSession(systemPrompt: session.systemPrompt)
        }
    }

    private func startNewSession() {
        messages = []
        streamingContent = ""
        isStreaming = false
        showContextWarning = false
        activeSession = nil

        if modelService.availability == .available {
            modelService.createSession(systemPrompt: systemPrompt)
        }
    }

    private func persistCurrentSession() {
        guard !messages.isEmpty else { return }

        if activeSession == nil {
            // Primera vez que guardamos esta sesión
            var session = Session(messages: messages, parameters: parameters, systemPrompt: systemPrompt)
            sessionStore.save(session)
            activeSession = session
            sessionID = session.id
        } else {
            // Actualizar sesión existente
            var session = activeSession!
            session.messages = messages
            session.parameters = parameters
            session.systemPrompt = systemPrompt
            sessionStore.save(session)
            activeSession = session
        }
    }

    // MARK: - Streaming message

    private var streamingMessageView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ASSISTANT")
                .roleLabelStyle()
                .foregroundStyle(Color.roleAssistant)

            HStack(alignment: .top, spacing: 4) {
                Text(streamingContent)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)

                // Blinking cursor
                Rectangle()
                    .fill(Color.amberGold)
                    .frame(width: 2, height: 16)
                    .opacity(isStreaming ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: isStreaming)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(messages.count.isMultiple(of: 2) ? Color.messageEven : Color.messageOdd)
    }

    // MARK: - Context warning

    private var contextWarningView: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.caption)
            Text("Context is \(Int(modelService.tokenUsage.percentage * 100))% full. Consider starting a new session.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tokenWarning.opacity(0.08))
    }

    // MARK: - Send

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isStreaming else { return }

        // Ensure session exists
        if modelService.availability == .available {
            if messages.isEmpty {
                modelService.createSession(systemPrompt: systemPrompt)
            }
        }

        // Add user message
        let userTokens = ModelService.estimateTokens(trimmed)
        let userMessage = ChatMessage(role: .user, content: trimmed, tokenCount: userTokens)
        messages.append(userMessage)
        inputText = ""

        // Start streaming response
        isStreaming = true
        streamingContent = ""

        Task {
            do {
                let stream = modelService.generateStream(prompt: trimmed, with: parameters)
                for try await delta in stream {
                    streamingContent += delta
                }

                // Streaming complete — add as message
                let assistantTokens = ModelService.estimateTokens(streamingContent)
                let assistantMessage = ChatMessage(
                    role: .assistant,
                    content: streamingContent,
                    tokenCount: assistantTokens
                )
                messages.append(assistantMessage)
                streamingContent = ""
                isStreaming = false

                // Guardar sesión tras cada intercambio completo
                persistCurrentSession()

                // First run banner
                if firstRunManager.shouldShowFirstRunMessage {
                    showFirstRunBanner = true
                    firstRunManager.markFirstRunShown()
                }

                // Context warning
                showContextWarning = modelService.tokenUsage.isCritical

            } catch let error as ModelError {
                isStreaming = false
                streamingContent = ""

                switch error {
                case .guardrailViolation:
                    messages.append(ChatMessage(
                        role: .system,
                        content: "⚠ The model declined this request due to content guidelines."
                    ))
                case .contextOverflow:
                    showContextWarning = true
                    messages.append(ChatMessage(
                        role: .system,
                        content: "Context window full. Start a new session to continue."
                    ))
                default:
                    messages.append(ChatMessage(
                        role: .system,
                        content: "Error: \(error.localizedDescription)"
                    ))
                }

                // Guardar aunque sea el mensaje de error
                persistCurrentSession()

            } catch {
                isStreaming = false
                streamingContent = ""
                messages.append(ChatMessage(
                    role: .system,
                    content: "Error: \(error.localizedDescription)"
                ))
                persistCurrentSession()
            }
        }
    }
}
