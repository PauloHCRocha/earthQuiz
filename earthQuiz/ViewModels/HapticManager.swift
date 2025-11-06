//
//  HapticManager.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//  Enhanced with platform guards on 2025-11-06.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

final class HapticManager {

    static let shared = HapticManager()

    #if canImport(UIKit)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    #endif

    private init() {
        #if canImport(UIKit)
        // Pre-warm generators to reduce first-use latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
        #endif
    }

    // MARK: - Impact Feedback

    func light() {
        #if canImport(UIKit)
        impactLight.impactOccurred()
        impactLight.prepare()
        #endif
    }

    func medium() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        impactMedium.prepare()
        #endif
    }

    func heavy() {
        #if canImport(UIKit)
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
        #endif
    }

    // MARK: - Selection Feedback

    func selection() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
        #endif
    }

    // MARK: - Notification Feedback

    func success() {
        #if canImport(UIKit)
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
        #endif
    }

    func warning() {
        #if canImport(UIKit)
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
        #endif
    }

    func error() {
        #if canImport(UIKit)
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
        #endif
    }
}
