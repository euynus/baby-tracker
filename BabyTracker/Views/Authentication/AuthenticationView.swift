//
//  AuthenticationView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var passcode = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                    
                    Text("宝宝日记")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                if authManager.usePasscode {
                    passcodeInput
                } else {
                    biometricButton
                }
                
                Spacer()
            }
            .padding()
        }
        .task {
            await authManager.authenticate()
        }
    }
    
    private var passcodeInput: some View {
        VStack(spacing: 20) {
            SecureField("输入密码", text: $passcode)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .keyboardType(.numberPad)
            
            Button(action: verifyPasscode) {
                Text("解锁")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            if showError {
                Text("密码错误")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
    }
    
    private var biometricButton: some View {
        Button(action: {
            Task {
                await authManager.authenticate()
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: "faceid")
                    .font(.system(size: 48))
                Text("使用 Face ID 解锁")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding(32)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
        }
    }
    
    private func verifyPasscode() {
        if authManager.authenticateWithPasscode(passcode) {
            showError = false
        } else {
            showError = true
            passcode = ""
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager())
}
