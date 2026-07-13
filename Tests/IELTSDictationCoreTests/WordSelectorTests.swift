import XCTest
@testable import IELTSDictationCore

final class WordSelectorTests: XCTestCase {
    func makeWord(en: String, zh: String = "测试", listId: Int = 17) -> Word {
        Word(en: en, zh: zh, pos: nil, listId: listId)
    }

    func testSelectExcludesJuniorHighWords() {
        let list = VocabList(id: 17, words: [
            makeWord(en: "abandon", listId: 17),
            makeWord(en: "apple", listId: 17),
            makeWord(en: "zebra", listId: 17),
        ])

        // Exclude "apple"
        let jh = JuniorHighWordSet(words: ["apple"])
        let selector = WordSelector(dailyTarget: 50)

        let selected = selector.select(from: [list], excluding: jh)
        XCTAssertEqual(selected.count, 2)
        XCTAssertTrue(selected.contains(where: { $0.en == "abandon" }))
        XCTAssertTrue(selected.contains(where: { $0.en == "zebra" }))
        XCTAssertFalse(selected.contains(where: { $0.en == "apple" }))
    }

    func testOverrideKeepPreservesJuniorHighWord() {
        let list = VocabList(id: 17, words: [
            makeWord(en: "accept", listId: 17),
            makeWord(en: "abandon", listId: 17),
        ])

        let jh = JuniorHighWordSet(words: ["accept"])
        let overrideKeep: Set<String> = ["accept"]
        let selector = WordSelector(dailyTarget: 50)

        let selected = selector.select(from: [list], excluding: jh, overrideKeep: overrideKeep)
        XCTAssertEqual(selected.count, 2)
        XCTAssertTrue(selected.contains(where: { $0.en == "accept" }))
    }

    func testSelectRespectsDailyTarget() {
        let words = (1...100).map { makeWord(en: "word\($0)", listId: 17) }
        let list = VocabList(id: 17, words: words)
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 50)
        let selected = selector.select(from: [list], excluding: jh)

        XCTAssertEqual(selected.count, 50)
    }

    func testSelectReturnsAllWhenBelowTarget() {
        let words = (1...30).map { makeWord(en: "word\($0)", listId: 17) }
        let list = VocabList(id: 17, words: words)
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 50)
        let selected = selector.select(from: [list], excluding: jh)

        XCTAssertEqual(selected.count, 30)
    }

    func testSelectAcrossMultipleLists() {
        let list17 = VocabList(id: 17, words: (1...30).map { makeWord(en: "a\($0)", listId: 17) })
        let list18 = VocabList(id: 18, words: (1...30).map { makeWord(en: "b\($0)", listId: 18) })
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 50)
        let selected = selector.select(from: [list17, list18], excluding: jh)

        XCTAssertEqual(selected.count, 50)
        // Verify all selected come from the two lists
        let validIds = Set(selected.map { $0.listId })
        XCTAssertTrue(validIds.isSubset(of: [17, 18]))
    }

    func testShuffleChangesOrder() {
        let words = (1...10).map { makeWord(en: "word\($0)", listId: 17) }
        let list = VocabList(id: 17, words: words)
        let jh = JuniorHighWordSet(words: [])

        let selector = WordSelector(dailyTarget: 10)

        // Run multiple times to detect shuffling
        var orders: [[String]] = []
        for _ in 0..<5 {
            let selected = selector.select(from: [list], excluding: jh, shuffle: true)
            orders.append(selected.map { $0.en })
        }

        // Not all orders should be identical (with high probability)
        let uniqueOrders = Set(orders)
        XCTAssertTrue(uniqueOrders.count > 1, "Shuffling should produce different orders")
    }
}
