import SwiftUI

struct RoleLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.caption, design: .monospaced).smallCaps())
            .foregroundStyle(.secondary)
    }
}

struct ConsoleOutputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
    }
}

struct StatusTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
    }
}

struct MetricValueStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.callout, design: .monospaced).weight(.semibold))
            .monospacedDigit()
    }
}

extension View {
    func roleLabelStyle() -> some View { modifier(RoleLabelStyle()) }
    func consoleOutputStyle() -> some View { modifier(ConsoleOutputStyle()) }
    func statusTextStyle() -> some View { modifier(StatusTextStyle()) }
    func metricValueStyle() -> some View { modifier(MetricValueStyle()) }
}
