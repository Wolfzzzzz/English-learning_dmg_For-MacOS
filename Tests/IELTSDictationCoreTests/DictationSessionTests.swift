import XCTest
@testable import IELTSDictationCore

final class DictationSessionTests: XCTestCase {
    func testSessionInitialization() {
        let words = [
            Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17),
            Word(en: "apple", zh: "苹果", pos: "n.", listId: 17),
        ]
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: words)
        let session = DictationSession(lesson: lesson)

        XCTAssertEqual(session.lesson.number, 1)
        XCTAssertEqual(session.lesson.questions.count, 2)
        XCTAssertFalse(session.isComplete)
        XCTAssertTrue(session.answers.isEmpty)
    }

    func testSubmitAnswer() {
        let words = [
            Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17),
        ]
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: words)
        let session = DictationSession(lesson: lesson)

        session.submit("abandon", at: 0)
        XCTAssertEqual(session.answer(at: 0), "abandon")
        XCTAssertTrue(session.isComplete)
    }

    func testOverwriteAnswer() {
        let word = Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17)
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: [word])
        let session = DictationSession(lesson: lesson)

        session.submit("wrong", at: 0)
        session.submit("abandon", at: 0)
        XCTAssertEqual(session.answer(at: 0), "abandon")
    }

    func testIsComplete() {
        let words = [
            Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17),
            Word(en: "apple", zh: "苹果", pos: "n.", listId: 17),
        ]
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: words)
        let session = DictationSession(lesson: lesson)

        XCTAssertFalse(session.isComplete)
        session.submit("abandon", at: 0)
        XCTAssertFalse(session.isComplete)
        session.submit("apple", at: 1)
        XCTAssertTrue(session.isComplete)
    }

    func testInvalidIndex() {
        let word = Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17)
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: [word])
        let session = DictationSession(lesson: lesson)

        session.submit("test", at: -1)
        session.submit("test", at: 1)

        XCTAssertTrue(session.answers.isEmpty)
    }

    func testDefaultAnswerEmpty() {
        let word = Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17)
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17], questions: [word])
        let session = DictationSession(lesson: lesson)

        XCTAssertEqual(session.answer(at: 0), "")
    }
}
