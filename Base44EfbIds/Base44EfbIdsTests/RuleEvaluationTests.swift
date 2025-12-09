import XCTest
@testable import Base44EfbIds

final class RuleEvaluationTests: XCTestCase {
    func testHighCpuRuleTriggersAfterThreshold() {
        let rule = HighCpuUsageRule(threshold: 50, consecutiveLimit: 2)
        var snapshot = TelemetrySnapshot(cpuLoad: 60)
        XCTAssertTrue(rule.evaluate(snapshot: snapshot).isEmpty)
        snapshot.cpuLoad = 65
        let events = rule.evaluate(snapshot: snapshot)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.category, .cpu)
    }

    func testUnusualNetworkRule() {
        let allowed = ["allowed.example"]
        let rule = UnusualNetworkDestinationRule(allowedHosts: allowed, minimumHits: 1)
        let event = NetworkEvent(url: URL(string: "https://bad.example")!, startTime: Date(), duration: 0.5, bytesSent: 10, bytesReceived: 20)
        let snapshot = TelemetrySnapshot(recentNetworkEvents: [event])
        let events = rule.evaluate(snapshot: snapshot)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.category, .network)
    }

    func testFileIntegrityViolationRule() {
        let baseline = ["/tmp/test.json": "abc"]
        let rule = FileIntegrityViolationRule(baseline: baseline)
        let state = FileHashState(path: "/tmp/test.json", hash: "xyz", lastModified: Date())
        let snapshot = TelemetrySnapshot(fileStates: [state])
        let events = rule.evaluate(snapshot: snapshot)
        XCTAssertEqual(events.first?.severity, .critical)
    }
}
