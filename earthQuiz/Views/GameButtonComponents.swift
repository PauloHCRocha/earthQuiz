//
//  GameButtonComponents.swift
//  earthQuiz
//
//  Extracted from GameView.swift for better organization
//

import SwiftUI

// MARK: - Compact Category Button
struct CompactCategoryButton: View {
    let category: Category
    let country: Country
    let isSelected: Bool
    let isDisabled: Bool
    let roundScore: RoundScore?
    let isBestCategory: Bool
    let isSmallScreen: Bool
    let action: (CGRect) -> Void

    @State private var buttonFrame: CGRect = .zero

    var body: some View {
        Button(action: { action(buttonFrame) }) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: isSmallScreen ? 22 : 24))
                    .frame(width: 32)
                    .foregroundColor(isSelected ? .white : .blue)

                VStack(alignment: .leading, spacing: 3) {
                    Text(category.rawValue)
                        .font(.system(size: isSmallScreen ? 16 : 18, weight: .semibold))
                        .lineLimit(1)

                    Text(category.description)
                        .font(.system(size: isSmallScreen ? 13 : 14))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let score = roundScore, (isSelected || isBestCategory) {
                    CompactScoreBadge(
                        score: isBestCategory ? GameManager.maxPointsPerRound : score.finalScore,
                        showStar: isBestCategory,
                        isSmallScreen: isSmallScreen
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, isSmallScreen ? 12 : 14)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color.secondary.opacity(0.1))
                        .onAppear { buttonFrame = geo.frame(in: .named("gameView")) }
                        .onChange(of: geo.frame(in: .named("gameView"))) { _, newFrame in
                            buttonFrame = newFrame
                        }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isBestCategory ? Color.yellow : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isDisabled)
    }
}

// MARK: - Compact Country Button
struct CompactCountryButton: View {
    let country: Country
    let category: Category
    let isSelected: Bool
    let isDisabled: Bool
    let roundScore: RoundScore?
    let isBestChoice: Bool
    let isSmallScreen: Bool
    let action: (CGRect) -> Void

    @State private var buttonFrame: CGRect = .zero

    var body: some View {
        Button(action: { action(buttonFrame) }) {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.system(size: isSmallScreen ? 30 : 34))

                Text(country.name)
                    .font(.system(size: isSmallScreen ? 17 : 19, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                if let score = roundScore, (isSelected || isBestChoice) {
                    CompactScoreBadge(
                        score: isBestChoice ? GameManager.maxPointsPerRound : score.finalScore,
                        showStar: isBestChoice,
                        isSmallScreen: isSmallScreen
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, isSmallScreen ? 12 : 14)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.purple : Color.secondary.opacity(0.1))
                        .onAppear { buttonFrame = geo.frame(in: .named("gameView")) }
                        .onChange(of: geo.frame(in: .named("gameView"))) { _, newFrame in
                            buttonFrame = newFrame
                        }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isBestChoice ? Color.yellow : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isDisabled)
    }
}

// MARK: - Compact Score Badge
struct CompactScoreBadge: View {
    let score: Int
    let showStar: Bool
    let isSmallScreen: Bool

    private var badgeColor: Color {
        switch score {
        case 1000...: return .green
        case 750..<1000: return .blue
        case 500..<750: return .cyan
        case 250..<500: return .orange
        default: return .red
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if showStar {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.yellow)
            }
            Text("+\(score)")
                .font(.system(size: isSmallScreen ? 14 : 15, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(badgeColor)
        .cornerRadius(8)
    }
}

// MARK: - Compact Trivia Card
struct CompactTriviaCard: View {
    let message: String
    let isSmallScreen: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundColor(.yellow)

            Text(message)
                .font(.system(size: isSmallScreen ? 13 : 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.yellow.opacity(0.1))
        )
    }
}

// MARK: - Flag Carousel View
struct FlagCarouselView: View {
    let flags: [String]
    let currentIndex: Int
    let flagSize: CGFloat

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(flags.enumerated()), id: \.offset) { index, flag in
                        let distance = abs(index - currentIndex)

                        Text(flag)
                            .font(.system(size: flagSize))
                            .scaleEffect(scale(for: distance))
                            .opacity(opacity(for: distance))
                            .blur(radius: blur(for: distance))
                            .frame(width: flagSize + 4, height: flagSize + 4)
                            .id(index)
                    }
                }
                .padding(.horizontal, UIScreen.main.bounds.width / 2 - flagSize / 2)
            }
            .scrollDisabled(true)
            .onChange(of: currentIndex) { _, newIndex in
                withAnimation(.easeOut(duration: 0.1)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(currentIndex, anchor: .center)
            }
        }
        .allowsHitTesting(false)
    }

    private func scale(for distance: Int) -> CGFloat {
        switch distance {
        case 0: return 1.0
        case 1: return 0.8
        case 2: return 0.6
        default: return 0.5
        }
    }

    private func opacity(for distance: Int) -> Double {
        switch distance {
        case 0: return 1.0
        case 1: return 0.55
        case 2: return 0.25
        default: return 0.1
        }
    }

    private func blur(for distance: Int) -> CGFloat {
        switch distance {
        case 0: return 0
        case 1: return 0.5
        case 2: return 1.2
        default: return 2.0
        }
    }
}

// MARK: - Timer Display View
struct TimerDisplayView: View {
    let timeRemaining: Double
    let totalTime: Double
    let isSmallScreen: Bool

    private var timeColor: Color {
        let percentage = timeRemaining / totalTime
        switch percentage {
        case 0.5...: return .green
        case 0.25..<0.5: return .orange
        default: return .red
        }
    }

    private var formattedTime: String {
        let seconds = Int(timeRemaining)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return String(format: "0:%02d", remainingSeconds)
        }
    }

    private var isLowTime: Bool {
        timeRemaining < 10
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.system(size: isSmallScreen ? 16 : 18, weight: .semibold))
                .foregroundColor(timeColor)

            Text(formattedTime)
                .font(.system(size: isSmallScreen ? 24 : 28, weight: .black, design: .monospaced))
                .foregroundColor(timeColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(timeColor.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(timeColor.opacity(0.5), lineWidth: 2)
                )
        )
        .scaleEffect(isLowTime ? 1.05 : 1.0)
        .animation(isLowTime ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isLowTime)
    }
}

// MARK: - Multiplier Indicator View
struct MultiplierIndicatorView: View {
    let multiplier: Double
    let scale: CGFloat
    let isSmallScreen: Bool

    private var multiplierColor: Color {
        switch multiplier {
        case 2.0...: return .purple
        case 1.8..<2.0: return .pink
        case 1.5..<1.8: return .red
        case 1.2..<1.5: return .orange
        default: return .gray
        }
    }

    private var isActive: Bool {
        multiplier > 1.0
    }

    var body: some View {
        HStack(spacing: 3) {
            if isActive {
                Image(systemName: "flame.fill")
                    .font(.system(size: isSmallScreen ? 9 : 10))
            }
            Text(String(format: "%.1fx", multiplier))
                .font(.system(size: isSmallScreen ? 11 : 12, weight: .bold))
        }
        .foregroundColor(isActive ? .white : .secondary)
        .padding(.horizontal, isSmallScreen ? 6 : 8)
        .padding(.vertical, isSmallScreen ? 2 : 3)
        .background(
            Capsule()
                .fill(isActive ? multiplierColor : Color.secondary.opacity(0.2))
        )
        .scaleEffect(scale)
    }
}
