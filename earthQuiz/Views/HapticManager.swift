//
//  HapticManager.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-09.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        // Preparar geradores para reduzir a latência na primeira utilização
        selectionGenerator.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationGenerator.prepare()
    }

    // Pequenas mudanças de seleção (ex.: trocar item)
    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // Impactos com diferentes intensidades
    func light() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }

    func medium() {
        mediumImpact.impactOccurred()
        mediumImpact.prepare()
    }

    func heavy() {
        heavyImpact.impactOccurred()
        heavyImpact.prepare()
    }

    // Notificações (sucesso/aviso/erro)
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
