import Foundation

/// Represents a single lesson (one day's dictation practice).
public struct Lesson: Codable, Equatable {
    /// The lesson number (1-based).
    public let number: Int
    /// The date string in UTC+8 (format: "yyyy-MM-dd").
    public let dateUTC8: String
    /// The list IDs covered in this lesson.
    public let listIds: [Int]
    /// The questions (words) for this lesson.
    public let questions: [Word]

    public init(number: Int, dateUTC8: String, listIds: [Int], questions: [Word]) {
        self.number = number
        self.dateUTC8 = dateUTC8
        self.listIds = listIds
        self.questions = questions
    }

    /// Format the lesson for display.
    public var displayTitle: String {
        let listRange = listIds.map { "List \($0)" }.joined(separator: "–")
        return "第 \(number) 课（\(listRange)）"
    }
}
