# Base44EfbIds

Base44EfbIds is a lightweight Swift iPad application acting as an Electronic Flight Bag (EFB) intrusion detection agent. It monitors allowed iOS telemetry, evaluates simple rules, and publishes structured security events over MQTT while keeping resource usage low.

## Project layout

```
Base44EfbIds/
  Base44EfbIdsApp.swift      // SwiftUI entry point
  ContentView.swift          // Diagnostic UI
  SecurityEvent.swift        // Security event model
  TelemetrySnapshot.swift    // Shared telemetry payloads
  TelemetrySource.swift      // Source protocol
  CpuTelemetrySource.swift   // CPU sampler
  NetworkTelemetrySource.swift // URLProtocol-based logger
  FileIntegrityTelemetrySource.swift // Hash specific files
  DetectionEngine.swift      // Aggregates telemetry + rules
  HighCpuUsageRule.swift
  UnusualNetworkDestinationRule.swift
  FileIntegrityViolationRule.swift
  MqttClient.swift           // Wrapper around CocoaMQTT
  TelemetryPublisher.swift
  EventLogStore.swift
  MonitoringController.swift // Glue for UI/publishing/storage
Base44EfbIdsTests/
  ... unit tests for rules, MQTT publishing, and encoding
```

The Xcode app target should be named **Base44EfbIds** with a minimum deployment target of iOS 16 to align with current iPad hardware and SwiftUI support.

## Building and running

1. Open `Base44EfbIds.xcodeproj` (or create one pointing at the `Base44EfbIds` sources) in Xcode 15+.
2. Ensure the deployment target is iPadOS/iOS 16 or later.
3. Add the [CocoaMQTT](https://github.com/emqx/CocoaMQTT) dependency via Swift Package Manager.
4. Build and run on an iPad (or simulator for UI validation).

The app presents a diagnostic screen indicating MQTT connectivity, events sent/queued, and a rolling list of recent security events. Monitoring begins automatically but can be paused with the toggle on screen.

## MQTT configuration

`MqttConfig` defines connection parameters:

```swift
let config = MqttConfig(
    host: "mqtt.example.com",
    port: 8883,
    clientId: UUID().uuidString,
    username: "pilot",
    password: "secret",
    tls: true,
    topicBase: "base44/efb/<device_id>/telemetry"
)
```

Update `Base44EfbIdsApp` with your broker values. Events are published to `topicBase/events` as JSON. `TelemetryPublisher` queues events while offline and flushes when connectivity returns.

## Telemetry collected (within iOS constraints)

- **CPU usage**: app-level CPU load derived from thread metrics at a 5s cadence.
- **Network usage**: outbound requests initiated by the app are intercepted via a custom `URLProtocol` that records host, timing, and byte counts.
- **File integrity**: hashes monitored files within the app container (e.g., policy or configuration JSON/PLIST files) to detect unexpected modifications.

All telemetry uses public APIs and remains inside the sandbox; no attempts are made to bypass iOS security boundaries.

## Detection rules

Sample rule implementations demonstrate extensibility:
- High CPU for consecutive samples.
- Connections to non-whitelisted destinations.
- File hash changes relative to a baseline.

Rules emit `SecurityEvent` objects that the publisher forwards and the UI displays.

### SecurityEvent JSON example

```json
{
  "id": "3A19A898-8B6A-4D7E-A0D0-8AF6AD740A9A",
  "timestamp": "2024-04-22T12:00:00Z",
  "severity": "warning",
  "category": "network",
  "message": "Unusual network destinations: malicious.example",
  "details": {
    "malicious.example": "3"
  }
}
```

## Local storage

`EventLogStore` keeps recent events in a compact JSON array with bounded entries. It automatically truncates to the configured maximum entry count to prevent unbounded disk growth.

## Alternative path (experimental)

A future experiment could package a Python-based IDS agent using Kivy or BeeWare running inside an iOS app container. The Python module would mirror the telemetry, rules, and MQTT publishing behavior described here while keeping the Swift UI for visibility.
