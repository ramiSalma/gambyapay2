import SwiftUI

struct ForcePinChangeView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    // MARK: - State Variables
    @State private var currentPin: String = ""
    @State private var newPin: String = ""
    @State private var confirmPin: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = AppStrings.error
    @State private var alertMessage: String = ""
    
    @State private var showCurrentPinError: Bool = false
    @State private var currentPinError: String = ""
    @State private var showNewPinError: Bool = false
    @State private var newPinError: String = ""
    @State private var showConfirmPinError: Bool = false
    @State private var confirmPinError: String = ""
    
    @State private var showConfirmationDialog: Bool = false
    @State private var pinChangeSuccess: Bool = false
    @State private var navigateToLogin: Bool = false
    
    // Parameters
    let phoneNumber: String
    let reason: String
    private let userDataManager = UserDataManager.shared
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                            .scaleEffect(1.5)
                        
                        Text(AppStrings.traitementEnCours)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Warning Card
                            warningCard
                            // PIN Change Form
                            pinChangeFormCard
                            securityTipsCard

                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        } .onAppear {
            print("🔵 ForcePinChangeView phone = '\(phoneNumber)'")
            print("🔵 ForcePinChangeView reason = '\(reason)'")
        }
        .navigationBarHidden(true)
        .alert(alertTitle, isPresented: $showAlert) {
            if pinChangeSuccess {
                Button(AppStrings.buttonTitle(AppStrings.ok)) {
                    // Delay before navigating to login
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigateToLogin = true
                    }
                }
            } else {
                Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
            }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            LoginView()
                .environmentObject(authManager)
        }
        .overlay(confirmationDialogOverlay)
        .interactiveDismissDisabled(true)  // Always disabled - this is FORCED change
    }
    
    private var headerView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blueH],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            
            HStack {
               
                
//                Text("Pin expiré")
                Text(reason == "FIRST_CONNECTION" ? AppStrings.premierAcces : AppStrings.pinExpire)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                
             }
        }
        .frame(height: 60)
        
    }
    
    // MARK: - Warning Card

    private var warningCard: some View {

        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.changementObligatoire)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
//                Text("Votre code PIN a expiré. Vous devez le modifier pour continuer à utiliser l'application.")
                Text(
                    reason == "FIRST_CONNECTION"
                    ? AppStrings.bienvenueVousDevezCreerVotreCodePinPourVotrePremier
                    : AppStrings.votreCodePinAExpireVousDevezLeModifierPour
                )
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - PIN Change Form Card
    private var pinChangeFormCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.modifierVotreCodePin)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.blueH)
                
                Rectangle()
                    .fill(Color.blueH)
                    .frame(width: 60, height: 2)
            }
            
            // Current PIN
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.codePinActuel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blueH)
                
                WalletPINField("****", text: $currentPin)
                    .keyboardType(.numberPad)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .onChange(of: currentPin) {
                        if currentPin.count > 4 {
                            currentPin = String(currentPin.prefix(4))
                        }
                        if showCurrentPinError {
                            showCurrentPinError = false
                        }
                    }
                
                if showCurrentPinError {
                    Text(currentPinError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // New PIN
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.nouveauCodePin)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blueH)
                
                WalletPINField("****", text: $newPin)
                    .keyboardType(.numberPad)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .onChange(of: newPin) {
                        if newPin.count > 4 {
                            newPin = String(newPin.prefix(4))
                        }
                        if showNewPinError {
                            showNewPinError = false
                        }
                    }
                
                if showNewPinError {
                    Text(newPinError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                } else if newPin.isValidWalletPIN && isWeakPin(newPin) {
                    Text(AppStrings.cePinNEstPasSecuriseVeuillezEnChoisirUn)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // Confirm PIN
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.confirmerLeNouveauPin)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blueH)
                
                WalletPINField("****", text: $confirmPin)
                    .keyboardType(.numberPad)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .onChange(of: confirmPin) {
                        if confirmPin.count > 4 {
                            confirmPin = String(confirmPin.prefix(4))
                        }
                        if showConfirmPinError {
                            showConfirmPinError = false
                        }
                    }
                
                if showConfirmPinError {
                    Text(confirmPinError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // Change PIN Button
            Button(action: {
                showChangePinConfirmationDialog()
            }) {
                Text(AppStrings.buttonTitle(AppStrings.changerLePin))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.blueH)
                    .cornerRadius(8)
            }
            .disabled(isLoading || !isFormValid())
            .opacity(isLoading || !isFormValid() ? 0.5 : 1.0)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Confirmation Dialog Overlay
    private var confirmationDialogOverlay: some View {
        Group {
            if showConfirmationDialog {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showConfirmationDialog = false
                        }
                    
                    VStack(spacing: 20) {
                        // Title
                        Text(AppStrings.confirmationDeChangementDePin)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        // Message
                        Text(AppStrings.confirmezVousLeChangementDeVotreCodePinCetteAction)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        // Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                showConfirmationDialog = false
                            }) {
                                Text(AppStrings.buttonTitle(AppStrings.annuler))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blueH)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.blueH.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                showConfirmationDialog = false
                                changePin()
                            }) {
                                Text(AppStrings.buttonTitle(AppStrings.changerLePin))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.blueH)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 20)
                    .padding(.horizontal, 32)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func isFormValid() -> Bool {
        return !currentPin.isEmpty &&
               !newPin.isEmpty &&
               !confirmPin.isEmpty &&
               currentPin.isValidWalletPIN &&
               newPin.isValidWalletPIN &&
               confirmPin.isValidWalletPIN &&
               !isWeakPin(newPin)
    }
    
    /// Rejects trivial PINs: repeated digits (0000, 1111), sequences (1234, 4321), and common weak codes.
    private func isWeakPin(_ pin: String) -> Bool {
        guard pin.isValidWalletPIN else { return false }
        
        let weakPins: Set<String> = [
            "0000", "1111", "2222", "3333", "4444",
            "5555", "6666", "7777", "8888", "9999",
            "0123", "1234", "2345", "3456", "4567", "5678", "6789",
            "9876", "8765", "7654", "6543", "5432", "4321", "3210",
            "1122", "1212", "1000", "2000", "2580",
            "000000", "111111", "123456", "654321", "012345"
        ]
        
        if weakPins.contains(pin) { return true }
        
        // All identical digits
        if Set(pin).count == 1 { return true }
        
        // Strictly ascending or descending by 1
        let digits = pin.compactMap { Int(String($0)) }
        let isAscending = zip(digits, digits.dropFirst()).allSatisfy { $1 == $0 + 1 }
        let isDescending = zip(digits, digits.dropFirst()).allSatisfy { $1 == $0 - 1 }
        return isAscending || isDescending
    }
    
    private func validateFields() -> Bool {
        var isValid = true
        
        // Clear previous errors
        showCurrentPinError = false
        showNewPinError = false
        showConfirmPinError = false
        
        // Validate current PIN
        if currentPin.isEmpty {
            currentPinError = AppStrings.leCodePinActuelEstRequis
            showCurrentPinError = true
            isValid = false
        } else if !currentPin.isValidWalletPIN {
            currentPinError = AppStrings.lePinDoitContenirExactement4Chiffres
            showCurrentPinError = true
            isValid = false
        }
        
        // Validate new PIN
        if newPin.isEmpty {
            newPinError = AppStrings.leNouveauCodePinEstRequis
            showNewPinError = true
            isValid = false
        } else if !newPin.isValidWalletPIN {
            newPinError = AppStrings.lePinDoitContenirExactement4Chiffres
            showNewPinError = true
            isValid = false
        } else if newPin == currentPin {
            newPinError = AppStrings.leNouveauPinDoitEtreDifferentDeLAncien
            showNewPinError = true
            isValid = false
        } else if isWeakPin(newPin) {
            newPinError = AppStrings.ceCodePinNEstPasSecuriseEx00001111
            showNewPinError = true
            isValid = false
        }
        
        // Validate confirm PIN
        if confirmPin.isEmpty {
            confirmPinError = AppStrings.laConfirmationDuCodePinEstRequise
            showConfirmPinError = true
            isValid = false
        } else if confirmPin != newPin {
            confirmPinError = AppStrings.lesCodesPinNeCorrespondentPas
            showConfirmPinError = true
            isValid = false
        }
        
        return isValid
    }
    
    private func showChangePinConfirmationDialog() {
        guard validateFields() else {
            return
        }
        
        showConfirmationDialog = true
    }
    
    private func changePin() {
        //print("🔄 Starting PIN change process")
        
        // ✅ Get saved wallet data from previous login
        let savedWalletNumber = userDataManager.getWalletNumber()
        let savedBankCode = userDataManager.getBankCode()
        

//        if savedWalletNumber.isEmpty {
//            //print("❌ No wallet number in storage - cannot change PIN")
//            alertTitle = "Erreur"
//            alertMessage = "Veuillez utiliser un appareil sur lequel vous vous connectez habituellement ou contacter le support."
//            showAlert = true
//            return
//        }
        
        isLoading = true
        
        // Create request with saved wallet number
        var request = RequestChangePin()
        request.phoneNumber = phoneNumber  // ✅ Use saved wallet number
        request.oldPinCode = currentPin
        request.newPinCode = newPin
        request.confPinCode = confirmPin
        request.bank = savedBankCode.isEmpty ? "00100" : savedBankCode  // ✅ Use saved bank code
        
        // Generate requestId
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        // Generate requestDate
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        
        //print("📤 PIN change request:")
        //print("  Wallet Number: \(request.walletNumber ?? "N/A")")
        //print("  Bank Code: \(request.bank ?? "N/A")")
        print("🔵 ForcePinChangeView request = '\(request)'")

        APIClient.shared.changePin(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                self.handlePinChangeResponse(result)
            }
        }
    }
    
    private func handlePinChangeResponse(_ result: Result<ResponseService, Error>) {
        switch result {
        case .success(let response):
            //print("✅ PIN change response received")
            //print("  RespCode: \(response.respCode ?? "N/A")")
            //print("  Message: \(response.message ?? "N/A")")
            
            if response.respCode == "000" {
                //print("✅ PIN change successful")
                handlePinChangeSuccess()
            } else {
                //print("❌ PIN change failed: \(response.message ?? "Unknown error")")
                handlePinChangeError(message: response.message)
            }
            
        case .failure(let error):
            //print("❌ PIN change request failed: \(error)")
            
            if let apiError = error as? APIError {
                handlePinChangeError(message: apiError.message)
            } else {
                handlePinChangeError(message: AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
            }
        }
    }
    
    private func handlePinChangeSuccess() {
        // Update PIN in UserDataManager
        userDataManager.savePinForAPI(newPin)
        //print("💾 New PIN saved to UserDataManager")
        
        // Clear fields
        clearAllFields()
        
        // Show success message
        pinChangeSuccess = true
        alertTitle = AppStrings.codePinModifie
        alertMessage = AppStrings.votreCodePinAEteModifieAvecSuccesUtilisezCe
        showAlert = true
    }
    
    private func handlePinChangeError(message: String?) {
        let errorMessage = message ?? AppStrings.erreurLorsDuChangementDePin
        
        if let msg = message?.lowercased() {
            if msg.contains("invalid") || msg.contains("incorrect") || msg.contains("actuel") {
                currentPinError = AppStrings.codePinActuelIncorrect
                showCurrentPinError = true
                return
            }
        }
        
        alertTitle = AppStrings.error
        alertMessage = errorMessage
        showAlert = true
    }
    
    private func clearAllFields() {
        currentPin = ""
        newPin = ""
        confirmPin = ""
    }
}

// MARK: - Conseils de sécurité

private var securityTipsCard: some View {
    VStack(alignment: .leading, spacing: 20) {
        
        // Header
        HStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.orange)
            
            Text(AppStrings.conseilsDeSecurite)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.brown)
        }
        
        Divider()
        
        // Tips
        VStack(alignment: .leading, spacing: 20) {
            
            securityTip(AppStrings.choisissezUnCodePinUniqueEtDifficileADeviner)
            
            securityTip(AppStrings.nePartagezJamaisVotreCodePinAvecPersonne)
            
            securityTip(AppStrings.votreCodePinExpireTousLes90JoursPourVotre)
            
            securityTip(AppStrings.evitezLesCodesSimplesComme1234Ou0000)
        }
    }
    .padding(24)
    .background(
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 4
            )
    )
}

// MARK: - Security Tip

private func securityTip(_ text: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
        Circle()
            .fill(Color.orange)
            .frame(width: 8, height: 8)
            .padding(.top, 8)
        
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
