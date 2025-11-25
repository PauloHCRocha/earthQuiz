//
//  AdMobManager.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-25.
//

import Foundation
import GoogleMobileAds

final class AdMobManager {
    static let shared = AdMobManager()

    private init() {}

    func initialize() {
        MobileAds.shared.start(completionHandler: nil)
    }
}
