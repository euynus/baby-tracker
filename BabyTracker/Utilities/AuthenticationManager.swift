//
//  AuthenticationManager.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import LocalAuthentication
import SwiftUI
import CryptoKit

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authenticationError: String?

    @AppStorage("isAuthenticationEnabled") var isAuthenticationEnabled = false
    @AppStorage("usePasscode") var usePasscode = false

    private let keychainService = "com.babytracker.security"
    private let keychainAccount = "passcodeHash"
    private let legacyPasscodeKey = "passcode"

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

        let keychainValue = KeychainManager.get(service: keychainService, account: keychainAccount)
        let isValid: Bool
        if let keychainValue {
            isValid = verify(passcode: passcode, storedValue: keychainValue)
        } else {
            // Backward compatibility for older plain-text storage.
            let legacyPasscode = UserDefaults.standard.string(forKey: legacyPasscodeKey)
            isValid = (legacyPasscode == passcode)
            if isValid {
                setPasscode(passcode)
                UserDefaults.standard.removeObject(forKey: legacyPasscodeKey)
            }
        }

        if isValid {
            isAuthenticated = true
        }
        return isValid
    }
    
    func setPasscode(_ passcode: String) {
        let salt = generateSalt()
        let hash = hash(passcode: passcode, salt: salt)
        _ = KeychainManager.set("\(salt):\(hash)", service: keychainService, account: keychainAccount)
        usePasscode = true
        isAuthenticationEnabled = true
    }
    
    func removeAuthentication() {
        isAuthenticationEnabled = false
        usePasscode = false
        KeychainManager.delete(service: keychainService, account: keychainAccount)
        UserDefaults.standard.removeObject(forKey: legacyPasscodeKey)
    }

    func removePasscode() {
        usePasscode = false
        KeychainManager.delete(service: keychainService, account: keychainAccount)
        UserDefaults.standard.removeObject(forKey: legacyPasscodeKey)
    }

    private func verify(passcode: String, storedValue: String) -> Bool {
        let components = storedValue.split(separator: ":", maxSplits: 1).map(String.init)
        guard components.count == 2 else { return false }
        let salt = components[0]
        let expectedHash = components[1]
        return hash(passcode: passcode, salt: salt) == expectedHash
    }

    private func hash(passcode: String, salt: String) -> String {
        let input = Data((salt + passcode).utf8)
        let digest = SHA256.hash(data: input)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func generateSalt(length: Int = 16) -> String {
        let bytes = (0..<length).map { _ in UInt8.random(in: 0...255) }
        return Data(bytes).base64EncodedString()
    }
}
