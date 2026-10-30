import SwiftUI

struct LoginView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var otpPhoneNumber = ""
    @State private var otpDeviceId = ""
    @StateObject private var otpDataObject = OtpData()
    @State private var phoneNumber = ""
    @State private var pin = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var circlesFloating = false
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.error
    @State private var navigateToOtp = false
    @State private var navigateToSignUp = false
    @State private var showBiometricButton = false
    @State private var otpData: (phoneNumber: String, deviceId: String) = ("", "")
    @State private var showVersionUpdateAlert = false
    @State private var versionUpdateMessage = ""
//    @State private var navigateToForcePinChange = false
//    @State private var phoneNumberForPinChange = ""
//    @State private var pinChangeReason = ""
    struct ForcePinChangeData: Identifiable {
        let id = UUID()
        let phoneNumber: String
        let reason: String
    }
    @State private var forcePinChangeData: ForcePinChangeData?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private let apiClient = APIClient.shared
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .frame(height: min(280, geometry.size.width * 0.72))
                    formSection
                        .frame(maxWidth: 354)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, -26)
                    footerSection
                        .padding(.top, 34)
                        .padding(.bottom, 36)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(alignment: .top) {
                ZStack(alignment: .bottom) {
                    backgroundGradient
                    UnevenRoundedRectangle(topLeadingRadius: 36, topTrailingRadius: 36)
                        .fill(.white)
                        .frame(height: 44)
                }
                .frame(height: min(324, geometry.size.width * 0.83))
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .onAppear(perform: setupView)
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .alert(AppStrings.updateRequired, isPresented: $showVersionUpdateAlert) {
            Button(AppStrings.buttonTitle(AppStrings.update)) {
                openAppStore()
            }
            Button(AppStrings.buttonTitle(AppStrings.quit), role: .destructive) {
                exit(0)
            }
        } message: {
            Text(versionUpdateMessage)
        }
        .sheet(isPresented: $navigateToOtp, onDismiss: {
            otpDataObject.clear()
        }) {
            OtpVerificationView(
                phoneNumber: otpDataObject.phoneNumber,
                deviceId: otpDataObject.deviceId
            )
            .environmentObject(authManager)
            .environmentObject(otpDataObject)  // ✅ Pass the object too
        }
        .sheet(isPresented: $navigateToSignUp) {
            RegistrationFlowView()
        }
//        .fullScreenCover(isPresented: $navigateToForcePinChange) {
//            ForcePinChangeView(
//                phoneNumber: phoneNumberForPinChange,
//                reason: pinChangeReason
//            )
//            .environmentObject(authManager)
//        }
        .fullScreenCover(item: $forcePinChangeData) { data in
            ForcePinChangeView(
                phoneNumber: data.phoneNumber,
                reason: data.reason
            )
            .environmentObject(authManager)
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "1761AD"), Color(hex: "0085B5"), Color(hex: "174EA6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var headerSection: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(.white.opacity(0.10))
                    .frame(width: 170, height: 170)
                    .offset(x: circlesFloating ? 10 : -8, y: circlesFloating ? 12 : -10)
                    .position(x: 53, y: 102)
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 94, height: 94)
                    .offset(x: circlesFloating ? -10 : 8, y: circlesFloating ? -12 : 10)
                    .position(x: proxy.size.width - 31, y: proxy.size.height - 15)
                Image("BITSLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(18)
                    .frame(width: 84, height: 84)
                    .background(.white, in: RoundedRectangle(cornerRadius: 19))
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.45)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    circlesFloating = true
                }
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: 30) {
            titleSection
            inputFieldsSection
            actionButtonsSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 30)
        .background(LoginAppearance.containerBackground, in: RoundedRectangle(cornerRadius: 26))
        .shadow(color: .black.opacity(0.18), radius: 9, y: 6)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppStrings.value("loginWelcome"))
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(Color(hex: "20212B"))
            Text(AppStrings.value("loginSubtitle"))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inputFieldsSection: some View {
        VStack(spacing: 20) {
            // Phone number field
            LoginPhoneField(
                icon: "phone.fill",
                placeholder: AppStrings.phoneNumber,
                text: $phoneNumber.walletPhoneNumber(),
                keyboardType: .numberPad,
                disabled: isLoading
            )
            .onChange(of: phoneNumber) {
                if phoneNumber.count > 10 {
                    phoneNumber = String(phoneNumber.prefix(10))
                }
            }
            
            // PIN field
            LoginPINField(
                icon: "lock.fill",
                placeholder: AppStrings.value("loginPINLabel"),
                text: $pin,
                showPassword: $showPassword,
                disabled: isLoading
            )
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 30) {
            Button(action: showForgotPinAlert) {
                Text(AppStrings.buttonTitle(AppStrings.forgotPin))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "174EA6"))
            }
            .disabled(isLoading)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Button(action: performLogin) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView().tint(.white)
                    }
                    Text(isLoading ? AppStrings.loggingIn : AppStrings.value("loginSignIn"))
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(hex: "007FB3"), in: RoundedRectangle(cornerRadius: 13))
                .shadow(color: .black.opacity(0.16), radius: 2, y: 2)
            }
            .disabled(isLoading || phoneNumber.isEmpty || !pin.isValidWalletPIN)

            // Biometric button
            if showBiometricButton {
                BiometricButton(
                    disabled: isLoading,
                    action: performBiometricLogin
                )
                .transition(.scale.combined(with: .opacity))
            }
            

        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 18) {
            Text(AppStrings.versionValue(String(describing: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")))
                .font(.system(size: 10))
                .foregroundColor(Color.gray.opacity(0.7))
            HStack(spacing: 5) {
                Text(AppStrings.noAccount).foregroundColor(.secondary)
                Button(action: { navigateToSignUp = true }) {
                    Text(AppStrings.buttonTitle(AppStrings.signUp))
                        .foregroundColor(Color(hex: "0788B9"))
                }
                .disabled(isLoading)
            }
            .font(.system(size: 12))
        }
    }

    // MARK: - Computed Properties
    
    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .regular ? 40 : 20
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        apiClient.initialize(with: UserDataManager.shared)
        setupBiometricButton()
        
        NotificationCenter.default.addObserver(
            forName: .tokenExpired,
            object: nil,
            queue: .main
        ) { _ in
            handleTokenExpiration()
        }
    }
    
    private func setupBiometricButton() {
        let phoneNumber = UserDataManager.shared.getPhoneNumber()
        let biometricEnabled = UserDataManager.shared.isBiometricEnabled()
        let biometricAvailable = BiometricHelper.isBiometricAvailable()
        let hasCredentials = !phoneNumber.isEmpty &&
                            KeychainManager.shared.retrieve(for: "biometric_\(phoneNumber)") != nil
        
        let shouldShow = biometricEnabled && biometricAvailable && hasCredentials
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            self.showBiometricButton = shouldShow
            
            if !phoneNumber.isEmpty && self.phoneNumber.isEmpty {
                self.phoneNumber = phoneNumber
            }
        }
        
    }
    
    private func handleTokenExpiration() {
        showAlertMessage(AppStrings.loginAgain, title: AppStrings.sessionExpired)
        setupBiometricButton()
    }
    
    private func performLogin() {
        guard !phoneNumber.isEmpty && (pin.isValidWalletPIN) else {
            showAlertMessage(AppStrings.fillAllFields)
            return
        }
        
        setLoading(true)
        
        let capturedPhoneNumber = self.phoneNumber
        let capturedPin = self.pin
        
        let request = AuthRequest(phoneNumber: capturedPhoneNumber, pin: capturedPin, deviceId: APIClient.getDeviceId())
        
        apiClient.login(request: request) { result in
            DispatchQueue.main.async {
                self.setLoading(false)
                
                self.handleLoginResponse(result, pin: capturedPin, phoneNumber: capturedPhoneNumber)
            }
        }
    }
    private func performBiometricLogin() {
 
        let phoneNumber = UserDataManager.shared.getPhoneNumber()
        guard !phoneNumber.isEmpty else {
            showAlertMessage(AppStrings.loginWithPin, title: AppStrings.sessionExpired)
            return
        }
        
        guard let savedPin = KeychainManager.shared.retrieve(for: "biometric_\(phoneNumber)") else {
            showAlertMessage(AppStrings.biometricCredentialsNotFoundPleaseLoginWithYourPin, title: AppStrings.error)
            UserDataManager.shared.setUseBiometric(false)
            setupBiometricButton()
            return
        }
        
        guard BiometricHelper.isBiometricAvailable() else {
            let status = BiometricHelper.getBiometricStatus()
            showAlertMessage(status.message, title: AppStrings.biometricUnavailable)
            return
        }
        
        BiometricHelper.authenticateWithCustomPrompt { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                  
                    self.setLoading(true)
                
                    let capturedPhoneNumber = phoneNumber
                    
                    let request = AuthRequest(phoneNumber: capturedPhoneNumber, pin: savedPin, deviceId: APIClient.getDeviceId())
                    
                    self.apiClient.login(request: request) { loginResult in
                        DispatchQueue.main.async {
                            self.setLoading(false)
                            self.handleLoginResponse(loginResult, pin: savedPin, phoneNumber: capturedPhoneNumber)
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Biometric authentication failed: \(error.localizedDescription)")
                    
                    if case .userCancel = error {
                        return
                    }
                    
                    self.showAlertMessage(error.localizedDescription, title: AppStrings.authenticationFailed)
                }
            }
        }
    }
    
    private func handleLoginResponse(_ result: Result<AuthResponse, Error>, pin: String, phoneNumber: String) {
        switch result {
            
        case .success(let authResponse):
            // Success case - user logged in successfully
            print("✅ SUCCESS")
            print("🔵 respCode:", authResponse.respCode ?? "nil")

                print("🔵 success:", authResponse.success ?? false)
                print("🔵 message:", authResponse.message ?? "nil")
                print("🔵 requiresPinChange:", authResponse.requiresPinChange ?? false)

                print("➡️ Going to handleAuthResponse")
            
            handleAuthResponse(authResponse, pin: pin)
            
        case .failure(let error):
            if let apiError = error as? APIError {
                let message = apiError.message ?? ""
                
                print("""
                
                ==================== 🟣 apiError  ====================
                \(apiError)
                ==================================================================
                
                """)
                // ============================================================
                // CHECK 1: Rate Limiting (HIGHEST PRIORITY)
                // ============================================================
                if message.contains("Too many") || message.contains("try again later") {
                    showAlertMessage(AppStrings.tropDeTentativesVeuillezReessayerDansQuelquesMinutes, title: AppStrings.limiteAtteinte)
                    return
                }
                
                // ============================================================
                // CHECK 2: OTP VERIFICATION REQUIRED (MOST COMMON)
                // ============================================================
//                if (apiError.respCode == "403" || apiError.respCode == "831") &&
                if apiError.respCode == "831" {
                    
                    let deviceId = APIClient.getDeviceId()
                    
                    self.otpDataObject.set(phoneNumber: phoneNumber, deviceId: deviceId)
                    
                    self.navigateToOtp = true
                    return
                }
                // ============================================================
                // CHECK 3: Version Update Required
                // ============================================================
                if apiError.respCode == "403" &&
                   apiError.details == "VERSION_UPDATE_REQUIRED" &&
                   !message.contains("OTP") {
                    
                    let updateMessage = AppStrings.uneNouvelleVersionDeLApplicationEstDisponibleVeuillezMettre
                    showVersionUpdateAlert(message: updateMessage)
                    return
                }
                
                // ============================================================
                // CHECK 6:ACCOUNT BLOKED
                // ============================================================
                if apiError.respCode == "805"
                   {
                    showAlertMessage(AppStrings.votreCompteEstBloqueVeuillezContacterLeServiceClient,title: AppStrings.compteBloque)
                    return
                }
                

                // ============================================================
                // CHECK 4: PIN Change Required
                // ============================================================

                
//                    self.phoneNumberForPinChange = phoneNumber
//
//                    // Change title depending on the response code
//                    if apiError.respCode == "FIRST_CONNECTION" {
//                        self.alertTitle = "Premier accès"
//                    self.alertMessage = message
//                    self.showAlert = true
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                        self.pinChangeReason = "FIRST_CONNECTION"
//                        self.navigateToForcePinChange = true
//                    }
//                        return
//                    }
                    
                if apiError.respCode == "FIRST_CONNECTION" {

                    print("🟢 FIRST_CONNECTION detected")
                    print("🟢 phoneNumber =", phoneNumber)
                    print("🟢 reason = FIRST_CONNECTION")

                    self.alertTitle = AppStrings.premierAcces
                    self.alertMessage = message
                    self.showAlert = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.forcePinChangeData = ForcePinChangeData(
                            phoneNumber: phoneNumber,
                            reason: "FIRST_CONNECTION"
                        )

                        print("🟢 Opening ForcePinChangeView")
                        print("🟢 reason sent = FIRST_CONNECTION")
                    }

                    return
                }
        // pin expired 
                
                if apiError.respCode == "PIN_EXPIRED" ||
                    apiError.respCode == "PIN_CHANGE_REQUIRED" {

                    print("🔵 PIN change required")
                    print("🔵 reason = PIN_EXPIRED")

                    alertTitle = AppStrings.codePinExpire
                    alertMessage = apiError.message ??
                        AppStrings.votreCodePinAExpireVousDevezLeModifierPour2

                    showAlert = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.forcePinChangeData = ForcePinChangeData(
                            phoneNumber: phoneNumber,
                            reason: "PIN_EXPIRED"
                        )
                    }

                    return
            }
                // ============================================================
                // CHECK 5: Account Locked
                // ============================================================
                if message.lowercased().contains("locked") ||
                   message.lowercased().contains("bloqué") {
                    showAlertMessage(AppStrings.votreCompteEstBloqueVeuillezContacterLeServiceClient, title: AppStrings.compteBloque)
                    return
                }
                
                // ============================================================
                // CHECK 6: Invalid Credentials
                // ============================================================
                if message.contains("Invalid credentials") ||
                   message.contains("Incorrect") ||
                   message.contains("incorrect") {
                    showAlertMessage(AppStrings.numeroDeTelephoneOuPinIncorrect, title: AppStrings.erreurDeConnexion)
                    return
                }
                
                // ============================================================
                // CHECK 7: Account Not Found
                // ============================================================
                if message.contains("not found") ||
                   message.contains("introuvable") {
                    showAlertMessage(AppStrings.compteIntrouvableVeuillezVerifierVotreNumeroDeTelephone, title: AppStrings.compteIntrouvable)
                    return
                }
                
                // ============================================================
                // CHECK 8: Generic API Error (DEFAULT)
                // ============================================================
                showAlertMessage(apiError.message ?? AppStrings.uneErreurEstSurvenue, title: AppStrings.error)
                
            } else {
                // ============================================================
                // Network Error (not API error)
                // ============================================================
                let errorMessage = AppStrings.erreurDeConnexionValue(String(describing: error.localizedDescription))
                showAlertMessage(errorMessage, title: AppStrings.erreurReseau)
            }
        }
    }
  
    private func handleAuthResponse(_ authResponse: AuthResponse, pin: String) {
        if let requiresPinChange = authResponse.requiresPinChange, requiresPinChange {
            if authResponse.respCode == "PIN_EXPIRED" ||
               authResponse.respCode == "PIN_CHANGE_REQUIRED" {
                print("🔵2 respCode:", authResponse.respCode ?? "nil")
                if let requiresPinChange = authResponse.requiresPinChange, requiresPinChange {

                    if authResponse.respCode == "PIN_EXPIRED" ||
                       authResponse.respCode == "PIN_CHANGE_REQUIRED" {

                        print("🔵 PIN change required")
                        print("🔵 reason = PIN_EXPIRED")

                        alertTitle = AppStrings.codePinExpire
                        alertMessage = authResponse.message ??
                            AppStrings.votreCodePinAExpireVousDevezLeModifierPour2

                        showAlert = true

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.forcePinChangeData = ForcePinChangeData(
                                phoneNumber: phoneNumber,
                                reason: "PIN_EXPIRED"
                            )
                        }

                        return
                    }
                }
//                phoneNumberForPinChange = phoneNumber
//                self.pinChangeReason = "PIN_EXPIRED"
//                alertTitle = "Code PIN Expiré"
//                alertMessage = authResponse.message ?? "Votre code PIN a expiré. Vous devez le modifier pour continuer."
//                showAlert = true
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    navigateToForcePinChange = true
//                }
//                return
            }
        }
        
        guard let success = authResponse.success, success else {
            handleLoginFailure(authResponse)
            return
        }
        
        handleLoginSuccess(authResponse, pin: pin)
    }
    
    private func handleLoginFailure(_ authResponse: AuthResponse) {
        let respCode = authResponse.respCode
        let message = authResponse.message
        print("🔵1 respCode:", authResponse.respCode ?? "nil")

        if respCode == "831" || respCode == "OTP_REQUIRED" || message == "OTP verification required" {
            let deviceId = APIClient.getDeviceId()
            otpDataObject.set(phoneNumber: phoneNumber, deviceId: deviceId)
            navigateToOtp = true
            return
        }
        
        let errorMessage = message ?? AppStrings.loginFailed
        showAlertMessage(errorMessage, title: AppStrings.loginFailed2)
    }
    
    private func handleLoginSuccess(_ authResponse: AuthResponse, pin: String) {
        
        guard let token = authResponse.token?.trimmingCharacters(in: .whitespacesAndNewlines),
              !token.isEmpty else {
        
            showAlertMessage(AppStrings.loginErrorNoAuthenticationTokenReceived, title: AppStrings.loginError)
            return
        }
        
        UserDataManager.shared.savePinForAPI(pin)
        UserDataManager.shared.saveUserData(from: authResponse)
        
        let savedToken = UserDataManager.shared.getToken()
        
        if savedToken.isEmpty {
            showAlertMessage(AppStrings.loginErrorCouldNotSaveAuthenticationData, title: AppStrings.loginError)
            return
        }
        
        apiClient.updateToken(token)
        
        if BiometricHelper.isBiometricAvailable() {
            _ = UserDataManager.shared.saveBiometricCredentials(pin: pin)
        }
        
        DispatchQueue.main.async {
            authManager.login()
        }
        
        if BiometricHelper.shouldPromptForBiometricSetup() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                promptForBiometricSetup()
            }
        }
    }
    
    private func promptForBiometricSetup() {
        let biometricType = BiometricHelper.getBiometricTypeString()
        
        let alert = UIAlertController(
            title: AppStrings.activerValue2(String(describing: biometricType)),
            message: AppStrings.voulezVousUtiliserValuePourUnAccesPlusRapideEt(String(describing: biometricType)),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: AppStrings.activer, style: .default) { _ in
            BiometricHelper.markBiometricSetupPrompted()
            UserDataManager.shared.setUseBiometric(true)
        })
        
        alert.addAction(UIAlertAction(title: AppStrings.pasMaintenant, style: .cancel) { _ in
            BiometricHelper.markBiometricSetupPrompted()
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setLoading(_ loading: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLoading = loading
        }
    }
    
    private func showAlertMessage(_ message: String, title: String = AppStrings.error) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func showForgotPinAlert() {
        alertTitle = AppStrings.forgotPinTitle
        alertMessage = AppStrings.forgotPinHelp
        showAlert = true
    }
    
    private func showVersionUpdateAlert(message: String) {
        versionUpdateMessage = message
        showVersionUpdateAlert = true
    }
    
    private func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/us/app/diamacash/id6754772255") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "https://apps.apple.com/us/app/diamacash/id6754772255") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Custom Components

private enum LoginAppearance {
    static let containerBackground = Color.white
}

private struct LoginPhoneField: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var disabled: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "248DD0"))
                .frame(width: 22)

            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .keyboardType(keyboardType)
                .disabled(disabled)
                .autocapitalization(.none)
        }
        .padding(.horizontal, 12)
        .frame(height: 49)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LoginAppearance.containerBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.gray.opacity(0.28), lineWidth: 1.5)
        )
        .overlay(alignment: .topLeading) {
            Text(placeholder)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(LoginAppearance.containerBackground)
                .offset(x: 10, y: -9)
        }
    }
}

private struct LoginPINField: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    var disabled: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "248DD0"))
                .frame(width: 22)

            if showPassword {
                WalletPINField(placeholder, text: $text, isSecure: false)
                    .font(.system(size: 14))
                    .keyboardType(.numberPad)
                    .disabled(disabled)
                    .onChange(of: text) { newValue in
                        if newValue.count > 4 { text = String(newValue.prefix(4)) }
                    }
            } else {
                WalletPINField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .keyboardType(.numberPad)
                    .disabled(disabled)
                    .onChange(of: text) { newValue in
                        if newValue.count > 4 { text = String(newValue.prefix(4)) }
                    }
            }


            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.75))
            }
            .disabled(disabled)
        }
        .padding(.horizontal, 12)
        .frame(height: 49)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LoginAppearance.containerBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color(hex: "248DD0"), lineWidth: 1.6)
        )
        .overlay(alignment: .topLeading) {
            Text(placeholder)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "248DD0"))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(LoginAppearance.containerBackground)
                .offset(x: 10, y: -9)
        }
    }
}


struct CustomTextField1: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var disabled: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 21, weight: .medium))
                .foregroundColor(Color(hex: "174EA6"))
                .frame(width: 28)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 18))
                .keyboardType(keyboardType)
                .disabled(disabled)
                .autocapitalization(.none)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.white))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray.opacity(0.8), lineWidth: 1.2)
        )
    }
}

struct CustomSecureField: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    var disabled: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 21, weight: .medium))
                .foregroundColor(Color(hex: "174EA6"))
                .frame(width: 28)
            
            if showPassword {
                WalletPINField(placeholder, text: $text, isSecure: false)
                    .font(.system(size: 18))
                    .keyboardType(.numberPad)
                    .disabled(disabled)
                    .onChange(of: text) { newValue in
                        if newValue.count > 4 { text = String(newValue.prefix(4)) }
                    }
            } else {
                WalletPINField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .keyboardType(.numberPad)
                    .disabled(disabled)
                    .onChange(of: text) { newValue in
                        if newValue.count > 4 { text = String(newValue.prefix(4)) }
                    }
            }
            
            
            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.75))
            }
            .disabled(disabled)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.white))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray.opacity(0.8), lineWidth: 1.2)
        )
    }
}

struct PrimaryButton: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    var isLoading: Bool = false
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }
                
                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 19)
            .background(
                    RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "0788B9"))
            )
            .shadow(
                color: disabled ? .clear : Color(hex: "0788B9").opacity(0.25),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(disabled)
        .animation(.easeInOut(duration: 0.2), value: disabled)
    }
}

struct BiometricButton: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: BiometricHelper.getBiometricType() == .faceID ? "faceid" : "touchid")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color(hex: "0788B9"))
                        .shadow(color: Color(hex: "0788B9").opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1.0)
    }
}
#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
