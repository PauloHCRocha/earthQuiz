//
//  Country.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import Foundation

struct Country: Identifiable, Codable {
    let id: String
    let name: String
    let flag: String
    let rankings: [Category: Int]

    init(id: String, name: String, flag: String, rankings: [Category: Int]) {
        self.id = id
        self.name = name
        self.flag = flag
        self.rankings = rankings
    }

    func ranking(for category: Category) -> Int {
        return rankings[category] ?? 999
    }

    func bestCategory(from availableCategories: [Category]) -> Category? {
        return availableCategories.min { category1, category2 in
            ranking(for: category1) < ranking(for: category2)
        }
    }
}

// MARK: - Codable
extension Country {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case flag
        case rankings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        flag = try container.decode(String.self, forKey: .flag)

        // Decode rankings from a [String: Int] dictionary and map to [Category: Int]
        let rawRankings = try container.decode([String: Int].self, forKey: .rankings)
        var mapped: [Category: Int] = [:]
        for (rawKey, value) in rawRankings {
            if let category = Category(rawValue: rawKey) {
                mapped[category] = value
            }
            // If a key doesn't map to a Category, we silently skip it.
            // Alternatively, you could throw a decoding error if strictness is desired.
        }
        rankings = mapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(flag, forKey: .flag)

        // Encode rankings as [String: Int] using Category.rawValue
        let rawRankings = Dictionary(uniqueKeysWithValues: rankings.map { (key, value) in
            (key.rawValue, value)
        })
        try container.encode(rawRankings, forKey: .rankings)
    }
}
