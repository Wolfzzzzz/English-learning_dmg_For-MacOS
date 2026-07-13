import Foundation

/// A set of junior high school vocabulary words used for exclusion filtering.
/// Words are stored lowercased for case-insensitive lookup.
public struct JuniorHighWordSet: Codable {
    /// Lowercased set of junior high words.
    public let words: Set<String>

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case words
    }

    /// Create a JuniorHighWordSet from an array of words (for testing).
    public init(words: [String]) {
        self.words = Set(words.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawWords = try container.decode([String].self, forKey: .words)
        self.words = Set(rawWords.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Array(words).sorted(), forKey: .words)
    }

    // MARK: - Public API

    /// Load junior high word set from the specified bundle's junior_high.json resource.
    public static func load(from bundle: Bundle) throws -> JuniorHighWordSet {
        guard let url = bundle.url(forResource: "junior_high", withExtension: "json") else {
            throw JuniorHighError.resourceNotFound("junior_high.json")
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(JuniorHighWordSet.self, from: data)
    }

    /// Check if a word is in the junior high set (case-insensitive).
    public func contains(_ en: String) -> Bool {
        words.contains(en.lowercased().trimmingCharacters(in: .whitespaces))
    }
}

// MARK: - Errors

public enum JuniorHighError: Error, LocalizedError {
    case resourceNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .resourceNotFound(let name):
            return "Resource not found: \(name)"
        }
    }
}
