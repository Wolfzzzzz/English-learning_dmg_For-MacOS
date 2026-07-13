import Foundation

/// Configuration for answer comparison rules.
public struct AnswerRule: Codable, Equatable {
    /// Trim leading/trailing whitespace before comparison.
    public var trimWhitespace: Bool
    /// Perform case-insensitive comparison.
    public var caseInsensitive: Bool
    /// Allow multiple acceptable answers from the word's `acceptableAnswers` array.
    public var allowMultiple: Bool

    public static let `default` = AnswerRule(
        trimWhitespace: true,
        caseInsensitive: true,
        allowMultiple: true
    )

    public init(trimWhitespace: Bool = true, caseInsensitive: Bool = true, allowMultiple: Bool = true) {
        self.trimWhitespace = trimWhitespace
        self.caseInsensitive = caseInsensitive
        self.allowMultiple = allowMultiple
    }
}

/// A single wrong item in the grading report.
public struct WrongItem: Codable, Equatable, Identifiable {
    /// Index of the question in the lesson.
    public let index: Int
    /// The word and its details.
    public let word: Word
    /// What the user typed.
    public let userAnswer: String

    public var id: String { "\(index)-\(word.en)" }

    public init(index: Int, word: Word, userAnswer: String) {
        self.index = index
        self.word = word
        self.userAnswer = userAnswer
    }
}

/// The result of grading a dictation session.
public struct GradingReport: Codable, Equatable {
    /// Total number of questions.
    public let totalCount: Int
    /// Number of correct answers.
    public let correctCount: Int
    /// Accuracy as a fraction (0.0 – 1.0).
    public let accuracy: Double
    /// List of wrong items.
    public let wrongItems: [WrongItem]

    public init(totalCount: Int, correctCount: Int, wrongItems: [WrongItem]) {
        self.totalCount = totalCount
        self.correctCount = correctCount
        self.accuracy = totalCount > 0 ? Double(correctCount) / Double(totalCount) : 1.0
        self.wrongItems = wrongItems
    }
}
