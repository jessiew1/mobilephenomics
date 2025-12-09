import XCTest
@testable import Base44EfbIds

final class TelemetryPublisherTests: XCTestCase {
    func testQueueFlushesWhenConnected() {
        let mock = MockMQTTClient()
        let config = MqttConfig(host: "localhost", port: 1883, clientId: "test", topicBase: "base44/test")
        let publisher = TelemetryPublisher(client: mock, config: config)
        publisher.connect()
        let event = SecurityEvent(severity: .info, category: .system, message: "hello")
        publisher.publish(event: event)
        XCTAssertEqual(mock.publishedMessages.count, 1)
    }
}

final class MockMQTTClient: MQTTClientType {
    var isConnected: Bool = false
    var publishedMessages: [(String, String)] = []

    func connect() { isConnected = true }
    func disconnect() { isConnected = false }
    func publish(topic: String, message: String) {
        publishedMessages.append((topic, message))
    }
}
