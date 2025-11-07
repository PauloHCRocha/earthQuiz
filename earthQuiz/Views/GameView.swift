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
                                .font(.system(size: 90))
                                .opacity(0.4)
                                .blur(radius: 2)
                                .id("flag-\(currentFlagIndex)")
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
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
        animatingFlags = Array(allFlags.shuffled().prefix(12))

        HapticManager.shared.light()

        // Start animation com delay mínimo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation {
                isAnimating = true
            }

            // Ciclar através das bandeiras rapidamente - SLOT MACHINE EFFECT
            for i in 0..<12 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    withAnimation(.easeInOut(duration: 0.08)) {
                        currentFlagIndex = i
                    }

                    // Haptic em algumas iterações
                    if i % 2 == 0 {
                        HapticManager.shared.selection()
                    }
                }
            }

            // Esconder animação e mostrar bandeira final
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation {
                    isAnimating = false
                }

                HapticManager.shared.medium()

                // Mostrar bandeira final com easeOutBack
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.timingCurve(0.34, 1.56, 0.64, 1, duration: 0.7)) {
                        showFinalFlag = true
                    }
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
