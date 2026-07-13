import Foundation

/// Represents a single list of vocabulary words from the Green Book.
public struct VocabList: Codable, Equatable {
    /// The list number (e.g. 17, 18, ...)
    public let id: Int
    /// Words contained in this list.
    public var words: [Word]

    public init(id: Int, words: [Word]) {
        self.id = id
        self.words = words
    }
}
