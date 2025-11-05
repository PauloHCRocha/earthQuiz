// HapticManager.swift
// earthQuiz
//
// Created by Claude on 2025-11-05.
//

import Foundation
import UIKit

final class HapticManager {

    static let shared = HapticManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        // Pre-warm generators to reduce first-use latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // Generic helpers
    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // Semantic helpers
    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }
}
