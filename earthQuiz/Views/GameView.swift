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
    @State private var scrollOffset: CGFloat = 0
    @State private var previousRoundIndex = -1
    @State private var isAnimating = false
    @State private var currentFlagIndex = 0

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
                // Country Display com animação de scroll horizontal
                VStack(spacing: 15) {
                    // Container com animação simplificada e garantida
                    ZStack {
                        // Versão simplificada: uma bandeira de cada vez que muda rapidamente
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

                        // Bandeira final com animação easeOutBack
                        if showFinalFlag {
                            Text(round.country.flag)
                                .font(.system(size: 100))
                                .scaleEffect(showFinalFlag ? 1.0 : 0.3)
                                .opacity(showFinalFlag ? 1.0 : 0)
                                .rotationEffect(.degrees(showFinalFlag ? 0 : -180))
                        }
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)

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
        // Reset state completamente
        showFinalFlag = false
        isAnimating = false
        scrollOffset = 0
        currentFlagIndex = 0

        // Get random flags for animation
        let allFlags = CountryData.shared.countries.map { $0.flag }
        animatingFlags = Array(allFlags.shuffled().prefix(15))

        HapticManager.shared.light()

        // Start IMEDIATAMENTE - sem delay!
        isAnimating = true

        // Ciclar através das bandeiras rapidamente - SLOT MACHINE EFFECT
        // Começa devagar e acelera (velocidade variável)
        let intervals: [Double] = [0.15, 0.13, 0.11, 0.09, 0.07, 0.06, 0.06, 0.06, 0.07, 0.08, 0.10, 0.12, 0.15, 0.18, 0.22]

        var cumulativeTime = 0.0
        for i in 0..<15 {
            cumulativeTime += intervals[i]

            DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime) {
                withAnimation(.linear(duration: intervals[i] * 0.8)) {
                    currentFlagIndex = i
                }

                // Haptic nos primeiros e últimos
                if i < 5 || i > 10 {
                    HapticManager.shared.selection()
                }
            }
        }

        // Esconder animação e mostrar bandeira final
        DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime + 0.2) {
            withAnimation(.easeOut(duration: 0.15)) {
                isAnimating = false
            }

            HapticManager.shared.medium()

            // Mostrar bandeira final com easeOutBack
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.timingCurve(0.34, 1.56, 0.64, 1, duration: 0.6)) {
                    showFinalFlag = true
                }
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
