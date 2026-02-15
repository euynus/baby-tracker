//
//  AuthenticationView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var passcode = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            AppTheme.pageGradient(for: colorScheme)
                .ignoresSafeArea()

            Circle()
                .fill(AppTheme.brand.opacity(colorScheme == .dark ? 0.18 : 0.24))
                .frame(width: 300, height: 300)
                .blur(radius: 24)
                .offset(x: 130, y: -250)

            Circle()
                .fill(AppTheme.secondary.opacity(colorScheme == .dark ? 0.16 : 0.20))
                .frame(width: 240, height: 240)
                .blur(radius: 22)
                .offset(x: -140, y: 280)

            VStack(spacing: 24) {
                Spacer()

                hero

                if authManager.usePasscode {
                    passcodeInput
                } else {
                    biometricButton
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .task {
            await authManager.authenticate()
        }
    }

    private var hero: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.white)
                .padding(14)
                .background(.white.opacity(0.22))
                .clipShape(Circle())

            Text("宝宝日记")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("安全登录后继续记录宝宝成长")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.88))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .gradientCard(AppTheme.heroGradient)
    }

    private var passcodeInput: some View {
        VStack(spacing: 14) {
            SecureField("输入密码", text: $passcode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            Button(action: verifyPasscode) {
                Text("解锁")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: AppTheme.heroGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            }
            .buttonStyle(.plain)
            .scaleButton()

            if showError {
                Text("密码错误")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var biometricButton: some View {
        Button(action: {
            Task {
                await authManager.authenticate()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "faceid")
                    .font(.system(size: 32, weight: .semibold))
                Text("使用 Face ID 解锁")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(colors: AppTheme.sleepGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleButton()
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
