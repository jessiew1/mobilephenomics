import Foundation
import os.log

public final class CpuTelemetrySource: TelemetrySource {
    private var timer: Timer?
    private var latestLoad: Double = 0
    private let logger = Logger(subsystem: "Base44EfbIds", category: "CpuTelemetry")

    public init() {}

    public func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.latestLoad = self?.sampleCpuLoad() ?? 0
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    public func collectSnapshot() -> TelemetrySnapshot {
        TelemetrySnapshot(cpuLoad: latestLoad)
    }

    private func sampleCpuLoad() -> Double {
        var threadsList = thread_act_array_t(nil)
        var threadCount: mach_msg_type_number_t = 0
        var threadInfo: thread_info_data_t = [integer_t](repeating: 0, count: Int(THREAD_INFO_MAX))
        var threadInfoCount: mach_msg_type_number_t
        var totalCPU: Double = 0

        let result = withUnsafeMutablePointer(to: &threadsList) { threadsPointer -> kern_return_t in
            return threadsPointer.withMemoryRebound(to: thread_act_t?.self, capacity: 1) { reboundPointer in
                task_threads(mach_task_self_, reboundPointer, &threadCount)
            }
        }

        if result == KERN_SUCCESS {
            for i in 0..<threadCount {
                threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let threadResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) { reboundPointer in
                        thread_info(threadsList[Int(i)], thread_flavor_t(THREAD_BASIC_INFO), reboundPointer, &threadInfoCount)
                    }
                }
                guard threadResult == KERN_SUCCESS else { continue }
                let threadBasicInfo = threadInfo.withUnsafeBufferPointer { buffer -> thread_basic_info in
                    let pointer = UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: thread_basic_info.self)
                    return pointer.pointee
                }
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalCPU += Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                }
            }
        } else {
            logger.error("Failed to collect thread info: \(result)")
        }
        return min(100.0, totalCPU)
    }
}
