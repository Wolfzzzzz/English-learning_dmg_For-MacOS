import Foundation

/// Protocol for persisting and loading daily reports.
public protocol ReportStore: AnyObject {
    /// Save a daily report.
    func save(_ report: DailyReport) throws
    /// Load all saved daily reports.
    func loadAll() throws -> [DailyReport]
    /// Collect all wrong items from all saved reports (for mistake book).
    func mistakes() -> [WrongItem]
    /// Clear all stored data (factory reset).
    func clearAll() throws
}
