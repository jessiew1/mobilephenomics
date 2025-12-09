import Foundation

public protocol TelemetrySource {
    func start()
    func stop()
    func collectSnapshot() -> TelemetrySnapshot
}
