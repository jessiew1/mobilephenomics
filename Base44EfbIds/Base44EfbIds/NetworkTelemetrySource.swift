import Foundation
import os.log

public final class NetworkTelemetrySource: TelemetrySource {
    private let queue = DispatchQueue(label: "NetworkTelemetrySource")
    private var recentEvents: [NetworkEvent] = []
    private let logger = Logger(subsystem: "Base44EfbIds", category: "NetworkTelemetry")
    private let windowSize: TimeInterval

    public init(windowSize: TimeInterval = 300) {
        self.windowSize = windowSize
    }

    public func start() {
        LoggingURLProtocol.source = self
    }

    public func stop() {
        LoggingURLProtocol.source = nil
    }

    public func collectSnapshot() -> TelemetrySnapshot {
        pruneOldEvents()
        return TelemetrySnapshot(recentNetworkEvents: recentEvents)
    }

    fileprivate func record(event: NetworkEvent) {
        queue.async {
            self.recentEvents.append(event)
            self.pruneOldEvents()
            self.logger.debug("Logged network event for \(event.url.absoluteString)")
        }
    }

    private func pruneOldEvents() {
        let cutoff = Date().addingTimeInterval(-windowSize)
        recentEvents = recentEvents.filter { $0.startTime >= cutoff }
    }

    public func instrument(_ configuration: URLSessionConfiguration) -> URLSessionConfiguration {
        var classes = configuration.protocolClasses ?? []
        classes.insert(LoggingURLProtocol.self, at: 0)
        configuration.protocolClasses = classes
        return configuration
    }
}

public final class LoggingURLProtocol: URLProtocol {
    fileprivate static weak var source: NetworkTelemetrySource?
    private var startTime: Date?
    private var session: URLSessionDataTask?

    public override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override func startLoading() {
        guard let client = client, let url = request.url else { return }
        startTime = Date()
        let config = URLSessionConfiguration.default
        config.protocolClasses = (config.protocolClasses ?? []).filter { $0 != LoggingURLProtocol.self }
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        self.session = session.dataTask(with: request) { data, response, error in
            defer { self.finish(eventDataLength: data?.count ?? 0, error: error) }
            if let response = response {
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                client.urlProtocol(self, didLoad: data)
            }
            if let error = error {
                client.urlProtocol(self, didFailWithError: error)
            } else {
                client.urlProtocolDidFinishLoading(self)
            }
        }
        session.resume()
    }

    public override func stopLoading() {
        session?.cancel()
    }

    private func finish(eventDataLength: Int, error: Error?) {
        guard let url = request.url, let startTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        let bytesSent = request.httpBody?.count ?? 0
        let event = NetworkEvent(url: url, startTime: startTime, duration: duration, bytesSent: Int64(bytesSent), bytesReceived: Int64(eventDataLength))
        LoggingURLProtocol.source?.record(event: event)
        if let error = error {
            Logger(subsystem: "Base44EfbIds", category: "NetworkTelemetry").error("Request failed: \(error.localizedDescription)")
        }
    }
}
