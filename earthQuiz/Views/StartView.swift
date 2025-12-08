//
//  StartView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var gameManager: GameManager
    @State private var globeRotation: Double = 0
    @State private var titleScale: CGFloat = 1.0
    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.height < 750

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: isSmallScreen ? 16 : 20) {
                        // Hero Section
                        VStack(spacing: 8) {
                            // Animated globe
                            Text("🌍")
                                .font(.system(size: isSmallScreen ? 56 : 72))
                                .rotationEffect(.degrees(globeRotation))
                                .scaleEffect(titleScale)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)

                            // Game title - arcade style
                            Text("EARTH QUIZ")
                                .font(.system(size: isSmallScreen ? 32 : 38, weight: .black, design: .rounded))
                                .tracking(2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 0)

                            // Tagline
                            Text("Testa o teu conhecimento mundial!")
                                .font(.system(size: isSmallScreen ? 14 : 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, isSmallScreen ? 16 : 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -20)

                        // How to play - compact card
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(gameManager.isFullReverseMode ? .purple : .blue)
                                Text("COMO JOGAR")
                                    .font(.system(size: 12, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }

                            VStack(spacing: 10) {
                                HowToPlayStep(
                                    number: "1",
                                    text: gameManager.isFullReverseMode ? "Vê a categoria apresentada" : "Vê o país apresentado",
                                    icon: gameManager.isFullReverseMode ? "chart.bar.fill" : "flag.fill",
                                    color: gameManager.isFullReverseMode ? .purple : .blue,
                                    isSmallScreen: isSmallScreen
                                )
                                HowToPlayStep(
                                    number: "2",
                                    text: gameManager.isFullReverseMode ? "Escolhe o país com melhor ranking" : "Escolhe a categoria onde tem melhor ranking",
                                    icon: gameManager.isFullReverseMode ? "globe.americas.fill" : "trophy.fill",
                                    color: gameManager.isFullReverseMode ? .pink : .orange,
                                    isSmallScreen: isSmallScreen
                                )
                                HowToPlayStep(
                                    number: "3",
                                    text: "Acerta rápido para bónus extra!",
                                    icon: "bolt.fill",
                                    color: .cyan,
                                    isSmallScreen: isSmallScreen
                                )
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.secondary.opacity(0.08))
                        )
                        .padding(.horizontal, 16)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeInOut(duration: 0.3), value: gameManager.isFullReverseMode)

                        // Bonus tips - horizontal scroll
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                                    .foregroundColor(.yellow)
                                Text("DICAS PRO")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    TipBadge(
                                        icon: "flame.fill",
                                        text: "Combo = Multiplicador",
                                        colors: [.orange, .red]
                                    )
                                    TipBadge(
                                        icon: "bolt.fill",
                                        text: "< 5s = Speed Bonus",
                                        colors: [.cyan, .blue]
                                    )
                                    TipBadge(
                                        icon: "star.fill",
                                        text: "5 Perfeitos = +1500",
                                        colors: [.yellow, .orange]
                                    )
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .opacity(showContent ? 1 : 0)

                        // Game mode selector
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                // Normal mode
                                GameModeButton(
                                    title: "CLÁSSICO",
                                    subtitle: "País → Categoria",
                                    icon: "globe.americas.fill",
                                    isSelected: !gameManager.isFullReverseMode,
                                    colors: [.blue, .cyan],
                                    isSmallScreen: isSmallScreen
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        gameManager.isFullReverseMode = false
                                    }
                                    HapticManager.shared.selection()
                                }

                                // Reverse mode
                                GameModeButton(
                                    title: "REVERSO",
                                    subtitle: "Categoria → País",
                                    icon: "arrow.left.arrow.right",
                                    isSelected: gameManager.isFullReverseMode,
                                    colors: [.purple, .pink],
                                    isSmallScreen: isSmallScreen
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        gameManager.isFullReverseMode = true
                                    }
                                    HapticManager.shared.selection()
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .opacity(showContent ? 1 : 0)
                    }
                    .padding(.bottom, 16)
                }

                // Play button - always visible
                Button(action: {
                    HapticManager.shared.heavy()
                    withAnimation {
                        gameManager.startNewGame()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("JOGAR")
                            .font(.system(size: 20, weight: .black))
                            .tracking(2)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: gameManager.isFullReverseMode ? [.purple, .pink] : [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: (gameManager.isFullReverseMode ? Color.purple : Color.green).opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // AdMob Banner
                BannerAdView()
                    .frame(height: 50)
                    .background(Color.secondary.opacity(0.1))
            }
            .onAppear {
                // Animate content in
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }

                // Gentle globe wobble
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    globeRotation = 8
                }

                // Subtle title pulse
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    titleScale = 1.05
                }
            }
        }
    }
}

// MARK: - How To Play Step
struct HowToPlayStep: View {
    let number: String
    let text: String
    let icon: String
    let color: Color
    let isSmallScreen: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Number badge
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }

            // Text
            Text(text)
                .font(.system(size: isSmallScreen ? 13 : 14, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            // Icon
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color.opacity(0.6))
        }
    }
}

// MARK: - Tip Badge
struct TipBadge: View {
    let icon: String
    let text: String
    let colors: [Color]

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

// MARK: - Game Mode Button
struct GameModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let colors: [Color]
    let isSmallScreen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: isSmallScreen ? 20 : 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : colors[0])

                Text(title)
                    .font(.system(size: isSmallScreen ? 12 : 13, weight: .black))
                    .tracking(0.5)

                Text(subtitle)
                    .font(.system(size: isSmallScreen ? 9 : 10, weight: .medium))
                    .opacity(0.8)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isSmallScreen ? 14 : 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected
                            ? LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? [Color.clear] : colors.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    StartView(gameManager: GameManager())
}
