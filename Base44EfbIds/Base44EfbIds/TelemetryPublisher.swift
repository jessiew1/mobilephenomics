import Foundation
import os.log

public protocol TelemetryPublisherDelegate: AnyObject {
    func telemetryPublisherDidUpdateQueue(_ publisher: TelemetryPublisher, queued: Int, sent: Int)
    func telemetryPublisher(_ publisher: TelemetryPublisher, connectionChanged isConnected: Bool)
}

public final class TelemetryPublisher {
    private let client: MQTTClientType
    private let config: MqttConfig
    private var queue: [SecurityEvent] = []
    private let encoder = JSONEncoder()
    private let logger = Logger(subsystem: "Base44EfbIds", category: "TelemetryPublisher")
    private var sentCount = 0
    public weak var delegate: TelemetryPublisherDelegate?

    public init(client: MQTTClientType, config: MqttConfig) {
        self.client = client
        self.config = config
        encoder.dateEncodingStrategy = .iso8601
    }

    public func connect() {
        client.connect()
        delegate?.telemetryPublisher(self, connectionChanged: client.isConnected)
        flushQueue()
    }

    public func disconnect() {
        client.disconnect()
        delegate?.telemetryPublisher(self, connectionChanged: false)
    }

    public func publish(event: SecurityEvent) {
        queue.append(event)
        flushQueue()
    }

    private func flushQueue() {
        guard client.isConnected else { return }
        while !queue.isEmpty {
            let event = queue.removeFirst()
            guard let data = try? encoder.encode(event), let json = String(data: data, encoding: .utf8) else { continue }
            let topic = "\(config.topicBase)/events"
            client.publish(topic: topic, message: json)
            sentCount += 1
        }
        delegate?.telemetryPublisherDidUpdateQueue(self, queued: queue.count, sent: sentCount)
    }
}
