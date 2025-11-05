//
//  StartView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Title
            VStack(spacing: 10) {
                Text("🌍")
                    .font(.system(size: 80))
                Text("Earth Quiz")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
                Text("Ranking Mundial")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Instructions
            VStack(alignment: .leading, spacing: 15) {
                InstructionRow(
                    icon: "🎯",
                    text: "5 categorias aleatórias são escolhidas"
                )
                InstructionRow(
                    icon: "🌎",
                    text: "Um país é apresentado a cada round"
                )
                InstructionRow(
                    icon: "🏆",
                    text: "Escolha a categoria com melhor ranking"
                )
                InstructionRow(
                    icon: "📊",
                    text: "Menor pontuação = melhor resultado"
                )
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)

            Spacer()

            // Start Button
            Button(action: {
                HapticManager.shared.heavy()
                withAnimation {
                    gameManager.startNewGame()
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Começar Jogo")
                        .font(.system(size: 20, weight: .semibold))
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
                .cornerRadius(15)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    StartView(gameManager: GameManager())
}
