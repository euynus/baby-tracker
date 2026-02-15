//
//  SecuritySettingsView.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var showingPasscodeSetup = false
    @State private var newPasscode = ""
    @State private var confirmPasscode = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                securityToggleCard

                if authManager.isAuthenticationEnabled {
                    verificationCard

                    if authManager.usePasscode {
                        removePasscodeButton
                    }
                }
            }
            .padding(.horizontal, AppTheme.paddingMedium)
            .padding(.vertical, 12)
        }
        .navigationTitle("安全设置")
        .navigationBarTitleDisplayMode(.inline)
        .appPageBackground()
        .sheet(isPresented: $showingPasscodeSetup) {
            PasscodeSetupView(
                newPasscode: $newPasscode,
                confirmPasscode: $confirmPasscode,
                showError: $showError,
                errorMessage: $errorMessage
            ) {
                if newPasscode == confirmPasscode && newPasscode.count >= 4 {
                    authManager.setPasscode(newPasscode)
                    showingPasscodeSetup = false
                    newPasscode = ""
                    confirmPasscode = ""
                    showError = false
                } else {
                    showError = true
                    errorMessage = newPasscode.count < 4 ? "密码至少4位" : "两次密码不一致"
                }
            }
        }
    }

    private var securityToggleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("启用安全锁", systemImage: "lock.fill")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $authManager.isAuthenticationEnabled)
                    .labelsHidden()
                    .onChange(of: authManager.isAuthenticationEnabled) { _, enabled in
                        if !enabled {
                            authManager.removeAuthentication()
                        }
                    }
            }

            Text("启用后，每次打开应用都需要验证身份")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .cardStyle()
    }

    private var verificationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("验证方式")
                .font(.headline)

            if biometricsAvailable {
                HStack {
                    Label(biometricType, systemImage: biometricIcon)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                }
            }

            Button(action: {
                showError = false
                errorMessage = ""
                showingPasscodeSetup = true
            }) {
                HStack {
                    Label("设置密码", systemImage: "key.fill")
                    Spacer()
                    Text(authManager.usePasscode ? "已设置" : "未设置")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(authManager.usePasscode ? AppTheme.accent : .secondary)
                }
                .font(.subheadline)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(AppTheme.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .scaleButton()
        }
        .padding(14)
        .cardStyle()
    }

    private var removePasscodeButton: some View {
        Button("移除密码", role: .destructive) {
            authManager.removePasscode()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(AppTheme.danger.opacity(0.16))
        .foregroundStyle(AppTheme.danger)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
    }

    private var biometricsAvailable: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    private var biometricType: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "生物识别"
        }
    }

    private var biometricIcon: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        switch context.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
    }
}

struct PasscodeSetupView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var newPasscode: String
    @Binding var confirmPasscode: String
    @Binding var showError: Bool
    @Binding var errorMessage: String
    let onSave: () -> Void

    @State private var step = 1

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerCard
                    inputCard
                    actionButton
                }
                .padding(.horizontal, AppTheme.paddingMedium)
                .padding(.vertical, 12)
            }
            .navigationTitle("设置密码")
            .navigationBarTitleDisplayMode(.inline)
            .appPageBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(AppTheme.secondary)

            Text(step == 1 ? "设置新密码" : "再次输入密码")
                .font(.title3.weight(.semibold))

            Text("密码至少 4 位")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .cardStyle()
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(step == 1 ? "输入密码" : "确认密码")
                .font(.headline)

            if step == 1 {
                SecureField("输入密码（至少4位）", text: $newPasscode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            } else {
                SecureField("再次输入密码", text: $confirmPasscode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(AppTheme.danger)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var actionButton: some View {
        Button(step == 1 ? "下一步" : "完成") {
            if step == 1 {
                if newPasscode.count >= 4 {
                    step = 2
                    showError = false
                } else {
                    showError = true
                    errorMessage = "密码至少4位"
                }
            } else {
                onSave()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: buttonEnabled ? [AppTheme.secondary, AppTheme.brand] : AppTheme.disabledGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .font(.headline)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        .disabled(!buttonEnabled)
        .scaleButton()
    }

    private var buttonEnabled: Bool {
        step == 1 ? newPasscode.count >= 4 : !confirmPasscode.isEmpty
    }
}

#Preview {
    NavigationStack {
        SecuritySettingsView()
    }
    .environmentObject(AuthenticationManager())
}
