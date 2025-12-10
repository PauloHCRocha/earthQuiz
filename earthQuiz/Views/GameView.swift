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

    // Multiplier indicator animation
    @State private var displayedMultiplier: Double = 1.0
    @State private var multiplierScale: CGFloat = 1.0
    @State private var previousMultiplier: Double = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                adaptiveContent(geometry: geometry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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

                // Mode change banner overlay - centered
                if showModeChangeBanner {
                    ModeChangeBannerView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                // Streak banner overlay - centered
                if showStreakBanner {
                    StreakBannerView(streak: streakCount, multiplier: streakMultiplier)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                }

                // Speed bonus banner overlay - centered
                if showSpeedBonusBanner {
                    SpeedBonusBannerView(bonus: speedBonusValue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                }

                // Extra round banner overlay - centered
                if showExtraRoundBanner {
                    ExtraRoundBannerView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    currentFlagIndex = 0
                    animatingFlags = []
                    roundContentOpacity = 1.0
                    roundContentOffset = 0
                    showModeChangeBanner = false
                    showStreakBanner = false
                    showSpeedBonusBanner = false
                    showExtraRoundBanner = false
                    previousStreak = 0
                    previousHasEarnedExtraRound = false

                    // Reset multiplier display
                    displayedMultiplier = 1.0
                    previousMultiplier = 1.0
                    multiplierScale = 1.0

                    // Start theme song
                    SoundManager.shared.playThemeSong()

                    // Trigger flag animation for new game
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        previousRoundIndex = 0
                        startFlagAnimation()
                    }
                } else if newState == .finished || newState == .notStarted {
                    // Stop theme song when game ends or returns to menu
                    SoundManager.shared.stopThemeSong()
                }
            }
            .onChange(of: gameManager.streakMultiplier) { oldValue, newValue in
                // Animate multiplier changes
                let currentSessionId = gameManager.gameSessionId
                let increased = newValue > previousMultiplier
                previousMultiplier = newValue

                // Pop animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    multiplierScale = increased ? 1.4 : 0.8
                }

                // Update value with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    guard gameManager.gameSessionId == currentSessionId else { return }
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        displayedMultiplier = newValue
                    }
                }

                // Return to normal scale
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard gameManager.gameSessionId == currentSessionId else { return }
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        multiplierScale = 1.0
                    }
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
        let isSmallScreen = screenHeight < 750 // iPhone 13 mini, SE
        let isMediumScreen = screenHeight < 850 // iPhone standard

        // Adaptive sizing - optimizado para caber sem scroll mas legível
        let flagSize: CGFloat = isSmallScreen ? 56 : (isMediumScreen ? 64 : 72)
        let titleFontSize: CGFloat = isSmallScreen ? 20 : (isMediumScreen ? 22 : 24)
        let optionSpacing: CGFloat = isSmallScreen ? 6 : 8

        return VStack(spacing: 0) {
            // Compact Header - arcade style
            HStack(spacing: 0) {
                // Quit button - minimal
                Button(action: {
                    HapticManager.shared.light()
                    showQuitAlert = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.red.opacity(0.8))
                }
                .frame(width: 44)

                Spacer()

                // Center - Score display or Timer (timed mode)
                if gameManager.gameMode == .timed {
                    // Timed mode header
                    VStack(spacing: 4) {
                        // Timer display
                        TimerDisplayView(
                            timeRemaining: gameManager.timeRemaining,
                            totalTime: gameManager.timedModeSelection?.seconds ?? 60,
                            isSmallScreen: isSmallScreen
                        )

                        // Questions answered count
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("\(gameManager.questionsAnswered)")
                                .font(.system(size: isSmallScreen ? 16 : 18, weight: .bold))
                            Text("respostas")
                                .font(.system(size: isSmallScreen ? 11 : 12))
                                .foregroundColor(.secondary)
                        }

                        // Score
                        Text("\(displayedScore) pts")
                            .font(.system(size: isSmallScreen ? 14 : 16, weight: .semibold))
                            .foregroundColor(.secondary)
                            .scaleEffect(scoreScale)
                            .overlay(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: ScorePositionKey.self, value: geo.frame(in: .named("gameView")))
                                }
                            )
                    }
                } else {
                    // Classic mode header
                    VStack(spacing: 2) {
                        // Round indicator
                        HStack(spacing: 4) {
                            ForEach(0..<gameManager.totalRounds, id: \.self) { index in
                                Circle()
                                    .fill(index < gameManager.currentRoundIndex ? Color.green :
                                          index == gameManager.currentRoundIndex ? Color.blue : Color.secondary.opacity(0.3))
                                    .frame(width: isSmallScreen ? 6 : 7, height: isSmallScreen ? 6 : 7)
                            }
                        }

                        // Score
                        Text("\(displayedScore)")
                            .font(.system(size: isSmallScreen ? 28 : 32, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .scaleEffect(scoreScale)
                            .overlay(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: ScorePositionKey.self, value: geo.frame(in: .named("gameView")))
                                }
                            )

                        // Multiplier
                        MultiplierIndicatorView(
                            multiplier: displayedMultiplier,
                            scale: multiplierScale,
                            isSmallScreen: isSmallScreen
                        )
                    }
                }

                Spacer()

                // Skip button (only in classic normal mode)
                if gameManager.gameMode == .classic,
                   let round = gameManager.currentRound, !round.isReverseMode,
                   gameManager.skipsRemaining > 0 && !gameManager.hasSkippedCurrentRound {
                    Button(action: {
                        withAnimation {
                            gameManager.skipCurrentCountry()
                        }
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                    }
                    .frame(width: 44)
                } else {
                    Color.clear.frame(width: 44)
                }
            }
            .frame(height: isSmallScreen ? 70 : 80) // Fixed header height for consistency
            .padding(.horizontal, 12)
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

            // Main content - NO ScrollView, fixed layout, aligned to top
            VStack(spacing: 0) {
                if let round = gameManager.currentRound {
                    // Top section: Country/Category display card
                    VStack(spacing: isSmallScreen ? 4 : 6) {
                        if round.isReverseMode {
                            // Reverse mode: Show category icon
                            if let category = round.category {
                                Image(systemName: category.icon)
                                    .font(.system(size: flagSize)) // Same size as flag
                                    .foregroundStyle(
                                        LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
                                    )
                                    .scaleEffect(showFinalFlag ? 1.0 : 0.3)
                                    .opacity(showFinalFlag ? 1.0 : 0)
                                    .frame(height: flagSize + 8)
                            }

                            // Category name
                            if showFinalFlag, let category = round.category {
                                Text(category.rawValue)
                                    .font(.system(size: titleFontSize, weight: .bold))
                            }
                        } else {
                            // Normal mode: Show country with carousel/roulette animation
                            ZStack {
                                if isAnimating && !animatingFlags.isEmpty {
                                    FlagCarouselView(
                                        flags: animatingFlags,
                                        currentIndex: currentFlagIndex,
                                        flagSize: flagSize
                                    )
                                }

                                // Final flag with bounce
                                if showFinalFlag, let country = round.country {
                                    Text(country.flag)
                                        .font(.system(size: flagSize))
                                        .scaleEffect(showFinalFlag ? 1.0 : 0.5)
                                        .opacity(showFinalFlag ? 1.0 : 0)
                                }
                            }
                            .frame(height: flagSize + 8)

                            // Country name
                            if showFinalFlag, let country = round.country {
                                Text(country.name)
                                    .font(.system(size: titleFontSize, weight: .bold))
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isSmallScreen ? 10 : 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: round.isReverseMode ? [Color.purple.opacity(0.1), Color.pink.opacity(0.05)] : [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .padding(.horizontal, 12)

                    // Question text - only when not completed
                    if showFinalFlag && !round.isCompleted {
                        Text(round.isReverseMode ? "Qual país tem o melhor ranking?" : "Qual a melhor categoria?")
                            .font(.system(size: isSmallScreen ? 13 : 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.top, isSmallScreen ? 4 : 6)
                            .padding(.bottom, isSmallScreen ? 4 : 6)
                    }

                    // Trivia when completed (only in classic mode)
                    if gameManager.gameMode == .classic, round.isCompleted, let trivia = round.triviaMessage {
                        CompactTriviaCard(message: trivia, isSmallScreen: isSmallScreen)
                            .padding(.horizontal, 12)
                            .padding(.top, isSmallScreen ? 4 : 6)
                    }

                    // Fixed spacer between card and buttons
                    Spacer()
                        .frame(height: isSmallScreen ? 8 : 12)

                    // Options grid - Categories or Countries
                    VStack(spacing: optionSpacing) {
                        if round.isReverseMode {
                            if let category = round.category, let options = round.countryOptions {
                                ForEach(options) { country in
                                    CompactCountryButton(
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
                                            if let score = gameManager.rounds[gameManager.currentRoundIndex].roundScore {
                                                triggerFlyingScore(value: score.finalScore, from: buttonFrame)
                                                if score.hasSpeedBonus {
                                                    triggerSpeedBonus(value: score.speedBonus)
                                                }
                                                playBonusSound(hasSpeedBonus: score.hasSpeedBonus, hasStreakBonus: gameManager.currentStreak >= 2)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            ForEach(round.availableCategories) { category in
                                if let country = round.country {
                                    CompactCategoryButton(
                                        category: category,
                                        country: country,
                                        isSelected: round.selectedCategory == category,
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
                                            if let score = gameManager.rounds[gameManager.currentRoundIndex].roundScore {
                                                triggerFlyingScore(value: score.finalScore, from: buttonFrame)
                                                if score.hasSpeedBonus {
                                                    triggerSpeedBonus(value: score.speedBonus)
                                                }
                                                playBonusSound(hasSpeedBonus: score.hasSpeedBonus, hasStreakBonus: gameManager.currentStreak >= 2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .opacity(isAnimating ? 0.5 : 1.0)

                    // Bottom spacer - flexible to push content up
                    Spacer(minLength: isSmallScreen ? 8 : 12)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top) // Force content to align to top
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

        // Reset animation state
        showFinalFlag = false
        isAnimating = false
        currentFlagIndex = 0

        // Check if reverse mode
        if let round = gameManager.currentRound, round.isReverseMode {
            // For reverse mode, show the category icon with a nice entrance
            HapticManager.shared.light()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showFinalFlag = true
                }
                gameManager.resetCurrentRoundStartTime()
            }
            return
        }

        // Get random flags for carousel/roulette effect
        // The country's flag should be in the middle with random flags before AND after
        // This gives the feeling that the roulette stopped randomly
        let allFlags = CountryData.shared.countries.map { $0.flag }
        let countryFlag = gameManager.currentRound?.country?.flag ?? "🌍"

        // Get random flags excluding the country's flag
        var otherFlags = allFlags.filter { $0 != countryFlag }.shuffled()

        // Build the array: random flags + country flag + more random flags after
        let flagsBefore = Array(otherFlags.prefix(14))
        let flagsAfter = Array(otherFlags.dropFirst(14).prefix(4))

        animatingFlags = flagsBefore + [countryFlag] + flagsAfter

        // The target index is where the country flag is (after flagsBefore)
        let targetIndex = flagsBefore.count

        HapticManager.shared.light()

        // Roulette/carousel effect: start fast, decelerate smoothly
        // Animation goes from 0 to targetIndex (where the country flag is)
        let totalSteps = targetIndex + 1
        var cumulativeTime = 0.0
        let startDelay = 0.1

        // Set isAnimating immediately
        isAnimating = true

        for i in 0..<totalSteps {
            // Smooth deceleration curve (like a spinning wheel slowing down)
            let progress = Double(i) / Double(max(totalSteps - 1, 1))
            // Starts at ~0.05s, ends at ~0.25s per flag
            let interval = 0.05 + (0.20 * pow(progress, 2.0))
            cumulativeTime += interval

            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + cumulativeTime) { [self] in
                guard gameManager.gameSessionId == currentSessionId else { return }
                guard isAnimating else { return }

                // Update index - animation is handled by FlagCarouselView
                currentFlagIndex = i

                // Haptic feedback: frequent at start (spinning fast), sparse at end (slowing down)
                if i < 4 {
                    HapticManager.shared.selection()
                } else if i > totalSteps - 3 {
                    HapticManager.shared.light()
                }
            }
        }

        // Final reveal - the carousel is already showing the country's flag (last in array)
        // Just transition smoothly to showFinalFlag
        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + cumulativeTime + 0.3) { [self] in
            guard gameManager.gameSessionId == currentSessionId else { return }

            HapticManager.shared.medium()

            // Hide carousel and show final flag simultaneously
            withAnimation(.easeOut(duration: 0.15)) {
                isAnimating = false
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showFinalFlag = true
            }
            gameManager.resetCurrentRoundStartTime()
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

// MARK: - Flag Carousel View
struct FlagCarouselView: View {
    let flags: [String]
    let currentIndex: Int
    let flagSize: CGFloat

    private var spacing: CGFloat { 10 }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
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

// MARK: - Timer Display View (for timed mode)
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

#Preview {
    GameView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        return manager
    }())
}
