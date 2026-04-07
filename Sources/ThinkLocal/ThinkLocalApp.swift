import SwiftUI

@main
struct ThinkLocalApp: App {
    @Environment(\.openWindow) var openWindow
    @FocusedValue(\.appAction) var appAction

    var body: some Scene {
        WindowGroup {
            NavigationShell()
        }
        .defaultSize(width: 1200, height: 800)
        .windowResizability(.contentMinSize)

        Window("About Think Local", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Think Local") {
                    openWindow(id: "about")
                }
            }

            CommandGroup(replacing: .help) {}

            CommandMenu("File") {
                Button("Export") {
                    appAction?(.exportCurrentMode)
                }
                .keyboardShortcut("e", modifiers: .command)
            }

            CommandMenu("Navigate") {
                Button("Command Palette") {
                    appAction?(.toggleCommandPalette)
                }
                .keyboardShortcut("k", modifiers: .command)

                Divider()

                ForEach(Array(AppMode.allCases.enumerated()), id: \.offset) { index, mode in
                    Button(mode.title) {
                        appAction?(.switchMode(index))
                    }
                    .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
                }

                Divider()

                Button("Toggle Inspector") {
                    appAction?(.toggleInspector)
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
            }
        }
    }
}
