//
//  GameRound.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import Foundation

struct GameRound: Identifiable {
    let id = UUID()
    let roundNumber: Int
    let country: Country
    let availableCategories: [Category]
    var selectedCategory: Category?
    var score: Int?

    var isCompleted: Bool {
        selectedCategory != nil && score != nil
    }
}
