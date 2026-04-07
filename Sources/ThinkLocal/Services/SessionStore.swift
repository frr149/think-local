import Foundation
import Observation

// Agrupación de sesiones por fecha, con orden determinista
enum DateGroup: Comparable, Hashable {
    case today
    case yesterday
    case older(Date)

    var label: String {
        switch self {
        case .today: "Today"
        case .yesterday: "Yesterday"
        case .older(let date):
            Self.formatter.string(from: date)
        }
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    static func < (lhs: DateGroup, rhs: DateGroup) -> Bool {
        switch (lhs, rhs) {
        case (.today, _): return true
        case (_, .today): return false
        case (.yesterday, _): return true
        case (_, .yesterday): return false
        case (.older(let a), .older(let b)): return a > b  // más reciente primero
        }
    }
}

@Observable
@MainActor
final class SessionStore {
    private(set) var sessions: [Session] = []
    private let directory: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        directory = appSupport.appendingPathComponent("ThinkLocal/sessions", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        loadAll()
    }

    // Sesiones agrupadas por fecha para mostrar en el sidebar
    var groupedByDate: [(DateGroup, [Session])] {
        let calendar = Calendar.current
        let sorted = sessions.sorted(by: { $0.updatedAt > $1.updatedAt })
        let grouped = Dictionary(grouping: sorted) { session -> DateGroup in
            if calendar.isDateInToday(session.updatedAt) { return .today }
            if calendar.isDateInYesterday(session.updatedAt) { return .yesterday }
            let startOfDay = calendar.startOfDay(for: session.updatedAt)
            return .older(startOfDay)
        }
        return grouped.sorted { $0.key < $1.key }
    }

    func save(_ session: Session) {
        var updated = session
        updated.updatedAt = Date()

        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = updated
        } else {
            sessions.insert(updated, at: 0)
        }
        writeToDisk(updated)
    }

    func delete(_ session: Session) {
        sessions.removeAll(where: { $0.id == session.id })
        let url = directory.appendingPathComponent("\(session.id.uuidString).json")
        try? FileManager.default.removeItem(at: url)
    }

    func loadAll() {
        let dir = directory
        Task.detached {
            let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
            let loaded = files.compactMap { url -> Session? in
                guard url.pathExtension == "json",
                      let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(Session.self, from: data)
            }.sorted(by: { $0.updatedAt > $1.updatedAt })

            await MainActor.run {
                self.sessions = loaded
            }
        }
    }

    private func writeToDisk(_ session: Session) {
        let url = directory.appendingPathComponent("\(session.id.uuidString).json")
        if let data = try? JSONEncoder().encode(session) {
            try? data.write(to: url)
        }
    }
}
