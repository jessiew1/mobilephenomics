import Foundation
import Combine

public final class MonitoringController: ObservableObject {
    @Published public private(set) var recentEvents: [SecurityEvent] = []
    @Published public private(set) var isConnected: Bool = false
    @Published public private(set) var queuedCount: Int = 0
    @Published public private(set) var sentCount: Int = 0

    private let detectionEngine: DetectionEngine
    private let publisher: TelemetryPublisher
    private let store: EventLogStore

    public init(detectionEngine: DetectionEngine, publisher: TelemetryPublisher, store: EventLogStore) {
        self.detectionEngine = detectionEngine
        self.publisher = publisher
        self.store = store
        self.recentEvents = store.loadRecent(limit: 25)
        detectionEngine.delegate = self
        publisher.delegate = self
    }

    public func start() {
        detectionEngine.start()
        publisher.connect()
    }

    public func stop() {
        detectionEngine.stop()
        publisher.disconnect()
    }
}

extension MonitoringController: DetectionEngineDelegate {
    public func detectionEngine(_ engine: DetectionEngine, didProduce events: [SecurityEvent]) {
        events.forEach { event in
            store.append(event: event)
            publisher.publish(event: event)
        }
        DispatchQueue.main.async {
            self.recentEvents = Array((self.recentEvents + events).suffix(50))
        }
    }
}

extension MonitoringController: TelemetryPublisherDelegate {
    public func telemetryPublisherDidUpdateQueue(_ publisher: TelemetryPublisher, queued: Int, sent: Int) {
        DispatchQueue.main.async {
            self.queuedCount = queued
            self.sentCount = sent
        }
    }

    public func telemetryPublisher(_ publisher: TelemetryPublisher, connectionChanged isConnected: Bool) {
        DispatchQueue.main.async {
            self.isConnected = isConnected
        }
    }
}
