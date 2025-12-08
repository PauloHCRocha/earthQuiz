//
//  GameRound.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import Foundation

// Score tier based on percentage of max points achieved
enum ScoreTier: String {
    case perfect = "Perfeito!"
    case great = "Excelente!"
    case good = "Bom!"
    case average = "Razoável"
    case poor = "Pode melhorar"

    var emoji: String {
        switch self {
        case .perfect: return "🎯"
        case .great: return "⭐️"
        case .good: return "👍"
        case .average: return "😐"
        case .poor: return "💪"
        }
    }

    static func from(score: Int, maxPoints: Int = 1000) -> ScoreTier {
        let percentage = Double(score) / Double(maxPoints)
        switch percentage {
        case 1.0: return .perfect
        case 0.75..<1.0: return .great
        case 0.50..<0.75: return .good
        case 0.25..<0.50: return .average
        default: return .poor
        }
    }
}

struct RoundScore {
    let baseScore: Int           // Score before multiplier
    let multiplier: Double       // Streak multiplier applied
    let speedBonus: Int          // Speed bonus (+200 if perfect + fast)
    let finalScore: Int          // Score after multiplier + speed bonus
    let tier: ScoreTier          // Score tier achieved
    let chosenRank: Int          // The rank of chosen option
    let bestRank: Int            // The best rank available
    let responseTime: Double     // Time taken to answer in seconds

    var isPerfect: Bool {
        return tier == .perfect
    }

    var hasSpeedBonus: Bool {
        return speedBonus > 0
    }

    // Multiplier bonus points (finalScore without speed bonus - baseScore)
    var multiplierBonus: Int {
        return Int(Double(baseScore) * multiplier) - baseScore
    }
}

struct GameRound: Identifiable {
    let id = UUID()
    let roundNumber: Int

    // Normal mode: show country, select category
    let country: Country?
    let availableCategories: [Category]
    var selectedCategory: Category?

    // Reverse mode (final round): show category, select country
    let isReverseMode: Bool
    let category: Category?
    let countryOptions: [Country]?
    var selectedCountry: Country?

    var score: Int?              // Legacy - kept for compatibility
    var roundScore: RoundScore?  // New detailed score
    var triviaMessage: String?

    // Timing for speed bonus
    var startTime: Date = Date()

    var isCompleted: Bool {
        roundScore != nil && (selectedCategory != nil || selectedCountry != nil)
    }

    // Normal mode initializer
    init(roundNumber: Int, country: Country, availableCategories: [Category]) {
        self.roundNumber = roundNumber
        self.country = country
        self.availableCategories = availableCategories
        self.isReverseMode = false
        self.category = nil
        self.countryOptions = nil
        self.startTime = Date()
    }

    // Reverse mode initializer
    init(roundNumber: Int, category: Category, countryOptions: [Country]) {
        self.roundNumber = roundNumber
        self.country = nil
        self.availableCategories = []
        self.isReverseMode = true
        self.category = category
        self.countryOptions = countryOptions
        self.startTime = Date()
    }
}
