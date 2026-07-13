import Foundation

/// A persisted daily report for a completed lesson.
public struct DailyReport: Codable, Equatable, Identifiable {
    /// The lesson number.
    public let lessonNumber: Int
    /// Date string in UTC+8 (format: "yyyy-MM-dd").
    public let dateUTC8: String
    /// Total number of questions.
    public let totalCount: Int
    /// Number of correct answers.
    public let correctCount: Int
    /// Accuracy as a fraction.
    public let accuracy: Double
    /// Wrong items from this lesson.
    public let wrongItems: [WrongItem]
    /// When this report was created.
    public let createdAt: Date

    public var id: String { dateUTC8 }

    public init(lessonNumber: Int, dateUTC8: String, totalCount: Int, correctCount: Int, wrongItems: [WrongItem], createdAt: Date = Date()) {
        self.lessonNumber = lessonNumber
        self.dateUTC8 = dateUTC8
        self.totalCount = totalCount
        self.correctCount = correctCount
        self.accuracy = totalCount > 0 ? Double(correctCount) / Double(totalCount) : 1.0
        self.wrongItems = wrongItems
        self.createdAt = createdAt
    }
}

// MARK: - Convenience initializer from GradingReport

extension DailyReport {
    /// Create a daily report from a grading report and lesson details.
    public init(from report: GradingReport, lesson: Lesson) {
        self.init(
            lessonNumber: lesson.number,
            dateUTC8: lesson.dateUTC8,
            totalCount: report.totalCount,
            correctCount: report.correctCount,
            wrongItems: report.wrongItems
        )
    }
}
