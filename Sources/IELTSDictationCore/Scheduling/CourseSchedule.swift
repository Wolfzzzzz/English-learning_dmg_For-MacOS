import Foundation

/// Policy for handling overflow beyond the available lists.
public enum OverflowPolicy: String, Codable, Sendable {
    /// Stop and indicate no more lessons.
    case stop
    /// Loop back to the beginning.
    case loop
}

/// Determines which list IDs correspond to a given date.
///
/// Formula: Lesson N (starting from lesson 1 on anchor date) uses
/// list(17 + 2*(N-1)) and list(17 + 2*(N-1) + 1).
public struct CourseSchedule {
    /// The anchor date (d=0, lesson 1).
    public let anchorDate: Date
    /// The starting list ID (default 17).
    public let startListId: Int
    /// Overflow behavior.
    public let overflow: OverflowPolicy
    /// The maximum list ID available (determined from vocabulary).
    public var maxListId: Int = .max

    /// UTC+8 calendar for all date calculations.
    public static var shanghaiCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return cal
    }

    public init(anchorDate: Date = DictationConstants.anchorDate,
                startListId: Int = DictationConstants.startListId,
                overflow: OverflowPolicy = DictationConstants.overflowPolicy) {
        self.anchorDate = anchorDate
        self.startListId = startListId
        self.overflow = overflow
    }

    /// Calculate the days offset from the anchor date to the given date (UTC+8).
    public func daysOffset(for date: Date) -> Int {
        let cal = Self.shanghaiCalendar
        let anchorDay = cal.startOfDay(for: anchorDate)
        let targetDay = cal.startOfDay(for: date)
        guard let diff = cal.dateComponents([.day], from: anchorDay, to: targetDay).day else {
            return 0
        }
        return max(0, diff)
    }

    /// Calculate the lesson number for the given date (1-based).
    public func lessonNumber(for date: Date) -> Int {
        let offset = daysOffset(for: date)
        return offset + 1 // Lesson 1 is on anchor day
    }

    /// Calculate the two list IDs for the given date.
    /// Returns nil if the lists exceed availability and overflow is .stop.
    public func listIds(for date: Date) -> (Int, Int)? {
        let lesson = lessonNumber(for: date)
        let first = startListId + 2 * (lesson - 1)
        let second = first + 1

        switch overflow {
        case .stop:
            guard first <= maxListId, second <= maxListId else {
                return nil
            }
            return (first, second)
        case .loop:
            let wrappedFirst = ((first - 1) % maxListId) + 1
            let wrappedSecond = ((second - 1) % maxListId) + 1
            return (wrappedFirst, wrappedSecond)
        }
    }
}

/// Shared constants for the dictation application.
public enum DictationConstants {
    /// UserDefaults key for anchor date override.
    private static let anchorOverrideKey = "com.ieltsdictation.anchorDateOverride"

    /// Default anchor date: 2026-07-13 UTC+8
    public static let anchorDate: Date = {
        let cal = CourseSchedule.shanghaiCalendar
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 7
        comps.day = 13
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        return cal.date(from: comps) ?? Date()
    }()

    /// Effective anchor date: uses UserDefaults override if set, otherwise uses default .
    public static var effectiveAnchorDate: Date {
        if let saved = UserDefaults.standard.object(forKey: anchorOverrideKey) as? Date {
            return saved
        }
        return anchorDate
    }

    /// Reset the anchor date to a new date (used by factory reset).
    /// - Parameter date: The date to set as the new anchor date.
    public static func resetAnchorDate(to date: Date) {
        let cal = CourseSchedule.shanghaiCalendar
        let startOfDay = cal.startOfDay(for: date)
        UserDefaults.standard.set(startOfDay, forKey: anchorOverrideKey)
    }

    /// The starting list ID.
    public static let startListId: Int = 1

    /// Overflow policy.
    public static let overflowPolicy: OverflowPolicy = .stop

    /// Daily target number of words.
    public static let dailyTarget: Int = 50
}
