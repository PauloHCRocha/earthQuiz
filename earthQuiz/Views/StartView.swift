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
        GeometryReader { geometry in
            adaptiveContent(geometry: geometry)
        }
    }

    private func adaptiveContent(geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let isSmallScreen = screenHeight < 750 // iPhone mini, SE
        let isMediumScreen = screenHeight < 850 // iPhone standard

        // Adaptive sizing - usando múltiplos de 8
        let emojiSize: CGFloat = isSmallScreen ? 48 : (isMediumScreen ? 56 : 64)
        let titleSize: CGFloat = isSmallScreen ? 28 : (isMediumScreen ? 34 : 40)
        let subtitleSize: CGFloat = isSmallScreen ? 14 : (isMediumScreen ? 17 : 20)
        let mainSpacing: CGFloat = isSmallScreen ? 12 : 16
        let instructionSpacing: CGFloat = isSmallScreen ? 10 : 12
        let horizontalPadding: CGFloat = isSmallScreen ? 24 : 32
        let topPadding: CGFloat = isSmallScreen ? 8 : 12
        let titleSpacing: CGFloat = 4

        return VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: mainSpacing) {
                    Spacer(minLength: isSmallScreen ? 8 : 12)

                    // Title
                    VStack(spacing: titleSpacing) {
                        Text("🌍")
                            .font(.system(size: emojiSize))
                        Text("Earth Quiz")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Ranking Mundial")
                            .font(.system(size: subtitleSize, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: instructionSpacing) {
                        InstructionRow(
                            icon: "🎯",
                            text: "5 categorias aleatórias são escolhidas",
                            isSmallScreen: isSmallScreen
                        )
                        InstructionRow(
                            icon: gameManager.isFullReverseMode ? "📊" : "🌎",
                            text: gameManager.isFullReverseMode ? "Uma categoria é apresentada a cada round" : "Um país é apresentado a cada round",
                            isSmallScreen: isSmallScreen
                        )
                        InstructionRow(
                            icon: gameManager.isFullReverseMode ? "🌎" : "🏆",
                            text: gameManager.isFullReverseMode ? "Escolha o país com melhor ranking nessa categoria" : "Escolha a categoria em que esse país tem melhor ranking",
                            isSmallScreen: isSmallScreen
                        )
                        InstructionRow(
                            icon: "⭐️",
                            text: "Ganhe pontos escolhendo a melhor opção! Acerte consecutivamente para bónus!",
                            isSmallScreen: isSmallScreen
                        )
                    }
                    .padding(isSmallScreen ? 12 : 16)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Reverse Mode Toggle
                    VStack(spacing: 4) {
                        Toggle(isOn: $gameManager.isFullReverseMode) {
                            HStack(spacing: 8) {
                                Image(systemName: gameManager.isFullReverseMode ? "arrow.left.arrow.right" : "arrow.right")
                                    .font(.system(size: isSmallScreen ? 14 : 16, weight: .semibold))
                                    .foregroundColor(gameManager.isFullReverseMode ? .purple : .blue)
                                Text("Modo Reverso")
                                    .font(.system(size: isSmallScreen ? 14 : 16, weight: .semibold))
                            }
                        }
                        .tint(.purple)
                        .padding(isSmallScreen ? 12 : 16)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(16)
                        .onChange(of: gameManager.isFullReverseMode) { _, _ in
                            HapticManager.shared.selection()
                        }

                        // Fixed height container para evitar que o banner seja empurrado
                        VStack {
                            if gameManager.isFullReverseMode {
                                Text("Todas as rondas mostrarão categorias")
                                    .font(.system(size: isSmallScreen ? 11 : 13))
                                    .foregroundColor(.secondary)
                                    .transition(.opacity)
                            }
                        }
                        .frame(height: 20)
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .padding(.top, topPadding)
                .padding(.bottom, isSmallScreen ? 8 : 12)
            }

            // Start Button - fixo no fundo
            Button(action: {
                HapticManager.shared.heavy()
                withAnimation {
                    gameManager.startNewGame()
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: isSmallScreen ? 16 : 20, weight: .semibold))
                    Text("Novo Jogo")
                        .font(.system(size: isSmallScreen ? 18 : 22, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isSmallScreen ? 16 : 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gameManager.isFullReverseMode ? [Color.purple, Color.pink] : [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: (gameManager.isFullReverseMode ? Color.purple : Color.blue).opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 16)

            // AdMob Banner at bottom - sempre visível
            BannerAdView()
                .frame(height: 50)
                .background(Color.secondary.opacity(0.1))
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    let isSmallScreen: Bool

    var body: some View {
        HStack(alignment: .top, spacing: isSmallScreen ? 12 : 16) {
            Text(icon)
                .font(.system(size: isSmallScreen ? 24 : 28))
            Text(text)
                .font(.system(size: isSmallScreen ? 15 : 17))
                .foregroundColor(.primary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

#Preview {
    StartView(gameManager: GameManager())
}

#Preview("Instruction Row") {
    InstructionRow(icon: "🎯", text: "5 categorias aleatórias são escolhidas", isSmallScreen: false)
}
