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

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                // Trophy com animação
                Text("🏆")
                    .font(.system(size: 100))
                    .scaleEffect(showTrophy ? 1.0 : 0.1)
                    .rotationEffect(.degrees(showTrophy ? 0 : 180))
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: showTrophy)
                    .padding(.top, 20)

                // Title
                Text("Jogo Terminado!")
                    .font(.system(size: 38, weight: .bold))
                    .opacity(showTrophy ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.3), value: showTrophy)

                // Rating com gradiente
                Text(gameManager.getScoreRating())
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(showTrophy ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.5), value: showTrophy)
                    .padding(.bottom, 10)

                // Total Score com card melhorado
                VStack(spacing: 12) {
                    Text("Pontuação Total")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Text("\(gameManager.totalScore)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: scoreGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Progress bar showing percentage of max score
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: scoreGradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * min(gameManager.getScorePercentage() / 100, 1.0), height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text("\(Int(gameManager.getScorePercentage()))% do máximo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 14) {
                        VStack {
                            Text("Média")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(gameManager.totalScore / gameManager.totalRounds)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Divider()
                            .frame(height: 40)

                        VStack {
                            Text("Máximo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(gameManager.getMaxPossibleScore())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }

                        if gameManager.bestStreak > 0 {
                            Divider()
                                .frame(height: 40)

                            VStack {
                                Text("Streak")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text("\(gameManager.bestStreak)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }

                    // Extra round earned indicator
                    if gameManager.hasEarnedExtraRound {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                            Text("Ronda Extra Desbloqueada!")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.purple)
                        .padding(.top, 4)
                    }

                    // Mystery bonus indicator
                    if gameManager.mysteryBonus > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                            Text("Bónus Excelência: +\(gameManager.mysteryBonus)")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.2))
                        )
                        .padding(.top, 4)
                    }

                    // Show performance indicator
                    let percentage = gameManager.getScorePercentage()
                    if percentage >= 100 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("Pontuação Perfeita!")
                                .font(.caption)
                        }
                        .foregroundColor(.yellow)
                        .padding(.top, 4)
                    } else if percentage >= 90 {
                        Text("Quase perfeito!")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.secondary.opacity(0.08))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .scaleEffect(showScore ? 1.0 : 0.8)
                .opacity(showScore ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.7), value: showScore)

                // Rounds Summary melhorado
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Resumo das Rodadas")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "flag.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 4)

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
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.secondary.opacity(0.08))
                )
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Buttons melhorados
                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.medium()
                        withAnimation {
                            gameManager.startNewGame()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Jogar Novamente")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }

                    Button(action: {
                        HapticManager.shared.light()
                        withAnimation {
                            gameManager.resetGame()
                        }
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Menu Principal")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                }
            }

            // AdMob Banner at bottom
            BannerAdView()
                .frame(height: 50)
                .background(Color.secondary.opacity(0.1))
        }
        .onAppear {
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

    private func scoreColor(for score: Int) -> Color {
        // Score is now arcade style (higher is better)
        switch score {
        case 1000:
            return .green
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
