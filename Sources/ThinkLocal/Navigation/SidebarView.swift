import SwiftUI

struct SidebarView: View {
    @Binding var selection: AppMode
    var sessionStore: SessionStore
    @Binding var selectedSessionID: UUID?

    // Modes grouped by their group property
    private let groups: [[AppMode]] = {
        let allGroups = Dictionary(grouping: AppMode.allCases, by: \.group)
        return (0...2).compactMap { allGroups[$0] }
    }()

    var body: some View {
        List(selection: $selection) {
            ForEach(Array(groups.enumerated()), id: \.offset) { index, modes in
                if index > 0 {
                    Divider()
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 4)
                }
                ForEach(modes) { mode in
                    Label(mode.title, systemImage: mode.icon)
                        .tag(mode)
                }
            }

            Section {
                Divider()
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 4)
                Text("Sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .padding(.top, 4)

                if sessionStore.sessions.isEmpty {
                    Text("No sessions yet")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .italic()
                } else {
                    ForEach(sessionStore.groupedByDate, id: \.0) { dateGroup, sessions in
                        Text(dateGroup.label)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .fontWeight(.medium)
                            .padding(.top, 6)
                            .listRowSeparator(.hidden)

                        ForEach(sessions) { session in
                            SessionRowView(session: session, isSelected: selectedSessionID == session.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSessionID = session.id
                                    selection = .chat
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        sessionStore.delete(session)
                                        if selectedSessionID == session.id {
                                            selectedSessionID = nil
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        sessionStore.delete(session)
                                        if selectedSessionID == session.id {
                                            selectedSessionID = nil
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        // Theme.sidebarWidth = 200
        .frame(minWidth: Theme.sidebarWidth)
        .listStyle(.sidebar)
    }
}

// MARK: - Session row

private struct SessionRowView: View {
    let session: Session
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(session.title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(1)

            if !session.lastMessagePreview.isEmpty {
                Text(session.lastMessagePreview)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}
