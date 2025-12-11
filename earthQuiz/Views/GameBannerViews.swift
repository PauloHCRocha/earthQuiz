//
//  GameBannerViews.swift
//  earthQuiz
//
//  Extracted from GameView.swift for better organization
//

import SwiftUI

// MARK: - Mode Change Banner
struct ModeChangeBannerView: View {
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(iconRotation))
                    .scaleEffect(iconScale)

                VStack(spacing: 8) {
                    Text("Modo Reverso")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Agora escolha o país!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 20, x: 0, y: 10)
            )
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    iconScale = 1.0
                }
                withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
                    iconRotation = 180
                }
            }
        }
    }
}

// MARK: - Streak Banner
struct StreakBannerView: View {
    let streak: Int
    let multiplier: Double

    @State private var flameScale: CGFloat = 0.3
    @State private var flameRotation: Double = -30
    @State private var textOpacity: Double = 0
    @State private var multiplierScale: CGFloat = 0.5

    private var streakText: String {
        switch streak {
        case 2: return "Em Chamas!"
        case 3: return "Imparável!"
        case 4: return "Dominando!"
        default: return "Lendário!"
        }
    }

    private var flameColor: Color {
        switch streak {
        case 2: return .orange
        case 3: return .red
        case 4: return .pink
        default: return .purple
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(flameColor.opacity(0.5))
                    .blur(radius: 15)
                    .scaleEffect(flameScale * 1.2)

                Image(systemName: "flame.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, flameColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(flameScale)
                    .rotationEffect(.degrees(flameRotation))
            }

            HStack(spacing: 4) {
                Text("\(streak)×")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)
                Text(streakText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .opacity(textOpacity)

            HStack(spacing: 6) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 18))
                Text(String(format: "%.1fx Bónus", multiplier))
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.yellow)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.black.opacity(0.3)))
            .scaleEffect(multiplierScale)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [flameColor.opacity(0.9), Color.orange.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: flameColor.opacity(0.6), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                flameScale = 1.0
                flameRotation = 0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                textOpacity = 1.0
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                multiplierScale = 1.0
            }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                flameRotation = 5
            }
        }
    }
}

// MARK: - Speed Bonus Banner
struct SpeedBonusBannerView: View {
    let bonus: Int

    @State private var boltScale: CGFloat = 0.3
    @State private var boltRotation: Double = -45
    @State private var textOpacity: Double = 0
    @State private var bonusScale: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.cyan.opacity(0.5))
                    .blur(radius: 12)
                    .scaleEffect(boltScale * 1.2)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(boltScale)
                    .rotationEffect(.degrees(boltRotation))
            }

            Text("Velocidade!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .opacity(textOpacity)

            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                Text("\(bonus) pontos")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.white.opacity(0.2)))
            .scaleEffect(bonusScale)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.6), radius: 16, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                boltScale = 1.0
                boltRotation = 0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
                textOpacity = 1.0
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.25)) {
                bonusScale = 1.0
            }
        }
    }
}

// MARK: - Extra Round Banner
struct ExtraRoundBannerView: View {
    @State private var iconScale: CGFloat = 0.3
    @State private var iconRotation: Double = -180
    @State private var textOpacity: Double = 0
    @State private var badgeScale: CGFloat = 0.5
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(glowOpacity))
                    .frame(width: 80, height: 80)
                    .blur(radius: 15)

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .purple],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
            }

            VStack(spacing: 4) {
                Text("Ronda Extra!")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                Text("Desbloqueada")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .opacity(textOpacity)

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                Text("4 Perfeitos Consecutivos!")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.yellow)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.black.opacity(0.3)))
            .scaleEffect(badgeScale)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .purple.opacity(0.6), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                iconScale = 1.0
                iconRotation = 0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                textOpacity = 1.0
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.35)) {
                badgeScale = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
        }
    }
}

// MARK: - Flying Score View
struct FlyingScoreView: View {
    let value: Int
    let startPoint: CGPoint
    let endPoint: CGPoint
    let onComplete: () -> Void

    @State private var progress: CGFloat = 0
    @State private var opacity: CGFloat = 1
    @State private var scale: CGFloat = 1.0

    private let flyDuration: Double = 1.2

    var body: some View {
        Text("+\(value)")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .position(currentPosition)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        scale = 1.0
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: flyDuration)) {
                        progress = 1
                    }
                    withAnimation(.easeIn(duration: flyDuration).delay(flyDuration * 0.5)) {
                        scale = 0.6
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + flyDuration - 0.15) {
                    withAnimation(.easeOut(duration: 0.15)) {
                        opacity = 0
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + flyDuration) {
                    onComplete()
                }
            }
    }

    private var currentPosition: CGPoint {
        let t = progress
        let controlY = min(startPoint.y, endPoint.y) - 80
        let x = pow(1-t, 2) * startPoint.x + 2 * (1-t) * t * ((startPoint.x + endPoint.x) / 2) + pow(t, 2) * endPoint.x
        let y = pow(1-t, 2) * startPoint.y + 2 * (1-t) * t * controlY + pow(t, 2) * endPoint.y
        return CGPoint(x: x, y: y)
    }
}
