import Foundation

public struct SecurityEvent: Codable, Identifiable, Equatable {
    public enum Severity: String, Codable {
        case info
        case warning
        case critical
    }

    public enum Category: String, Codable {
        case cpu
        case network
        case file
        case system
    }

    public let id: UUID
    public let timestamp: Date
    public let severity: Severity
    public let category: Category
    public let message: String
    public let details: [String: String]

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        severity: Severity,
        category: Category,
        message: String,
        details: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.severity = severity
        self.category = category
        self.message = message
        self.details = details
    }
}
