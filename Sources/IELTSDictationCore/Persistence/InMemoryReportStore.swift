import Foundation

/// In-memory implementation of ReportStore for testing.
public final class InMemoryReportStore: ReportStore {
    private var reports: [DailyReport] = []

    public init() {}

    public func save(_ report: DailyReport) throws {
        // Replace existing report for the same date
        if let index = reports.firstIndex(where: { $0.dateUTC8 == report.dateUTC8 }) {
            reports[index] = report
        } else {
            reports.append(report)
        }
    }

    public func loadAll() throws -> [DailyReport] {
        reports
    }

    public func mistakes() -> [WrongItem] {
        reports.flatMap { $0.wrongItems }
    }

    public func clearAll() throws {
        reports.removeAll()
    }
}
