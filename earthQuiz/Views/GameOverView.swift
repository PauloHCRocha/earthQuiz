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

                    HStack(spacing: 14) {
                        VStack {
                            Text("Média")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(gameManager.totalScore / 5)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Divider()
                            .frame(height: 40)

                        VStack {
                            Text("Rodadas")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("5")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Divider()
                            .frame(height: 40)

                        VStack {
                            Text("Melhor")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(gameManager.getOptimalScore())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }

                    // Show performance comparison
                    let optimal = gameManager.getOptimalScore()
                    let difference = gameManager.totalScore - optimal
                    if difference > 0 {
                        Text("+\(difference) do ideal")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                    } else if difference == 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("Pontuação Perfeita!")
                                .font(.caption)
                        }
                        .foregroundColor(.yellow)
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
                        if let selectedCategory = round.selectedCategory,
                           let score = round.score {
                            HStack(spacing: 12) {
                                // Round number
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.blue)
                                }

                                // Country
                                HStack(spacing: 8) {
                                    Text(round.country.flag)
                                        .font(.system(size: 24))
                                    Text(round.country.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                // Category
                                HStack(spacing: 4) {
                                    Image(systemName: selectedCategory.icon)
                                        .font(.system(size: 10))
                                    Text(selectedCategory.rawValue)
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(8)

                                // Score badge
                                Text("#\(score)")
                                    .font(.system(size: 15, weight: .bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(scoreColor(for: score))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.secondary.opacity(0.05))
                                    .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
                            )
                            .opacity(showRounds ? 1 : 0)
                            .offset(x: showRounds ? 0 : -20)
                            .animation(.easeOut(duration: 0.3).delay(1.0 + Double(index) * 0.1), value: showRounds)
                        }
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
        let averageScore = gameManager.totalScore / 5
        switch averageScore {
        case 0...10:
            return [.green, .mint]
        case 11...25:
            return [.blue, .cyan]
        case 26...50:
            return [.orange, .yellow]
        default:
            return [.red, .pink]
        }
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
