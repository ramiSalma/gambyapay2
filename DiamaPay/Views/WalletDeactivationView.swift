//
//  WalletDeactivationView.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//  Updated: Auto-verify recipient on 9–10 digits and UI optimizations
//

import SwiftUI

struct WalletDeactivationView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var selectedReasonIndex = 0
    @State private var customReason = ""
    @State private var selectedPaymentMethod: PaymentMethod? = nil
    
    @State private var navigateToLogin = false
    
    // Wallet transfer
    @State private var receiverPhone = ""
    @State private var walletHolderName = ""
    @State private var verifiedWalletHolder = ""
    @State private var destinationBank = ""
    @State private var isRecipientVerified = false
    
    // Account transfer
    @State private var linkedAccounts: [Account] = []
    @State private var selectedAccount: Account? = nil
    @State private var accountHolderName = ""
    
    // Branch transfer
    @State private var branches: [Branch] = []
    @State private var selectedBranch: Branch? = nil
    
    // PIN
    @State private var pin = ""
    @State private var showPin = false
    
    // UI State
    @State private var isLoading = false
    @State private var isVerifying = false
    @State private var showAlert = false
    @State private var alertTitle = AppStrings.error
    @State private var alertMessage = ""
    @State private var showConfirmationDialog = false
    @State private var showOtpDialog = false
    @State private var otpCode = ""
    @State private var showSuccessDialog = false
    
    // Deactivation auth code for OTP verification
    @State private var deactivationAuthCode = ""
    
    private let androidBlue = Color(hex: "174EA6")
    private let androidAccent = Color(hex: "0083B7")
    private let androidText = Color(hex: "545D69")

    private let userDataManager = UserDataManager.shared
    private let deactivationReasons = [
        AppStrings.original("selectionnerUneRaison"),
        AppStrings.original("jeNUtilisePlusLeService"),
        AppStrings.original("problemesDeSecurite"),
        AppStrings.original("interfaceDifficileAUtiliser"),
        AppStrings.original("fraisTropEleves"),
        AppStrings.original("serviceClientInsatisfaisant"),
        AppStrings.original("changementDeSituationFinanciere"),
        AppStrings.original("autreRaison")
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.deactivateWallet, headerColor: Color(hex: "174EA6"))

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
                            headerCard
                            reasonCard
                            paymentMethodCard
                            
                            if selectedPaymentMethod != nil {
                                transferDetailsCard
                                pinCard
                            }
                            
                            warningCard
                            submitButton
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(confirmationDialogOverlay)
        .overlay(otpDialogOverlay)
        .overlay(successDialogOverlay)
        .background(
            NavigationLink(
                destination: LoginView()
                    .navigationBarHidden(true),
                isActive: $navigateToLogin,
                label: { EmptyView() }
            )
        )
    }
    
    private var headerCard: some View {
        Text(AppStrings.deactivationIntro)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity, minHeight: 78)
            .background(androidAccent)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 3)
    }

    private func sectionHeading(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(androidBlue)
            Rectangle()
                .fill(androidAccent)
                .frame(width: 38, height: 3)
        }
    }

    // MARK: - Reason Card
    private var reasonCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeading(AppStrings.deactivationReasonTitle)
                .padding(.bottom, 22)

            Text(AppStrings.deactivationSelectReason)
                .font(.system(size: 13))
                .foregroundColor(androidText)
                .padding(.bottom, 9)

            Menu {
                ForEach(0..<deactivationReasons.count, id: \.self) { index in
                    Button(AppStrings.buttonTitle(AppStrings.option(deactivationReasons[index]))) {
                        selectedReasonIndex = index
                    }
                }
            } label: {
                Text(selectedReasonIndex == 0 ? AppStrings.deactivationSelectReason : AppStrings.option(deactivationReasons[selectedReasonIndex]))
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 22)
                    .frame(height: 50)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(androidText, lineWidth: 1))
                    .contentShape(RoundedRectangle(cornerRadius: 8))
            }

            if selectedReasonIndex == deactivationReasons.count - 1 {
                TextField(AppStrings.detailsSupplementairesMax50Caracteres, text: $customReason, axis: .vertical)
                    .font(.system(size: 14))
                    .padding(12)
                    .frame(height: 100, alignment: .top)
                    .background(Color(hex: "F5F5F5"))
                    .cornerRadius(8)
                    .padding(.top, 16)
                    .onChange(of: customReason) {
                        if customReason.count > 50 {
                            customReason = String(customReason.prefix(50))
                        }
                    }
            }
        }
        .padding(.horizontal, 19)
        .padding(.top, 24)
        .padding(.bottom, 34)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.04), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 3)
    }

    // MARK: - Payment Method Card
    private var paymentMethodCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeading(AppStrings.deactivationTransferTitle)
                .padding(.bottom, 22)

            Text(AppStrings.deactivationTransferHelp)
                .font(.system(size: 13))
                .foregroundColor(androidText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 13)

            VStack(spacing: 0) {
                paymentMethodButton(.account, title: AppStrings.deactivationLinkedAccount)
                paymentMethodButton(.wallet, title: AppStrings.wallet)
                paymentMethodButton(.branch, title: AppStrings.deactivationCashOut)
            }
        }
        .padding(.horizontal, 19)
        .padding(.top, 24)
        .padding(.bottom, 18)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.04), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 3)
    }

    private func paymentMethodButton(_ method: PaymentMethod, title: String) -> some View {
        Button(action: {
            selectedPaymentMethod = method
            resetTransferDetails()

            switch method {
            case .account:
                loadLinkedAccounts()
            case .branch:
                loadBranches()
            case .wallet:
                break
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().stroke(selectedPaymentMethod == method ? androidAccent : Color.gray, lineWidth: 2)
                    if selectedPaymentMethod == method {
                        Circle().fill(androidAccent).padding(5)
                    }
                }
                .frame(width: 18, height: 18)
                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 6)
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedPaymentMethod == method ? .isSelected : [])
    }

    // MARK: - Transfer Details Card
    private var transferDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.detailsDuDestinataire)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.blueH)
                
                Rectangle()
                    .fill(Color.blueH)
                    .frame(width: 60, height: 2)
            }
            
            if selectedPaymentMethod == .wallet {
                walletTransferSection
            } else if selectedPaymentMethod == .account {
                accountTransferSection
            } else if selectedPaymentMethod == .branch {
                branchTransferSection
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Wallet Transfer Section (Optimized with Auto-Verify)
    private var walletTransferSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.numeroDeTelephoneDuDestinataire)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                TextField(AppStrings.phoneNumber, text: $receiverPhone.walletPhoneNumber())
                    .keyboardType(.numberPad)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 12)
                    .onChange(of: receiverPhone) {
                        // Verify supported phone lengths up to the ten-digit input limit.
                        if (9...10).contains(receiverPhone.count) {
                            verifyWalletRecipient()
                        } else if receiverPhone.count < 9 {
                            // Reset recipient info if digits are deleted
                            resetWalletVerificationFields()
                        }
                    }
                
                if isVerifying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                        .scaleEffect(0.8)
                        .padding(.trailing, 12)
                } else if isRecipientVerified && !walletHolderName.isEmpty && (9...10).contains(receiverPhone.count) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blueH)
                        .padding(.trailing, 12)
                }
            }
            .frame(height: 48)
            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
            .cornerRadius(8)
            
            if isRecipientVerified && !walletHolderName.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.nomDuTitulaire)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blueH)
                            .font(.system(size: 14))
                        
                        Text(walletHolderName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.blueH.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var accountTransferSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.compteBancaireLie)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            if linkedAccounts.isEmpty {
                HStack {
                    Text(AppStrings.chargementDesComptes)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(height: 48)
                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                .cornerRadius(8)
            } else {
                Menu {
                    ForEach(linkedAccounts, id: \.accountNumber) { account in
                        Button(AppStrings.buttonTitle("\(account.accountNumber) - \(account.accountHolder)")) {
                            selectedAccount = account
                            accountHolderName = account.accountHolder
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedAccount != nil ? "\(selectedAccount!.accountNumber) - \(selectedAccount!.accountHolder)" : AppStrings.selectionnerUnCompte)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
            }
            
            if !accountHolderName.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.nomDuTitulaireDuCompte)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(accountHolderName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var branchTransferSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.agenceDeRetrait)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            if branches.isEmpty {
                HStack {
                    Text(AppStrings.chargementDesAgences)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(height: 48)
                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                .cornerRadius(8)
            } else {
                Menu {
                    ForEach(branches, id: \.id) { branch in
                        Button(AppStrings.buttonTitle("\(branch.id ?? "") - \(branch.name ?? "")")) {
                            selectedBranch = branch
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedBranch != nil ? "\(selectedBranch!.id ?? "") - \(selectedBranch!.name ?? "")" : AppStrings.selectionnerUneAgence)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
            }
            
            Text(AppStrings.vousPourrezRetirerVotreSoldeDirectementEnAgenceAvecUne)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - PIN Card
    private var pinCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.confirmationDeSecurite)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.red)
            
            Text(AppStrings.entrezVotreCodePinPourConfirmerLaDesactivationDefinitiveDe)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            HStack {
                if showPin {
                    WalletPINField(AppStrings.pin, text: $pin, isSecure: false)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                        .cornerRadius(8)
                        .onChange(of: pin) {
                            if pin.count > 4 {
                                pin = String(pin.prefix(4))
                            }
                        }
                } else {
                    WalletPINField(AppStrings.pin, text: $pin)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                        .cornerRadius(8)
                        .onChange(of: pin) {
                            if pin.count > 4 {
                                pin = String(pin.prefix(4))
                            }
                        }
                }
                
                Button(action: {
                    showPin.toggle()
                }) {
                    Image(systemName: showPin ? "eye.slash" : "eye")
                        .foregroundColor(.blueH)
                        .padding(.trailing, 12)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Warning Card
    private var warningCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(AppStrings.importantInformation)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 230/255, green: 81/255, blue: 0/255))
            
            VStack(alignment: .leading, spacing: 12) {
                warningText(AppStrings.leSoldeRestantSeraTransfereVersLeDestinataireChoisi)
                warningText(AppStrings.votrePortefeuilleSeraDefinitivementFerme)
                warningText(AppStrings.cetteActionNePeutPasEtreAnnulee)
                warningText(AppStrings.vousDevrezCreerUnNouveauComptePourUtiliserNosServices)
                warningText(AppStrings.unCodeOtpSeraEnvoyePourConfirmationFinale)
            }
        }
        .padding(.horizontal, 19)
        .padding(.vertical, 24)
        .background(Color(red: 255/255, green: 243/255, blue: 224/255))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 3)
    }
    
    private func warningText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(Color(red: 230/255, green: 81/255, blue: 0/255))
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: validateAndShowConfirmation) {
            Text(AppStrings.buttonTitle(AppStrings.submit))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(androidBlue)
                .cornerRadius(8)
        }
        .disabled(isLoading)
        .padding(.horizontal, 30)
        .padding(.top, 14)
        .padding(.bottom, 20)
    }
    
    // MARK: - Dialog Overlays
    private var confirmationDialogOverlay: some View {
        Group {
            if showConfirmationDialog {
                DeactivationConfirmationDialog(
                    isPresented: $showConfirmationDialog,
                    onConfirm: {
                        showConfirmationDialog = false
                        processDeactivation()
                    },
                    onCancel: {
                        showConfirmationDialog = false
                    }
                )
            }
        }
    }
    
    private var otpDialogOverlay: some View {
        Group {
            if showOtpDialog {
                OtpVerificationDialog(
                    otpCode: $otpCode,
                    isPresented: $showOtpDialog,
                    onVerify: {
                        verifyOtp(otpCode)
                    },
                    onCancel: {
                        showOtpDialog = false
                    }
                )
            }
        }
    }
    
    private var successDialogOverlay: some View {
        Group {
            if showSuccessDialog {
                DeactivationSuccessDialog(
                    isPresented: $showSuccessDialog,
                    navigateToLogin: $navigateToLogin
                )
            }
        }
    }

    // MARK: - Helper Methods
    private func resetTransferDetails() {
        receiverPhone = ""
        walletHolderName = ""
        verifiedWalletHolder = ""
        destinationBank = ""
        isRecipientVerified = false
        selectedAccount = nil
        accountHolderName = ""
        selectedBranch = nil
    }
    
    private func resetWalletVerificationFields() {
        walletHolderName = ""
        verifiedWalletHolder = ""
        destinationBank = ""
        isRecipientVerified = false
    }
    
    private func verifyWalletRecipient() {
        guard (9...10).contains(receiverPhone.count) else {
            return
        }
        
        isVerifying = true
        
        var request = RequestNameEnquiry()
        request.source = "P"
        request.phoneNumber = receiverPhone
        request.bank = "00100"
        request.pin = userDataManager.getPinForAPI()
        
        let randomLong = UInt64.random(in: 0...UInt64.max)
        let requestIdNumber = randomLong % 1000000000000
        request.requestId = String(format: "%012llu", requestIdNumber)
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.getWalletInfo(request: request) { result in
            DispatchQueue.main.async {
                self.isVerifying = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.handleVerificationSuccess(response)
                    } else {
                        self.handleVerificationError(response)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                    self.resetWalletVerificationFields()
                }
            }
        }
    }
    
    private func handleVerificationSuccess(_ response: ResponseServiceJson) {
        if let result = response.result {
            let clientName = result["walletHolder"] as? String ?? ""
            let phoneConfirmed = result["phoneNumber"] as? String ?? ""
            
            let phoneSuffix = String(phoneConfirmed.suffix(9))
            if !receiverPhone.hasSuffix(phoneSuffix) && receiverPhone != phoneConfirmed {
                showErrorAlert(AppStrings.leNumeroVerifieNeCorrespondPasAuNumeroSaisi)
                resetWalletVerificationFields()
                return
            }
            
            destinationBank = "00100"
            verifiedWalletHolder = clientName
            walletHolderName = clientName
            isRecipientVerified = true
        } else {
            showErrorAlert(AppStrings.informationDuDestinataireNonDisponible)
            resetWalletVerificationFields()
        }
    }
    
    private func handleVerificationError(_ response: ResponseServiceJson) {
        let errorMessage = response.message ?? {
            switch response.respCode {
            case "001": return AppStrings.portefeuilleNonTrouve
            case "003": return AppStrings.donneesManquantesDansLaRequete
            case "005": return AppStrings.codePinIncorrect
            case "006": return AppStrings.codePinBloque
            case "021": return AppStrings.utilisateurNonAutorise
            default: return AppStrings.echecDeLaVerificationCodeValue(String(describing: response.respCode ?? "N/A"))
            }
        }()
        
        showErrorAlert(errorMessage)
        resetWalletVerificationFields()
    }
    
    private func loadLinkedAccounts() {
        isLoading = true
        
        var request = RequestListLinkedAcc()
        request.source = "W"
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        
        let bankCode = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        request.bank = bankCode
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.getLinkedAccounts(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.parseLinkedAccounts(response)
                    } else {
                        self.showErrorAlert(AppStrings.erreurValue(String(describing: response.message ?? AppStrings.impossibleDeChargerLesComptes)))
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    private func parseLinkedAccounts(_ response: JResponseService) {
        linkedAccounts.removeAll()
        
        if let resultList = response.result {
            for accountData in resultList {
                guard let dict = accountData as? [String: Any] else { continue }
                
                var account = Account()
                account.accountNumber = dict["accountNumber"] as? String ?? ""
                account.accountHolder = dict["accountHolder"] as? String ?? ""
                account.accountName = dict["accountName"] as? String ?? ""
                account.bankCode = dict["bankCode"] as? String ?? ""
                account.bankName = dict["bankName"] as? String ?? ""
                account.accountType = dict["accountType"] as? String ?? ""
                account.currency = dict["currency"] as? String ?? ""
                account.balance = dict["balance"] as? String ?? ""
                
                linkedAccounts.append(account)
            }
        }
        
        if linkedAccounts.isEmpty {
            showErrorAlert(AppStrings.aucunCompteBancaireLieTrouve)
        }
    }
    
    private func loadBranches() {
        isLoading = true
        
        let bankCode = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        
        APIClient.shared.getAllBranches(bankCode: bankCode) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let branchList):
                    self.branches = branchList
                    if self.branches.isEmpty {
                        self.showErrorAlert(AppStrings.aucuneAgenceTrouvee)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    private func validateAndShowConfirmation() {
        if selectedReasonIndex == 0 {
            showErrorAlert(AppStrings.veuillezSelectionnerUneRaisonDeDesactivation)
            return
        }
        
        if selectedReasonIndex == deactivationReasons.count - 1 && customReason.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorAlert(AppStrings.veuillezPreciserLaRaisonDeDesactivation)
            return
        }
        
        guard let paymentMethod = selectedPaymentMethod else {
            showErrorAlert(AppStrings.veuillezSelectionnerUneMethodeDeTransfert)
            return
        }
        
        switch paymentMethod {
        case .wallet:
            if receiverPhone.trimmingCharacters(in: .whitespaces).isEmpty {
                showErrorAlert(AppStrings.veuillezSaisirLeNumeroDuDestinataire)
                return
            }
            if !isRecipientVerified || verifiedWalletHolder.isEmpty {
                showErrorAlert(AppStrings.veuillezDAbordVerifierLeDestinataire)
                return
            }
        case .account:
            if selectedAccount == nil {
                showErrorAlert(AppStrings.veuillezSelectionnerUnCompte)
                return
            }
        case .branch:
            if selectedBranch == nil {
                showErrorAlert(AppStrings.veuillezSelectionnerUneAgence)
                return
            }
        }
        
        if pin.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorAlert(AppStrings.veuillezSaisirVotreCodePin)
            return
        }
        
        if !pin.isValidWalletPIN {
            showErrorAlert(AppStrings.leCodePinDoitContenirAuMoins4Chiffres)
            return
        }
        
        showConfirmationDialog = true
    }
    
    private func processDeactivation() {
        //print("=== STARTING WALLET DEACTIVATION PROCESS ===")
        isLoading = true
        
        var request = RequestDeactivateWallet()
        request.source = "P"
        let phoneNumber = userDataManager.getPhoneNumber()
        request.phoneNumber = phoneNumber
        //print("Source: P, Phone Number: \(phoneNumber)")
        
        request.pin = pin
        //print("PIN length: \(pin.count)")
        
        let reason = selectedReasonIndex == deactivationReasons.count - 1
            ? customReason.trimmingCharacters(in: .whitespaces)
            : deactivationReasons[selectedReasonIndex]
        request.reason = reason
        //print("Reason: \(reason)")
        
        guard let paymentMethod = selectedPaymentMethod else { return }
        
        switch paymentMethod {
        case .wallet:
            request.paymentMethod = "W"
            request.receiver = receiverPhone
            request.beneficiaryName = verifiedWalletHolder
            request.institution = destinationBank
            //print("Wallet transfer - Receiver: \(receiverPhone), Beneficiary: \(verifiedWalletHolder), Institution: \(destinationBank)")
            
        case .account:
            request.paymentMethod = "A"
            request.receiver = selectedAccount?.accountNumber ?? ""
            request.beneficiaryName = selectedAccount?.accountHolder ?? ""
            request.institution = selectedAccount?.bankCode ?? ""
            //print("Account transfer - Account: \(request.receiver), Holder: \(request.beneficiaryName), Bank: \(request.institution)")
            
        case .branch:
            request.paymentMethod = "B"
            let branchId = selectedBranch?.id ?? ""
            let branchName = selectedBranch?.name ?? ""
            request.receiver = branchId
            request.beneficiaryName = AppStrings.branchCashOutValue(String(describing: branchName))
            let userBankCode = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
            request.institution = userBankCode
            //print("Branch transfer - Branch ID: \(branchId), Branch Name: \(branchName), Institution: \(userBankCode)")
        }
        
        request.walletNumber = userDataManager.getPhoneNumber()
        //print("Wallet Number: \(request.walletNumber)")
     
        let randomLong = UInt64.random(in: 0...UInt64.max)
        let requestIdNumber = randomLong % 1000000000000
        request.requestId = String(format: "%012llu", requestIdNumber)
        //print("Generated Request ID: \(request.requestId)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = dateFormatter.string(from: Date())
        //print("Request Date: \(request.requestDate)")
        
        request.entityId = userDataManager.getUserCode()
        //print("Entity ID: \(request.entityId)")
        
        //print("=== SENDING DEACTIVATION REQUEST ===")
        
        APIClient.shared.deactivateWallet(request: request) { result in
            DispatchQueue.main.async {
                //print("=== DEACTIVATION RESPONSE RECEIVED ===")
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    //print("Response Status: \(response.status ?? "nil")")
                    //print("Response Code: \(response.respCode ?? "nil")")
                    //print("Response Message: \(response.message ?? "nil")")
                    //print("Response Auth Code: \(response.authCode ?? "nil")")
                    
                    if response.respCode == "000" {
                        self.deactivationAuthCode = response.authCode ?? ""
                        //print("Deactivation request successful")
                        
                        if let message = response.message, message.contains("OTP") {
                            //print("OTP verification required - showing OTP dialog")
                            self.showOtpDialog = true
                        } else {
                            //print("No OTP required - showing success dialog")
                            self.showSuccessDialog = true
                        }
                    } else {
                        //print("Deactivation request failed with code: \(response.respCode ?? "nil")")
                        let errorMsg = response.message ?? AppStrings.erreurLorsDeLaDesactivationDuPortefeuille
                        self.showErrorAlert(errorMsg)
                    }
                    
                case .failure(let error):
                    //print("=== DEACTIVATION REQUEST FAILED ===")
                    if let apiError = error as? APIError {
                        //print("Error: \(apiError.message)")
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        //print("Network error: \(error.localizedDescription)")
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    private func verifyOtp(_ otp: String) {
        //print("=== STARTING OTP VERIFICATION ===")
        //print("OTP: \(otp)")
        //print("AuthCode: \(deactivationAuthCode)")
        
        guard !otp.trimmingCharacters(in: .whitespaces).isEmpty else {
            showErrorAlert(AppStrings.veuillezSaisirLeCodeOtp)
            return
        }
        
        guard otp.count == 6 else {
            showErrorAlert(AppStrings.leCodeOtpDoitContenirExactement6Chiffres)
            return
        }
        
        isLoading = true
        
        let phoneNumber = userDataManager.getPhoneNumber()
        let entityId = userDataManager.getUserCode()
        
        let request = OtpRequest(
            phoneNumber: phoneNumber,
            authCode: deactivationAuthCode,
            otp: otp,
            entityId: entityId
        )
        APIClient.shared.verifyOtp(request: request) { result in
            DispatchQueue.main.async {
                //print("=== OTP VERIFICATION RESPONSE RECEIVED ===")
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    //print("Response Status: \(response.status ?? "nil")")
                    //print("Response Code: \(response.respCode ?? "nil")")
                    //print("Response Message: \(response.message ?? "nil")")
                    
                    if response.respCode == "000" || response.isSuccessful {
                        //print("OTP verification successful")
                        self.showOtpDialog = false
                        self.showSuccessDialog = true
                    } else {
                        //print("OTP verification failed: \(response.respCode ?? "nil")")
                        let errorMsg = response.message ?? AppStrings.codeOtpInvalideVeuillezReessayer
                        self.showErrorAlert(errorMsg)
                    }
                    
                case .failure(let error):
                    //print("=== OTP VERIFICATION REQUEST FAILED ===")
                    if let apiError = error as? APIError {
                        //print("Error: \(apiError.message)")
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        //print("Network error: \(error.localizedDescription)")
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccessAlert(_ message: String) {
        alertTitle = AppStrings.succes
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Payment Method Enum
enum PaymentMethod {
    case account
    case wallet
    case branch
}

// MARK: - Deactivation Confirmation Dialog
struct DeactivationConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 20) {
                Text(AppStrings.confirmationDeDesactivation)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(AppStrings.etesVousSurDeVouloirDesactiverDefinitivementVotrePortefeuilleCette)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blueH)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blueH.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: onConfirm) {
                        Text(AppStrings.buttonTitle(AppStrings.ouiDesactiver))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - OTP Verification Dialog
struct OtpVerificationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var otpCode: String
    @Binding var isPresented: Bool
    let onVerify: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 20) {
                Text(AppStrings.verificationOtp)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(AppStrings.unCodeDeVerificationAEteEnvoyeAVotreNumero)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                WalletCodeField(AppStrings.codeOtp, text: $otpCode, isSecure: false, maxLength: 6, centered: true)
                    .keyboardType(.numberPad)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: otpCode) {
                        if otpCode.count > 6 {
                            otpCode = String(otpCode.prefix(6))
                        }
                    }
                
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blueH)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blueH.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        guard otpCode.isValidOTP else {
                            return
                        }
                        onVerify()
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.verifier))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
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
            .padding(.horizontal, 40)
        }
    }
}

struct DeactivationSuccessDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var isPresented: Bool
    @Binding var navigateToLogin: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text(AppStrings.demandeEnvoyee)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(AppStrings.votreDemandeDeDesactivationAEteTransmiseAvecSuccesLe)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                
                Button(action: {
                    closeAndNavigate()
                }) {
                    Text(AppStrings.buttonTitle(AppStrings.fermer))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blueH)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                closeAndNavigate()
            }
        }
    }
    
    private func closeAndNavigate() {
        if isPresented {
            isPresented = false
            navigateToLogin = true
        }
    }
}

// MARK: - Preview
struct WalletDeactivationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletDeactivationView()
        }
    }
}
