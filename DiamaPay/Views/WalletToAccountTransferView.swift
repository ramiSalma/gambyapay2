//
//  WalletToAccountTransferView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  WalletToAccountTransferView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import SwiftUI

struct WalletToAccountTransferView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSource: SourceOfFunds = .wallet
    @State private var selectedWallet: SponsoringWallet?
    
    // MARK: - State Variables
    @State private var selectedAccount: Account?
    @State private var accountNumber = ""
    @State private var showSavedAccounts = false
    @State private var accountName: String = ""
    @State private var isAccountVerified = false
    @State private var amount: String = ""
    @State private var paymentDetails: String = ""
    
    @State private var isVerifying = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var isSavePrompt = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.error
    
    // Transfer management
    @State private var calculatedFee: Double = 0.0
    @State private var totalAmountWithFee: Double = 0.0
    @State private var feeRuleIndex = ""
    @State private var nameEnquiryAuthCode: String = ""
    
    @State private var withdrawalFee: Double = 0.0
    @State private var isWithdrawalFeeEnabled: Bool = false
    @State private var isCalculatingWithdrawalFee = false
    @State private var withdrawalFeeError: String? = nil
    
    // Success dialog state
    @State private var showSuccessDialog = false
    @State private var isSavingBeneficiary = false
    @State private var transactionId = ""
    @State private var transactionDate = ""
    @State private var transactionReference = ""
    
    private let userDataManager = UserDataManager.shared
    private let defaultCurrency = "GMD"
    private let numericCurrency = "270"
    
    @State private var showConfirmationDialog = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                compactHeader

                if isLoading {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                            .scaleEffect(1.2)
                        
                        Text(AppStrings.traitementEnCours)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            // Balance Display
                            SourceOfFundsView(
                                onSourceChanged: { source in
                                    selectedSource = source
                                },
                                onWalletChanged: { wallet in
                                    selectedWallet = wallet
                                },
                                walletTransferStyle: true
                            )
                            
                            // Recipient Details Card
                            recipientDetailsCard
                            
                            // Amount Card
                            amountCard

                            // Reference Card
                            referenceCard
                            
                            // Submit Button
                            submitButton
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 14)
                        .padding(.bottom, 18)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(
                onSponsors: {},
                onQR: {},
                onLimits: {},
                onSettings: {}
            )
        }
        .navigationBarHidden(true)
        .alert(alertTitle, isPresented: $showAlert) {
            if isSavePrompt {
                Button(AppStrings.buttonTitle(AppStrings.save)) { saveCurrentBeneficiary() }
                Button(AppStrings.buttonTitle(AppStrings.notNow), role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
            }
        } message: {
            Text(isSavePrompt
                 ? AppStrings.wouldYouLikeToSaveValueToYourBeneficiaries(String(describing: accountName))
                 : alertMessage)
        }
        .overlay {
            if showSuccessDialog {
                AccountTransferSuccessView(
                    transactionId: transactionId,
                    transactionDate: transactionDate,
                    amount: amount,
                    accountName: accountName,
                    accountNumber: selectedAccount?.accountNumber ?? "",
                    bankName: selectedAccount?.bankName ?? "",
                    senderName: userDataManager.getUserName(),
                    senderWallet: userDataManager.getWalletNumber(),
                    senderPhone: userDataManager.getPhoneNumber(),
                    withdrawalFee: isWithdrawalFeeEnabled ? withdrawalFee : 0.0,
                    fee: calculatedFee,
                    total: totalAmountWithFee,
                    currency: defaultCurrency,
                    paymentDetails: paymentDetails,
                    onClose: {
                        showSuccessDialog = false
                        isSavePrompt = true
                        alertTitle = AppStrings.saveBeneficiary
                        alertMessage = ""
                        showAlert = true
                    }
                )
            }
        }
        .sheet(isPresented: $showSavedAccounts) {
            SavedAccountRecipientsView { beneficiary in
                let account = Account(
                    accountNumber: beneficiary.destination ?? "",
                    accountName: beneficiary.name ?? "",
                    bankCode: beneficiary.destBankCode ?? beneficiary.bankCode ?? "",
                    bankName: beneficiary.destBankCode ?? beneficiary.bankCode ?? "",
                    accountHolder: beneficiary.name ?? ""
                )
                selectedAccount = account
                accountNumber = account.accountNumber
                accountName = account.accountHolder
                isAccountVerified = false
                nameEnquiryAuthCode = ""
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .overlay(confirmationDialogOverlay)
    }
    

    private var compactHeader: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
            }
            Spacer()
            Text(AppStrings.walletToAccount)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 34, height: 34)
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .background(Color(hex: "174EA6").ignoresSafeArea(edges: .top))
    }

    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + defaultCurrency
    }
    
    
    private var confirmationDialogOverlay: some View {
        Group {
            if showConfirmationDialog {
                AccountTransferConfirmationDialog(
                    amount: amount,
                    fee: calculatedFee,
                    total: totalAmountWithFee,
                    currency: defaultCurrency,
                    accountName: accountName,
                    accountNumber: selectedAccount?.accountNumber ?? "",
                    bankName: selectedAccount?.bankName ?? "",
                    paymentDetails: paymentDetails,
                    isPresented: $showConfirmationDialog,
                    onConfirm: { pinCode in
                        showConfirmationDialog = false
                        processTransfer(with: pinCode)
                    },
                    onCancel: {
                        showConfirmationDialog = false
                    }
                )
            }
        }
    }
    

    // MARK: - Recipient Details Card
    private var recipientDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.accountDetails)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 88, height: 2)
            }
            
            HStack(alignment: .top, spacing: 10) {
                TextField(AppStrings.enterAccountNumber, text: $accountNumber)
                    .keyboardType(.numberPad)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
                    .onChange(of: accountNumber) { newValue in
                        if selectedAccount?.accountNumber != newValue {
                            selectedAccount = nil
                            accountName = ""
                            isAccountVerified = false
                            nameEnquiryAuthCode = ""
                        }
                    }

                VStack(spacing: 5) {
                    Button {
                        verifyEnteredAccount()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(Color(hex: "0788B9"))
                            .frame(width: 38, height: 38)
                            .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "0788B9"), lineWidth: 1.5))
                    }
                    .disabled(accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isVerifying)
                    Text(AppStrings.verify).font(.system(size: 12, weight: .medium)).foregroundColor(Color(hex: "0788B9"))
                }

                VStack(spacing: 5) {
                    Button {
                        showSavedAccounts = true
                    } label: {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "174EA6"))
                            .frame(width: 38, height: 38)
                            .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "0788B9"), lineWidth: 1.5))
                    }
                    .disabled(isVerifying)
                    Text(AppStrings.saved).font(.system(size: 12, weight: .medium)).foregroundColor(Color(hex: "174EA6"))
                }
            }
            
            // Account name display
            TextField(AppStrings.beneficiaryName, text: .constant(accountName))
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
                .disabled(true)
        }
        .padding(13)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
    // MARK: - Amount Card
    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.amount)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 72, height: 2)
            }
            
            // Replace the TextField with FormattedTextField
            FormattedTextField(
                placeholder: AppStrings.amount2,
                text: $amount,
                walletTransferStyle: true
            )
                .onChange(of: amount) {
                    NSObject.cancelPreviousPerformRequests(withTarget: self)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.calculateWithdrawalFee()
                    }
                }
        }
        .padding(13)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
    
    
    private func calculateWithdrawalFeeDebounced() {
        calculateWithdrawalFee()
    }
    
    private func calculateWithdrawalFee() {
        let cleanAmount = amount.cleanCurrencyValue()
        
        guard !cleanAmount.isEmpty,
              let amountValue = Double(cleanAmount),
              amountValue > 0 else {
            withdrawalFee = 0.0
            withdrawalFeeError = nil
            isWithdrawalFeeEnabled = false
            return
        }
        
        isCalculatingWithdrawalFee = true
        withdrawalFeeError = nil
        
        let request = WalletFeeQuoteRequest.current(
            amount: amountValue, destination: selectedAccount?.accountNumber ?? "",
            transactionType: "42", destinationBank: selectedAccount?.bankCode ?? "00100"
        )
        
        APIClient.shared.calculateWithdrawalFee(request: request) { result in
            DispatchQueue.main.async {
                self.isCalculatingWithdrawalFee = false
                
                switch result {
                case .success(let response):
                    print("response: \(response)")
                    print("response: \(response.self)")
                    print("response: \(response.message)")
                    print("response: \(response.respCode)")

                    if response.respCode == "000" {
                        self.withdrawalFee = response.feeAmount ?? 0.0
                        if self.withdrawalFee == 0 {
                            self.isWithdrawalFeeEnabled = false
                        }
                    } else {
                        self.withdrawalFee = 0.0
                        self.isWithdrawalFeeEnabled = false
                        self.withdrawalFeeError = response.message
                    }
                    
                case .failure(_):
                    self.withdrawalFee = 0.0
                    self.isWithdrawalFeeEnabled = false
                    self.withdrawalFeeError = AppStrings.impossibleDeCalculer
                }
            }
        }
    }
    
    // MARK: - Reference Card
    private var referenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.reasonOptional)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 100, height: 2)
            }
            
            TextField(AppStrings.enterAReason, text: $paymentDetails)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
                .onReceive(paymentDetails.publisher.collect()) { chars in
                    if chars.count > 25 {
                        paymentDetails = String(chars.prefix(25))
                    }
                }
        }
        .padding(13)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                validateAndShowConfirmation()
            }) {
                Text(AppStrings.buttonTitle(AppStrings.submit))
                    .font(.system(size: 15, weight: .bold)).tracking(1)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 42)
                    .background(selectedAccount != nil && !accountName.isEmpty && !amount.isEmpty
                                ? Color(hex: "0788B9")
                                : Color(hex: "DCDCDC"))
                    .cornerRadius(10)
            }
            .disabled(isLoading || isVerifying || selectedAccount == nil || accountName.isEmpty)
        }
        .padding(12)
    }

    private func verifyAccount(_ account: Account) {
        guard !account.accountNumber.isEmpty else {
            showErrorAlert(AppStrings.numeroDeCompteInvalide)
            return
        }
        
        isVerifying = true
        accountName = ""
        
        var request = RequestWalletToBankAccountNE()
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.source = "W"
        request.desBank = account.bankCode.isEmpty ? "00100" : account.bankCode
        request.srcBank = "00100"
        request.desAccount = account.accountNumber
        
        // Generate requestId
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.transferWalletToAccountNE(request: request) { result in
            DispatchQueue.main.async {
                self.isVerifying = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.handleVerificationSuccess(response, account: account)
                    } else {
                        self.handleVerificationError(response)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                    self.accountName = ""
                }
            }
        }
    }

    private func verifyEnteredAccount() {
        let number = accountNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !number.isEmpty else {
            showErrorAlert(AppStrings.enterAnAccountNumber)
            return
        }

        let sameSavedAccount = selectedAccount?.accountNumber == number
        let bankCode = sameSavedAccount ? (selectedAccount?.bankCode ?? "00100") : "00100"
        let bankName = sameSavedAccount ? (selectedAccount?.bankName ?? bankCode) : bankCode
        let account = Account(accountNumber: number, bankCode: bankCode, bankName: bankName)
        selectedAccount = account
        isAccountVerified = false
        verifyAccount(account)
    }
    
    private func handleVerificationSuccess(_ response: ResponseServiceJson, account: Account) {
        if let result = response.result {
            if let nameToCredit = result["accountHolder"] as? String {
                accountName = nameToCredit
                isAccountVerified = true
                nameEnquiryAuthCode = response.authCode ?? ""
                showSuccessAlert(AppStrings.compteVerifieAvecSucces)
            } else {
                accountName = account.accountHolder.isEmpty ? account.accountName : account.accountHolder
                isAccountVerified = true
                nameEnquiryAuthCode = response.authCode ?? ""
                showSuccessAlert(AppStrings.compteVerifie)
            }
        } else {
            showErrorAlert(AppStrings.informationDuCompteNonDisponible)
            accountName = ""
            isAccountVerified = false
        }
    }
    
    private func handleVerificationError(_ response: ResponseServiceJson) {
        let errorMessage = response.message ?? {
            switch response.respCode {
            case "001": return AppStrings.compteNonTrouve
            case "003": return AppStrings.donneesManquantesDansLaRequete
            default: return AppStrings.echecDeLaVerificationCodeValue(String(describing: response.respCode ?? AppStrings.nA))
            }
        }()
        
        showErrorAlert(errorMessage)
        accountName = ""
        isAccountVerified = false
    }
    
    private func validateAndShowConfirmation() {
        guard validateInputs() else { return }
        calculateTransactionFee()
    }
    
    private func validateInputs() -> Bool {
        if selectedSource == .sponsor && selectedWallet == nil {
            showErrorAlert(AppStrings.pleaseSelectASponsorWallet)
            return false
        }

        if accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || selectedAccount?.accountNumber != accountNumber || !isAccountVerified {
            showErrorAlert(AppStrings.veuillezSaisirUnNumeroDeCompteValideEtLe)
            return false
        }
        
        if amount.isEmpty {
            showErrorAlert(AppStrings.leMontantEstRequis)
            return false
        }
        
        if accountName.isEmpty {
            showErrorAlert(AppStrings.veuillezDAbordVerifierLeCompte)
            return false
        }
        
        return true
    }
    
    private func calculateTransactionFee() {
        isLoading = true
        
        let feeRequest = WalletFeeQuoteRequest.current(
            amount: Double(amount.cleanCurrencyValue().replacingOccurrences(of: ",", with: ".")) ?? 0.0, destination: selectedAccount?.accountNumber ?? "",
            transactionType: selectedSource == .wallet ? "42" : "10", destinationBank: selectedAccount?.bankCode ?? "00100"
        )
        
        APIClient.shared.calculateTransactionFee(request: feeRequest) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.calculatedFee = response.result?.totalFees ?? 0.0
                        self.totalAmountWithFee = (Double(self.amount.cleanCurrencyValue().replacingOccurrences(of: ",", with: ".")) ?? 0.0) + self.calculatedFee
                        self.feeRuleIndex = response.result?.ruleIndex ?? ""
                    } else {
                        self.calculatedFee = 0.0
                        self.totalAmountWithFee = Double(self.amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0
                    }
                case .failure(_):
                    self.calculatedFee = 0.0
                    self.totalAmountWithFee = Double(self.amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0
                }
                
                self.showConfirmationDialog = true
            }
        }
    }
    
    private func processTransfer(with pinCode: String) {
        guard let account = selectedAccount,
              !account.accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorAlert(AppStrings.veuillezSelectionnerUnCompteValide)
            return
        }
        let walletNumber = userDataManager.getWalletNumber()
        let phoneNumber = userDataManager.getPhoneNumber()
        let normalizedAmount = amount.cleanCurrencyValue()
        guard !walletNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let baseAmount = Double(normalizedAmount), baseAmount > 0 else {
            showErrorAlert(AppStrings.veuillezVerifierLeNumeroDeCompteEtSaisirUn)
            return
        }
        guard !pinCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorAlert(AppStrings.veuillezSaisirVotreCodePin)
            return
        }

        isLoading = true
        
        var request = RequestWalletToAccount()
        request.walletNumber = walletNumber
        request.phoneNumber = phoneNumber
        request.source = "W"
        request.srcBank = "00100"
        request.desAccount = account.accountNumber
        request.desBank = account.bankCode.isEmpty ? "00100" : account.bankCode
        let withdrawalFeeValue = isWithdrawalFeeEnabled ? withdrawalFee : 0.0
        let finalAmount = baseAmount + withdrawalFeeValue
        request.amount = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), finalAmount)
        request.currency = numericCurrency
        request.reason = String(paymentDetails.prefix(25))
        request.pin = pinCode
        request.authCode = nameEnquiryAuthCode
        request.sponsorWallet = selectedSource == .sponsor ? selectedWallet?.walletNumber : nil
        
        // Generate request ID
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        let requestId = String((datePrefix + randomDigits).prefix(12))
        request.requestId = requestId
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.transferWalletToAccount(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.handleTransferSuccess(response, requestId: requestId)
                    }else {
                        self.showError(message: AppStrings.transfertEchoueValue(String(describing: response.message ?? AppStrings.unknownError)))
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
    
    private func handleTransferSuccess(_ response: ResponseServiceJson, requestId: String) {
        if let reference = response.resultString, !reference.isEmpty {
            transactionId = reference
        } else if let result = response.result {
            transactionId = result["transactionId"] as? String ?? 
                           result["reference"] as? String ?? 
                           requestId
        } else {
            transactionId = requestId
        }
        
        transactionReference = transactionId
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        transactionDate = dateFormatter.string(from: Date())
        
        showSuccessDialog = true
    }

    private func saveCurrentBeneficiary() {
        guard !isSavingBeneficiary else { return }
        let phoneNumber = userDataManager.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phoneNumber.isEmpty, let account = selectedAccount else {
            isSavePrompt = false
            alertTitle = AppStrings.unableToSaveBeneficiary
            alertMessage = AppStrings.theAccountDetailsAreUnavailablePleaseTryAgain
            showAlert = true
            return
        }

        isSavingBeneficiary = true
        let requestId = DateFormatter.with(format: "yyMMdd").string(from: Date())
            + String(format: "%06d", Int.random(in: 0...999999))
        let request = WalletBeneficiaryAddRequest(
            phoneNumber: phoneNumber,
            destination: account.accountNumber,
            institutionCode: account.bankCode.isEmpty ? "00100" : account.bankCode,
            transactionType: "42",
            name: accountName,
            requestId: requestId,
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: userDataManager.getUserCode().isEmpty ? phoneNumber : userDataManager.getUserCode()
        )

        APIClient.shared.addWalletBeneficiary(request: request) { result in
            DispatchQueue.main.async {
                isSavingBeneficiary = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    clearTransferForm()
                    presentationMode.wrappedValue.dismiss()
                    return
                case .success(let response):
                    isSavePrompt = false
                    alertTitle = AppStrings.unableToSaveBeneficiary
                    alertMessage = response.message ?? AppStrings.pleaseTryAgainLater
                case .failure(let error):
                    isSavePrompt = false
                    alertTitle = AppStrings.unableToSaveBeneficiary
                    alertMessage = (error as? APIError)?.message ?? AppStrings.pleaseCheckYourConnectionAndTryAgain
                }
                showAlert = true
            }
        }
    }

    private func clearTransferForm() {
        selectedSource = .wallet
        selectedWallet = nil
        selectedAccount = nil
        accountNumber = ""
        accountName = ""
        isAccountVerified = false
        amount = ""
        paymentDetails = ""
        calculatedFee = 0
        totalAmountWithFee = 0
        feeRuleIndex = ""
        nameEnquiryAuthCode = ""
        withdrawalFee = 0
        isWithdrawalFeeEnabled = false
        isCalculatingWithdrawalFee = false
        withdrawalFeeError = nil
        transactionId = ""
        transactionDate = ""
        transactionReference = ""
    }
    private func showError(message: String) {
        isSavePrompt = false
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }
    private func showErrorAlert(_ message: String) {
        isSavePrompt = false
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

