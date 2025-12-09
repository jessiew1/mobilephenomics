import Foundation

public protocol DetectionRule {
    func evaluate(snapshot: TelemetrySnapshot) -> [SecurityEvent]
}
