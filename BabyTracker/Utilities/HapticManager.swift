//
//  HapticManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Light impact - for button taps
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // Medium impact - for toggle switches
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // Heavy impact - for important actions
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // Success - for completed actions
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Warning - for cautionary actions
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // Error - for failed actions
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // Selection changed - for picker/segment changes
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// SwiftUI View extension for easy haptic feedback
extension View {
    func hapticFeedback(_ style: HapticStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                switch style {
                case .light: HapticManager.shared.light()
                case .medium: HapticManager.shared.medium()
                case .heavy: HapticManager.shared.heavy()
                case .success: HapticManager.shared.success()
                case .warning: HapticManager.shared.warning()
                case .error: HapticManager.shared.error()
                case .selection: HapticManager.shared.selection()
                }
            }
        )
    }
}

enum HapticStyle {
    case light, medium, heavy, success, warning, error, selection
}
