import XCTest
@testable import IELTSDictationCore

final class FileReportStoreTests: XCTestCase {
    var tempURL: URL!
    var store: FileReportStore!

    override func setUp() {
        super.setUp()
        tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_reports_\(UUID().uuidString).json")
        store = FileReportStore(fileURL: tempURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempURL)
        super.tearDown()
    }

    func testSaveAndLoad() throws {
        let report = DailyReport(
            lessonNumber: 1,
            dateUTC8: "2026-07-13",
            totalCount: 50,
            correctCount: 40,
            wrongItems: [
                WrongItem(index: 0, word: Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17), userAnswer: "abandom")
            ]
        )

        try store.save(report)
        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].lessonNumber, 1)
        XCTAssertEqual(loaded[0].correctCount, 40)
        XCTAssertEqual(loaded[0].wrongItems.count, 1)
    }

    func testLoadEmptyStore() throws {
        let loaded = try store.loadAll()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testSaveMultipleAndReplace() throws {
        let report1 = DailyReport(
            lessonNumber: 1, dateUTC8: "2026-07-13",
            totalCount: 50, correctCount: 40, wrongItems: []
        )
        let report2 = DailyReport(
            lessonNumber: 2, dateUTC8: "2026-07-14",
            totalCount: 50, correctCount: 45, wrongItems: []
        )

        try store.save(report1)
        try store.save(report2)
        XCTAssertEqual(try store.loadAll().count, 2)

        // Replace report for 2026-07-13
        let report1Updated = DailyReport(
            lessonNumber: 1, dateUTC8: "2026-07-13",
            totalCount: 50, correctCount: 50, wrongItems: []
        )
        try store.save(report1Updated)
        let all = try store.loadAll()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all.first(where: { $0.dateUTC8 == "2026-07-13" })?.correctCount, 50)
    }

    func testMistakes() throws {
        let report1 = DailyReport(
            lessonNumber: 1, dateUTC8: "2026-07-13",
            totalCount: 50, correctCount: 48,
            wrongItems: [
                WrongItem(index: 0, word: Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17), userAnswer: "abandom")
            ]
        )
        let report2 = DailyReport(
            lessonNumber: 2, dateUTC8: "2026-07-14",
            totalCount: 50, correctCount: 49,
            wrongItems: [
                WrongItem(index: 1, word: Word(en: "abolish", zh: "废除", pos: "v.", listId: 18), userAnswer: "aboliish")
            ]
        )

        try store.save(report1)
        try store.save(report2)

        let mistakes = store.mistakes()
        XCTAssertEqual(mistakes.count, 2)
    }

    func testInMemoryStore() throws {
        let inMemory = InMemoryReportStore()

        let report = DailyReport(
            lessonNumber: 1, dateUTC8: "2026-07-13",
            totalCount: 50, correctCount: 40, wrongItems: []
        )
        try inMemory.save(report)
        XCTAssertEqual(try inMemory.loadAll().count, 1)
        XCTAssertTrue(inMemory.mistakes().isEmpty)
    }

    func testDailyReportFromGradingReport() {
        let report = GradingReport(
            totalCount: 2, correctCount: 1,
            wrongItems: [
                WrongItem(index: 0, word: Word(en: "abandon", zh: "放弃", pos: "v.", listId: 17), userAnswer: "abandom")
            ]
        )
        let lesson = Lesson(number: 1, dateUTC8: "2026-07-13", listIds: [17, 18], questions: [])
        let daily = DailyReport(from: report, lesson: lesson)

        XCTAssertEqual(daily.lessonNumber, 1)
        XCTAssertEqual(daily.dateUTC8, "2026-07-13")
        XCTAssertEqual(daily.totalCount, 2)
        XCTAssertEqual(daily.correctCount, 1)
    }
}
