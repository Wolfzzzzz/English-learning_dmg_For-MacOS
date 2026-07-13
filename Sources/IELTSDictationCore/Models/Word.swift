import Foundation

/// Represents a single vocabulary word entry.
public struct Word: Codable, Equatable, Identifiable {
    /// The English spelling (canonical form).
    public let en: String
    /// The Chinese definition/translation.
    public let zh: String
    /// Part of speech, e.g. "v.", "n.", "adj."
    public let pos: String?
    /// The list ID this word belongs to. Defaults to 0 (set by VocabList after loading).
    public var listId: Int = 0
    /// Optional alternative acceptable spellings (British/American variants, etc.).
    public var acceptableAnswers: [String]?

    public var id: String { en }

    public init(en: String, zh: String, pos: String? = nil, listId: Int = 0, acceptableAnswers: [String]? = nil) {
        self.en = en
        self.zh = zh
        self.pos = pos
        self.listId = listId
        self.acceptableAnswers = acceptableAnswers
    }

    // Custom decoder: listId is optional in JSON, defaults to 0
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        en = try container.decode(String.self, forKey: .en)
        zh = try container.decode(String.self, forKey: .zh)
        pos = try container.decodeIfPresent(String.self, forKey: .pos)
        listId = try container.decodeIfPresent(Int.self, forKey: .listId) ?? 0
        acceptableAnswers = try container.decodeIfPresent([String].self, forKey: .acceptableAnswers)
    }
}
