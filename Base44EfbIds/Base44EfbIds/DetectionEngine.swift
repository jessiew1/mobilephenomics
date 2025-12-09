import Foundation
import os.log

public protocol DetectionEngineDelegate: AnyObject {
    func detectionEngine(_ engine: DetectionEngine, didProduce events: [SecurityEvent])
}

public final class DetectionEngine {
    private let sources: [TelemetrySource]
    private let rules: [DetectionRule]
    private let logger = Logger(subsystem: "Base44EfbIds", category: "DetectionEngine")
    private var timer: Timer?
    public weak var delegate: DetectionEngineDelegate?

    public init(sources: [TelemetrySource], rules: [DetectionRule]) {
        self.sources = sources
        self.rules = rules
    }

    public func start(interval: TimeInterval = 10) {
        sources.forEach { $0.start() }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.runEvaluation()
        }
    }

    public func stop() {
        sources.forEach { $0.stop() }
        timer?.invalidate()
        timer = nil
    }

    private func runEvaluation() {
        var mergedSnapshot = TelemetrySnapshot()
        sources.forEach { source in
            let snapshot = source.collectSnapshot()
            mergedSnapshot.merge(with: snapshot)
        }
        let events = rules.flatMap { $0.evaluate(snapshot: mergedSnapshot) }
        guard !events.isEmpty else { return }
        logger.log("Detection generated \(events.count) events")
        delegate?.detectionEngine(self, didProduce: events)
    }
}
