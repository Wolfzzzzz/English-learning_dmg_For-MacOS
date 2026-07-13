import XCTest
@testable import IELTSDictationCore

final class GradingTests: XCTestCase {
    func testExactMatchIsCorrect() {
        let word = Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17)
        XCTAssertTrue(Grading.isCorrect(user: "abandon", word: word))
    }

    func testCaseInsensitiveMatch() {
        let word = Word(en: "Abandon", zh: "放弃", pos: "v.", listId: 17)
        XCTAssertTrue(Grading.isCorrect(user: "abandon", word: word))
        XCTAssertTrue(Grading.isCorrect(user: "ABANDON", word: word))
    }

    func testTrimWhitespace() {
        let word = Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17)
        XCTAssertTrue(Grading.isCorrect(user: "  abandon  ", word: word))
        XCTAssertTrue(Grading.isCorrect(user: "abandon ", word: word))
    }

    func testAcceptableAnswers() {
        let word = Word(en: "colour", zh: "颜色", pos: "n.", listId: 17,
                        acceptableAnswers: ["color"])
        XCTAssertTrue(Grading.isCorrect(user: "color", word: word))
        XCTAssertTrue(Grading.isCorrect(user: "colour", word: word))
        XCTAssertTrue(Grading.isCorrect(user: "Colour", word: word))
    }

    func testWrongAnswer() {
        let word = Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17)
        XCTAssertFalse(Grading.isCorrect(user: "abandom", word: word))
        XCTAssertFalse(Grading.isCorrect(user: "give up", word: word))
    }

    func testEmptyAnswer() {
        let word = Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17)
        XCTAssertFalse(Grading.isCorrect(user: "", word: word))
    }

    func testGradeFullSession() {
        let words = [
            Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17),
            Word(en: "apple", zh: "苹果", pos: "n.", listId: 17),
            Word(en: "zebra", zh: "斑马", pos: "n.", listId: 17),
        ]
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: words)
        let session = DictationSession(lesson: lesson)
        session.submit("abandon", at: 0)
        session.submit("apple", at: 1)
        session.submit("zebra", at: 2)

        let report = Grading.grade(session: session)
        XCTAssertEqual(report.totalCount, 3)
        XCTAssertEqual(report.correctCount, 3)
        XCTAssertEqual(report.accuracy, 1.0)
        XCTAssertTrue(report.wrongItems.isEmpty)
    }

    func testGradeWithMistakes() {
        let words = [
            Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17),
            Word(en: "apple", zh: "苹果", pos: "n.", listId: 17),
        ]
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: words)
        let session = DictationSession(lesson: lesson)
        session.submit("abandom", at: 0)
        session.submit("apple", at: 1)

        let report = Grading.grade(session: session)
        XCTAssertEqual(report.totalCount, 2)
        XCTAssertEqual(report.correctCount, 1)
        XCTAssertEqual(report.accuracy, 0.5)
        XCTAssertEqual(report.wrongItems.count, 1)
        XCTAssertEqual(report.wrongItems[0].word.en, "abandon")
        XCTAssertEqual(report.wrongItems[0].userAnswer, "abandom")
    }

    func testGradeWithEmptyAnswers() {
        let words = [
            Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17),
        ]
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: words)
        let session = DictationSession(lesson: lesson)
        // No answer submitted

        let report = Grading.grade(session: session)
        XCTAssertEqual(report.totalCount, 1)
        XCTAssertEqual(report.correctCount, 0)
        XCTAssertEqual(report.wrongItems.count, 1)
    }

    func testMultiWordNormalization() {
        let word = Word(en: "look after", zh: "照顾", pos: "phr.", listId: 17)
        // Multiple spaces should be normalized
        XCTAssertTrue(Grading.isCorrect(user: "look  after", word: word))
        XCTAssertTrue(Grading.isCorrect(user: "LOOK AFTER", word: word))
    }

    func testDisableCaseInsensitive() {
        let word = Word(en: "Abandon", zh: "放弃", pos: "v.", listId: 17)
        let rule = AnswerRule(trimWhitespace: true, caseInsensitive: false, allowMultiple: true)
        XCTAssertFalse(Grading.isCorrect(user: "abandon", word: word, rule: rule))
        XCTAssertTrue(Grading.isCorrect(user: "Abandon", word: word, rule: rule))
    }
}
