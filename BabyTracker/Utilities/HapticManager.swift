//
//  HapticManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//  Updated for SPM compatibility: 2026-02-11
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Light impact - for button taps
    func light() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    // Medium impact - for toggle switches
    func medium() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    // Heavy impact - for important actions
    func heavy() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    // Success - for completed actions
    func success() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    // Warning - for cautionary actions
    func warning() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
    
    // Error - for failed actions
    func error() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    // Selection changed - for picker/segment changes
    func selection() {
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
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
