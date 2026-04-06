import SwiftUI

extension Notification.Name {
    static let newSession = Notification.Name("newSession")
}

struct NavigationShell: View {
    // Persists selected mode across launches
    @SceneStorage("selectedMode") private var selectedModeRaw: String = AppMode.chat.rawValue
    @State private var showInspector: Bool = true
    @State private var parameters: GenerationParameters = .balanced
    @State private var showCommandPalette: Bool = false
    @State private var showCompareMode: Bool = false
    @State private var commandRegistry: CommandRegistry = CommandRegistry()
    @State private var imageService = ImageGenerationService()
    @State private var resourceMonitor = ResourceMonitorService()
    @State private var modelService = ModelService()
    @State private var systemPrompt = "You are a helpful assistant."
    @State private var sessionStore = SessionStore()
    @State private var activeSessionID: UUID?

    private var selectedMode: AppMode {
        AppMode(rawValue: selectedModeRaw) ?? .chat
    }

    private func handleAction(_ action: AppAction) {
        switch action {
        case .switchMode(let index):
            guard index >= 0, index < AppMode.allCases.count else { return }
            selectedModeRaw = AppMode.allCases[index].rawValue
        case .toggleInspector:
            showInspector.toggle()
        case .toggleCommandPalette:
            showCommandPalette.toggle()
        case .newSession:
            activeSessionID = nil
            selectedModeRaw = AppMode.chat.rawValue
            NotificationCenter.default.post(name: .newSession, object: nil)
        case .exportCurrentMode:
            break // TODO: wire to ExportService
        }
    }

    private func setupCommandRegistry() {
        commandRegistry.commands = [
            // Navigation commands
            Command(
                title: "Go to Chat",
                icon: "brain",
                shortcut: "⌘1",
                category: .navigation,
                action: { selectedModeRaw = AppMode.chat.rawValue }
            ),
            Command(
                title: "Go to Image Studio",
                icon: "paintpalette",
                shortcut: "⌘2",
                category: .navigation,
                action: { selectedModeRaw = AppMode.imageStudio.rawValue }
            ),
            Command(
                title: "Go to Schemas",
                icon: "curlybraces",
                shortcut: "⌘3",
                category: .navigation,
                action: { selectedModeRaw = AppMode.schemas.rawValue }
            ),
            Command(
                title: "Go to Tools Lab",
                icon: "wrench.and.screwdriver",
                shortcut: "⌘4",
                category: .navigation,
                action: { selectedModeRaw = AppMode.toolsLab.rawValue }
            ),
            Command(
                title: "Go to Model Info",
                icon: "cpu",
                shortcut: "⌘5",
                category: .navigation,
                action: { selectedModeRaw = AppMode.modelInfo.rawValue }
            ),
            // Action commands
            Command(
                title: "New Session",
                icon: "plus.square",
                shortcut: "⌘N",
                category: .action,
                action: { handleAction(.newSession) }
            ),
            Command(
                title: "Toggle Inspector",
                icon: "sidebar.right",
                shortcut: "⌘⇧I",
                category: .action,
                action: { handleAction(.toggleInspector) }
            ),
            Command(
                title: "Export",
                icon: "arrow.up.doc",
                shortcut: "⌘E",
                category: .action,
                action: { handleAction(.exportCurrentMode) }
            ),
            // Template commands
            Command(
                title: "/classify — Classify text into categories",
                icon: "tag",
                shortcut: nil,
                category: .template,
                action: { /* Insert /classify template */ }
            ),
            Command(
                title: "/summarize — Summarize text concisely",
                icon: "text.quote",
                shortcut: nil,
                category: .template,
                action: { /* Insert /summarize template */ }
            ),
            Command(
                title: "/extract — Extract structured data",
                icon: "doc.text",
                shortcut: nil,
                category: .template,
                action: { /* Insert /extract template */ }
            ),
            Command(
                title: "/translate — Translate to another language",
                icon: "globe",
                shortcut: nil,
                category: .template,
                action: { /* Insert /translate template */ }
            ),
        ]
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                selection: Binding(
                    get: { selectedMode },
                    set: { selectedModeRaw = $0.rawValue }
                ),
                sessionStore: sessionStore,
                selectedSessionID: $activeSessionID
            )
        } detail: {
            VStack(spacing: 0) {
                // Central canvas placeholder per mode
                ZStack {
                    Color.clear
                    Group {
                        switch selectedMode {
                        case .modelInfo:
                            ModelInspectorView(modelService: modelService)
                        case .chat:
                            if showCompareMode {
                                CompareView(
                                    parameters: $parameters,
                                    systemPrompt: $systemPrompt
                                )
                            } else {
                                ChatView(
                                    modelService: modelService,
                                    parameters: $parameters,
                                    systemPrompt: $systemPrompt,
                                    sessionStore: sessionStore,
                                    sessionID: $activeSessionID
                                )
                            }
                        case .schemas:
                            StructuredOutputView(
                                modelService: modelService,
                                parameters: $parameters
                            )
                        case .toolsLab:
                            ToolCallingLabView(parameters: parameters)
                        case .imageStudio:
                            ImageStudioView(service: imageService)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                StatusBarView(
                    mode: selectedMode,
                    showParams: !showInspector,
                    parameters: parameters
                )
            }
        }
        // Theme.minWindowWidth = 900, Theme.minWindowHeight = 600
        .frame(minWidth: Theme.minWindowWidth, minHeight: Theme.minWindowHeight)
        .focusedValue(\.appAction, handleAction)
        .inspector(isPresented: $showInspector) {
            InspectorView(mode: selectedMode, parameters: $parameters, systemPrompt: $systemPrompt)
        }
        // Command palette overlay
        .overlay {
            if showCommandPalette {
                CommandPaletteView(isPresented: $showCommandPalette, registry: commandRegistry)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ResourceMonitorView(
                    monitor: resourceMonitor,
                    isGenerating: modelService.isGenerating
                )
            }
            if selectedMode == .chat {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showCompareMode.toggle()
                    } label: {
                        Image(systemName: "rectangle.split.2x1")
                    }
                    .help(showCompareMode ? "Exit Compare Mode" : "Enter Compare Mode")
                    .foregroundStyle(showCompareMode ? Color.amberGold : Color.primary)
                }
            }
        }
        .onAppear {
            setupCommandRegistry()
            resourceMonitor.startMonitoring()
        }
        .onChange(of: modelService.tokensPerSecond) { _, tps in
            resourceMonitor.updateTokensPerSecond(tps)
        }
    }
}
