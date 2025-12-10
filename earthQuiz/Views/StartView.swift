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
    @State private var selectedTimedOption: GameManager.TimedModeOption? = nil
    @State private var isTimedMode = false
    @State private var showProTips = false

    var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.height < 750
            let isMediumScreen = geometry.size.height < 850 // iPhone 15 Pro, etc.

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
                                .font(.system(size: isSmallScreen ? 15 : (isMediumScreen ? 16 : 18), weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, isSmallScreen ? 16 : 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -20)

                        // How to play - compact card
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(gameManager.isFullReverseMode ? .purple : .blue)
                                Text("COMO JOGAR")
                                    .font(.system(size: 12, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(.secondary)
                                Spacer()

                                // Pro Tips button
                                Button(action: {
                                    HapticManager.shared.light()
                                    showProTips = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 12))
                                        Text("DICAS")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color.yellow.opacity(0.15))
                                    )
                                }
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

                        // Game type selector (Classic vs Timed)
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                                Text("MODO DE JOGO")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)

                            HStack(spacing: 10) {
                                // Classic mode
                                GameTypeButton(
                                    title: "5 RONDAS",
                                    icon: "list.number",
                                    isSelected: !isTimedMode,
                                    colors: [.blue, .cyan],
                                    isSmallScreen: isSmallScreen
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isTimedMode = false
                                        selectedTimedOption = nil
                                    }
                                    HapticManager.shared.selection()
                                }

                                // Timed mode
                                GameTypeButton(
                                    title: "CONTRA-RELÓGIO",
                                    icon: "timer",
                                    isSelected: isTimedMode,
                                    colors: [.orange, .red],
                                    isSmallScreen: isSmallScreen
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isTimedMode = true
                                        if selectedTimedOption == nil {
                                            selectedTimedOption = .sixty
                                        }
                                    }
                                    HapticManager.shared.selection()
                                }
                            }
                            .padding(.horizontal, 16)

                            // Time duration options (only show when timed mode is selected)
                            if isTimedMode {
                                HStack(spacing: 8) {
                                    ForEach(GameManager.TimedModeOption.allCases, id: \.rawValue) { option in
                                        TimeDurationButton(
                                            option: option,
                                            isSelected: selectedTimedOption == option,
                                            isSmallScreen: isSmallScreen
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedTimedOption = option
                                            }
                                            HapticManager.shared.selection()
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .opacity(showContent ? 1 : 0)

                        // Classic mode options (only show when classic mode selected)
                        if !isTimedMode {
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    // Normal mode
                                    GameModeButton(
                                        title: "CLÁSSICO",
                                        subtitle: "País → Categoria",
                                        icon: "globe.americas.fill",
                                        isSelected: !gameManager.isFullReverseMode,
                                        colors: [.blue, .cyan],
                                        isSmallScreen: isSmallScreen,
                                        isMediumScreen: isMediumScreen
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
                                        isSmallScreen: isSmallScreen,
                                        isMediumScreen: isMediumScreen
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
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.bottom, 16)
                }

                // Play button - always visible
                Button(action: {
                    HapticManager.shared.heavy()
                    withAnimation {
                        if isTimedMode, let timedOption = selectedTimedOption {
                            gameManager.startTimedGame(duration: timedOption)
                        } else {
                            gameManager.startNewGame()
                        }
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: isTimedMode ? "timer" : "play.fill")
                            .font(.system(size: isSmallScreen ? 18 : 20, weight: .bold))
                        Text(isTimedMode ? "INICIAR" : "JOGAR")
                            .font(.system(size: isSmallScreen ? 20 : 22, weight: .black))
                            .tracking(2)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isSmallScreen ? 14 : (isMediumScreen ? 16 : 18))
                    .background(
                        LinearGradient(
                            colors: isTimedMode ? [.orange, .red] : (gameManager.isFullReverseMode ? [.purple, .pink] : [.green, .mint]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: (isTimedMode ? Color.orange : (gameManager.isFullReverseMode ? Color.purple : Color.green)).opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // AdMob Banner
                BannerAdView()
                    .frame(height: 50)
                    .background(Color.secondary.opacity(0.1))
            }
            .onAppear {
                // Play menu music
                SoundManager.shared.playMenuMusic()

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
            .sheet(isPresented: $showProTips) {
                ProTipsSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Pro Tips Sheet
struct ProTipsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                Text("DICAS PRO")
                    .font(.system(size: 22, weight: .black))
                    .tracking(2)
                Spacer()
            }
            .padding(.top, 8)

            // Tips list
            VStack(spacing: 16) {
                ProTipRow(
                    icon: "flame.fill",
                    title: "Combo Multiplier",
                    description: "Acerta várias seguidas para multiplicar os pontos! 2x, 3x, 4x...",
                    colors: [.orange, .red]
                )

                ProTipRow(
                    icon: "bolt.fill",
                    title: "Speed Bonus",
                    description: "Responde em menos de 5 segundos para ganhar +200 pontos extra!",
                    colors: [.cyan, .blue]
                )

                ProTipRow(
                    icon: "star.fill",
                    title: "Bónus de Excelência",
                    description: "Acerta todas as 5 rondas na perfeição para ganhar +1500 pontos!",
                    colors: [.yellow, .orange]
                )

                ProTipRow(
                    icon: "plus.circle.fill",
                    title: "Ronda Extra",
                    description: "4 respostas perfeitas consecutivas desbloqueiam uma 6ª ronda!",
                    colors: [.purple, .pink]
                )
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Pro Tip Row
struct ProTipRow: View {
    let icon: String
    let title: String
    let description: String
    let colors: [Color]

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
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
        HStack(spacing: 10) {
            // Number badge
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: isSmallScreen ? 28 : 30, height: isSmallScreen ? 28 : 30)
                Text(number)
                    .font(.system(size: isSmallScreen ? 14 : 15, weight: .bold))
                    .foregroundColor(color)
            }

            // Text
            Text(text)
                .font(.system(size: isSmallScreen ? 14 : 15, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            // Icon
            Image(systemName: icon)
                .font(.system(size: isSmallScreen ? 14 : 15))
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
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
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

// MARK: - Game Type Button (Classic vs Timed)
struct GameTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let colors: [Color]
    let isSmallScreen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: isSmallScreen ? 16 : 18, weight: .semibold))
                    .foregroundColor(isSelected ? .white : colors[0])

                Text(title)
                    .font(.system(size: isSmallScreen ? 12 : 13, weight: .bold))
                    .tracking(0.5)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isSmallScreen ? 12 : 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                            ? LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? [Color.clear] : colors.map { $0.opacity(0.3) },
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Time Duration Button
struct TimeDurationButton: View {
    let option: GameManager.TimedModeOption
    let isSelected: Bool
    let isSmallScreen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(option.displayName)
                    .font(.system(size: isSmallScreen ? 14 : 16, weight: .bold))
                Text("\(option.rawValue)s")
                    .font(.system(size: isSmallScreen ? 10 : 11, weight: .medium))
                    .opacity(0.7)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isSmallScreen ? 10 : 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected
                            ? LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.clear : Color.orange.opacity(0.3),
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
    let isMediumScreen: Bool
    let action: () -> Void

    private var iconSize: CGFloat {
        isSmallScreen ? 22 : (isMediumScreen ? 24 : 28)
    }

    private var titleSize: CGFloat {
        isSmallScreen ? 13 : (isMediumScreen ? 14 : 15)
    }

    private var subtitleSize: CGFloat {
        isSmallScreen ? 10 : (isMediumScreen ? 11 : 12)
    }

    private var verticalPadding: CGFloat {
        isSmallScreen ? 12 : (isMediumScreen ? 14 : 18)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: isSmallScreen ? 4 : 6) {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(isSelected ? .white : colors[0])

                Text(title)
                    .font(.system(size: titleSize, weight: .black))
                    .tracking(0.5)

                Text(subtitle)
                    .font(.system(size: subtitleSize, weight: .medium))
                    .opacity(0.8)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
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
