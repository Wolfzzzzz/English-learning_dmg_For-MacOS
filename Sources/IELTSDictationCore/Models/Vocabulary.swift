import Foundation

/// Container for the full vocabulary loaded from the bundled JSON resource.
public struct Vocabulary: Codable {
    /// Schema version.
    public let version: Int
    /// Source file description.
    public let source: String?
    /// All vocabulary lists, keyed by list ID.
    public let lists: [Int: VocabList]

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case version, source, lists
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(Int.self, forKey: .version)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        let listsArray = try container.decode([VocabList].self, forKey: .lists)
        var dict: [Int: VocabList] = [:]
        for var list in listsArray {
            // Assign listId to each word from its parent VocabList
            for i in list.words.indices {
                list.words[i].listId = list.id
            }
            dict[list.id] = list
        }
        self.lists = dict
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(source, forKey: .source)
        let listsArray = Array(lists.values).sorted { $0.id < $1.id }
        try container.encode(listsArray, forKey: .lists)
    }

    // MARK: - Public API

    /// Load vocabulary from the specified bundle's vocab.json resource.
    public static func load(from bundle: Bundle) throws -> Vocabulary {
        guard let url = bundle.url(forResource: "vocab", withExtension: "json") else {
            throw VocabularyError.resourceNotFound("vocab.json")
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Vocabulary.self, from: data)
    }

    /// Retrieve the VocabList objects for the given list IDs (in order).
    public func lists(with ids: [Int]) -> [VocabList] {
        ids.compactMap { lists[$0] }
    }
}

// MARK: - Errors

public enum VocabularyError: Error, LocalizedError {
    case resourceNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .resourceNotFound(let name):
            return "Resource not found: \(name)"
        }
    }
}
