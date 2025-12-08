//
//  GameView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

// PreferenceKey para capturar a posição do score no header
struct ScorePositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// PreferenceKey para capturar a posição do ranking selecionado
struct SelectedRankingPositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct GameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var animatingFlags: [String] = []
    @State private var showFinalFlag = false
    @State private var previousRoundIndex = -1
    @State private var isAnimating = false
    @State private var currentFlagIndex = 0
    @State private var showAllRankings = false
    @State private var showQuitAlert = false

    // Flying score animation states
    @State private var flyingScoreValue: Int = 0
    @State private var showFlyingScore = false
    @State private var flyingScoreStart: CGPoint = .zero
    @State private var flyingScoreEnd: CGPoint = .zero
    @State private var scorePosition: CGRect = .zero
    @State private var scoreScale: CGFloat = 1.0

    // Animated score counter
    @State private var displayedScore: Int = 0
    @State private var previousTotalScore: Int = 0

    // Round transition animation
    @State private var roundContentOpacity: Double = 1.0
    @State private var roundContentOffset: CGFloat = 0

    // Mode change animation
    @State private var showModeChangeBanner: Bool = false
    @State private var previousRoundWasReverseMode: Bool? = nil

    // Streak animation
    @State private var showStreakBanner: Bool = false
    @State private var streakCount: Int = 0
    @State private var streakMultiplier: Double = 1.0
    @State private var previousStreak: Int = 0

    // Speed bonus animation
    @State private var showSpeedBonusBanner: Bool = false
    @State private var speedBonusValue: Int = 0

    // Extra round animation
    @State private var showExtraRoundBanner: Bool = false
    @State private var previousHasEarnedExtraRound: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                adaptiveContent(geometry: geometry)

                // Flying score overlay
                if showFlyingScore {
                    FlyingScoreView(
                        value: flyingScoreValue,
                        startPoint: flyingScoreStart,
                        endPoint: flyingScoreEnd,
                        onComplete: {
                            // Start counting animation when flying score arrives
                            animateScoreCounter(from: previousTotalScore, to: gameManager.totalScore)
                        }
                    )
                }

                // Mode change banner overlay
                if showModeChangeBanner {
                    ModeChangeBannerView()
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                // Streak banner overlay
                if showStreakBanner {
                    StreakBannerView(streak: streakCount, multiplier: streakMultiplier)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                }

                // Speed bonus banner overlay
                if showSpeedBonusBanner {
                    SpeedBonusBannerView(bonus: speedBonusValue)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                }

                // Extra round banner overlay
                if showExtraRoundBanner {
                    ExtraRoundBannerView()
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .coordinateSpace(name: "gameView")
            .onPreferenceChange(ScorePositionKey.self) { rect in
                scorePosition = rect
            }
            .onAppear {
                displayedScore = gameManager.totalScore
                previousTotalScore = gameManager.totalScore
                // Start theme song when game view appears
                if gameManager.gameState == .playing {
                    SoundManager.shared.playThemeSong()
                }
            }
            .onChange(of: gameManager.gameState) { _, newState in
                if newState == .playing {
                    // Reset all game state
                    displayedScore = 0
                    previousTotalScore = 0
                    previousRoundWasReverseMode = nil
                    previousRoundIndex = -1
                    showFinalFlag = false
                    isAnimating = false
                    roundContentOpacity = 1.0
                    roundContentOffset = 0
                    showModeChangeBanner = false
                    showStreakBanner = false
                    showSpeedBonusBanner = false
                    showExtraRoundBanner = false
                    previousStreak = 0
                    previousHasEarnedExtraRound = false

                    // Start theme song
                    SoundManager.shared.playThemeSong()
                } else if newState == .finished || newState == .notStarted {
                    // Stop theme song when game ends or returns to menu
                    SoundManager.shared.stopThemeSong()
                }
            }
            .onChange(of: gameManager.hasEarnedExtraRound) { oldValue, newValue in
                // Show extra round banner when unlocked
                if newValue && !oldValue && !previousHasEarnedExtraRound {
                    previousHasEarnedExtraRound = true
                    triggerExtraRoundBanner()
                }
            }
            .onChange(of: gameManager.currentStreak) { oldValue, newValue in
                // Show streak banner when streak increases to 2 or more (multiplier activates)
                if newValue >= 2 && newValue > oldValue {
                    streakCount = newValue
                    streakMultiplier = gameManager.streakMultiplier

                    // Check if there's a speed bonus showing - if so, delay the streak banner
                    let currentSessionId = gameManager.gameSessionId
                    let hasSpeedBonus = gameManager.currentRound?.roundScore?.hasSpeedBonus ?? false
                    let streakDelay: Double = hasSpeedBonus ? 2.6 : 0.0 // Wait for speed bonus to finish (2.0s + 0.3s fade + 0.3s gap)

                    DispatchQueue.main.asyncAfter(deadline: .now() + streakDelay) { [self] in
                        guard gameManager.gameSessionId == currentSessionId else { return }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            showStreakBanner = true
                        }
                        HapticManager.shared.success()

                        // Hide after 2.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
                            guard gameManager.gameSessionId == currentSessionId else { return }
                            withAnimation(.easeOut(duration: 0.3)) {
                                showStreakBanner = false
                            }
                        }
                    }
                }
            }
        }
    }

    private func animateScoreCounter(from startValue: Int, to endValue: Int) {
        let difference = endValue - startValue
        let duration: Double = 0.6
        let steps = min(difference, 20) // Max 20 steps for smooth animation
        let stepDuration = duration / Double(steps)
        let currentSessionId = gameManager.gameSessionId

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (stepDuration * Double(i))) { [self] in
                // Cancel if game session changed
                guard gameManager.gameSessionId == currentSessionId else { return }

                let progress = Double(i) / Double(steps)
                displayedScore = startValue + Int(Double(difference) * progress)

                // Pulse effect on each step
                if i > 0 {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
                        scoreScale = 1.15
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
                        guard gameManager.gameSessionId == currentSessionId else { return }
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.7)) {
                            scoreScale = 1.0
                        }
                    }
                }

                // Final pulse
                if i == steps {
                    HapticManager.shared.success()
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                        scoreScale = 1.25
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                        guard gameManager.gameSessionId == currentSessionId else { return }
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                            scoreScale = 1.0
                        }
                    }
                }
            }
        }
    }

    private func adaptiveContent(geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let isSmallScreen = screenHeight < 750 // iPhone mini, SE
        let isMediumScreen = screenHeight < 850 // iPhone standard

        // Adaptive sizing - usando múltiplos de 8
        let flagSize: CGFloat = isSmallScreen ? 72 : (isMediumScreen ? 80 : 96)
        let categoryIconSize: CGFloat = 48
        let titleFontSize: CGFloat = isSmallScreen ? 24 : (isMediumScreen ? 26 : 28)
        let categorySpacing: CGFloat = isSmallScreen ? 12 : 16

        return VStack(spacing: 0) {
            // Fixed Header - outside ScrollView
            HStack {
                // Quit button
                Button(action: {
                    HapticManager.shared.light()
                    showQuitAlert = true
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: isSmallScreen ? 12 : 13))
                        Text("Desistir")
                            .font(.system(size: isSmallScreen ? 12 : 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, isSmallScreen ? 8 : 10)
                    .padding(.vertical, isSmallScreen ? 5 : 6)
                    .background(Color.red)
                    .cornerRadius(8)
                }

                Spacer()

                VStack(alignment: .center, spacing: 1) {
                    Text("Ronda \(gameManager.currentRoundIndex + 1)/\(gameManager.totalRounds)")
                        .font(.system(size: isSmallScreen ? 13 : 14))
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("Pontuação:")
                            .font(.system(size: isSmallScreen ? 18 : 20, weight: .bold))
                        Text("\(displayedScore)")
                            .font(.system(size: isSmallScreen ? 18 : 20, weight: .bold))
                            .foregroundColor(.blue)
                            .scaleEffect(scoreScale)
                            .fixedSize(horizontal: true, vertical: false)
                            .overlay(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: ScorePositionKey.self, value: geo.frame(in: .named("gameView")))
                                }
                            )
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }

                Spacer()

                // Skip button (only in normal mode)
                if let round = gameManager.currentRound, !round.isReverseMode,
                   gameManager.skipsRemaining > 0 && !gameManager.hasSkippedCurrentRound {
                    Button(action: {
                        withAnimation {
                            gameManager.skipCurrentCountry()
                        }
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: isSmallScreen ? 12 : 13))
                            Text("Skip")
                                .font(.system(size: isSmallScreen ? 12 : 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, isSmallScreen ? 8 : 10)
                        .padding(.vertical, isSmallScreen ? 5 : 6)
                        .background(Color.orange)
                        .cornerRadius(8)
                    }
                } else {
                    // Spacer invisível para manter o centro alinhado
                    Color.clear
                        .frame(width: isSmallScreen ? 80 : 90, height: 1)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color(UIColor.systemBackground))
            .fixedSize(horizontal: false, vertical: true)
            .alert("Desistir do Jogo?", isPresented: $showQuitAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Desistir", role: .destructive) {
                    HapticManager.shared.medium()
                    withAnimation {
                        gameManager.resetGame()
                    }
                }
            } message: {
                Text("Tem a certeza que deseja desistir? O seu progresso será perdido.")
            }

            // Scrollable content
            ScrollView {
                VStack(spacing: 0) {
                    if let round = gameManager.currentRound {
                        // Display based on mode
                        if round.isReverseMode {
                            // Reverse mode: Show category
                            VStack(spacing: isSmallScreen ? 8 : 16) {
                                ZStack {
                                    // Category icon
                                    if let category = round.category {
                                        Image(systemName: category.icon)
                                            .font(.system(size: categoryIconSize))
                                            .foregroundColor(.blue)
                                            .scaleEffect(showFinalFlag ? 1.0 : 0.3)
                                            .opacity(showFinalFlag ? 1.0 : 0)
                                    }
                                }
                                .frame(height: categoryIconSize + (isSmallScreen ? 8 : 16))

                                if showFinalFlag, let category = round.category {
                                    VStack(spacing: 4) {
                                        Text(category.rawValue)
                                            .font(.system(size: titleFontSize, weight: .bold))
                                            .transition(.opacity.combined(with: .move(edge: .bottom)))

                                        Text(category.description)
                                            .font(.system(size: isSmallScreen ? 12 : 14))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .padding(.horizontal, isSmallScreen ? 16 : 24)
                                            .transition(.opacity)
                                        
                                    }
                                }
                            }
                            .padding(.vertical, isSmallScreen ? 16 : 24)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: isSmallScreen ? 12 : 16)
                                    .fill(Color.blue.opacity(0.1))
                                    .shadow(color: .blue.opacity(0.1), radius: isSmallScreen ? 4 : 8, x: 0, y: isSmallScreen ? 2 : 4)
                            )
                            .padding(.horizontal, isSmallScreen ? 12 : 16)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 16)
                        } else {
                            // Normal mode: Show country with animation
                            VStack(spacing: isSmallScreen ? 8 : 16) {
                                ZStack {
                                    // Slot machine animation
                                    if isAnimating && !animatingFlags.isEmpty {
                                        Text(animatingFlags[currentFlagIndex % animatingFlags.count])
                                            .font(.system(size: flagSize * 0.95))
                                            .opacity(0.85)
                                            .id("flag-\(currentFlagIndex)")
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .trailing),
                                                removal: .move(edge: .leading)
                                            ))
                                    }

                                    // Final flag
                                    if showFinalFlag, let country = round.country {
                                        Text(country.flag)
                                            .font(.system(size: flagSize))
                                            .scaleEffect(showFinalFlag ? 1.0 : 0.3)
                                            .opacity(showFinalFlag ? 1.0 : 0)
                                            .rotationEffect(.degrees(showFinalFlag ? 0 : -180))
                                    }
                                }
                                .frame(height: flagSize + (isSmallScreen ? 8 : 16))

                                if showFinalFlag, let country = round.country {
                                    Text(country.name)
                                        .font(.system(size: titleFontSize, weight: .bold))
                                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                                }
                            }
                            .padding(.vertical, isSmallScreen ? 16 : 24)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: isSmallScreen ? 12 : 16)
                                    .fill(Color.blue.opacity(0.1))
                                    .shadow(color: .blue.opacity(0.1), radius: isSmallScreen ? 4 : 8, x: 0, y: isSmallScreen ? 2 : 4)
                            )
                            .padding(.horizontal, isSmallScreen ? 12 : 16)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 16)
                        }

                        // Question (fora do modo-specific)
                        if showFinalFlag && !round.isCompleted {
                            Text(round.isReverseMode ? "Qual país tem o melhor ranking?" : "Qual a categoria com melhor ranking?")
                                .font(.system(size: isSmallScreen ? 14 : 16, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 24)
                                .transition(.opacity)
                        }

                        // Show trivia/fact when round is completed
                        if round.isCompleted, let trivia = round.triviaMessage {
                            TriviaCard(message: trivia, isSmallScreen: isSmallScreen)
                                .padding(.horizontal, isSmallScreen ? 12 : 16)
                                .padding(.top, isSmallScreen ? 12 : 16)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }

                        // Options - Categories or Countries based on mode
                        VStack(spacing: categorySpacing) {
                            if round.isReverseMode {
                                // Reverse mode: show countries
                                if let category = round.category, let options = round.countryOptions {
                                    ForEach(options) { country in
                                        CountryOptionButton(
                                            country: country,
                                            category: category,
                                            isSelected: round.selectedCountry?.id == country.id,
                                            isDisabled: round.isCompleted || isAnimating,
                                            roundScore: round.roundScore,
                                            isBestChoice: round.isCompleted && country.ranking(for: category) == options.map { $0.ranking(for: category) }.min(),
                                            isSmallScreen: isSmallScreen
                                        ) { buttonFrame in
                                            if !round.isCompleted && !isAnimating {
                                                HapticManager.shared.selection()
                                                withAnimation(.spring()) {
                                                    gameManager.selectCountry(country)
                                                }
                                                // Trigger flying score and bonus animations
                                                if let score = gameManager.rounds[gameManager.currentRoundIndex].roundScore {
                                                    triggerFlyingScore(value: score.finalScore, from: buttonFrame)
                                                    if score.hasSpeedBonus {
                                                        triggerSpeedBonus(value: score.speedBonus)
                                                    }
                                                    // Play appropriate sound based on bonuses
                                                    playBonusSound(hasSpeedBonus: score.hasSpeedBonus, hasStreakBonus: gameManager.currentStreak >= 2)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Normal mode: show categories
                                ForEach(round.availableCategories) { category in
                                    if let country = round.country {
                                        CategoryButton(
                                            category: category,
                                            country: country,
                                            isSelected: round.selectedCategory == category,
                                            isAvailable: true,
                                            isDisabled: round.isCompleted || isAnimating,
                                            roundScore: round.roundScore,
                                            isBestCategory: round.isCompleted && gameManager.getOptimalScoreForRound(round)?.category == category,
                                            isSmallScreen: isSmallScreen
                                        ) { buttonFrame in
                                            if !round.isCompleted && !isAnimating {
                                                HapticManager.shared.selection()
                                                withAnimation(.spring()) {
                                                    gameManager.selectCategory(category)
                                                }
                                                // Trigger flying score and bonus animations
                                                if let score = gameManager.rounds[gameManager.currentRoundIndex].roundScore {
                                                    triggerFlyingScore(value: score.finalScore, from: buttonFrame)
                                                    if score.hasSpeedBonus {
                                                        triggerSpeedBonus(value: score.speedBonus)
                                                    }
                                                    // Play appropriate sound based on bonuses
                                                    playBonusSound(hasSpeedBonus: score.hasSpeedBonus, hasStreakBonus: gameManager.currentStreak >= 2)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, isSmallScreen ? 16 : 16)
                        .padding(.top, 24)
                        .padding(.bottom, isSmallScreen ? 24 : 32)
                        .opacity(isAnimating ? 0.5 : 1.0)
                    }
                }
                .opacity(roundContentOpacity)
                .offset(x: roundContentOffset)
                .onChange(of: gameManager.currentRoundIndex) { oldValue, newValue in
                    if newValue != previousRoundIndex {
                        showAllRankings = false
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
            }

            // AdMob Banner at bottom
            BannerAdView()
                .frame(height: 50)
                .background(Color.secondary.opacity(0.1))
        }
    }

    private func triggerFlyingScore(value: Int, from startRect: CGRect) {
        // Save current score before it updates
        previousTotalScore = displayedScore
        let currentSessionId = gameManager.gameSessionId

        flyingScoreValue = value
        // Start from right side of the button
        flyingScoreStart = CGPoint(x: startRect.maxX - 30, y: startRect.midY)

        // Small delay to let the ranking badge appear first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
            // Cancel if game session changed
            guard gameManager.gameSessionId == currentSessionId else { return }

            // Capture score position at animation time (more reliable)
            flyingScoreEnd = CGPoint(x: scorePosition.midX, y: scorePosition.midY)

            // Fallback: if position seems invalid, use a reasonable default
            if flyingScoreEnd.x <= 0 || flyingScoreEnd.y <= 0 {
                // Approximate center-top of screen
                flyingScoreEnd = CGPoint(x: UIScreen.main.bounds.width / 2, y: 80)
            }

            showFlyingScore = true

            // Hide after animation completes (1.2s for slower animation)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                showFlyingScore = false
            }
        }
    }

    private func playBonusSound(hasSpeedBonus: Bool, hasStreakBonus: Bool) {
        if hasSpeedBonus && hasStreakBonus {
            // Both bonuses - play outstanding sound
            SoundManager.shared.playOutstanding()
        } else if hasSpeedBonus {
            // Only speed bonus
            SoundManager.shared.playSpeedBonus()
        } else if hasStreakBonus {
            // Only streak bonus
            SoundManager.shared.playCombo()
        }
    }

    private func triggerSpeedBonus(value: Int) {
        let currentSessionId = gameManager.gameSessionId
        speedBonusValue = value

        // Show speed bonus banner with a slight delay after the score appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showSpeedBonusBanner = true
            }
            HapticManager.shared.success()

            // Hide after 2.0 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    showSpeedBonusBanner = false
                }
            }
        }
    }

    private func triggerExtraRoundBanner() {
        let currentSessionId = gameManager.gameSessionId

        // Calculate delay based on other banners that might be showing
        // Speed bonus: 0.3 + 2.0 + 0.3 = 2.6s
        // Streak banner: 2.6 + 2.5 + 0.3 = 5.4s (if speed bonus exists)
        // We show extra round banner after all others
        let hasSpeedBonus = gameManager.currentRound?.roundScore?.hasSpeedBonus ?? false
        let hasStreakBonus = gameManager.currentStreak >= 2

        var delay: Double = 0.5
        if hasSpeedBonus {
            delay += 2.6 // Wait for speed bonus
        }
        if hasStreakBonus {
            delay += 3.0 // Wait for streak banner
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [self] in
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showExtraRoundBanner = true
            }
            HapticManager.shared.heavy()

            // Hide after 3.0 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    showExtraRoundBanner = false
                }
            }
        }
    }

    private func startFlagAnimation() {
        // Reset state
        showFinalFlag = false
        isAnimating = false
        currentFlagIndex = 0
        let currentSessionId = gameManager.gameSessionId

        // Determine if this is a round transition (not first round)
        let isTransition = previousRoundIndex >= 0

        if isTransition {
            // Store the previous mode before we check for changes
            let wasReverseMode = previousRoundWasReverseMode ?? false

            // Animate out current content (slide left + fade)
            withAnimation(.easeIn(duration: 0.25)) {
                roundContentOpacity = 0
                roundContentOffset = -50
            }

            // After slide out, check if we need to show mode change banner
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [self] in
                // Cancel if game session changed
                guard gameManager.gameSessionId == currentSessionId else { return }

                // Check current round mode NOW (after the new round is created)
                let currentRoundIsReverse = gameManager.currentRound?.isReverseMode ?? false
                let modeChanged = !wasReverseMode && currentRoundIsReverse

                if modeChanged {
                    // Show mode change banner
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showModeChangeBanner = true
                    }
                    HapticManager.shared.heavy()

                    // Hide banner and continue with animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
                        guard gameManager.gameSessionId == currentSessionId else { return }
                        withAnimation(.easeOut(duration: 0.3)) {
                            showModeChangeBanner = false
                        }

                        // Then slide in new content
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                            guard gameManager.gameSessionId == currentSessionId else { return }
                            self.slideInNewRound()
                        }
                    }
                } else {
                    // No mode change, just slide in
                    self.slideInNewRound()
                }
            }
        } else {
            // First round - just show normally
            let currentRoundIsReverse = gameManager.currentRound?.isReverseMode ?? false
            roundContentOpacity = 1
            roundContentOffset = 0
            previousRoundWasReverseMode = currentRoundIsReverse
            performFlagAnimation()
        }
    }

    private func slideInNewRound() {
        // Instantly move to right side (no animation)
        roundContentOffset = 50
        roundContentOpacity = 0
        let currentSessionId = gameManager.gameSessionId

        // Update previous mode tracker
        previousRoundWasReverseMode = gameManager.currentRound?.isReverseMode ?? false

        // Small delay then slide in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                roundContentOpacity = 1
                roundContentOffset = 0
            }

            // Continue with flag animation after slide in starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                self.performFlagAnimation()
            }
        }
    }

    private func performFlagAnimation() {
        let currentSessionId = gameManager.gameSessionId

        // Check if reverse mode
        if let round = gameManager.currentRound, round.isReverseMode {
            // For reverse mode, just show the category icon immediately
            HapticManager.shared.light()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.timingCurve(0.34, 1.56, 0.64, 1, duration: 0.55)) {
                    showFinalFlag = true
                }
                // Start speed bonus timer after animation completes
                gameManager.resetCurrentRoundStartTime()
            }
            return
        }

        // Get random flags for normal mode
        let allFlags = CountryData.shared.countries.map { $0.flag }
        animatingFlags = Array(allFlags.shuffled().prefix(18))

        HapticManager.shared.light()

        // Start immediately
        isAnimating = true

        // Variable speed intervals (slot machine effect)
        let intervals: [Double] = [0.12, 0.11, 0.10, 0.08, 0.07, 0.06, 0.05, 0.05, 0.05, 0.06, 0.07, 0.08, 0.10, 0.12, 0.15, 0.18, 0.22, 0.28]

        var cumulativeTime = 0.0
        for i in 0..<18 {
            cumulativeTime += intervals[i]

            DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.linear(duration: intervals[i] * 0.75)) {
                    currentFlagIndex = i
                }

                // Haptic at key moments
                if i < 4 || i > 13 {
                    HapticManager.shared.selection()
                }
            }
        }

        // Hide animation and show final flag
        DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeTime + 0.2) { [self] in
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.easeOut(duration: 0.12)) {
                isAnimating = false
            }

            HapticManager.shared.medium()

            // Show final flag with easeOutBack
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.timingCurve(0.34, 1.56, 0.64, 1, duration: 0.55)) {
                    showFinalFlag = true
                }
                // Start speed bonus timer after animation completes
                gameManager.resetCurrentRoundStartTime()
            }
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let country: Country
    let isSelected: Bool
    let isAvailable: Bool
    let isDisabled: Bool
    let roundScore: RoundScore?  // Score for this round (nil if not completed)
    let isBestCategory: Bool
    let isSmallScreen: Bool
    let action: (CGRect) -> Void

    @State private var buttonFrame: CGRect = .zero

    private var ranking: Int {
        country.ranking(for: category)
    }

    var body: some View {
        Button(action: { action(buttonFrame) }) {
            HStack(spacing: isSmallScreen ? 10 : 12) {
                Image(systemName: category.icon)
                    .font(.system(size: isSmallScreen ? 20 : 22))
                    .frame(width: isSmallScreen ? 34 : 38)

                VStack(alignment: .leading, spacing: isSmallScreen ? 3 : 3) {
                    Text(category.rawValue)
                        .font(.system(size: isSmallScreen ? 16 : 17, weight: .semibold))
                        .lineLimit(1)

                    Text(category.description)
                        .font(.system(size: isSmallScreen ? 10 : 11))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Show score badge for selected category OR best category
                if let score = roundScore, (isSelected || isBestCategory) {
                    ScoreBadge(
                        score: isBestCategory ? GameManager.maxPointsPerRound : score.finalScore,
                        tier: isBestCategory ? .perfect : score.tier,
                        showStar: isBestCategory,
                        isSmallScreen: isSmallScreen
                    )
                }
            }
            .padding(.horizontal, isSmallScreen ? 12 : 14)
            .padding(.vertical, isSmallScreen ? 12 : 14)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geo in
                    backgroundColor
                        .onAppear {
                            buttonFrame = geo.frame(in: .named("gameView"))
                        }
                        .onChange(of: geo.frame(in: .named("gameView"))) { _, newFrame in
                            buttonFrame = newFrame
                        }
                }
            )
            .foregroundColor(foregroundColor)
            .cornerRadius(isSmallScreen ? 13 : 14)
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8)
            .overlay(
                RoundedRectangle(cornerRadius: isSmallScreen ? 13 : 14)
                    .stroke(isBestCategory ? Color.yellow : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if isDisabled {
            return Color.secondary.opacity(0.08)
        } else {
            return Color.secondary.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isDisabled {
            return .secondary
        } else {
            return .primary
        }
    }

}

// MARK: - Score Badge Component

struct ScoreBadge: View {
    let score: Int
    let tier: ScoreTier
    let showStar: Bool
    let isSmallScreen: Bool

    var body: some View {
        HStack(spacing: 4) {
            if showStar {
                Image(systemName: "star.fill")
                    .font(.system(size: isSmallScreen ? 10 : 11))
                    .foregroundColor(.yellow)
            }
            Text("+\(score)")
                .font(.system(size: isSmallScreen ? 14 : 15, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, isSmallScreen ? 8 : 10)
        .padding(.vertical, isSmallScreen ? 5 : 6)
        .background(tierColor)
        .cornerRadius(isSmallScreen ? 8 : 9)
    }

    private var tierColor: Color {
        switch tier {
        case .perfect: return .green
        case .great: return .blue
        case .good: return .cyan
        case .average: return .orange
        case .poor: return .red
        }
    }
}

struct CountryOptionButton: View {
    let country: Country
    let category: Category
    let isSelected: Bool
    let isDisabled: Bool
    let roundScore: RoundScore?  // Score for this round (nil if not completed)
    let isBestChoice: Bool
    let isSmallScreen: Bool
    let action: (CGRect) -> Void

    @State private var buttonFrame: CGRect = .zero

    private var ranking: Int {
        country.ranking(for: category)
    }

    var body: some View {
        Button(action: { action(buttonFrame) }) {
            HStack(spacing: isSmallScreen ? 10 : 12) {
                Text(country.flag)
                    .font(.system(size: isSmallScreen ? 24 : 28))
                    .frame(width: isSmallScreen ? 34 : 38)

                Text(country.name)
                    .font(.system(size: isSmallScreen ? 16 : 17, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                // Show score badge for selected country OR best choice
                if let score = roundScore, (isSelected || isBestChoice) {
                    ScoreBadge(
                        score: isBestChoice ? GameManager.maxPointsPerRound : score.finalScore,
                        tier: isBestChoice ? .perfect : score.tier,
                        showStar: isBestChoice,
                        isSmallScreen: isSmallScreen
                    )
                }
            }
            .padding(.horizontal, isSmallScreen ? 12 : 14)
            .padding(.vertical, isSmallScreen ? 12 : 14)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geo in
                    backgroundColor
                        .onAppear {
                            buttonFrame = geo.frame(in: .named("gameView"))
                        }
                        .onChange(of: geo.frame(in: .named("gameView"))) { _, newFrame in
                            buttonFrame = newFrame
                        }
                }
            )
            .foregroundColor(foregroundColor)
            .cornerRadius(isSmallScreen ? 13 : 14)
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8)
            .overlay(
                RoundedRectangle(cornerRadius: isSmallScreen ? 13 : 14)
                    .stroke(isBestChoice ? Color.yellow : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if isDisabled {
            return Color.secondary.opacity(0.08)
        } else {
            return Color.secondary.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isDisabled {
            return .secondary
        } else {
            return .primary
        }
    }
}

struct TriviaCard: View {
    let message: String
    let isSmallScreen: Bool

    var body: some View {
        HStack(alignment: .top, spacing: isSmallScreen ? 10 : 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: isSmallScreen ? 18 : 20))
                .foregroundColor(.yellow)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Sabia que?")
                    .font(.system(size: isSmallScreen ? 12 : 13, weight: .semibold))
                    .foregroundColor(.orange)

                Text(message)
                    .font(.system(size: isSmallScreen ? 13 : 14))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .padding(isSmallScreen ? 12 : 14)
        .background(
            RoundedRectangle(cornerRadius: isSmallScreen ? 12 : 14)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: isSmallScreen ? 12 : 14)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct FlyingScoreView: View {
    let value: Int
    let startPoint: CGPoint
    let endPoint: CGPoint
    let onComplete: () -> Void

    @State private var progress: CGFloat = 0
    @State private var opacity: CGFloat = 1
    @State private var scale: CGFloat = 1.0

    // Animation duration
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
                // Initial pop effect
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        scale = 1.0
                    }
                }

                // Start flying after initial pop
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: flyDuration)) {
                        progress = 1
                    }

                    // Shrink as it approaches the target
                    withAnimation(.easeIn(duration: flyDuration).delay(flyDuration * 0.5)) {
                        scale = 0.6
                    }
                }

                // Fade out at the end
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + flyDuration - 0.15) {
                    withAnimation(.easeOut(duration: 0.15)) {
                        opacity = 0
                    }
                }

                // Trigger completion callback when animation ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + flyDuration) {
                    onComplete()
                }
            }
    }

    private var currentPosition: CGPoint {
        // Bezier curve for smoother arc
        let t = progress

        // Control point for the curve (creates an arc going up then down)
        let controlY = min(startPoint.y, endPoint.y) - 80

        // Quadratic bezier: P = (1-t)²P0 + 2(1-t)tP1 + t²P2
        let x = pow(1-t, 2) * startPoint.x + 2 * (1-t) * t * ((startPoint.x + endPoint.x) / 2) + pow(t, 2) * endPoint.x
        let y = pow(1-t, 2) * startPoint.y + 2 * (1-t) * t * controlY + pow(t, 2) * endPoint.y

        return CGPoint(x: x, y: y)
    }
}

struct ModeChangeBannerView: View {
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Banner content
            VStack(spacing: 16) {
                // Animated icon
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
                // Icon animation
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
            // Animated flame icon
            ZStack {
                // Glow effect
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

            // Streak count
            HStack(spacing: 4) {
                Text("\(streak)×")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)
                Text(streakText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .opacity(textOpacity)

            // Multiplier badge
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 18))
                Text(String(format: "%.1fx Bónus", multiplier))
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.yellow)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.3))
            )
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
            // Flame animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                flameScale = 1.0
                flameRotation = 0
            }

            // Text fade in
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                textOpacity = 1.0
            }

            // Multiplier pop
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                multiplierScale = 1.0
            }

            // Continuous flame wobble
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                flameRotation = 5
            }
        }
    }
}

struct SpeedBonusBannerView: View {
    let bonus: Int

    @State private var boltScale: CGFloat = 0.3
    @State private var boltRotation: Double = -45
    @State private var textOpacity: Double = 0
    @State private var bonusScale: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 12) {
            // Animated bolt icon
            ZStack {
                // Glow effect
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

            // Speed bonus text
            Text("Velocidade!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .opacity(textOpacity)

            // Bonus badge
            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                Text("\(bonus) pontos")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
            )
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
            // Bolt animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                boltScale = 1.0
                boltRotation = 0
            }

            // Text fade in
            withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
                textOpacity = 1.0
            }

            // Bonus pop
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.25)) {
                bonusScale = 1.0
            }
        }
    }
}

struct ExtraRoundBannerView: View {
    @State private var iconScale: CGFloat = 0.3
    @State private var iconRotation: Double = -180
    @State private var textOpacity: Double = 0
    @State private var badgeScale: CGFloat = 0.5
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        VStack(spacing: 14) {
            // Animated plus icon
            ZStack {
                // Pulsing glow effect
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

            // Extra round text
            VStack(spacing: 4) {
                Text("Ronda Extra!")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                Text("Desbloqueada")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .opacity(textOpacity)

            // Info badge
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                Text("4 Perfeitos Consecutivos!")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.yellow)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.3))
            )
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
            // Icon animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                iconScale = 1.0
                iconRotation = 0
            }

            // Text fade in
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                textOpacity = 1.0
            }

            // Badge pop
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.35)) {
                badgeScale = 1.0
            }

            // Pulsing glow
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
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
