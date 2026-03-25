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
                .fill(AppTheme.brand.opacity(colorScheme == .dark ? 0.16 : 0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 34)
                .offset(x: 150, y: -250)

            Circle()
                .fill(AppTheme.secondary.opacity(colorScheme == .dark ? 0.16 : 0.20))
                .frame(width: 260, height: 260)
                .blur(radius: 26)
                .offset(x: -140, y: 260)

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
            .padding(.vertical, 24)
        }
        .task {
            await authManager.authenticate()
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                AppIconBadge(symbol: "heart.text.square.fill", colors: AppTheme.mintHeroGradient, size: 60)
                Spacer()
                Text("安全访问")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.82))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("宝宝日记")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("进入记录中心之前，先完成一次安全验证。")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.90))
            }

            HStack(spacing: 10) {
                AppStatusChip(title: "保护内容", value: "成长数据")
                AppStatusChip(title: "支持方式", value: authManager.usePasscode ? "密码" : "Face ID")
            }
        }
        .padding(22)
        .gradientCard(AppTheme.heroGradient)
    }

    private var passcodeInput: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionTitle(
                eyebrow: "Unlock",
                title: "输入密码",
                subtitle: "验证通过后进入首页和记录流。"
            )

            SecureField("输入密码", text: $passcode)
                .keyboardType(.numberPad)
                .appInputFieldStyle()

            Button("解锁") {
                verifyPasscode()
            }
            .buttonStyle(AppPrimaryButtonStyle())

            if showError {
                Text("密码错误，请重新输入。")
                    .font(.caption)
                    .foregroundStyle(AppTheme.danger)
            }
        }
        .padding(18)
        .cardStyle()
    }

    private var biometricButton: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionTitle(
                eyebrow: "Biometric",
                title: "生物识别解锁",
                subtitle: "保持进入速度，同时不牺牲数据安全。"
            )

            Button(action: {
                Task {
                    await authManager.authenticate()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "faceid")
                        .font(.system(size: 28, weight: .semibold))
                    Text("使用 Face ID 解锁")
                        .font(.headline)
                }
            }
            .buttonStyle(AppPrimaryButtonStyle(gradient: AppTheme.sleepGradient))
        }
        .padding(18)
        .cardStyle()
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
