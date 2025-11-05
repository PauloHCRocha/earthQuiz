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
    @State private var currentAnimationIndex = 0
    @State private var previousRoundIndex = -1

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Round \(gameManager.currentRoundIndex + 1)/5")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Pontuação: \(gameManager.totalScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            .padding()

            if let round = gameManager.currentRound {
                // Country Display com animação de scroll
                VStack(spacing: 15) {
                    ZStack {
                        // Animação de bandeiras
                        if !showFinalFlag && !animatingFlags.isEmpty {
                            Text(animatingFlags[currentAnimationIndex % animatingFlags.count])
                                .font(.system(size: 100))
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                                .id("animating-\(currentAnimationIndex)")
                        }

                        // Bandeira final
                        if showFinalFlag {
                            Text(round.country.flag)
                                .font(.system(size: 100))
                                .transition(.scale.combined(with: .opacity))
                                .id("final-\(round.id)")
                        }
                    }
                    .frame(height: 120)

                    if showFinalFlag {
                        Text(round.country.name)
                            .font(.system(size: 32, weight: .bold))
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                        .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                .onChange(of: gameManager.currentRoundIndex) { oldValue, newValue in
                    if newValue != previousRoundIndex {
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

                Spacer()

                // Question
                if showFinalFlag {
                    Text("Qual categoria tem o melhor ranking?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                // Categories
                if showFinalFlag {
                    VStack(spacing: 15) {
                        ForEach(round.availableCategories) { category in
                            CategoryButton(
                                category: category,
                                isSelected: round.selectedCategory == category,
                                isDisabled: round.isCompleted,
                                ranking: round.selectedCategory == category ? round.country.ranking(for: category) : nil
                            ) {
                                if !round.isCompleted {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring()) {
                                        gameManager.selectCategory(category)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()
            }
        }
    }

    private func startFlagAnimation() {
        // Reset state
        withAnimation {
            showFinalFlag = false
        }
        currentAnimationIndex = 0

        // Get random flags for animation
        let allFlags = CountryData.shared.countries.map { $0.flag }
        animatingFlags = Array(allFlags.shuffled().prefix(8))

        HapticManager.shared.light()

        // Animate through flags quickly
        var delay = 0.0
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    currentAnimationIndex = i
                }
                // Haptic leve durante a animação
                if i < 7 {
                    HapticManager.shared.selection()
                }
            }
            delay += 0.08
        }

        // Show final flag
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.2) {
            HapticManager.shared.medium()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showFinalFlag = true
            }
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let isDisabled: Bool
    let ranking: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .frame(width: 40)
                Text(category.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                if let ranking = ranking {
                    Text("#\(ranking)")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(rankingColor(for: ranking))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(15)
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if isDisabled {
            return Color.gray.opacity(0.2)
        } else {
            return Color.secondary.opacity(0.1)
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isDisabled {
            return .gray
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
