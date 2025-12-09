import Foundation

public final class UnusualNetworkDestinationRule: DetectionRule {
    private let allowedHosts: Set<String>
    private let minimumHits: Int

    public init(allowedHosts: [String], minimumHits: Int = 2) {
        self.allowedHosts = Set(allowedHosts)
        self.minimumHits = minimumHits
    }

    public func evaluate(snapshot: TelemetrySnapshot) -> [SecurityEvent] {
        let suspicious = snapshot.recentNetworkEvents.filter { event in
            guard let host = event.url.host else { return false }
            return !allowedHosts.contains(host)
        }
        guard suspicious.count >= minimumHits else { return [] }
        let hostCounts = Dictionary(grouping: suspicious, by: { $0.url.host ?? "unknown" })
            .mapValues { $0.count }
        let message = "Unusual network destinations: \(hostCounts.keys.joined(separator: ", "))"
        var details: [String: String] = [:]
        for (host, count) in hostCounts {
            details[host] = "\(count)"
        }
        return [SecurityEvent(
            severity: .warning,
            category: .network,
            message: message,
            details: details
        )]
    }
}
