# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Earth Quiz is an iOS trivia game built with SwiftUI where players identify which category (Population, Football, Tourism, GDP, etc.) a given country ranks best in globally. The game uses an MVVM architecture with Combine for state management.

## Build & Run Commands

### Build the project
```bash
xcodebuild -scheme earthQuiz -configuration Debug build -project earthQuiz.xcodeproj
```

### Build for specific simulator
```bash
xcodebuild -scheme earthQuiz -sdk iphonesimulator -configuration Debug build -project earthQuiz.xcodeproj
```

### Clean build
```bash
xcodebuild clean -scheme earthQuiz -project earthQuiz.xcodeproj
```

### Run in Xcode
Open `earthQuiz.xcodeproj` in Xcode and press `Cmd + R` to build and run on the selected simulator or device.

## Dependencies

The project uses Swift Package Manager (SPM) for dependency management:
- **GoogleMobileAds** (12.14.0) - AdMob SDK for banner ads
- **GoogleUserMessagingPlatform** (3.1.0) - User messaging for GDPR/privacy compliance

Dependencies are resolved automatically by Xcode. If needed, resolve packages manually:
```bash
xcodebuild -resolvePackageDependencies -project earthQuiz.xcodeproj
```

## Architecture

### MVVM Pattern
- **Models**: `Country`, `Category`, `GameRound` - immutable data structures
- **ViewModels**: `GameManager` (game state), `AdMobManager` (ads), `HapticManager` (haptics) - use `@Published` properties
- **Views**: SwiftUI views that observe ViewModels via `@ObservedObject`

### Core Game Flow
1. **Game Start**: `GameManager.startNewGame()` selects 5 random categories and creates first round
2. **Round Creation**: `createNextRound()` generates a new `GameRound` with random unused country and available categories
3. **Category Selection**: `selectCategory()` calculates score based on country's ranking, triggers haptic feedback, advances to next round after 1.5s delay
4. **Game Completion**: After 5 rounds, `gameState` transitions to `.finished`

### Key Design Patterns

**Category Elimination**: Once a category is selected in a round, it's removed from `availableCategories` for subsequent rounds. This creates strategic decision-making as the game progresses.

**Country Uniqueness**: `usedCountries` set ensures no country appears twice in a single game. The skip feature temporarily removes a country from this set to allow rerolling.

**Haptic Feedback**: `HapticManager` provides tactile feedback based on score quality:
- 1-10 ranking: Success haptic
- 11-25: Medium impact
- 26-50: Light impact
- 50+: Warning haptic

**Platform Guards**: `HapticManager` uses `#if canImport(UIKit)` to safely handle UIKit dependencies, allowing the code to compile on non-iOS platforms.

**AdMob Integration**: `AdMobManager` is a singleton that initializes the Google Mobile Ads SDK at app launch. `BannerAdView` is a `UIViewRepresentable` wrapper that displays banner ads at the bottom of `GameView`. Currently uses Google's test ad unit ID (`ca-app-pub-3940256099942544/2934735716`) - replace with production ad unit ID before app store release.

### State Management
`GameManager` is the single source of truth, using `@Published` properties:
- `gameState`: `.notStarted`, `.playing`, `.finished`
- `rounds`: Array of completed and current rounds
- `currentRoundIndex`: Index into rounds array
- `totalScore`: Cumulative score across all rounds
- `selectedCategories`: The 5 categories chosen at game start

### Data Model
`CountryData.shared.countries` contains hardcoded country data with rankings for all categories. Each `Country` has:
- `id`, `name`, `flag` (emoji)
- `rankings`: Dictionary mapping `Category` to ranking position (lower is better)
- `ranking(for:)`: Returns ranking for a category, defaults to 999 if missing
- `bestCategory(from:)`: Finds optimal category choice from available options

### View Hierarchy
```
ContentView (root)
├── StartView (gameState == .notStarted)
├── GameView (gameState == .playing)
│   ├── Header (round, score, skip button)
│   ├── Country display (flag + name with slot machine animation)
│   ├── Category grid (available categories)
│   └── BannerAdView (bottom banner ad)
└── GameOverView (gameState == .finished)
    └── Results summary with optimal scores
```

### Animations
**Slot Machine Effect**: When a new round starts, `GameView` plays a slot machine animation showing random country flags before revealing the actual country. The animation uses variable-speed intervals to create deceleration effect, with haptic feedback at key moments. Implementation in `startFlagAnimation()` uses `DispatchQueue.asyncAfter` with cumulative timing for smooth transitions.

## Important Implementation Details

### Category Selection Logic
When a category is selected, the score is the country's ranking in that category. The game rewards selecting the category where the country ranks highest (lowest number). After selection, that category is removed from future rounds.

### Skip Functionality
- Players get 1 skip per game (`skipsRemaining`)
- Can only skip once per round (`hasSkippedCurrentRound`)
- Skipping replaces the current country with a new random unused country
- Skip button only shows when skip is available and not yet used in current round

### Score Calculation
- Total score is sum of all ranking positions selected
- Lower is better (best possible score depends on countries drawn)
- Average score determines rating:
  - 0-10: Excepcional! 🏆
  - 11-25: Excelente! ⭐️
  - 26-50: Muito Bom! 👏
  - 51-100: Bom! 👍
  - 100+: Continue praticando! 💪

### Optimal Score Display
`GameOverView` shows optimal score by retroactively calculating the best possible category choice for each round given the available categories at that time. This helps players understand how well they performed.

### AdMob Configuration
**Test Mode**: The app currently uses Google's test ad unit ID. To switch to production:
1. Replace `adUnitID` in `BannerAdView.swift` with your production ad unit from AdMob console
2. Ensure proper Info.plist configuration for AdMob App ID
3. Test ads thoroughly before release

**Initialization**: `AdMobManager.shared.initialize()` is called in `earthQuizApp.init()` to start the Mobile Ads SDK before any views load.

## Adding New Features

### Adding a New Category
1. Add case to `Category` enum in `Models/Category.swift`
2. Add icon mapping in `Category.icon` computed property
3. Add description in `Category.description` computed property
4. Update all countries in `CountryData.swift` to include ranking for new category

### Adding a New Country
Add new `Country` instance to `CountryData.shared.countries` array with rankings for all 15 categories. Use realistic ranking data where possible.

### Modifying Game Rules
- Change number of rounds: Update hardcoded `5` in `GameManager.startNewGame()` and `createNextRound()`
- Change number of categories: Modify `.prefix(5)` in `startNewGame()`
- Change skip count: Modify initial `skipsRemaining` value
- Change delay before next round: Modify `deadline: .now() + 1.5` in `selectCategory()`

## File Locations
- Models: `earthQuiz/Models/` (Category.swift, Country.swift, GameRound.swift)
- ViewModels: `earthQuiz/ViewModels/` (GameManager.swift, AdMobManager.swift, HapticManager.swift)
- Views: `earthQuiz/Views/` (ContentView.swift, StartView.swift, GameView.swift, GameOverView.swift, BannerAdView.swift)
- Data: `earthQuiz/Data/CountryData.swift`
- App entry: `earthQuiz/earthQuizApp.swift`

## Troubleshooting

### Build Issues
- **Package resolution fails**: Run `xcodebuild -resolvePackageDependencies -project earthQuiz.xcodeproj`
- **AdMob not loading**: Verify GoogleMobileAds package is properly resolved and `AdMobManager.shared.initialize()` is called in app init
- **Simulator compatibility**: Use `-sdk iphonesimulator` flag when building for simulator
