//
//  GameView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameManager: GameManager

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
                // Country Display
                VStack(spacing: 15) {
                    Text(round.country.flag)
                        .font(.system(size: 100))
                    Text(round.country.name)
                        .font(.system(size: 32, weight: .bold))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal)

                Spacer()

                // Question
                Text("Qual categoria tem o melhor ranking?")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Categories
                VStack(spacing: 15) {
                    ForEach(round.availableCategories) { category in
                        CategoryButton(
                            category: category,
                            isSelected: round.selectedCategory == category,
                            isDisabled: round.isCompleted,
                            ranking: round.selectedCategory == category ? round.country.ranking(for: category) : nil
                        ) {
                            if !round.isCompleted {
                                withAnimation(.spring()) {
                                    gameManager.selectCategory(category)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
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
