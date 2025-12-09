import Foundation

public final class HighCpuUsageRule: DetectionRule {
    private let threshold: Double
    private let consecutiveLimit: Int
    private var consecutiveHits = 0

    public init(threshold: Double = 80.0, consecutiveLimit: Int = 3) {
        self.threshold = threshold
        self.consecutiveLimit = consecutiveLimit
    }

    public func evaluate(snapshot: TelemetrySnapshot) -> [SecurityEvent] {
        guard let cpuLoad = snapshot.cpuLoad else { return [] }
        if cpuLoad >= threshold {
            consecutiveHits += 1
        } else {
            consecutiveHits = 0
        }

        guard consecutiveHits >= consecutiveLimit else { return [] }
        return [SecurityEvent(
            severity: .warning,
            category: .cpu,
            message: "High CPU usage detected",
            details: [
                "cpuLoad": String(format: "%.2f", cpuLoad),
                "consecutiveSamples": "\(consecutiveHits)"
            ]
        )]
    }
}
