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
    @Published var isFullReverseMode: Bool = false

    // Streak system
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0

    // Session ID to cancel pending async operations when game is reset
    @Published private(set) var gameSessionId: UUID = UUID()

    // Scoring constants
    static let maxPointsPerRound: Int = 1000
    static let speedBonusPoints: Int = 200
    static let speedBonusTimeLimit: Double = 5.0
    static let mysteryBonusPoints: Int = 1500

    // Extra round tracking
    @Published var hasEarnedExtraRound: Bool = false
    @Published var totalRounds: Int = 5

    // End game bonus
    @Published var mysteryBonus: Int = 0

    enum GameState {
        case notStarted
        case playing
        case finished
    }

    // Calculate streak multiplier based on consecutive perfect scores
    var streakMultiplier: Double {
        switch currentStreak {
        case 0: return 1.0
        case 1: return 1.0   // First perfect doesn't get bonus
        case 2: return 1.2   // 2 in a row: 20% bonus
        case 3: return 1.5   // 3 in a row: 50% bonus
        case 4: return 1.8   // 4 in a row: 80% bonus
        default: return 2.0  // 5+ in a row: 100% bonus (double points!)
        }
    }

    var currentRound: GameRound? {
        guard currentRoundIndex < rounds.count else { return nil }
        return rounds[currentRoundIndex]
    }

    var isGameFinished: Bool {
        return currentRoundIndex >= rounds.count
    }

    func startNewGame() {
        // Generate new session ID to cancel any pending async operations
        gameSessionId = UUID()

        // Reset game state
        gameState = .playing
        rounds = []
        currentRoundIndex = 0
        totalScore = 0
        usedCountries = []
        skipsRemaining = 1
        hasSkippedCurrentRound = false
        currentStreak = 0
        bestStreak = 0
        hasEarnedExtraRound = false
        totalRounds = 5
        mysteryBonus = 0

        // Select 5 random categories (6th will be added if extra round is earned)
        selectedCategories = Category.allCases.shuffled().prefix(5).map { $0 }

        // Create first round
        createNextRound()
    }

    private func createNextRound() {
        guard currentRoundIndex < totalRounds else {
            finishGame()
            return
        }

        // Get available categories (not yet used)
        let availableCategories = selectedCategories.filter { category in
            !rounds.contains { round in
                round.selectedCategory == category || round.category == category
            }
        }

        // Determine if this round should be reverse mode
        // Last round is always reverse mode (round 5 normally, or round 6 if extra round earned)
        let isLastRound = currentRoundIndex == totalRounds - 1
        let shouldBeReverseMode = isFullReverseMode || isLastRound || (availableCategories.count == 1)

        if shouldBeReverseMode, let category = availableCategories.first {
            // Reverse mode: show category, select from 5 countries
            let allCountries = CountryData.shared.countries
            var selectedCountries: [Country] = []
            var availableCountries = allCountries.filter { !usedCountries.contains($0.id) }

            // If we don't have enough unused countries, use all countries
            if availableCountries.count < 5 {
                availableCountries = allCountries
            }

            selectedCountries = Array(availableCountries.shuffled().prefix(5))

            // Mark these countries as used
            for country in selectedCountries {
                usedCountries.insert(country.id)
            }

            let round = GameRound(
                roundNumber: currentRoundIndex + 1,
                category: category,
                countryOptions: selectedCountries
            )

            rounds.append(round)
        } else {
            // Normal mode: select a random country that hasn't been used yet
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
    }

    func selectCategory(_ category: Category) {
        guard currentRoundIndex < rounds.count else { return }
        guard let country = rounds[currentRoundIndex].country else { return }

        // Calculate response time
        let responseTime = Date().timeIntervalSince(rounds[currentRoundIndex].startTime)

        let chosenRank = country.ranking(for: category)

        // Find the best rank available among all options
        let bestRank = rounds[currentRoundIndex].availableCategories
            .map { country.ranking(for: $0) }
            .min() ?? 1

        // Calculate score using inverse proportion formula
        let roundScore = calculateScore(chosenRank: chosenRank, bestRank: bestRank, responseTime: responseTime)

        // Update current round
        rounds[currentRoundIndex].selectedCategory = category
        rounds[currentRoundIndex].score = roundScore.finalScore
        rounds[currentRoundIndex].roundScore = roundScore

        // Generate trivia message for the BEST category (correct answer)
        if let bestCategory = country.bestCategory(from: rounds[currentRoundIndex].availableCategories) {
            let bestRanking = country.ranking(for: bestCategory)
            rounds[currentRoundIndex].triviaMessage = generateTrivia(for: country, category: bestCategory, ranking: bestRanking)
        }

        // Update total score
        totalScore += roundScore.finalScore

        // Haptic feedback based on score tier
        DispatchQueue.main.async {
            switch roundScore.tier {
            case .perfect:
                HapticManager.shared.success()
            case .great:
                HapticManager.shared.success()
            case .good:
                HapticManager.shared.medium()
            case .average:
                HapticManager.shared.light()
            case .poor:
                HapticManager.shared.warning()
            }
        }

        // Move to next round after a delay (5 seconds to read trivia)
        // Capture session ID to cancel if game is reset
        let currentSessionId = gameSessionId
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self, self.gameSessionId == currentSessionId else { return }
            self.nextRound()
        }
    }

    func selectCountry(_ country: Country) {
        guard currentRoundIndex < rounds.count else { return }
        guard let category = rounds[currentRoundIndex].category else { return }
        guard let countryOptions = rounds[currentRoundIndex].countryOptions else { return }

        // Calculate response time
        let responseTime = Date().timeIntervalSince(rounds[currentRoundIndex].startTime)

        let chosenRank = country.ranking(for: category)

        // Find the best rank available among all options
        let bestRank = countryOptions.map { $0.ranking(for: category) }.min() ?? 1

        // Calculate score using inverse proportion formula
        let roundScore = calculateScore(chosenRank: chosenRank, bestRank: bestRank, responseTime: responseTime)

        // Update current round
        rounds[currentRoundIndex].selectedCountry = country
        rounds[currentRoundIndex].score = roundScore.finalScore
        rounds[currentRoundIndex].roundScore = roundScore

        // Generate trivia message for the BEST country (correct answer)
        if let bestCountry = countryOptions.min(by: { $0.ranking(for: category) < $1.ranking(for: category) }) {
            rounds[currentRoundIndex].triviaMessage = generateTrivia(for: bestCountry, category: category, ranking: bestRank)
        }

        // Update total score
        totalScore += roundScore.finalScore

        // Haptic feedback based on score tier
        DispatchQueue.main.async {
            switch roundScore.tier {
            case .perfect:
                HapticManager.shared.success()
            case .great:
                HapticManager.shared.success()
            case .good:
                HapticManager.shared.medium()
            case .average:
                HapticManager.shared.light()
            case .poor:
                HapticManager.shared.warning()
            }
        }

        // Move to next round after a delay (5 seconds to read trivia)
        // Capture session ID to cancel if game is reset
        let currentSessionId = gameSessionId
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self, self.gameSessionId == currentSessionId else { return }
            self.nextRound()
        }
    }

    /// Reset the start time for the current round (called when animation finishes)
    func resetCurrentRoundStartTime() {
        guard currentRoundIndex < rounds.count else { return }
        rounds[currentRoundIndex].startTime = Date()
    }

    func skipCurrentCountry() {
        guard skipsRemaining > 0 && !hasSkippedCurrentRound else { return }
        guard currentRoundIndex < rounds.count else { return }

        // Can't skip in reverse mode
        guard !rounds[currentRoundIndex].isReverseMode else { return }

        skipsRemaining -= 1
        hasSkippedCurrentRound = true

        // Remove current country from used countries so it can appear again
        if let currentCountryId = rounds[currentRoundIndex].country?.id {
            usedCountries.remove(currentCountryId)
        }

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

    // MARK: - Scoring System

    /// Calculate score using inverse proportion formula:
    /// Score = MaxPoints * (BestRankAvailable / ChosenRank)
    /// If perfect, streak is updated FIRST, then multiplier is applied
    /// Speed bonus of +200 if perfect AND answered in less than 5 seconds
    private func calculateScore(chosenRank: Int, bestRank: Int, responseTime: Double) -> RoundScore {
        let safeChosenRank = max(1, chosenRank)
        let safeBestRank = max(1, bestRank)

        // Base score calculation: MaxPoints * (BestRank / ChosenRank)
        let baseScore = Int(Double(Self.maxPointsPerRound) * (Double(safeBestRank) / Double(safeChosenRank)))

        // Determine tier before applying multiplier
        let tier = ScoreTier.from(score: baseScore, maxPoints: Self.maxPointsPerRound)

        // Update streak FIRST (before calculating multiplier)
        // This way, the current perfect answer contributes to the streak
        updateStreak(isPerfect: tier == .perfect)

        // Check for extra round eligibility (4 consecutive perfects)
        checkExtraRoundEligibility()

        // Apply streak multiplier only if perfect (now includes this answer in streak)
        let multiplier = tier == .perfect ? streakMultiplier : 1.0
        let scoreWithMultiplier = Int(Double(baseScore) * multiplier)

        // Speed bonus: +200 if perfect AND answered quickly (< 5 seconds)
        let speedBonus = (tier == .perfect && responseTime < Self.speedBonusTimeLimit) ? Self.speedBonusPoints : 0
        let finalScore = scoreWithMultiplier + speedBonus

        return RoundScore(
            baseScore: baseScore,
            multiplier: multiplier,
            speedBonus: speedBonus,
            finalScore: finalScore,
            tier: tier,
            chosenRank: chosenRank,
            bestRank: bestRank,
            responseTime: responseTime
        )
    }

    /// Check if player has earned an extra round (4 consecutive perfects)
    private func checkExtraRoundEligibility() {
        // Only check if we haven't already earned extra round and we're at round 4 with streak of 4
        if !hasEarnedExtraRound && currentStreak >= 4 && currentRoundIndex == 3 {
            hasEarnedExtraRound = true
            totalRounds = 6

            // Add a 6th category for the extra round
            let usedCategories = Set(selectedCategories)
            let availableCategories = Category.allCases.filter { !usedCategories.contains($0) }
            if let newCategory = availableCategories.randomElement() {
                selectedCategories.append(newCategory)
            }
        }
    }

    /// Update streak based on whether the player got a perfect score
    private func updateStreak(isPerfect: Bool) {
        if isPerfect {
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
    }

    private func nextRound() {
        currentRoundIndex += 1
        hasSkippedCurrentRound = false

        if currentRoundIndex < totalRounds {
            createNextRound()
        } else {
            finishGame()
        }
    }

    private func finishGame() {
        // Calculate end-of-game mystery bonus
        mysteryBonus = calculateEndGameBonus()

        // Add mystery bonus to total score
        totalScore += mysteryBonus

        gameState = .finished
    }

    /// Calculate end-of-game mystery bonus
    /// Returns +1500 points if ALL rounds were perfect (base score 1000)
    /// Must be perfect in all 5 rounds, or all 6 rounds if extra round was earned
    func calculateEndGameBonus() -> Int {
        let perfectCount = rounds.filter { $0.roundScore?.baseScore == Self.maxPointsPerRound }.count
        // Must have perfect score in ALL rounds (5 or 6 depending on extra round)
        return perfectCount == totalRounds ? Self.mysteryBonusPoints : 0
    }

    /// Count total perfect scores in the game (Tier S - Acertos Críticos)
    var totalPerfectScores: Int {
        return rounds.filter { $0.roundScore?.tier == .perfect }.count
    }

    /// Count total great scores in the game (Tier A - Acertos Excelentes)
    var totalGreatScores: Int {
        return rounds.filter { $0.roundScore?.tier == .great }.count
    }

    /// Get accuracy-based title (independent of time/bonuses)
    /// Based only on perfect (S) and great (A) tier achievements
    func getAccuracyTitle() -> (title: String, emoji: String, description: String) {
        let perfects = totalPerfectScores
        let greats = totalGreatScores
        let goodOrBetter = perfects + greats

        // 5+ Acertos Críticos (all perfect): "Atlas Humano"
        if perfects >= totalRounds {
            return ("Atlas Humano", "🌍", "Conhecimento geográfico perfeito!")
        }
        // 4 Acertos Críticos: "Mestre Geográfico"
        else if perfects >= 4 {
            return ("Mestre Geográfico", "🎓", "Domínio quase perfeito!")
        }
        // 3+ Acertos Excelentes (S ou A): "Viajante Experiente"
        else if goodOrBetter >= 3 {
            return ("Viajante Experiente", "✈️", "Conhece bem o mundo!")
        }
        // Menos de 3 bons acertos: "Turista"
        else {
            return ("Turista", "🧳", "Continue a explorar o mundo!")
        }
    }

    func resetGame() {
        // Generate new session ID to cancel any pending async operations
        gameSessionId = UUID()

        gameState = .notStarted
        selectedCategories = []
        rounds = []
        currentRoundIndex = 0
        totalScore = 0
        usedCountries = []
        currentStreak = 0
        bestStreak = 0
        hasEarnedExtraRound = false
        totalRounds = 5
        mysteryBonus = 0
    }

    func getBestPossibleCategory(for country: Country, from categories: [Category]) -> Category? {
        return categories.min { cat1, cat2 in
            country.ranking(for: cat1) < country.ranking(for: cat2)
        }
    }

    /// Get overall game rating based on total score
    /// Max possible: 7500 points (5 perfect rounds with full streak bonuses)
    func getScoreRating() -> String {
        let percentage = getScorePercentage()

        switch percentage {
        case 90...:
            return "Lendário! 🏆"
        case 75..<90:
            return "Excelente! ⭐️"
        case 60..<75:
            return "Muito Bom! 👏"
        case 45..<60:
            return "Bom! 👍"
        case 30..<45:
            return "Razoável 😊"
        default:
            return "Continue a praticar! 💪"
        }
    }

    /// Get the maximum possible score (all perfect answers with streak + speed bonuses + mystery bonus)
    /// Round 1: 1000 × 1.0 + 200 = 1200 (streak 1, no multiplier bonus, but speed bonus)
    /// Round 2: 1000 × 1.2 + 200 = 1400 (streak 2)
    /// Round 3: 1000 × 1.5 + 200 = 1700 (streak 3)
    /// Round 4: 1000 × 1.8 + 200 = 2000 (streak 4) - triggers extra round!
    /// Round 5: 1000 × 2.0 + 200 = 2200 (streak 5)
    /// Round 6: 1000 × 2.0 + 200 = 2200 (streak 6, extra round)
    /// Mystery Bonus: +1500 (5+ perfects)
    /// Total: 12200
    func getMaxPossibleScore() -> Int {
        // Base multipliers for 6 rounds (max with extra round)
        let multipliers = [1.0, 1.2, 1.5, 1.8, 2.0, 2.0]
        let roundCount = totalRounds

        var total = 0
        for i in 0..<roundCount {
            // Base score with multiplier
            total += Int(Double(Self.maxPointsPerRound) * multipliers[i])
            // Speed bonus for each round
            total += Self.speedBonusPoints
        }

        // Add mystery bonus if applicable (5+ perfects)
        if roundCount >= 5 {
            total += Self.mysteryBonusPoints
        }

        return total
    }

    /// Get the base max score without extra round (for display purposes)
    func getBaseMaxPossibleScore() -> Int {
        let multipliers = [1.0, 1.2, 1.5, 1.8, 2.0]
        var total = 0
        for multiplier in multipliers {
            total += Int(Double(Self.maxPointsPerRound) * multiplier)
            total += Self.speedBonusPoints
        }
        total += Self.mysteryBonusPoints
        return total
    }

    /// Get percentage of max score achieved
    func getScorePercentage() -> Double {
        return Double(totalScore) / Double(getMaxPossibleScore()) * 100
    }

    func getOptimalScore() -> Int {
        var optimalScore = 0
        for round in rounds {
            if round.isReverseMode {
                // For reverse mode, find the best country from options
                if let category = round.category, let options = round.countryOptions {
                    let bestRanking = options.map { $0.ranking(for: category) }.min() ?? 999
                    optimalScore += bestRanking
                }
            } else {
                // For normal mode, find best category for the country
                if let country = round.country, let bestCategory = country.bestCategory(from: round.availableCategories) {
                    optimalScore += country.ranking(for: bestCategory)
                }
            }
        }
        return optimalScore
    }

    func getOptimalScoreForRound(_ round: GameRound) -> (category: Category, ranking: Int)? {
        if round.isReverseMode {
            // For reverse mode, show the category and the best country's ranking
            guard let category = round.category, let options = round.countryOptions else {
                return nil
            }
            let bestRanking = options.map { $0.ranking(for: category) }.min() ?? 999
            return (category, bestRanking)
        } else {
            // For normal mode, show best category for the country
            guard let country = round.country, let bestCategory = country.bestCategory(from: round.availableCategories) else {
                return nil
            }
            let ranking = country.ranking(for: bestCategory)
            return (bestCategory, ranking)
        }
    }

    private func generateTrivia(for country: Country, category: Category, ranking: Int) -> String {
        // First try to get specific trivia from country data
        if let specificTrivia = country.triviaText(for: category) {
            return specificTrivia
        }

        // Fallback to generic trivia based on ranking
        let countryName = country.name
        let categoryName = category.rawValue

        switch ranking {
        case 1:
            return "\(countryName) é o #1 mundial em \(categoryName)!"
        case 2...5:
            return "\(countryName) está no top 5 mundial em \(categoryName), ocupando a posição #\(ranking)."
        case 6...10:
            return "\(countryName) está no top 10 mundial em \(categoryName), na posição #\(ranking)."
        case 11...25:
            return "\(countryName) tem uma posição respeitável em \(categoryName), ranking #\(ranking)."
        case 26...50:
            return "\(countryName) está na posição #\(ranking) em \(categoryName), na metade superior do ranking mundial."
        case 51...100:
            return "\(countryName) ocupa a posição #\(ranking) em \(categoryName)."
        default:
            return "\(countryName) está na posição #\(ranking) em \(categoryName), com espaço para melhorar."
        }
    }
}
