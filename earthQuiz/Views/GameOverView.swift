//
//  GameOverView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 25) {
            Spacer()

            // Trophy
            Text("🏆")
                .font(.system(size: 80))

            // Title
            Text("Jogo Terminado!")
                .font(.system(size: 36, weight: .bold))

            // Rating
            Text(gameManager.getScoreRating())
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.blue)

            // Total Score
            VStack(spacing: 5) {
                Text("Pontuação Total")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(gameManager.totalScore)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.primary)
                Text("Média: \(gameManager.totalScore / 5)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()

            Spacer()

            // Rounds Summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Resumo das Rodadas")
                    .font(.headline)
                    .padding(.bottom, 5)

                ForEach(Array(gameManager.rounds.enumerated()), id: \.element.id) { index, round in
                    if let selectedCategory = round.selectedCategory,
                       let score = round.score {
                        HStack {
                            Text("\(round.country.flag) \(round.country.name)")
                                .font(.system(size: 14))
                            Spacer()
                            Text(selectedCategory.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                            Text("#\(score)")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(scoreColor(for: score))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)

            Spacer()

            // Buttons
            VStack(spacing: 15) {
                Button(action: {
                    withAnimation {
                        gameManager.startNewGame()
                    }
                }) {
                    Text("Jogar Novamente")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                }

                Button(action: {
                    withAnimation {
                        gameManager.resetGame()
                    }
                }) {
                    Text("Menu Principal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
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
    GameOverView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        // Simulate completing the game
        manager.gameState = .finished
        manager.totalScore = 75
        return manager
    }())
}
