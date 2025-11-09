//
//  GameView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var animatingFlags: [String] = []
    @State private var showFinalFlag = false
    @State private var previousRoundIndex = -1
    @State private var isAnimating = false
    @State private var currentFlagIndex = 0
    @State private var showAllRankings = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Round \(gameManager.currentRoundIndex + 1)/5")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Pontuação: \(gameManager.totalScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()

                // Skip button
                if gameManager.skipsRemaining > 0 && !gameManager.hasSkippedCurrentRound {
                    Button(action: {
                        withAnimation {
                            gameManager.skipCurrentCountry()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14))
                            Text("Skip")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)

            if let round = gameManager.currentRound {
                // Country Display com animação
                VStack(spacing: 12) {
                    ZStack {
                        // Slot machine animation
                        if isAnimating && !animatingFlags.isEmpty {
                            Text(animatingFlags[currentFlagIndex % animatingFlags.count])
                                .font(.system(size: 95))
                                .opacity(0.85)
                                .id("flag-\(currentFlagIndex)")
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                ))
                        }

                        // Final flag
                        if showFinalFlag {
                            Text(round.country.flag)
                                .font(.system(size: 100))
                                .scaleEffect(showFinalFlag ? 1.0 : 0.3)
                                .opacity(showFinalFlag ? 1.0 : 0)
                                .rotationEffect(.degrees(showFinalFlag ? 0 : -180))
                        }
                    }
                    .frame(height: 110)

                    if showFinalFlag {
                        Text(round.country.name)
                            .font(.system(size: 30, weight: .bold))
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                        .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                .onChange(of: gameManager.currentRoundIndex) { oldValue, newValue in
                    if newValue != previousRoundIndex {
                        showAllRankings = false
                        startFlagAnimation()
                        previousRoundIndex = newValue
                    }
                }
                .onAppear {
                    if previousRoundIndex == -1 {
                        startFlagAnimation()
                        previousRoundIndex = gameManager.currentRoundIndex
                    }
                }

                // Question
                if showFinalFlag && !round.isCompleted {
                    Text("Qual categoria tem o melhor ranking?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                // Show best category hint if round is completed
                if round.isCompleted, let optimal = gameManager.getOptimalScoreForRound(round) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Melhor: \(optimal.category.rawValue) (#\(optimal.ranking))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(10)
                    .transition(.scale.combined(with: .opacity))
                }

                // Categories - Show ALL categories
                if showFinalFlag {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Category.allCases) { category in
                                CategoryButton(
                                    category: category,
                                    country: round.country,
                                    isSelected: round.selectedCategory == category,
                                    isAvailable: round.availableCategories.contains(category),
                                    isDisabled: round.isCompleted,
                                    showRanking: round.isCompleted || round.selectedCategory == category,
                                    isBestCategory: gameManager.getOptimalScoreForRound(round)?.category == category
                                ) {
                                    if !round.isCompleted && round.availableCategories.contains(category) {
                                        HapticManager.shared.selection()
                                        withAnimation(.spring()) {
                                            gameManager.selectCategory(category)
                                            // Show all rankings after selection
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation {
                                                    showAllRankings = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: 10)
            }
        }
    }

    private func startFlagAnimation() {
        // Reset state
        showFinalFlag = false
        isAnimating = false
        currentFlagIndex = 0

        // Get random flags
        let allFlags = CountryData.shared.countries.map { $0.flag }
        animatingFlags = Array(allFlags.shuffled().prefix(18))

        HapticManager.shared.light()

        // Start immediately
        isAnimating = true

        // Variable speed intervals (slot machine effect)
        let intervals: [Double] = [0.12, 0.11, 0.10, 0.08, 0.07, 0.06, 0.05, 0.05, 0.05, 0.06, 0.07, 0.08, 0.10, 0.12, 0.15, 0.18, 0.22, 0.28]

        var cumulativeTime = 0.0
        for i in 0..<18 {
            cumulativeTime += intervals[i]

            DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime) {
                withAnimation(.linear(duration: intervals[i] * 0.75)) {
                    currentFlagIndex = i
                }

                // Haptic at key moments
                if i < 4 || i > 13 {
                    HapticManager.shared.selection()
                }
            }
        }

        // Hide animation and show final flag
        DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime + 0.2) {
            withAnimation(.easeOut(duration: 0.12)) {
                isAnimating = false
            }

            HapticManager.shared.medium()

            // Show final flag with easeOutBack
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.timingCurve(0.34, 1.56, 0.64, 1, duration: 0.55)) {
                    showFinalFlag = true
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let country: Country
    let isSelected: Bool
    let isAvailable: Bool
    let isDisabled: Bool
    let showRanking: Bool
    let isBestCategory: Bool
    let action: () -> Void

    private var ranking: Int {
        country.ranking(for: category)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Show lock icon for unavailable categories
                if !isAvailable {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary.opacity(0.5))
                        .frame(width: 38)
                } else {
                    Image(systemName: category.icon)
                        .font(.system(size: 22))
                        .frame(width: 38)
                }

                Text(category.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                // Show star for best category (only if it was available)
                if isBestCategory && isDisabled && isAvailable {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                }

                // Show ranking for selected category or if round is completed and category was available
                if showRanking && isAvailable {
                    Text("#\(ranking)")
                        .font(.system(size: 17, weight: .bold))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(rankingColor(for: ranking))
                        .foregroundColor(.white)
                        .cornerRadius(9)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(14)
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isBestCategory && isDisabled && isAvailable ? Color.yellow : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .disabled(!isAvailable || (isDisabled && !isSelected))
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if !isAvailable {
            return Color.secondary.opacity(0.05)
        } else if isDisabled {
            return Color.secondary.opacity(0.08)
        } else {
            return Color.secondary.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if !isAvailable {
            return .secondary.opacity(0.4)
        } else if isDisabled {
            return .secondary
        } else {
            return .primary
        }
    }

    private func rankingColor(for ranking: Int) -> Color {
        switch ranking {
        case 1...10:
            return .green
        case 11...25:
            return .blue
        case 26...50:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    GameView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        return manager
    }())
}
