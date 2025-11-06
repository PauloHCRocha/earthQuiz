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
                    // Container para o scroll horizontal - Fixed size
                    ZStack {
                        if isAnimating {
                            // Scroll horizontal de bandeiras com posição fixa
                            HStack(spacing: 50) {
                                ForEach(Array(animatingFlags.enumerated()), id: \.offset) { index, flag in
                                    Text(flag)
                                        .font(.system(size: 80))
                                        .opacity(0.5)
                                }
                            }
                            .offset(x: scrollOffset)
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
                    .clipped()

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
        showFinalFlag = false
        isAnimating = false

        // Get random flags for animation
        let allFlags = CountryData.shared.countries.map { $0.flag }
        animatingFlags = Array(allFlags.shuffled().prefix(20))

        HapticManager.shared.light()

        // Start immediately with animation
        DispatchQueue.main.async {
            // Position inicial - bem à direita para ser visível
            scrollOffset = 600
            isAnimating = true

            // Pequeno delay para garantir que a view está renderizada
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                // Fase 1: Scroll acelerado (1.0s)
                withAnimation(.timingCurve(0.42, 0, 0.58, 1, duration: 1.0)) {
                    scrollOffset = -1500
                }

                // Haptic durante o scroll
                for i in 0..<7 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.14) {
                        HapticManager.shared.selection()
                    }
                }

                // Fase 2: Desaceleração com easeOut (0.6s)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.6)) {
                        scrollOffset = -2500
                    }
                }

                // Esconder scroll e mostrar bandeira final
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    isAnimating = false
                    HapticManager.shared.medium()

                    // Mostrar bandeira final com easeOutBack pronunciado
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
