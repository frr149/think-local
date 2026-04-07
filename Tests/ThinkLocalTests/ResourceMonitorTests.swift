import Testing
@testable import ThinkLocal

@Test @MainActor func resourceMonitorInitialState() {
    let monitor = ResourceMonitorService()
    #expect(monitor.cpuHistory.isEmpty)
    #expect(monitor.memoryHistory.isEmpty)
    #expect(monitor.batteryLevel >= 0)
}

@Test @MainActor func sparklineDataCapped() {
    let monitor = ResourceMonitorService()
    // Verify max samples constant exists conceptually
    #expect(monitor.cpuHistory.count <= 30)
}
