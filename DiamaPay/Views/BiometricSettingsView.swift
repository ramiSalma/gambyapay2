//
//  BiometricSettingsView.swift
//  DiamaPay
//
//  Created by Bits on 2/10/2025.
//


import SwiftUI

struct BiometricSettingsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    
    @Environment(\.presentationMode) var presentationMode
    @State private var biometricEnabled: Bool
    @State private var showPINPrompt = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isProcessing = false
    
    private let userDataManager = UserDataManager.shared
    
    init() {
        _biometricEnabled = State(initialValue: UserDataManager.shared.isBiometricEnabled())
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.biometricAuthentication, headerColor: Color(hex: "174EA6"))

                
                ScrollView {
                    VStack(spacing: 20) {
                        // Biometric Info Card
                        biometricInfoCard
                        
                        // Toggle Card
                        biometricToggleCard
                        
                        // Instructions Card
                        instructionsCard
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPINPrompt) {
            PINPromptView { pin in
                enableBiometric(with: pin)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .overlay(
            Group {
                if isProcessing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        )
    }

    private let blue = Color(hex: "174EA6")
    private let cyan = Color(hex: "087FB3")

    private var biometricInfoCard: some View {
        VStack(spacing: 20) {
            Image(systemName: BiometricHelper.getBiometricType().icon)
                .font(.system(size: 42)).foregroundColor(blue)
            Text(BiometricHelper.isBiometricAvailable() ? AppStrings.value("biometryAvailable") : AppStrings.biometricUnavailable)
                .font(.system(size: 21, weight: .bold)).foregroundColor(blue)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }

    private var biometricToggleCard: some View {
        VStack(alignment: .leading, spacing: 26) {
            HStack(spacing: 14) {
                Image(systemName: "shield.fill").font(.system(size: 24)).foregroundColor(blue)
                Text(AppStrings.value("enableBiometricLogin"))
                    .font(.system(size: 17, weight: .bold)).foregroundColor(.black)
                Spacer(minLength: 0)
                Toggle(AppStrings.value("enableBiometricLogin"), isOn: $biometricEnabled)
                    .labelsHidden().tint(blue)
                    .onChange(of: biometricEnabled) { handleToggleChange(biometricEnabled) }
                    .disabled(!BiometricHelper.isBiometricAvailable() || isProcessing)
            }
            Text(AppStrings.value("biometricLoginDescription"))
                .font(.system(size: 14)).foregroundColor(.gray)
            if !BiometricHelper.isBiometricAvailable() {
                Text(BiometricHelper.getBiometricStatus().message)
                    .font(.footnote).foregroundColor(.orange)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(blue, lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 2, y: 2)
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(AppStrings.importantInformation, systemImage: "info.circle.fill")
                .font(.system(size: 16, weight: .bold)).foregroundColor(cyan)
            ForEach(["biometricSensors", "biometricPrivacy", "biometricFallback", "biometricSharedDevice"], id: \.self) { key in
                HStack(alignment: .top, spacing: 12) {
                    Circle().fill(cyan).frame(width: 6, height: 6).padding(.top, 6)
                    Text(AppStrings.value(key)).font(.system(size: 13))
                        .foregroundColor(Color(hex: "475467"))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(cyan, lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 2, y: 2)
    }

    // MARK: - Computed Properties
    private var biometricStatusText: String {
        if BiometricHelper.isBiometricAvailable() {
            return biometricEnabled ? 
                AppStrings.laConnexionBiometriqueEstActiveePourUneConnexionRapideEt :
                AppStrings.activezLaConnexionBiometriquePourUneAuthentificationPlusRapide
        } else {
            return BiometricHelper.getBiometricStatus().message
        }
    }
    
    // MARK: - Actions
    private func handleToggleChange(_ newValue: Bool) {
        if newValue {
            // Enabling - show PIN prompt
            showPINPrompt = true
        } else {
            // Disabling - just disable
            disableBiometric()
        }
    }
    
    private func enableBiometric(with pin: String) {
        isProcessing = true
        
        // Verify PIN is correct by attempting authentication
        BiometricHelper.authenticateWithCustomPrompt(
            reason: AppStrings.confirmerPourActiverValue(String(describing: BiometricHelper.getBiometricTypeString()))
        ) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                switch result {
                case .success:
                    // Save PIN in Keychain
                    if self.userDataManager.saveBiometricCredentials(pin: pin) {
                        self.userDataManager.setUseBiometric(true)
                        self.alertTitle = AppStrings.succes
                        self.alertMessage = AppStrings.valueActiveAvecSucces(String(describing: BiometricHelper.getBiometricTypeString()))
                        self.showAlert = true
                        
                        //print("✅ Biometric login enabled successfully")
                    } else {
                        self.biometricEnabled = false
                        self.alertTitle = AppStrings.error
                        self.alertMessage = AppStrings.impossibleDActiverValue(String(describing: BiometricHelper.getBiometricTypeString()))
                        self.showAlert = true
                        
                        //print("❌ Failed to save biometric credentials")
                    }
                    
                case .failure(let error):
                    self.biometricEnabled = false
                    
                    // Don't show error for user cancellation
                    if case .userCancel = error {
                        return
                    }
                    
                    self.alertTitle = AppStrings.error
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    
                    //print("❌ Biometric authentication failed: \(error)")
                }
            }
        }
    }
    
    private func disableBiometric() {
        userDataManager.setUseBiometric(false)
        
        alertTitle = AppStrings.desactive
        alertMessage = AppStrings.valueDesactive(String(describing: BiometricHelper.getBiometricTypeString()))
        showAlert = true
        
        //print("ℹ️ Biometric login disabled")
    }
}

// MARK: - Instruction Row
struct InstructionRow: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color(hex: "174EA6"))
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PINPromptView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var pin = ""
    @State private var showPassword = false
    @State private var isVerifying = false
    @State private var errorMessage = ""
    let onPINEntered: (String) -> Void
    
    private let userDataManager = UserDataManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Image(systemName: BiometricHelper.getBiometricType().icon)
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "174EA6"))
                    
                    Text(AppStrings.activerValue(String(describing: BiometricHelper.getBiometricTypeString())))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(AppStrings.entrezVotrePinPourConfirmer)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(hex: "174EA6"))
                            .frame(width: 20)
                        
                        if showPassword {
                            WalletPINField(AppStrings.pin, text: $pin, isSecure: false)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .medium))
                        } else {
                            WalletPINField(AppStrings.pin, text: $pin)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(errorMessage.isEmpty ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
                    .onChange(of: pin) { newValue in
                        if newValue.count > 4 { pin = String(newValue.prefix(4)) }
                        errorMessage = ""
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(AppStrings.option(errorMessage))
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: verifyPin) {
                        if isVerifying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(AppStrings.buttonTitle(AppStrings.confirmer))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(pin.isValidWalletPIN ? Color(hex: "174EA6") : Color.gray)
                    .cornerRadius(8)
                    .disabled(!pin.isValidWalletPIN || isVerifying)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarItems(
                leading: Button(AppStrings.buttonTitle(AppStrings.annuler)) { presentationMode.wrappedValue.dismiss() }
                    .foregroundColor(Color(hex: "174EA6"))
            )
        }
    }
   
    private func verifyPin() {
        errorMessage = ""
        
        guard pin.isValidWalletPIN else {
            errorMessage = AppStrings.lePinDoitContenirExactement4Chiffres
            return
        }
        
        isVerifying = true
        
        PinVerificationService.verify(pin: pin) { verifiedPin in
            isVerifying = false
            onPINEntered(verifiedPin)
            presentationMode.wrappedValue.dismiss()
        } onFailure: { message in
            isVerifying = false
            errorMessage = message
            pin = ""
        }
    }
    
}

#Preview {
    BiometricSettingsView()
}
