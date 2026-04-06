import SwiftUI

struct CommandPaletteView: View {
    @Binding var isPresented: Bool
    @State private var searchText: String = ""
    @State private var selectedIndex: Int = 0
    @State private var registry: CommandRegistry
    @AppStorage("recentlyUsedCommands") private var recentlyUsedData: Data = Data()

    init(isPresented: Binding<Bool>, registry: CommandRegistry) {
        self._isPresented = isPresented
        self._registry = State(initialValue: registry)
    }

    private var filteredCommands: [Command] {
        if searchText.isEmpty {
            return recentlyUsed.isEmpty ? registry.commands : recentlyUsed
        }
        return registry.search(searchText)
    }

    private var recentlyUsed: [Command] {
        do {
            let ids = try JSONDecoder().decode([String].self, from: recentlyUsedData)
            return registry.commands.filter { ids.contains($0.id) }
        } catch {
            return []
        }
    }

    private func executeCommand(_ command: Command) {
        saveRecentlyUsed(command.id)
        command.action()
        isPresented = false
    }

    private func saveRecentlyUsed(_ id: String) {
        do {
            var ids = try JSONDecoder().decode([String].self, from: recentlyUsedData)
            ids.removeAll { $0 == id }
            ids.insert(id, at: 0)
            ids = Array(ids.prefix(10))
            recentlyUsedData = try JSONEncoder().encode(ids)
        } catch {
            let ids = [id]
            recentlyUsedData = (try? JSONEncoder().encode(ids)) ?? Data()
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search commands...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .default))
                }
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(.rect(topLeadingRadius: 8, topTrailingRadius: 8))

                if filteredCommands.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("No commands found")
                            .foregroundStyle(.secondary)
                        if !searchText.isEmpty {
                            Text("Try a different search")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                } else {
                    List(Array(filteredCommands.enumerated()), id: \.offset, selection: .constant(selectedIndex)) { index, command in
                        CommandRowView(command: command)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                executeCommand(command)
                            }
                            .background(
                                Group {
                                    if index == selectedIndex {
                                        Color.accentColor.opacity(0.2)
                                            .cornerRadius(4)
                                    }
                                }
                            )
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: 500, maxHeight: 400)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 20)
            .onKeyPress(.upArrow) {
                selectedIndex = max(0, selectedIndex - 1)
                return .handled
            }
            .onKeyPress(.downArrow) {
                selectedIndex = min(filteredCommands.count - 1, selectedIndex + 1)
                return .handled
            }
            .onKeyPress(.return) {
                if !filteredCommands.isEmpty, selectedIndex < filteredCommands.count {
                    executeCommand(filteredCommands[selectedIndex])
                }
                return .handled
            }
            .onKeyPress(.escape) {
                isPresented = false
                return .handled
            }
            .onAppear {
                selectedIndex = 0
            }
            .onChange(of: filteredCommands.count) {
                selectedIndex = 0
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

struct CommandRowView: View {
    let command: Command

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: command.icon)
                .font(.system(size: 16))
                .frame(width: 20, alignment: .center)
                .foregroundStyle(categoryColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(command.title)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            Spacer()

            if let shortcut = command.shortcut {
                Text(shortcut)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }

    private var categoryColor: Color {
        switch command.category {
        case .navigation:
            return .blue
        case .action:
            return .green
        case .template:
            return .orange
        }
    }
}

