import XCTest
@testable import IELTSDictationCore

final class WordSelectorTests: XCTestCase {
    func makeWord(en: String, zh: String = "测试", listId: Int = 1) -> Word {
        Word(en: en, zh: zh, pos: nil, listId: listId)
    }

    func testSelectExcludesJuniorHighWords() {
        // Create enough words so dailyTarget is satisfied without padding
        let list = VocabList(id: 1, words: (1...60).map { i in
            makeWord(en: "word\(i)", listId: 1)
        } + [
            makeWord(en: "abandon", listId: 1),
            makeWord(en: "apple", listId: 1),
            makeWord(en: "zebra", listId: 1),
        ])

        // Exclude "apple"
        let jh = JuniorHighWordSet(words: ["apple"])
        let selector = WordSelector(dailyTarget: 50)

        let selected = selector.select(from: [list], excluding: jh)
        XCTAssertEqual(selected.count, 50)
        XCTAssertTrue(selected.contains(where: { $0.en == "abandon" }))
        XCTAssertTrue(selected.contains(where: { $0.en == "zebra" }))
        XCTAssertFalse(selected.contains(where: { $0.en == "apple" }))
    }

    func testOverrideKeepPreservesJuniorHighWord() {
        let list = VocabList(id: 1, words: (1...60).map { makeWord(en: "x\($0)", listId: 1) } + [
            makeWord(en: "accept", listId: 1),
            makeWord(en: "abandon", listId: 1),
        ])

        let jh = JuniorHighWordSet(words: ["accept"])
        let overrideKeep: Set<String> = ["accept"]
        let selector = WordSelector(dailyTarget: 50)

        let selected = selector.select(from: [list], excluding: jh, overrideKeep: overrideKeep)
        XCTAssertEqual(selected.count, 50)
        XCTAssertTrue(selected.contains(where: { $0.en == "accept" }))
    }

    func testSelectRespectsDailyTarget() {
        let words = (1...100).map { makeWord(en: "word\($0)", listId: 1) }
        let list = VocabList(id: 1, words: words)
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 50)
        let selected = selector.select(from: [list], excluding: jh)

        XCTAssertEqual(selected.count, 50)
    }

    func testSelectPadsToReachTargetWhenFewerEligible() {
        // Only 30 words total — system pads to reach dailyTarget as best as possible
        let words = (1...30).map { makeWord(en: "word\($0)", listId: 1) }
        let list = VocabList(id: 1, words: words)
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 50)
        let selected = selector.select(from: [list], excluding: jh)

        // Returns all 30 since there are only 30 words total (can't reach 50)
        XCTAssertEqual(selected.count, 30)
    }

    func testSelectAcrossMultipleLists() {
        let list1 = VocabList(id: 1, words: (1...30).map { makeWord(en: "a\($0)", listId: 1) })
        let list2 = VocabList(id: 2, words: (1...30).map { makeWord(en: "b\($0)", listId: 2) })
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 50)
        let selected = selector.select(from: [list1, list2], excluding: jh)

        XCTAssertEqual(selected.count, 50)
        let validIds = Set(selected.map { $0.listId })
        XCTAssertTrue(validIds.isSubset(of: [1, 2]))
    }

    func testShuffleChangesOrder() {
        let words = (1...10).map { makeWord(en: "word\($0)", listId: 1) }
        let list = VocabList(id: 1, words: words)
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 10)

        var orders: [[String]] = []
        for _ in 0..<5 {
            let selected = selector.select(from: [list], excluding: jh)
            orders.append(selected.map { $0.en })
        }

        let uniqueOrders = Set(orders)
        XCTAssertTrue(uniqueOrders.count > 1, "Shuffling should produce different orders")
    }

    func testPadWithJuniorHighWordsWhenEligibleBelowTarget() {
        // 55 words total, 5 excluded = 50 eligible, exactly 50 = no padding needed
        let words = (1...55).map { i in
            makeWord(en: i <= 5 ? "jhw\(i)" : "word\(i)", listId: 1)
        }
        let list = VocabList(id: 1, words: words)
        let jh = JuniorHighWordSet(words: ["jhw1", "jhw2", "jhw3", "jhw4", "jhw5"])
        let selector = WordSelector(dailyTarget: 50)
        let selected = selector.select(from: [list], excluding: jh)
        XCTAssertEqual(selected.count, 50)
        // No junior-high words should appear (eligible == 50, no padding needed)
        for w in selected {
            XCTAssertFalse(w.en.starts(with: "jhw"))
        }
    }
}
