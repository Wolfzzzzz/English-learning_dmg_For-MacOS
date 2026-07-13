import Foundation

/// Manages the state of a dictation session (user's answers).
public final class DictationSession {
    /// The lesson being practiced.
    public let lesson: Lesson
    /// User's answers keyed by question index.
    private(set) public var answers: [Int: String] = [:]
    /// Whether all questions have been answered.
    public var isComplete: Bool {
        answers.count == lesson.questions.count
    }

    public init(lesson: Lesson) {
        self.lesson = lesson
    }

    /// Submit a user answer for the question at the given index.
    public func submit(_ answer: String, at index: Int) {
        guard index >= 0, index < lesson.questions.count else { return }
        answers[index] = answer
    }

    /// Get the user answer for a given index, or an empty string.
    public func answer(at index: Int) -> String {
        answers[index] ?? ""
    }
}
