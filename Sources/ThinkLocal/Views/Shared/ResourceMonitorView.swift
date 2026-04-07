import SwiftUI

// MARK: - Compact toolbar badge

struct ResourceMonitorBadge: View {
    let monitor: ResourceMonitorService
    let isGenerating: Bool

    @State private var dotOpacity: Double = 1.0

    var body: some View {
        HStack(spacing: 4) {
            Text("Neural Engine:")
                .statusTextStyle()

            Circle()
                .fill(isGenerating ? Color.green : Color.secondary)
                .frame(width: 6, height: 6)
                .opacity(dotOpacity)
                .onAppear {
                    guard isGenerating else { return }
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        dotOpacity = 0.3
                    }
                }
                .onChange(of: isGenerating) { _, generating in
                    if generating {
                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                            dotOpacity = 0.3
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            dotOpacity = 1.0
                        }
                    }
                }

            if isGenerating && monitor.tokensPerSecond > 0 {
                Text("Active · \(Int(monitor.tokensPerSecond)) tok/s")
                    .statusTextStyle()
            } else {
                Text(isGenerating ? "Active" : "Idle")
                    .statusTextStyle()
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
    }
}

// MARK: - Popover detail

struct ResourceMonitorPopover: View {
    let monitor: ResourceMonitorService
    let isGenerating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            metricRow(
                label: "CPU",
                value: String(format: "%.1f%%", monitor.cpuUsage),
                valueColor: monitor.cpuUsage > 80 ? .orange : .primary,
                sparkData: monitor.cpuHistory,
                sparkColor: monitor.cpuUsage > 80 ? .orange : .accentColor
            )

            Divider()

            metricRow(
                label: "MEM",
                value: String(format: "%.0f MB", monitor.memoryUsageMB),
                valueColor: .primary,
                sparkData: monitor.memoryHistory,
                sparkColor: .blue
            )

            Divider()

            metricRow(
                label: "ANE",
                value: isGenerating ? "Active" : "Idle",
                valueColor: isGenerating ? .green : .secondary,
                sparkData: [],
                sparkColor: .green,
                showSparkline: false
            )

            Divider()

            metricRow(
                label: "BAT",
                value: batteryValue,
                valueColor: monitor.batteryLevel < 20 ? .orange : .primary,
                sparkData: monitor.batteryHistory,
                sparkColor: monitor.batteryLevel < 20 ? .orange : .green
            )

            Divider()

            metricRow(
                label: "TPS",
                value: String(format: "%.1f tok/s", monitor.tokensPerSecond),
                valueColor: .primary,
                sparkData: monitor.tpsHistory,
                sparkColor: .purple
            )

            Divider()

            Text("30 samples / 1s interval")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .frame(width: 280)
    }

    private var batteryValue: String {
        var text = String(format: "%.0f%%", monitor.batteryLevel)
        if !monitor.isPluggedIn, let remaining = monitor.batteryTimeRemaining {
            let minutes = Int(remaining / 60)
            let hours = minutes / 60
            let mins = minutes % 60
            if hours > 0 {
                text += " · \(hours)h \(mins)m"
            } else {
                text += " · \(mins)m"
            }
        } else if monitor.isPluggedIn {
            text += " · Charging"
        }
        return text
    }

    @ViewBuilder
    private func metricRow(
        label: String,
        value: String,
        valueColor: Color,
        sparkData: [Double],
        sparkColor: Color,
        showSparkline: Bool = true
    ) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(.caption, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, alignment: .leading)

                Text(value)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(valueColor)
                    .monospacedDigit()

                Spacer()
            }

            if showSparkline {
                SparklineView(data: sparkData, color: sparkColor, height: 20)
            }
        }
    }
}

// MARK: - Combined view with popover trigger

struct ResourceMonitorView: View {
    let monitor: ResourceMonitorService
    let isGenerating: Bool

    @State private var showPopover: Bool = false

    var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            ResourceMonitorBadge(monitor: monitor, isGenerating: isGenerating)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPopover, arrowEdge: .bottom) {
            ResourceMonitorPopover(monitor: monitor, isGenerating: isGenerating)
        }
    }
}
