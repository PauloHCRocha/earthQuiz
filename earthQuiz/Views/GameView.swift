//
//  GameView.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

// MARK: - Preference Key for Score Position
struct ScorePositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Game View
struct GameView: View {
    @ObservedObject var gameManager: GameManager

    // Flag animation states
    @State private var animatingFlags: [String] = []
    @State private var showFinalFlag = false
    @State private var previousRoundIndex = -1
    @State private var isAnimating = false
    @State private var currentFlagIndex = 0
    @State private var showQuitAlert = false

    // Flying score animation
    @State private var flyingScoreValue: Int = 0
    @State private var showFlyingScore = false
    @State private var flyingScoreStart: CGPoint = .zero
    @State private var flyingScoreEnd: CGPoint = .zero
    @State private var scorePosition: CGRect = .zero
    @State private var scoreScale: CGFloat = 1.0

    // Score counter animation
    @State private var displayedScore: Int = 0
    @State private var previousTotalScore: Int = 0

    // Round transition animation
    @State private var roundContentOpacity: Double = 1.0
    @State private var roundContentOffset: CGFloat = 0

    // Banner states
    @State private var showModeChangeBanner = false
    @State private var previousRoundWasReverseMode: Bool? = nil
    @State private var showStreakBanner = false
    @State private var streakCount: Int = 0
    @State private var streakMultiplier: Double = 1.0
    @State private var showSpeedBonusBanner = false
    @State private var speedBonusValue: Int = 0
    @State private var showExtraRoundBanner = false
    @State private var previousHasEarnedExtraRound = false

    // Multiplier animation
    @State private var displayedMultiplier: Double = 1.0
    @State private var multiplierScale: CGFloat = 1.0
    @State private var previousMultiplier: Double = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                adaptiveContent(geometry: geometry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // Overlay banners
                overlayBanners
            }
            .coordinateSpace(name: "gameView")
            .onPreferenceChange(ScorePositionKey.self) { scorePosition = $0 }
            .onAppear(perform: handleOnAppear)
            .onChange(of: gameManager.gameState, handleGameStateChange)
            .onChange(of: gameManager.streakMultiplier, handleMultiplierChange)
            .onChange(of: gameManager.hasEarnedExtraRound, handleExtraRoundChange)
            .onChange(of: gameManager.currentStreak, handleStreakChange)
        }
    }

    // MARK: - Overlay Banners
    @ViewBuilder
    private var overlayBanners: some View {
        if showFlyingScore {
            FlyingScoreView(
                value: flyingScoreValue,
                startPoint: flyingScoreStart,
                endPoint: flyingScoreEnd,
                onComplete: { animateScoreCounter(from: previousTotalScore, to: gameManager.totalScore) }
            )
        }

        if showModeChangeBanner {
            ModeChangeBannerView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
        }

        if showStreakBanner {
            StreakBannerView(streak: streakCount, multiplier: streakMultiplier)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(insertion: .scale(scale: 0.5).combined(with: .opacity), removal: .opacity))
        }

        if showSpeedBonusBanner {
            SpeedBonusBannerView(bonus: speedBonusValue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(insertion: .scale(scale: 0.5).combined(with: .opacity), removal: .opacity))
        }

        if showExtraRoundBanner {
            ExtraRoundBannerView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(insertion: .scale(scale: 0.5).combined(with: .opacity), removal: .opacity))
        }
    }

    // MARK: - Adaptive Content
    private func adaptiveContent(geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let isSmallScreen = screenHeight < 750
        let isMediumScreen = screenHeight < 850
        let flagSize: CGFloat = isSmallScreen ? 56 : (isMediumScreen ? 64 : 72)
        let titleFontSize: CGFloat = isSmallScreen ? 20 : (isMediumScreen ? 22 : 24)
        let optionSpacing: CGFloat = isSmallScreen ? 6 : 8

        return VStack(spacing: 0) {
            // Header
            gameHeader(isSmallScreen: isSmallScreen)

            // Main content
            mainContent(
                isSmallScreen: isSmallScreen,
                flagSize: flagSize,
                titleFontSize: titleFontSize,
                optionSpacing: optionSpacing
            )

            // AdMob Banner
            BannerAdView()
                .frame(height: 50)
                .background(Color.secondary.opacity(0.1))
        }
    }

    // MARK: - Game Header
    private func gameHeader(isSmallScreen: Bool) -> some View {
        HStack(spacing: 0) {
            // Quit button
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

            // Center - Score or Timer
            if gameManager.gameMode == .timed {
                timedModeHeader(isSmallScreen: isSmallScreen)
            } else {
                classicModeHeader(isSmallScreen: isSmallScreen)
            }

            Spacer()

            // Skip button (only in classic normal mode)
            skipButton
        }
        .frame(height: isSmallScreen ? 70 : 80)
        .padding(.horizontal, 12)
        .alert("Desistir do Jogo?", isPresented: $showQuitAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Desistir", role: .destructive) {
                HapticManager.shared.medium()
                withAnimation { gameManager.resetGame() }
            }
        } message: {
            Text("Tem a certeza que deseja desistir? O seu progresso será perdido.")
        }
    }

    private func timedModeHeader(isSmallScreen: Bool) -> some View {
        VStack(spacing: 4) {
            TimerDisplayView(
                timeRemaining: gameManager.timeRemaining,
                totalTime: gameManager.timedModeSelection?.seconds ?? 60,
                isSmallScreen: isSmallScreen
            )

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

            Text("\(displayedScore) pts")
                .font(.system(size: isSmallScreen ? 14 : 16, weight: .semibold))
                .foregroundColor(.secondary)
                .scaleEffect(scoreScale)
                .overlay(scorePositionCapture)
        }
    }

    private func classicModeHeader(isSmallScreen: Bool) -> some View {
        VStack(spacing: 2) {
            // Round indicators
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
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
                .scaleEffect(scoreScale)
                .overlay(scorePositionCapture)

            // Multiplier
            MultiplierIndicatorView(
                multiplier: displayedMultiplier,
                scale: multiplierScale,
                isSmallScreen: isSmallScreen
            )
        }
    }

    private var scorePositionCapture: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: ScorePositionKey.self, value: geo.frame(in: .named("gameView")))
        }
    }

    @ViewBuilder
    private var skipButton: some View {
        if gameManager.gameMode == .classic,
           let round = gameManager.currentRound, !round.isReverseMode,
           gameManager.skipsRemaining > 0 && !gameManager.hasSkippedCurrentRound {
            Button(action: {
                withAnimation { gameManager.skipCurrentCountry() }
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

    // MARK: - Main Content
    private func mainContent(isSmallScreen: Bool, flagSize: CGFloat, titleFontSize: CGFloat, optionSpacing: CGFloat) -> some View {
        VStack(spacing: 0) {
            if let round = gameManager.currentRound {
                // Country/Category display card
                displayCard(round: round, isSmallScreen: isSmallScreen, flagSize: flagSize, titleFontSize: titleFontSize)

                // Question text
                if showFinalFlag && !round.isCompleted {
                    Text(round.isReverseMode ? "Qual país tem o melhor ranking?" : "Qual a melhor categoria?")
                        .font(.system(size: isSmallScreen ? 13 : 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, isSmallScreen ? 4 : 6)
                        .padding(.bottom, isSmallScreen ? 4 : 6)
                }

                // Trivia (classic mode only)
                if gameManager.gameMode == .classic, round.isCompleted, let trivia = round.triviaMessage {
                    CompactTriviaCard(message: trivia, isSmallScreen: isSmallScreen)
                        .padding(.horizontal, 12)
                        .padding(.top, isSmallScreen ? 4 : 6)
                }

                Spacer().frame(height: isSmallScreen ? 8 : 12)

                // Options grid
                optionsGrid(round: round, optionSpacing: optionSpacing, isSmallScreen: isSmallScreen)

                Spacer(minLength: isSmallScreen ? 8 : 12)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .opacity(roundContentOpacity)
        .offset(x: roundContentOffset)
        .onChange(of: gameManager.currentRoundIndex) { oldValue, newValue in
            if newValue != previousRoundIndex {
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

    private func displayCard(round: GameRound, isSmallScreen: Bool, flagSize: CGFloat, titleFontSize: CGFloat) -> some View {
        VStack(spacing: isSmallScreen ? 4 : 6) {
            if round.isReverseMode {
                // Reverse mode: Category icon
                if let category = round.category {
                    Image(systemName: category.icon)
                        .font(.system(size: flagSize))
                        .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom))
                        .scaleEffect(showFinalFlag ? 1.0 : 0.3)
                        .opacity(showFinalFlag ? 1.0 : 0)
                        .frame(height: flagSize + 8)
                }

                if showFinalFlag, let category = round.category {
                    Text(category.rawValue)
                        .font(.system(size: titleFontSize, weight: .bold))
                }
            } else {
                // Normal mode: Country flag
                ZStack {
                    if isAnimating && !animatingFlags.isEmpty {
                        FlagCarouselView(flags: animatingFlags, currentIndex: currentFlagIndex, flagSize: flagSize)
                    }

                    if showFinalFlag, let country = round.country {
                        Text(country.flag)
                            .font(.system(size: flagSize))
                            .scaleEffect(showFinalFlag ? 1.0 : 0.5)
                            .opacity(showFinalFlag ? 1.0 : 0)
                    }
                }
                .frame(height: flagSize + 8)

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
    }

    private func optionsGrid(round: GameRound, optionSpacing: CGFloat, isSmallScreen: Bool) -> some View {
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
                            handleCountrySelection(country: country, round: round, buttonFrame: buttonFrame)
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
                            handleCategorySelection(category: category, round: round, buttonFrame: buttonFrame)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .opacity(isAnimating ? 0.5 : 1.0)
    }

    // MARK: - Selection Handlers
    private func handleCountrySelection(country: Country, round: GameRound, buttonFrame: CGRect) {
        guard !round.isCompleted && !isAnimating else { return }
        HapticManager.shared.selection()
        withAnimation(.spring()) { gameManager.selectCountry(country) }
        if let score = gameManager.rounds[gameManager.currentRoundIndex].roundScore {
            triggerFlyingScore(value: score.finalScore, from: buttonFrame)
            if score.hasSpeedBonus { triggerSpeedBonus(value: score.speedBonus) }
            playBonusSound(hasSpeedBonus: score.hasSpeedBonus, hasStreakBonus: gameManager.currentStreak >= 2)
        }
    }

    private func handleCategorySelection(category: Category, round: GameRound, buttonFrame: CGRect) {
        guard !round.isCompleted && !isAnimating else { return }
        HapticManager.shared.selection()
        withAnimation(.spring()) { gameManager.selectCategory(category) }
        if let score = gameManager.rounds[gameManager.currentRoundIndex].roundScore {
            triggerFlyingScore(value: score.finalScore, from: buttonFrame)
            if score.hasSpeedBonus { triggerSpeedBonus(value: score.speedBonus) }
            playBonusSound(hasSpeedBonus: score.hasSpeedBonus, hasStreakBonus: gameManager.currentStreak >= 2)
        }
    }

    // MARK: - Lifecycle Handlers
    private func handleOnAppear() {
        displayedScore = gameManager.totalScore
        previousTotalScore = gameManager.totalScore
        if gameManager.gameState == .playing {
            SoundManager.shared.playThemeSong()
        }
    }

    private func handleGameStateChange(_ oldState: GameManager.GameState, _ newState: GameManager.GameState) {
        if newState == .playing {
            resetGameViewState()
            SoundManager.shared.playThemeSong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                previousRoundIndex = 0
                startFlagAnimation()
            }
        } else if newState == .finished || newState == .notStarted {
            SoundManager.shared.stopThemeSong()
        }
    }

    private func resetGameViewState() {
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
        previousHasEarnedExtraRound = false
        displayedMultiplier = 1.0
        previousMultiplier = 1.0
        multiplierScale = 1.0
    }

    private func handleMultiplierChange(_ oldValue: Double, _ newValue: Double) {
        let currentSessionId = gameManager.gameSessionId
        let increased = newValue > previousMultiplier
        previousMultiplier = newValue

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            multiplierScale = increased ? 1.4 : 0.8
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                displayedMultiplier = newValue
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                multiplierScale = 1.0
            }
        }
    }

    private func handleExtraRoundChange(_ oldValue: Bool, _ newValue: Bool) {
        if newValue && !oldValue && !previousHasEarnedExtraRound {
            previousHasEarnedExtraRound = true
            triggerExtraRoundBanner()
        }
    }

    private func handleStreakChange(_ oldValue: Int, _ newValue: Int) {
        guard newValue >= 2 && newValue > oldValue else { return }

        streakCount = newValue
        streakMultiplier = gameManager.streakMultiplier

        let currentSessionId = gameManager.gameSessionId
        let hasSpeedBonus = gameManager.currentRound?.roundScore?.hasSpeedBonus ?? false
        let streakDelay: Double = hasSpeedBonus ? 2.6 : 0.0

        DispatchQueue.main.asyncAfter(deadline: .now() + streakDelay) {
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showStreakBanner = true
            }
            HapticManager.shared.success()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    showStreakBanner = false
                }
            }
        }
    }

    // MARK: - Score Animation
    private func animateScoreCounter(from startValue: Int, to endValue: Int) {
        let difference = endValue - startValue
        let duration: Double = 0.6
        let steps = min(difference, 20)
        let stepDuration = duration / Double(steps)
        let currentSessionId = gameManager.gameSessionId

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (stepDuration * Double(i))) {
                guard gameManager.gameSessionId == currentSessionId else { return }

                let progress = Double(i) / Double(steps)
                displayedScore = startValue + Int(Double(difference) * progress)

                if i > 0 {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) { scoreScale = 1.15 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        guard gameManager.gameSessionId == currentSessionId else { return }
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.7)) { scoreScale = 1.0 }
                    }
                }

                if i == steps {
                    HapticManager.shared.success()
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) { scoreScale = 1.25 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        guard gameManager.gameSessionId == currentSessionId else { return }
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) { scoreScale = 1.0 }
                    }
                }
            }
        }
    }

    private func triggerFlyingScore(value: Int, from startRect: CGRect) {
        previousTotalScore = displayedScore
        let currentSessionId = gameManager.gameSessionId

        flyingScoreValue = value
        flyingScoreStart = CGPoint(x: startRect.maxX - 30, y: startRect.midY)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard gameManager.gameSessionId == currentSessionId else { return }

            flyingScoreEnd = CGPoint(x: scorePosition.midX, y: scorePosition.midY)
            if flyingScoreEnd.x <= 0 || flyingScoreEnd.y <= 0 {
                flyingScoreEnd = CGPoint(x: UIScreen.main.bounds.width / 2, y: 80)
            }

            showFlyingScore = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                guard gameManager.gameSessionId == currentSessionId else { return }
                showFlyingScore = false
            }
        }
    }

    private func playBonusSound(hasSpeedBonus: Bool, hasStreakBonus: Bool) {
        if hasSpeedBonus && hasStreakBonus {
            SoundManager.shared.playOutstanding()
        } else if hasSpeedBonus {
            SoundManager.shared.playSpeedBonus()
        } else if hasStreakBonus {
            SoundManager.shared.playCombo()
        }
    }

    private func triggerSpeedBonus(value: Int) {
        let currentSessionId = gameManager.gameSessionId
        speedBonusValue = value

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showSpeedBonusBanner = true
            }
            HapticManager.shared.success()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    showSpeedBonusBanner = false
                }
            }
        }
    }

    private func triggerExtraRoundBanner() {
        let currentSessionId = gameManager.gameSessionId
        let hasSpeedBonus = gameManager.currentRound?.roundScore?.hasSpeedBonus ?? false
        let hasStreakBonus = gameManager.currentStreak >= 2

        var delay: Double = 0.5
        if hasSpeedBonus { delay += 2.6 }
        if hasStreakBonus { delay += 3.0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showExtraRoundBanner = true
            }
            HapticManager.shared.heavy()

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    showExtraRoundBanner = false
                }
            }
        }
    }

    // MARK: - Flag Animation
    private func startFlagAnimation() {
        showFinalFlag = false
        isAnimating = false
        currentFlagIndex = 0
        let currentSessionId = gameManager.gameSessionId
        let isTransition = previousRoundIndex >= 0

        if isTransition {
            let wasReverseMode = previousRoundWasReverseMode ?? false

            withAnimation(.easeIn(duration: 0.25)) {
                roundContentOpacity = 0
                roundContentOffset = -50
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                guard gameManager.gameSessionId == currentSessionId else { return }

                let currentRoundIsReverse = gameManager.currentRound?.isReverseMode ?? false
                let modeChanged = !wasReverseMode && currentRoundIsReverse

                if modeChanged {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showModeChangeBanner = true
                    }
                    HapticManager.shared.heavy()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        guard gameManager.gameSessionId == currentSessionId else { return }
                        withAnimation(.easeOut(duration: 0.3)) {
                            showModeChangeBanner = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            guard gameManager.gameSessionId == currentSessionId else { return }
                            slideInNewRound()
                        }
                    }
                } else {
                    slideInNewRound()
                }
            }
        } else {
            let currentRoundIsReverse = gameManager.currentRound?.isReverseMode ?? false
            roundContentOpacity = 1
            roundContentOffset = 0
            previousRoundWasReverseMode = currentRoundIsReverse
            performFlagAnimation()
        }
    }

    private func slideInNewRound() {
        roundContentOffset = 50
        roundContentOpacity = 0
        let currentSessionId = gameManager.gameSessionId

        previousRoundWasReverseMode = gameManager.currentRound?.isReverseMode ?? false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard gameManager.gameSessionId == currentSessionId else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                roundContentOpacity = 1
                roundContentOffset = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                guard gameManager.gameSessionId == currentSessionId else { return }
                performFlagAnimation()
            }
        }
    }

    private func performFlagAnimation() {
        let currentSessionId = gameManager.gameSessionId
        showFinalFlag = false
        isAnimating = false
        currentFlagIndex = 0

        // Reverse mode - simple entrance
        if let round = gameManager.currentRound, round.isReverseMode {
            HapticManager.shared.light()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                guard gameManager.gameSessionId == currentSessionId else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showFinalFlag = true
                }
                gameManager.resetCurrentRoundStartTime()
            }
            return
        }

        // Normal mode - carousel animation
        let allFlags = CountryData.shared.countries.map { $0.flag }
        let countryFlag = gameManager.currentRound?.country?.flag ?? "🌍"
        let otherFlags = allFlags.filter { $0 != countryFlag }.shuffled()
        let flagsBefore = Array(otherFlags.prefix(14))
        let flagsAfter = Array(otherFlags.dropFirst(14).prefix(4))

        animatingFlags = flagsBefore + [countryFlag] + flagsAfter
        let targetIndex = flagsBefore.count

        HapticManager.shared.light()
        isAnimating = true

        let totalSteps = targetIndex + 1
        var cumulativeTime = 0.0
        let startDelay = 0.1

        for i in 0..<totalSteps {
            let progress = Double(i) / Double(max(totalSteps - 1, 1))
            let interval = 0.05 + (0.20 * pow(progress, 2.0))
            cumulativeTime += interval

            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + cumulativeTime) {
                guard gameManager.gameSessionId == currentSessionId, isAnimating else { return }
                currentFlagIndex = i

                if i < 4 {
                    HapticManager.shared.selection()
                } else if i > totalSteps - 3 {
                    HapticManager.shared.light()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + cumulativeTime + 0.3) {
            guard gameManager.gameSessionId == currentSessionId else { return }
            HapticManager.shared.medium()

            withAnimation(.easeOut(duration: 0.15)) { isAnimating = false }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { showFinalFlag = true }
            gameManager.resetCurrentRoundStartTime()
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
