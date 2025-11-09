//
//  GameManager.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var gameState: GameState = .notStarted
    @Published var selectedCategories: [Category] = []
    @Published var rounds: [GameRound] = []
    @Published var currentRoundIndex: Int = 0
    @Published var totalScore: Int = 0
    @Published var usedCountries: Set<String> = []
    @Published var skipsRemaining: Int = 1
    @Published var hasSkippedCurrentRound: Bool = false

    enum GameState {
        case notStarted
        case playing
        case finished
    }

    var currentRound: GameRound? {
        guard currentRoundIndex < rounds.count else { return nil }
        return rounds[currentRoundIndex]
    }

    var isGameFinished: Bool {
        return currentRoundIndex >= rounds.count
    }

    func startNewGame() {
        // Reset game state
        gameState = .playing
        rounds = []
        currentRoundIndex = 0
        totalScore = 0
        usedCountries = []
        skipsRemaining = 1
        hasSkippedCurrentRound = false

        // Select 5 random categories
        selectedCategories = Category.allCases.shuffled().prefix(5).map { $0 }

        // Create first round
        createNextRound()
    }

    private func createNextRound() {
        guard currentRoundIndex < 5 else {
            gameState = .finished
            return
        }

        // Get available categories (not yet used)
        let availableCategories = selectedCategories.filter { category in
            !rounds.contains { round in
                round.selectedCategory == category
            }
        }

        // Select a random country that hasn't been used yet
        var country: Country
        repeat {
            country = CountryData.shared.randomCountry()
        } while usedCountries.contains(country.id)

        usedCountries.insert(country.id)

        let round = GameRound(
            roundNumber: currentRoundIndex + 1,
            country: country,
            availableCategories: availableCategories
        )

        rounds.append(round)
    }

    func selectCategory(_ category: Category) {
        guard currentRoundIndex < rounds.count else { return }

        let country = rounds[currentRoundIndex].country
        let ranking = country.ranking(for: category)

        // Update current round
        rounds[currentRoundIndex].selectedCategory = category
        rounds[currentRoundIndex].score = ranking

        // Update total score
        totalScore += ranking

        // Haptic feedback baseado na pontuação
        DispatchQueue.main.async {
            switch ranking {
            case 1...10:
                HapticManager.shared.success()
            case 11...25:
                HapticManager.shared.medium()
            case 26...50:
                HapticManager.shared.light()
            default:
                HapticManager.shared.warning()
            }
        }

        // Move to next round after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.nextRound()
        }
    }

    func skipCurrentCountry() {
        guard skipsRemaining > 0 && !hasSkippedCurrentRound else { return }
        guard currentRoundIndex < rounds.count else { return }

        skipsRemaining -= 1
        hasSkippedCurrentRound = true

        // Remove current country from used countries so it can appear again
        let currentCountryId = rounds[currentRoundIndex].country.id
        usedCountries.remove(currentCountryId)

        // Select a new country
        var country: Country
        repeat {
            country = CountryData.shared.randomCountry()
        } while usedCountries.contains(country.id)

        usedCountries.insert(country.id)

        // Update current round with new country
        let availableCategories = rounds[currentRoundIndex].availableCategories
        rounds[currentRoundIndex] = GameRound(
            roundNumber: currentRoundIndex + 1,
            country: country,
            availableCategories: availableCategories
        )

        HapticManager.shared.light()
    }

    private func nextRound() {
        currentRoundIndex += 1
        hasSkippedCurrentRound = false

        if currentRoundIndex < 5 {
            createNextRound()
        } else {
            gameState = .finished
        }
    }

    func resetGame() {
        gameState = .notStarted
        selectedCategories = []
        rounds = []
        currentRoundIndex = 0
        totalScore = 0
        usedCountries = []
    }

    func getBestPossibleCategory(for country: Country, from categories: [Category]) -> Category? {
        return categories.min { cat1, cat2 in
            country.ranking(for: cat1) < country.ranking(for: cat2)
        }
    }

    func getScoreRating() -> String {
        let averageScore = totalScore / 5
        switch averageScore {
        case 0...10:
            return "Excepcional! 🏆"
        case 11...25:
            return "Excelente! ⭐️"
        case 26...50:
            return "Muito Bom! 👏"
        case 51...100:
            return "Bom! 👍"
        default:
            return "Continue praticando! 💪"
        }
    }

    func getOptimalScore() -> Int {
        var optimalScore = 0
        for round in rounds {
            if let bestCategory = round.country.bestCategory(from: round.availableCategories) {
                optimalScore += round.country.ranking(for: bestCategory)
            }
        }
        return optimalScore
    }

    func getOptimalScoreForRound(_ round: GameRound) -> (category: Category, ranking: Int)? {
        guard let bestCategory = round.country.bestCategory(from: round.availableCategories) else {
            return nil
        }
        let ranking = round.country.ranking(for: bestCategory)
        return (bestCategory, ranking)
    }
}
