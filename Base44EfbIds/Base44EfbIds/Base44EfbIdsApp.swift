import SwiftUI

@main
struct Base44EfbIdsApp: App {
    @StateObject private var controller: MonitoringController
    @State private var isRunning = true

    init() {
        let cpu = CpuTelemetrySource()
        let network = NetworkTelemetrySource()
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let policyFile = documents.appendingPathComponent("policy.json")
        if !FileManager.default.fileExists(atPath: policyFile.path) {
            try? "{}".data(using: .utf8)?.write(to: policyFile)
        }
        let fileIntegrity = FileIntegrityTelemetrySource(monitoredFiles: [policyFile.path])

        let rules: [DetectionRule] = [
            HighCpuUsageRule(),
            UnusualNetworkDestinationRule(allowedHosts: ["apple.com", "base44.example"]),
            FileIntegrityViolationRule(baseline: [policyFile.path: ""])
        ]

        let engine = DetectionEngine(sources: [cpu, network, fileIntegrity], rules: rules)
        let config = MqttConfig(host: "example.com", port: 8883, clientId: UUID().uuidString, topicBase: "base44/efb/demo")
        let mqttClient = MqttClient(config: config)
        let publisher = TelemetryPublisher(client: mqttClient, config: config)
        let storeURL = documents.appendingPathComponent("events.json")
        let store = EventLogStore(fileURL: storeURL)
        _controller = StateObject(wrappedValue: MonitoringController(detectionEngine: engine, publisher: publisher, store: store))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(controller: controller, isRunning: $isRunning)
        }
    }
}
