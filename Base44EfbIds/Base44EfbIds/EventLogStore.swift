import Foundation

public final class EventLogStore {
    private let fileURL: URL
    private let maxEntries: Int
    private let fileManager: FileManager
    private let encoder: JSONEncoder

    public init(fileURL: URL, maxEntries: Int = 200, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.maxEntries = maxEntries
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    public func append(event: SecurityEvent) {
        var events = loadRecent(limit: maxEntries - 1)
        events.append(event)
        save(events: events)
    }

    public func loadRecent(limit: Int) -> [SecurityEvent] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let items = try? decoder.decode([SecurityEvent].self, from: data) else { return [] }
        return Array(items.suffix(limit))
    }

    private func save(events: [SecurityEvent]) {
        let trimmed = Array(events.suffix(maxEntries))
        guard let data = try? encoder.encode(trimmed) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
