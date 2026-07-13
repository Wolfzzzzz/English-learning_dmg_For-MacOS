import XCTest
@testable import IELTSDictationCore

final class CourseScheduleTests: XCTestCase {
    let cal = CourseSchedule.shanghaiCalendar

    func testAnchorDate() {
        // Anchor date should be 2026-07-13
        let anchor = DictationConstants.anchorDate
        let comps = cal.dateComponents([.year, .month, .day], from: anchor)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 7)
        XCTAssertEqual(comps.day, 13)
    }

    func testLesson1OnAnchorDay() {
        let schedule = CourseSchedule()
        let anchor = DictationConstants.anchorDate

        let ids = schedule.listIds(for: anchor)
        XCTAssertNotNil(ids)
        XCTAssertEqual(ids?.0, 1)
        XCTAssertEqual(ids?.1, 2)
        XCTAssertEqual(schedule.lessonNumber(for: anchor), 1)
    }

    func testLesson2NextDay() {
        let schedule = CourseSchedule()
        let day2 = cal.date(from: DateComponents(year: 2026, month: 7, day: 14))!

        let ids = schedule.listIds(for: day2)
        XCTAssertNotNil(ids)
        XCTAssertEqual(ids?.0, 3)
        XCTAssertEqual(ids?.1, 4)
        XCTAssertEqual(schedule.lessonNumber(for: day2), 2)
    }

    func testLesson3Day3() {
        let schedule = CourseSchedule()
        let day3 = cal.date(from: DateComponents(year: 2026, month: 7, day: 15))!

        let ids = schedule.listIds(for: day3)
        XCTAssertNotNil(ids)
        XCTAssertEqual(ids?.0, 5)
        XCTAssertEqual(ids?.1, 6)
        XCTAssertEqual(schedule.lessonNumber(for: day3), 3)
    }

    func testDaysOffset() {
        let schedule = CourseSchedule()
        let day2 = cal.date(from: DateComponents(year: 2026, month: 7, day: 14))!

        XCTAssertEqual(schedule.daysOffset(for: day2), 1)
        XCTAssertEqual(schedule.daysOffset(for: DictationConstants.anchorDate), 0)

        // Before anchor date should return 0
        let before = cal.date(from: DateComponents(year: 2026, month: 7, day: 12))!
        XCTAssertEqual(schedule.daysOffset(for: before), 0)
    }

    func testOverflowStopReturnsNil() {
        var schedule = CourseSchedule(overflow: .stop)
        schedule.maxListId = 6 // Only lists up to 6

        let day0 = cal.date(from: DateComponents(year: 2026, month: 7, day: 13))!
        let day1 = cal.date(from: DateComponents(year: 2026, month: 7, day: 14))!
        let day2 = cal.date(from: DateComponents(year: 2026, month: 7, day: 15))!
        let day3 = cal.date(from: DateComponents(year: 2026, month: 7, day: 16))!

        // List 1-2 should be available (day0)
        XCTAssertNotNil(schedule.listIds(for: day0))
        // List 3-4 should also be available (day1)
        XCTAssertNotNil(schedule.listIds(for: day1))

        if let ids = schedule.listIds(for: day2) {
            XCTAssertEqual(ids.0, 5)
            XCTAssertEqual(ids.1, 6)
        }

        // Overflow: 7 > 6, should return nil
        XCTAssertNil(schedule.listIds(for: day3))
    }

    func testOverflowLoopWraps() {
        var schedule = CourseSchedule(overflow: .loop)
        schedule.maxListId = 6

        // Day 3 (July 16): lists should be 7,8 -> wrap to 1,2
        let day3 = cal.date(from: DateComponents(year: 2026, month: 7, day: 16))!
        let ids = schedule.listIds(for: day3)
        XCTAssertNotNil(ids)
        // 7 % 6 = 1, 8 % 6 = 2
        XCTAssertEqual(ids?.0, 1)
        XCTAssertEqual(ids?.1, 2)
    }

    func testLessonNumberProgression() {
        let schedule = CourseSchedule()

        XCTAssertEqual(schedule.lessonNumber(for: DictationConstants.anchorDate), 1)

        let day7 = cal.date(from: DateComponents(year: 2026, month: 7, day: 19))!
        XCTAssertEqual(schedule.lessonNumber(for: day7), 7)

        let day30 = cal.date(from: DateComponents(year: 2026, month: 8, day: 11))!
        XCTAssertEqual(schedule.lessonNumber(for: day30), 30)
    }

    func testShanghaiCalendarTimeZone() {
        let tz = CourseSchedule.shanghaiCalendar.timeZone
        XCTAssertEqual(tz.identifier, "Asia/Shanghai")
    }
}
