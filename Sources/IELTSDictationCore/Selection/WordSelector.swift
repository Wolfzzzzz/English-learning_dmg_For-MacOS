import Foundation

/// Selects daily words from the available lists, excluding junior high words.
public struct WordSelector {
    /// Number of words to select per day.
    public let dailyTarget: Int

    public init(dailyTarget: Int = DictationConstants.dailyTarget) {
        self.dailyTarget = dailyTarget
    }

    /// Select words from the given lists, excluding junior high vocabulary.
    ///
    /// - Parameters:
    ///   - lists: The vocabulary lists to select from.
    ///   - excludingSet: Junior high words to exclude.
    ///   - overrideKeep: Set of words to keep even if they appear in the exclusion set.
    ///   - shuffle: Whether to randomize the order.
    /// - Returns: Selected words, up to `dailyTarget` (fewer if not enough available).
    public func select(from lists: [VocabList],
                       excluding set: JuniorHighWordSet,
                       overrideKeep: Set<String> = [],
                       shuffle: Bool = false) -> [Word] {
        // Collect all eligible words not in the junior high set (unless in overrideKeep)
        let eligible = lists.flatMap { list in
            list.words.filter { word in
                let normalized = word.en.lowercased().trimmingCharacters(in: .whitespaces)
                return overrideKeep.contains(normalized) || !set.contains(word.en)
            }
        }

        // Shuffle if requested
        var selected = eligible
        if shuffle {
            selected.shuffle()
        }

        // Take up to dailyTarget
        return Array(selected.prefix(dailyTarget))
    }
}
