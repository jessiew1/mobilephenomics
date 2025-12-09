import XCTest
@testable import Base44EfbIds

final class SecurityEventTests: XCTestCase {
    func testEncodingAndDecoding() throws {
        let event = SecurityEvent(
            id: UUID(uuidString: "12345678-1234-1234-1234-1234567890ab")!,
            timestamp: ISO8601DateFormatter().date(from: "2024-01-01T00:00:00Z")!,
            severity: .critical,
            category: .file,
            message: "Test",
            details: ["k": "v"]
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(event)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(SecurityEvent.self, from: data)
        XCTAssertEqual(decoded, event)
    }
}
