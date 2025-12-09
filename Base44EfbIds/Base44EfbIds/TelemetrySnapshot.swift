import Foundation

public struct NetworkEvent: Codable, Equatable {
    public let url: URL
    public let startTime: Date
    public let duration: TimeInterval
    public let bytesSent: Int64
    public let bytesReceived: Int64

    public init(url: URL, startTime: Date, duration: TimeInterval, bytesSent: Int64, bytesReceived: Int64) {
        self.url = url
        self.startTime = startTime
        self.duration = duration
        self.bytesSent = bytesSent
        self.bytesReceived = bytesReceived
    }
}

public struct FileHashState: Codable, Equatable {
    public let path: String
    public let hash: String
    public let lastModified: Date

    public init(path: String, hash: String, lastModified: Date) {
        self.path = path
        self.hash = hash
        self.lastModified = lastModified
    }
}

public struct TelemetrySnapshot: Codable, Equatable {
    public let timestamp: Date
    public var cpuLoad: Double?
    public var recentNetworkEvents: [NetworkEvent]
    public var fileStates: [FileHashState]

    public init(
        timestamp: Date = Date(),
        cpuLoad: Double? = nil,
        recentNetworkEvents: [NetworkEvent] = [],
        fileStates: [FileHashState] = []
    ) {
        self.timestamp = timestamp
        self.cpuLoad = cpuLoad
        self.recentNetworkEvents = recentNetworkEvents
        self.fileStates = fileStates
    }

    public mutating func merge(with other: TelemetrySnapshot) {
        if cpuLoad == nil {
            cpuLoad = other.cpuLoad
        }
        recentNetworkEvents.append(contentsOf: other.recentNetworkEvents)
        fileStates.append(contentsOf: other.fileStates)
    }
}
