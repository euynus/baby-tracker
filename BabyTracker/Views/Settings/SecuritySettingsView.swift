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
        Form {
            Section {
                Toggle("启用安全锁", isOn: $authManager.isAuthenticationEnabled)
            } header: {
                Text("安全选项")
            } footer: {
                Text("启用后，每次打开应用需要验证身份")
            }
            
            if authManager.isAuthenticationEnabled {
                Section("验证方式") {
                    if biometricsAvailable {
                        HStack {
                            Label(biometricType, systemImage: biometricIcon)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Button(action: { showingPasscodeSetup = true }) {
                        HStack {
                            Label("设置密码", systemImage: "key.fill")
                            Spacer()
                            if authManager.usePasscode {
                                Text("已设置")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                
                if authManager.usePasscode {
                    Section {
                        Button("移除密码", role: .destructive) {
                            authManager.usePasscode = false
                        }
                    }
                }
            }
        }
        .navigationTitle("安全设置")
        .navigationBarTitleDisplayMode(.inline)
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
                } else {
                    showError = true
                    errorMessage = newPasscode.count < 4 ? "密码至少4位" : "两次密码不一致"
                }
            }
        }
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
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "lock.circle")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                
                Text(step == 1 ? "设置密码" : "确认密码")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if step == 1 {
                    SecureField("输入密码（至少4位）", text: $newPasscode)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 40)
                } else {
                    SecureField("再次输入密码", text: $confirmPasscode)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 40)
                }
                
                if showError {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                if step == 1 {
                    Button("下一步") {
                        if newPasscode.count >= 4 {
                            step = 2
                            showError = false
                        } else {
                            showError = true
                            errorMessage = "密码至少4位"
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newPasscode.count < 4)
                } else {
                    Button("完成") {
                        onSave()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(confirmPasscode.isEmpty)
                }
                
                Spacer()
            }
            .navigationTitle("设置密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SecuritySettingsView()
    }
    .environmentObject(AuthenticationManager())
}
