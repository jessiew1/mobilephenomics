import CryptoKit
import Foundation

public final class FileIntegrityTelemetrySource: TelemetrySource {
    private let monitoredFiles: [String]
    private let fileManager: FileManager

    public init(monitoredFiles: [String], fileManager: FileManager = .default) {
        self.monitoredFiles = monitoredFiles
        self.fileManager = fileManager
    }

    public func start() {}

    public func stop() {}

    public func collectSnapshot() -> TelemetrySnapshot {
        let states: [FileHashState] = monitoredFiles.compactMap { path in
            guard let data = fileManager.contents(atPath: path) else { return nil }
            let hash = SHA256.hash(data: data)
            let hex = hash.compactMap { String(format: "%02x", $0) }.joined()
            let attributes = try? fileManager.attributesOfItem(atPath: path)
            let modificationDate = attributes?[.modificationDate] as? Date ?? Date()
            return FileHashState(path: path, hash: hex, lastModified: modificationDate)
        }
        return TelemetrySnapshot(fileStates: states)
    }
}
