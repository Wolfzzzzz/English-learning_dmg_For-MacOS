import Foundation

/// Utility for grading dictation sessions.
public enum Grading {
    /// Grade a dictation session against the correct answers.
    ///
    /// - Parameters:
    ///   - session: The completed dictation session.
    ///   - rule: The answer comparison rules.
    /// - Returns: A grading report.
    public static func grade(session: DictationSession, rule: AnswerRule = .default) -> GradingReport {
        var correctCount = 0
        var wrongItems: [WrongItem] = []

        for (index, word) in session.lesson.questions.enumerated() {
            let userAnswer = session.answer(at: index)
            if isCorrect(user: userAnswer, word: word, rule: rule) {
                correctCount += 1
            } else {
                wrongItems.append(WrongItem(index: index, word: word, userAnswer: userAnswer))
            }
        }

        return GradingReport(
            totalCount: session.lesson.questions.count,
            correctCount: correctCount,
            wrongItems: wrongItems
        )
    }

    /// Determine if a user answer matches the correct word.
    ///
    /// - Parameters:
    ///   - user: The user's answer string.
    ///   - word: The correct word entry.
    ///   - rule: Comparison rules.
    /// - Returns: True if the answer is considered correct.
    public static func isCorrect(user: String, word: Word, rule: AnswerRule = .default) -> Bool {
        var userAnswer = user
        var correctAnswer = word.en

        if rule.trimWhitespace {
            userAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
            correctAnswer = correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Normalize multiple spaces to single space
        userAnswer = userAnswer.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        correctAnswer = correctAnswer.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        if rule.caseInsensitive {
            userAnswer = userAnswer.lowercased()
            correctAnswer = correctAnswer.lowercased()
        }

        // Check against the canonical answer
        if userAnswer == correctAnswer {
            return true
        }

        // Check against acceptable alternatives
        if rule.allowMultiple, let alternatives = word.acceptableAnswers {
            for alt in alternatives {
                var normalizedAlt = alt
                if rule.trimWhitespace {
                    normalizedAlt = normalizedAlt.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                normalizedAlt = normalizedAlt.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                if rule.caseInsensitive {
                    normalizedAlt = normalizedAlt.lowercased()
                }
                if userAnswer == normalizedAlt {
                    return true
                }
            }
        }

        return false
    }
}
