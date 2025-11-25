//
//  earthQuizApp.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

@main
struct earthQuizApp: App {
    init() {
        // Initialize AdMob SDK
        AdMobManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
