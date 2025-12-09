import Foundation

public final class FileIntegrityViolationRule: DetectionRule {
    private var baseline: [String: String]

    public init(baseline: [String: String]) {
        self.baseline = baseline
    }

    public func evaluate(snapshot: TelemetrySnapshot) -> [SecurityEvent] {
        var events: [SecurityEvent] = []
        for state in snapshot.fileStates {
            guard let baselineHash = baseline[state.path] else { continue }
            if baselineHash != state.hash {
                events.append(SecurityEvent(
                    severity: .critical,
                    category: .file,
                    message: "File integrity violation detected",
                    details: [
                        "path": state.path,
                        "expectedHash": baselineHash,
                        "observedHash": state.hash
                    ]
                ))
            }
        }
        return events
    }

    public func updateBaseline(with snapshot: TelemetrySnapshot) {
        snapshot.fileStates.forEach { state in
            baseline[state.path] = state.hash
        }
    }
}
