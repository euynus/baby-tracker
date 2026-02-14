//
//  AuthenticationManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import LocalAuthentication
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authenticationError: String?

    @AppStorage("isAuthenticationEnabled") var isAuthenticationEnabled = false
    @AppStorage("usePasscode") var usePasscode = false
    @AppStorage("passcode") private var storedPasscode = ""

    func authenticate() async {
        guard isAuthenticationEnabled else {
            isAuthenticated = true
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "解锁宝宝日记"
                )
                
                isAuthenticated = success
            } catch {
                authenticationError = error.localizedDescription
                if !usePasscode {
                    isAuthenticated = false
                }
            }
        } else {
            // Biometric not available, use passcode
            if !usePasscode {
                isAuthenticated = true
            }
        }
    }
    
    func authenticateWithPasscode(_ passcode: String) -> Bool {
        guard usePasscode else { return true }
        let isValid = passcode == storedPasscode
        if isValid {
            isAuthenticated = true
        }
        return isValid
    }
    
    func setPasscode(_ passcode: String) {
        storedPasscode = passcode
        usePasscode = true
        isAuthenticationEnabled = true
    }
    
    func removeAuthentication() {
        isAuthenticationEnabled = false
        usePasscode = false
        storedPasscode = ""
    }
}
