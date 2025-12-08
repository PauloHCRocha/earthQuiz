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
    let trivia: [Category: String]

    init(id: String, name: String, flag: String, rankings: [Category: Int], trivia: [Category: String] = [:]) {
        self.id = id
        self.name = name
        self.flag = flag
        self.rankings = rankings
        self.trivia = trivia
    }

    func triviaText(for category: Category) -> String? {
        return trivia[category]
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
        case trivia
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        flag = try container.decode(String.self, forKey: .flag)

        // Decode rankings from a [String: Int] dictionary and map to [Category: Int]
        let rawRankings = try container.decode([String: Int].self, forKey: .rankings)
        var mappedRankings: [Category: Int] = [:]
        for (rawKey, value) in rawRankings {
            if let category = Category(rawValue: rawKey) {
                mappedRankings[category] = value
            }
        }
        rankings = mappedRankings

        // Decode trivia from a [String: String] dictionary and map to [Category: String]
        let rawTrivia = try container.decodeIfPresent([String: String].self, forKey: .trivia) ?? [:]
        var mappedTrivia: [Category: String] = [:]
        for (rawKey, value) in rawTrivia {
            if let category = Category(rawValue: rawKey) {
                mappedTrivia[category] = value
            }
        }
        trivia = mappedTrivia
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

        // Encode trivia as [String: String] using Category.rawValue
        let rawTrivia = Dictionary(uniqueKeysWithValues: trivia.map { (key, value) in
            (key.rawValue, value)
        })
        try container.encode(rawTrivia, forKey: .trivia)
    }
}
