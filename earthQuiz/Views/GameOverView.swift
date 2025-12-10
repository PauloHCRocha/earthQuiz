//
//  GameOverView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showTrophy = false
    @State private var showScore = false
    @State private var showRounds = false

    // Excellence bonus animation
    @State private var displayedScore: Int = 0
    @State private var showExcellenceBonus = false
    @State private var excellenceBonusScale: CGFloat = 0.3
    @State private var excellenceBonusAdded = false
    @State private var scoreScale: CGFloat = 1.0

    var body: some View {
        let titleData = gameManager.getAccuracyTitle()
        let isTimedMode = gameManager.gameMode == .timed

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // Arcade-style header
                    VStack(spacing: 8) {
                        // Header text - different for timed mode
                        if isTimedMode {
                            Text("TEMPO ESGOTADO!")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .tracking(2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 0)
                                .scaleEffect(showTrophy ? 1.0 : 0.5)
                                .opacity(showTrophy ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showTrophy)

                            // Time duration badge
                            if let timedOption = gameManager.timedModeSelection {
                                HStack(spacing: 6) {
                                    Image(systemName: "timer")
                                        .font(.system(size: 18))
                                    Text(timedOption.displayName)
                                        .font(.system(size: 20, weight: .black))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .scaleEffect(showTrophy ? 1.0 : 0.3)
                                .opacity(showTrophy ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: showTrophy)
                            }
                        } else {
                            // GAME OVER text with arcade style
                            Text("GAME OVER")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .tracking(4)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 0)
                                .scaleEffect(showTrophy ? 1.0 : 0.5)
                                .opacity(showTrophy ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showTrophy)

                            // Title badge with emoji
                            HStack(spacing: 8) {
                                Text(titleData.emoji)
                                    .font(.system(size: 28))
                                Text(titleData.title)
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: titleGradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.secondary.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                LinearGradient(
                                                    colors: titleGradientColors,
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .scaleEffect(showTrophy ? 1.0 : 0.3)
                            .opacity(showTrophy ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: showTrophy)
                        }
                    }
                    .padding(.top, 16)

                    // Score card - more compact
                    VStack(spacing: 10) {
                        if isTimedMode {
                            // Timed mode: Show questions answered prominently
                            VStack(spacing: 4) {
                                Text("\(gameManager.questionsAnswered)")
                                    .font(.system(size: 56, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(scoreScale)
                                    .contentTransition(.numericText())

                                Text("QUESTÕES")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .tracking(2)
                            }

                            // Stats row for timed mode
                            HStack(spacing: 16) {
                                // Correct answers
                                StatBadge(
                                    icon: "checkmark.circle.fill",
                                    label: "Perfeitos",
                                    value: "\(gameManager.correctAnswers)",
                                    color: .green
                                )

                                // Accuracy percentage
                                StatBadge(
                                    icon: "percent",
                                    label: "Precisão",
                                    value: gameManager.questionsAnswered > 0 ? "\(Int(Double(gameManager.correctAnswers) / Double(gameManager.questionsAnswered) * 100))%" : "0%",
                                    color: .blue
                                )

                                // Total score
                                StatBadge(
                                    icon: "star.fill",
                                    label: "Pontos",
                                    value: "\(displayedScore)",
                                    color: .yellow
                                )
                            }

                            // Questions per minute
                            if let timedOption = gameManager.timedModeSelection {
                                let questionsPerMinute = Double(gameManager.questionsAnswered) / (timedOption.seconds / 60.0)
                                HStack(spacing: 8) {
                                    BonusBadge(
                                        icon: "speedometer",
                                        text: String(format: "%.1f questões/min", questionsPerMinute),
                                        colors: [.cyan, .blue]
                                    )
                                }
                            }
                        } else {
                            // Classic mode: Original display
                            VStack(spacing: 2) {
                                Text("\(displayedScore)")
                                    .font(.system(size: 56, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: scoreGradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(scoreScale)
                                    .contentTransition(.numericText())

                                Text("PONTOS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .tracking(2)
                            }

                            // Stats row - horizontal compact
                            HStack(spacing: 16) {
                                // Average
                                StatBadge(
                                    icon: "chart.bar.fill",
                                    label: "Média",
                                    value: "\(displayedScore / max(gameManager.totalRounds, 1))",
                                    color: .blue
                                )

                                // Best Streak
                                if gameManager.bestStreak > 0 {
                                    StatBadge(
                                        icon: "flame.fill",
                                        label: "Streak",
                                        value: "\(gameManager.bestStreak)x",
                                        color: .orange
                                    )
                                }

                                // Perfects count
                                if gameManager.totalPerfectScores > 0 {
                                    StatBadge(
                                        icon: "star.fill",
                                        label: "Perfeitos",
                                        value: "\(gameManager.totalPerfectScores)",
                                        color: .yellow
                                    )
                                }
                            }

                            // Bonus badges row
                            if gameManager.hasEarnedExtraRound || (gameManager.mysteryBonus > 0 && showExcellenceBonus) {
                                HStack(spacing: 8) {
                                    if gameManager.hasEarnedExtraRound {
                                        BonusBadge(
                                            icon: "plus.circle.fill",
                                            text: "Ronda Extra",
                                            colors: [.purple, .pink]
                                        )
                                    }

                                    if gameManager.mysteryBonus > 0 && showExcellenceBonus {
                                        BonusBadge(
                                            icon: "sparkles",
                                            text: excellenceBonusAdded ? "+\(gameManager.mysteryBonus) Adicionado" : "+\(gameManager.mysteryBonus)",
                                            colors: [.yellow, .orange]
                                        )
                                        .scaleEffect(excellenceBonusScale)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary.opacity(0.08))
                    )
                    .padding(.horizontal, 16)
                    .scaleEffect(showScore ? 1.0 : 0.8)
                    .opacity(showScore ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: showScore)

                // Rounds Summary - only show in classic mode (timed mode can have many rounds)
                if !isTimedMode {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard.fill")
                                .foregroundColor(.blue)
                            Text("Resumo")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Text("\(gameManager.totalRounds) rondas")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }

                        ForEach(Array(gameManager.rounds.enumerated()), id: \.element.id) { index, round in
                            RoundSummaryRow(
                                index: index,
                                round: round,
                                showRounds: showRounds,
                                scoreColor: scoreColor,
                                isExtraRound: gameManager.hasEarnedExtraRound && index == gameManager.totalRounds - 1
                            )
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.secondary.opacity(0.08))
                    )
                    .padding(.horizontal, 16)
                }

                // Arcade-style buttons
                HStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.medium()
                        withAnimation {
                            if isTimedMode, let timedOption = gameManager.timedModeSelection {
                                // Replay same timed mode
                                gameManager.startTimedGame(duration: timedOption)
                            } else {
                                gameManager.startNewGame()
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isTimedMode ? "arrow.counterclockwise" : "play.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text(isTimedMode ? "REPETIR" : "JOGAR")
                                .font(.system(size: 14, weight: .black))
                                .tracking(1)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: isTimedMode ? [.orange, .red] : [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: (isTimedMode ? Color.orange : Color.green).opacity(0.4), radius: 6, x: 0, y: 3)
                    }

                    Button(action: {
                        HapticManager.shared.light()
                        withAnimation {
                            gameManager.resetGame()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 14, weight: .medium))
                            Text("MENU")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                }
            }

            // AdMob Banner at bottom
            BannerAdView()
                .frame(height: 50)
                .background(Color.secondary.opacity(0.1))
        }
        .onAppear {
            // Play menu music
            SoundManager.shared.playMenuMusic()

            // Calculate score without excellence bonus for initial display
            let scoreWithoutBonus = gameManager.totalScore - gameManager.mysteryBonus
            displayedScore = scoreWithoutBonus

            HapticManager.shared.success()
            withAnimation {
                showTrophy = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                showScore = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showRounds = true
            }

            // Excellence bonus animation sequence
            if gameManager.mysteryBonus > 0 {
                // Show the excellence bonus badge
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        showExcellenceBonus = true
                        excellenceBonusScale = 1.0
                    }
                    HapticManager.shared.heavy()
                }

                // Add bonus to score with animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        excellenceBonusAdded = true
                        scoreScale = 1.15
                    }

                    // Animate score counting up
                    animateScoreAddition(from: scoreWithoutBonus, adding: gameManager.mysteryBonus)

                    HapticManager.shared.success()

                    // Return score to normal scale
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scoreScale = 1.0
                        }
                    }
                }
            }
        }
    }

    private func animateScoreAddition(from startValue: Int, adding bonus: Int) {
        let endValue = startValue + bonus
        let duration: Double = 0.8
        let steps = 20
        let stepDuration = duration / Double(steps)

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (stepDuration * Double(i))) {
                let progress = Double(i) / Double(steps)
                // Ease out curve for more dramatic finish
                let easedProgress = 1 - pow(1 - progress, 3)
                withAnimation(.linear(duration: stepDuration)) {
                    displayedScore = startValue + Int(Double(bonus) * easedProgress)
                }
            }
        }
    }

    private var scoreGradientColors: [Color] {
        let percentage = gameManager.getScorePercentage()
        switch percentage {
        case 90...:
            return [.green, .mint]
        case 75..<90:
            return [.blue, .cyan]
        case 50..<75:
            return [.orange, .yellow]
        default:
            return [.red, .pink]
        }
    }

    private var titleGradientColors: [Color] {
        let perfects = gameManager.totalPerfectScores
        let goodOrBetter = perfects + gameManager.totalGreatScores

        // Atlas Humano (all perfect)
        if perfects >= gameManager.totalRounds {
            return [.yellow, .orange]
        }
        // Mestre Geográfico (4+ perfects)
        else if perfects >= 4 {
            return [.green, .mint]
        }
        // Viajante Experiente (3+ good)
        else if goodOrBetter >= 3 {
            return [.blue, .cyan]
        }
        // Turista
        else {
            return [.purple, .pink]
        }
    }

    private func scoreColor(for score: Int) -> Color {
        // Score is arcade style (higher is better)
        // With multipliers and speed bonus, scores can exceed 1000
        switch score {
        case 1000...:
            return .green  // Perfect score or better (with bonuses)
        case 750..<1000:
            return .blue
        case 500..<750:
            return .cyan
        case 250..<500:
            return .orange
        default:
            return .red
        }
    }
}

struct RoundSummaryRow: View {
    let index: Int
    let round: GameRound
    let showRounds: Bool
    let scoreColor: (Int) -> Color
    let isExtraRound: Bool

    private var hasMultiplier: Bool {
        guard let roundScore = round.roundScore else { return false }
        return roundScore.multiplier > 1.0
    }

    private var hasSpeedBonus: Bool {
        guard let roundScore = round.roundScore else { return false }
        return roundScore.speedBonus > 0
    }

    private var multiplierBonusPoints: Int {
        guard let roundScore = round.roundScore else { return 0 }
        return roundScore.multiplierBonus
    }

    var body: some View {
        if round.isReverseMode {
            // Reverse mode: show category and selected country
            if let category = round.category,
               let selectedCountry = round.selectedCountry,
               let score = round.score {
                reverseModeSummary(category: category, country: selectedCountry, score: score)
            }
        } else {
            // Normal mode: show country and selected category
            if let country = round.country,
               let selectedCategory = round.selectedCategory,
               let score = round.score {
                normalModeSummary(country: country, category: selectedCategory, score: score)
            }
        }
    }

    private func normalModeSummary(country: Country, category: Category, score: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Round number header
            HStack(spacing: 6) {
                Text("Ronda \(index + 1)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                if isExtraRound {
                    extraRoundBadge
                }
            }

            // Main content row
            HStack(spacing: 8) {
                // Country flag and name
                HStack(spacing: 6) {
                    Text(country.flag)
                        .font(.system(size: 22))
                    Text(country.name)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                }

                Spacer()

                // Score badge
                scoreBadge(score)
            }

            // Second row: Category selected + bonuses
            HStack(spacing: 6) {
                // Category badge
                categoryBadge(category)

                // Speed bonus badge if applicable
                if hasSpeedBonus, let roundScore = round.roundScore {
                    speedBonusBadge(bonus: roundScore.speedBonus)
                }

                // Multiplier badge if applicable
                if hasMultiplier, let roundScore = round.roundScore {
                    multiplierBadge(multiplier: roundScore.multiplier, bonus: multiplierBonusPoints)
                }

                Spacer()
            }
        }
        .padding(12)
        .background(rowBackground)
        .opacity(showRounds ? 1 : 0)
        .offset(x: showRounds ? 0 : -20)
        .animation(.easeOut(duration: 0.3).delay(1.0 + Double(index) * 0.1), value: showRounds)
    }

    private func reverseModeSummary(category: Category, country: Country, score: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Round number header
            HStack(spacing: 6) {
                Text("Ronda \(index + 1)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                if isExtraRound {
                    extraRoundBadge
                }
            }

            // Main content row
            HStack(spacing: 8) {
                // Category icon and name
                HStack(spacing: 6) {
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                }

                Spacer()

                // Score badge
                scoreBadge(score)
            }

            // Second row: Country selected + bonuses
            HStack(spacing: 6) {
                // Country badge
                countryBadge(country)

                // Speed bonus badge if applicable
                if hasSpeedBonus, let roundScore = round.roundScore {
                    speedBonusBadge(bonus: roundScore.speedBonus)
                }

                // Multiplier badge if applicable
                if hasMultiplier, let roundScore = round.roundScore {
                    multiplierBadge(multiplier: roundScore.multiplier, bonus: multiplierBonusPoints)
                }

                Spacer()
            }
        }
        .padding(12)
        .background(rowBackground)
        .opacity(showRounds ? 1 : 0)
        .offset(x: showRounds ? 0 : -20)
        .animation(.easeOut(duration: 0.3).delay(1.0 + Double(index) * 0.1), value: showRounds)
    }

    private func categoryBadge(_ category: Category) -> some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 11))
            Text(category.rawValue)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.blue.opacity(0.15))
        .foregroundColor(.blue)
        .cornerRadius(8)
    }

    private func countryBadge(_ country: Country) -> some View {
        HStack(spacing: 4) {
            Text(country.flag)
                .font(.system(size: 14))
            Text(country.name)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.green.opacity(0.15))
        .foregroundColor(.green)
        .cornerRadius(8)
    }

    private func speedBonusBadge(bonus: Int) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 9))
            Text("+\(bonus)")
                .font(.system(size: 10, weight: .bold))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.cyan)
        .foregroundColor(.white)
        .cornerRadius(6)
    }

    private var extraRoundBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 8))
            Text("EXTRA")
                .font(.system(size: 9, weight: .bold))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            LinearGradient(
                colors: [.purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(4)
    }

    private func multiplierBadge(multiplier: Double, bonus: Int) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "flame.fill")
                .font(.system(size: 9))
            Text(String(format: "%.1fx", multiplier))
                .font(.system(size: 10, weight: .bold))
            Text("+\(bonus)")
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            LinearGradient(
                colors: [.orange, .red],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(6)
    }

    private func scoreBadge(_ score: Int) -> some View {
        Text("+\(score)")
            .font(.system(size: 15, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(scoreColor(score))
            .foregroundColor(.white)
            .cornerRadius(10)
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.05))
            .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Compact Stat Badge
struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Bonus Badge
struct BonusBadge: View {
    let icon: String
    let text: String
    let colors: [Color]

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

#Preview {
    GameOverView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        // Simulate completing the game
        manager.gameState = .finished
        manager.totalScore = 75
        return manager
    }())
}
