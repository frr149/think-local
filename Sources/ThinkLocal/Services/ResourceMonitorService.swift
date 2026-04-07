import Foundation
import Observation
import IOKit.ps

@Observable
@MainActor
final class ResourceMonitorService {
    private(set) var cpuUsage: Double = 0
    private(set) var memoryUsageMB: Double = 0
    private(set) var batteryLevel: Double = 100
    private(set) var batteryTimeRemaining: TimeInterval? = nil
    private(set) var isPluggedIn: Bool = true
    private(set) var tokensPerSecond: Double = 0

    // Sparkline data (last 30 samples)
    private(set) var cpuHistory: [Double] = []
    private(set) var memoryHistory: [Double] = []
    private(set) var batteryHistory: [Double] = []
    private(set) var tpsHistory: [Double] = []

    private var timer: Timer?
    private let maxSamples = 30

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.sample()
            }
        }
        sample()
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func updateTokensPerSecond(_ tps: Double) {
        tokensPerSecond = tps
    }

    private func sample() {
        cpuUsage = Self.getProcessCPU()
        memoryUsageMB = Self.getProcessMemoryMB()
        (batteryLevel, batteryTimeRemaining, isPluggedIn) = Self.getBatteryInfo()

        cpuHistory.append(cpuUsage)
        memoryHistory.append(memoryUsageMB)
        batteryHistory.append(batteryLevel)
        tpsHistory.append(tokensPerSecond)

        if cpuHistory.count > maxSamples { cpuHistory.removeFirst() }
        if memoryHistory.count > maxSamples { memoryHistory.removeFirst() }
        if batteryHistory.count > maxSamples { batteryHistory.removeFirst() }
        if tpsHistory.count > maxSamples { tpsHistory.removeFirst() }
    }

    // CPU usage for current process
    private static func getProcessCPU() -> Double {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        let result = task_threads(mach_task_self_, &threadList, &threadCount)
        guard result == KERN_SUCCESS, let threads = threadList else { return 0 }

        var totalCPU: Double = 0
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var infoCount = mach_msg_type_number_t(MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(infoCount)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
                }
            }
            if result == KERN_SUCCESS {
                totalCPU += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100
            }
        }
        vm_deallocate(
            mach_task_self_,
            vm_address_t(bitPattern: threads),
            vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_act_t>.size)
        )
        return totalCPU
    }

    // Memory in MB for current process
    private static func getProcessMemoryMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        return Double(info.resident_size) / 1_048_576
    }

    // Battery info
    private static func getBatteryInfo() -> (level: Double, timeRemaining: TimeInterval?, isPluggedIn: Bool) {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any]
        else {
            return (100, nil, true)
        }

        let level = desc[kIOPSCurrentCapacityKey as String] as? Double ?? 100
        let maxCapacity = desc[kIOPSMaxCapacityKey as String] as? Double ?? 100
        let percentage = maxCapacity > 0 ? (level / maxCapacity) * 100 : 100
        let isCharging = desc[kIOPSIsChargingKey as String] as? Bool ?? true
        let timeToEmpty = desc[kIOPSTimeToEmptyKey as String] as? Int
        let timeRemaining: TimeInterval? = timeToEmpty.map { $0 > 0 ? TimeInterval($0 * 60) : nil } ?? nil

        return (percentage, timeRemaining, isCharging)
    }
}
