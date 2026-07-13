import Foundation

/// File-based implementation of ReportStore.
/// Stores reports as a JSON array in Application Support directory.
public final class FileReportStore: ReportStore {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.ieltsdictation.filereportstore", qos: .utility)

    /// Bundle identifier used for the Application Support subdirectory.
    public static let bundleID = "com.ieltsdictation.app"

    /// Default reports file URL.
    public static var defaultFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent(bundleID)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("reports.json")
    }

    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL
    }

    public func save(_ report: DailyReport) throws {
        try queue.sync {
            var reports = try loadAllInternal()
            // Replace existing report for the same date
            if let index = reports.firstIndex(where: { $0.dateUTC8 == report.dateUTC8 }) {
                reports[index] = report
            } else {
                reports.append(report)
            }
            let data = try JSONEncoder().encode(reports)
            try data.write(to: fileURL, options: .atomic)
        }
    }

    public func loadAll() throws -> [DailyReport] {
        try queue.sync {
            try loadAllInternal()
        }
    }

    public func mistakes() -> [WrongItem] {
        guard let reports = try? loadAll() else { return [] }
        return reports.flatMap { $0.wrongItems }
    }

    public func clearAll() throws {
        try queue.sync {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        }
    }

    // MARK: - Internal (non-thread-safe, call within queue)

    private func loadAllInternal() throws -> [DailyReport] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([DailyReport].self, from: data)
    }
}
