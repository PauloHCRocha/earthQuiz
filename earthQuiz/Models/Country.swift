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
