import Foundation

/// Selects daily words from the available lists, excluding junior high words.
public struct WordSelector {
    /// Number of words to select per day.
    public let dailyTarget: Int

    public init(dailyTarget: Int = DictationConstants.dailyTarget) {
        self.dailyTarget = dailyTarget
    }

    /// Select exactly `dailyTarget` words from the given lists, excluding junior high vocabulary.
    /// Words are always shuffled. If fewer than `dailyTarget` words remain after exclusion,
    /// the remaining words from the lists are included to reach the target.
    ///
    /// - Parameters:
    ///   - lists: The vocabulary lists to select from.
    ///   - excludingSet: Junior high words to exclude.
    ///   - overrideKeep: Set of words to keep even if they appear in the exclusion set.
    /// - Returns: Exactly `dailyTarget` words (or all available words if fewer than target).
    public func select(from lists: [VocabList],
                       excluding set: JuniorHighWordSet,
                       overrideKeep: Set<String> = []) -> [Word] {
        let allWords = lists.flatMap { $0.words }

        // Collect eligible words (not in junior high set, unless in overrideKeep)
        var eligible = allWords.filter { word in
            let normalized = word.en.lowercased().trimmingCharacters(in: .whitespaces)
            return overrideKeep.contains(normalized) || !set.contains(word.en)
        }

        // If fewer than dailyTarget, include remaining words to reach exactly the target
        if eligible.count < dailyTarget {
            let rest = allWords.filter { !eligible.contains($0) }
            eligible.append(contentsOf: rest.shuffled().prefix(dailyTarget - eligible.count))
        }

        // Always shuffle
        return eligible.shuffled().prefix(dailyTarget).map { $0 }
    }
}
