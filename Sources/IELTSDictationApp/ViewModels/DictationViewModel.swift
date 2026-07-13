import Foundation
import IELTSDictationCore

/// View model for the main dictation view.
@MainActor
final class DictationViewModel: ObservableObject {
    // MARK: - Dependencies
    private let vocabulary: Vocabulary
    private let juniorHigh: JuniorHighWordSet
    private let overrideKeep: Set<String>
    private let selector: WordSelector
    private let schedule: CourseSchedule
    private let store: ReportStore
    private let dateProvider: DateProvider

    // MARK: - Published State
    @Published var lesson: Lesson?
    @Published var session: DictationSession?
    @Published var report: GradingReport?
    @Published var hasCompletedToday: Bool = false
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var showGradeConfirmation: Bool = false
    @Published var showResetConfirmation: Bool = false

    // MARK: - Derived
    var lessonDisplayTitle: String { lesson?.displayTitle ?? "加载中…" }
    var dateDisplay: String { lesson?.dateUTC8 ?? "" }
    var wordCountText: String {
        guard let lesson = lesson else { return "今日单词：-" }
        return "今日单词：\(lesson.questions.count) 个"
    }
    var statusText: String {
        if report != nil { return "已完成 ✓" }
        return hasCompletedToday ? "已完成 ✓" : "未开始"
    }

    // MARK: - Init
    init(vocabulary: Vocabulary,
         juniorHigh: JuniorHighWordSet,
         overrideKeep: Set<String>,
         selector: WordSelector,
         schedule: CourseSchedule,
         store: ReportStore,
         dateProvider: DateProvider) {
        self.vocabulary = vocabulary
        self.juniorHigh = juniorHigh
        self.overrideKeep = overrideKeep
        self.selector = selector
        self.schedule = schedule
        self.store = store
        self.dateProvider = dateProvider
    }

    // MARK: - Public API

    /// Prepare today's lesson based on the current date.
    func prepareTodayLesson() throws {
        isLoading = true
        errorMessage = nil

        let now = dateProvider.now
        let cal = CourseSchedule.shanghaiCalendar
        let dateStr = formatDate(now, calendar: cal)

        // Check if already completed today
        let existingReports = (try? store.loadAll()) ?? []
        if existingReports.contains(where: { $0.dateUTC8 == dateStr }) {
            hasCompletedToday = true
        }

        // Find the max list ID from vocabulary
        let maxId = vocabulary.lists.keys.max() ?? 0
        var mutableSchedule = schedule
        mutableSchedule.maxListId = maxId

        // Get list IDs for today
        guard let (listA, listB) = mutableSchedule.listIds(for: now) else {
            errorMessage = "所有课程已完成！"
            isLoading = false
            return
        }

        // Fetch lists
        let lists = vocabulary.lists(with: [listA, listB])
        guard !lists.isEmpty else {
            errorMessage = "未找到对应 List 的词汇数据。"
            isLoading = false
            return
        }

        // Select words
        let selectedWords = selector.select(
            from: lists,
            excluding: juniorHigh,
            overrideKeep: overrideKeep
        )

        let lessonNumber = mutableSchedule.lessonNumber(for: now)
        let lesson = Lesson(
            number: lessonNumber,
            dateUTC8: dateStr,
            listIds: [listA, listB],
            questions: selectedWords
        )

        self.lesson = lesson
        self.session = DictationSession(lesson: lesson)

        // If already completed, load the report
        if hasCompletedToday {
            if let existing = existingReports.first(where: { $0.dateUTC8 == dateStr }) {
                self.report = GradingReport(
                    totalCount: existing.totalCount,
                    correctCount: existing.correctCount,
                    wrongItems: existing.wrongItems
                )
            }
        }

        isLoading = false
    }

    /// Submit an answer for a question.
    func submitAnswer(_ answer: String, at index: Int) {
        session?.submit(answer, at: index)
    }

    /// Grade the current session and save the report.
    func grade() {
        guard let session = session else { return }
        let gradingReport = Grading.grade(session: session)
        self.report = gradingReport

        // Save to store
        if let lesson = lesson {
            let dailyReport = DailyReport(from: gradingReport, lesson: lesson)
            try? store.save(dailyReport)
        }

        hasCompletedToday = true
    }

    /// Reset all data and restart from lesson 1 (factory reset).
    func resetAllData() {
        try? store.clearAll()
        // Reset anchor date to today → course restarts from List 17-18
        DictationConstants.resetAnchorDate(to: dateProvider.now)
        lesson = nil
        session = nil
        report = nil
        hasCompletedToday = false
        isLoading = true
        errorMessage = nil
        // Reload with new anchor date
        do {
            try prepareTodayLesson()
        } catch {
            errorMessage = "重置后加载失败：\(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Helpers

    /// Load all historical reports.
    func loadHistory() -> [DailyReport] {
        (try? store.loadAll()) ?? []
    }

    /// Load all mistakes from history.
    func loadMistakes() -> [WrongItem] {
        store.mistakes()
    }

    /// Calculate progress statistics.
    var progressStats: (totalWords: Int, totalCorrect: Int, totalLessons: Int, streakDays: Int) {
        let reports = loadHistory()
        let totalLessons = reports.count
        let totalWords = reports.reduce(0) { $0 + $1.totalCount }
        let totalCorrect = reports.reduce(0) { $0 + $1.correctCount }

        // Calculate streak (consecutive days ending with today or yesterday)
        let cal = CourseSchedule.shanghaiCalendar
        let today = cal.startOfDay(for: dateProvider.now)
        let sortedDates = reports
            .compactMap { report -> Date? in
                let fmt = DateFormatter()
                fmt.calendar = cal
                fmt.timeZone = cal.timeZone
                fmt.dateFormat = "yyyy-MM-dd"
                return fmt.date(from: report.dateUTC8)
            }
            .map { cal.startOfDay(for: $0) }
            .sorted(by: >)

        var streak = 0
        var expectedDate = today
        for date in sortedDates {
            if date == expectedDate || date == cal.date(byAdding: .day, value: -1, to: expectedDate) {
                streak += 1
                expectedDate = date
            } else if date < expectedDate {
                break
            }
        }

        return (totalWords, totalCorrect, totalLessons, streak)
    }

    private func formatDate(_ date: Date, calendar: Calendar) -> String {
        let fmt = DateFormatter()
        fmt.calendar = calendar
        fmt.timeZone = calendar.timeZone
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}
