//
//  AccountToWalletTransferView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import SwiftUI
import PDFKit

struct AccountToWalletTransferView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var walletBalance = UserDataManager.shared.getAvailableBalance()
    @State private var hasLoadedAccounts = false
    @State private var linkedAccounts: [Account] = []
    @State private var selectedAccount: Account? = nil
    @State private var showLinkedAccounts = false
    @State private var accountNameVerified: String = ""
    
    @State private var amount: String = ""
    @State private var reference: String = ""
    
    @State private var isLoading = false
    @State private var isVerifying = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.error
    
    // Fee calculation
    @State private var calculatedFee: Double = 0.0
    @State private var totalAmountWithFee: Double = 0.0
    @State private var feeQuoteID = UUID()
    @State private var isCalculatingTransferFee = false
    
    @State private var withdrawalFee: Double = 0.0
    @State private var isWithdrawalFeeEnabled: Bool = false
    
    
    // Success dialog
    @State private var showSuccessDialog = false
    @State private var transactionId = ""
    @State private var transactionDate = ""
    @State private var transactionAmount = ""
    @State private var transactionReference = ""
    
    @State private var showConfirmationDialog = false
    
    private let userDataManager = UserDataManager.shared
    private let defaultCurrency = "GMD"
    private let numericCurrency = "270"
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                StandingInstructionHeader(title: AppStrings.accountToWallet) {
                    presentationMode.wrappedValue.dismiss()
                }

                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "174EA6")))
                            .scaleEffect(1.5)
                        
                        Text(AppStrings.traitementEnCours)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Title Card
                            
                          
                            
                            sourceOfFundsCard
                                .padding(.bottom, 14)
                            accountSelectionCard
                            
                            // Amount Card
                            amountCard
                            
                      
                            // Reference Card
                            referenceCard
                            
                            // Submit Button
                            submitButton
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {}, onHome: {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .tint(Color(hex: "174EA6"))
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .sheet(isPresented: $showSuccessDialog) {
            AccountToWalletSuccessView(
                transactionId: transactionId,
                transactionDate: transactionDate,
                amount: transactionAmount,
                sourceAccountNumber: selectedAccount?.accountNumber ?? "",
                sourceAccountHolder: accountNameVerified.isEmpty ? (selectedAccount?.accountHolder ?? "") : accountNameVerified,
                sourceBankName: selectedAccount?.bankName ?? "",
                recipientName: userDataManager.getUserName(),
                recipientWallet: userDataManager.getWalletNumber(),
                recipientPhone: userDataManager.getPhoneNumber(),
                withdrawalFee: isWithdrawalFeeEnabled ? withdrawalFee : 0.0,
                fee: calculatedFee,
                total: totalAmountWithFee,
                currency: defaultCurrency,
                paymentDetails: transactionReference,
                onClose: {
                    showSuccessDialog = false
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showLinkedAccounts) {
            SavedLinkedAccountsView(accounts: linkedAccounts) { account in
                selectAccount(account)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .overlay(confirmationDialogOverlay)
        .onAppear {
            if !hasLoadedAccounts {
                hasLoadedAccounts = true
                fetchLinkedAccounts()
            }
            refreshWalletBalance()
        }
    }
    
    private var confirmationDialogOverlay: some View {
        Group {
            if showConfirmationDialog {
                AccountToWalletConfirmationDialog(
                    amount: amount,
                    fee: calculatedFee,
                    withdrawalFee: isWithdrawalFeeEnabled ? withdrawalFee : 0.0,
                    total: totalAmountWithFee,
                    currency: defaultCurrency,
                    accountNumber: selectedAccount?.accountNumber ?? "",
                    accountHolder: accountNameVerified.isEmpty ? (selectedAccount?.accountHolder ?? "") : accountNameVerified,
                    paymentDetails: reference,
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
    
    
    private var sourceOfFundsCard: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 12) {
                Rectangle().fill(Color(hex: "0086B5")).frame(width: 3, height: 21)
                Text(AppStrings.sourceOfFunds).font(.system(size: 19, weight: .medium)).foregroundColor(.black)
            }
            Text(AppStrings.wallet)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(hex: "359B46"))
                .cornerRadius(8)
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(standingText("Available balance", "Solde disponible"))
                        .font(.system(size: 12, weight: .medium))
                        .tracking(0.6)
                        .foregroundColor(.gray)
                    Text(balanceText)
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                Spacer()
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color(hex: "BDBDBD"))
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .background(Color(hex: "FAFAFA"))
        }
        .padding(23)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "EEEEEE")))
        .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
    }

    private var balanceText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: NSNumber(value: walletBalance)) ?? "0.00") + " GMD"
    }

    private func refreshWalletBalance() {
        APIClient.shared.getBalance { result in
            DispatchQueue.main.async {
                if case .success(let response) = result {
                    walletBalance = response.availableAmount
                    userDataManager.saveWalletBalance(availableAmount: response.availableAmount,
                                                      totalAmount: response.totalAmount,
                                                      currency: response.currency)
                }
            }
        }
    }

    private var accountSelectionCard: some View {
        standingCard(standingText("Account Details", "Détails du compte")) {
            Button { showLinkedAccounts = true } label: {
                HStack {
                    Text(AppStrings.buttonTitle(selectedAccount?.accountNumber ?? AppStrings.selectionnerUnCompte))
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer(minLength: 0)
                    if isVerifying { ProgressView() }
                }
                .standingField()
            }
            .buttonStyle(.plain)
            Text(accountNameVerified.isEmpty ? standingText("Recipient Name", "Nom du bénéficiaire") : accountNameVerified)
                .font(.system(size: 14))
                .standingField()
        }
    }

    private var amountCard: some View {
        standingCard(AppStrings.montant3) {
            TextField(standingText("Amount *", "Montant *"), text: $amount)
                .keyboardType(.decimalPad)
                .standingField()
                .task(id: amount) {
                    do { try await Task.sleep(nanoseconds: 400_000_000) } catch { return }
                    calculateTransferFee()
                }
                .onChange(of: amount) {
                    feeQuoteID = UUID()
                    calculatedFee = 0
                    totalAmountWithFee = 0
                    isCalculatingTransferFee = false
                }
        }
    }

    private func calculateTransferFee(completion: ((Bool) -> Void)? = nil) {
        let quoteID = UUID()
        feeQuoteID = quoteID
        calculatedFee = 0
        totalAmountWithFee = 0
        withdrawalFee = 0
        isWithdrawalFeeEnabled = false
        guard let account = selectedAccount,
              let value = Double(getCleanAmount(amount)), value.isFinite, value > 0 else {
            isCalculatingTransferFee = false
            completion?(false)
            return
        }
        isCalculatingTransferFee = true
        let bank = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        let request = WalletFeeQuoteRequest(
            walletNumber: userDataManager.getWalletNumber(),
            phoneNumber: userDataManager.getPhoneNumber(), source: "W", bank: bank,
            currency: "270", amount: getCleanAmount(amount), destination: userDataManager.getWalletNumber(),
            transactionType: "45", destinationBank: bank,
            requestId: DateFormatter.with(format: "yyMMdd").string(from: Date()) + String(format: "%06d", Int.random(in: 0...999999)),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: userDataManager.getUserCode())
        APIClient.shared.calculateWalletFee(request: request) { result in
            DispatchQueue.main.async {
                guard self.feeQuoteID == quoteID,
                      self.selectedAccount?.accountNumber == account.accountNumber,
                      self.selectedAccount?.bankCode == account.bankCode else { return }
                self.isCalculatingTransferFee = false
                switch result {
                case .success(let response):
                    guard response.respCode == "000", let quote = response.result,
                          let fee = quote.feeAmount, fee.isFinite, fee >= 0 else {
                        if completion != nil { self.showErrorAlert(response.message ?? AppStrings.unableToCalculateFees) }
                        completion?(false)
                        return
                    }
                    let tax = quote.taxAmount ?? 0
                    let total = quote.totalAmount ?? (value + fee + tax)
                    guard tax.isFinite, tax >= 0, total.isFinite, total >= value else {
                        if completion != nil { self.showErrorAlert(AppStrings.invalidFeeQuotePleaseTryAgain) }
                        completion?(false)
                        return
                    }
                    self.calculatedFee = fee + tax
                    self.totalAmountWithFee = total
                    completion?(true)
                case .failure(let error):
                    if completion != nil { self.showErrorAlert((error as? APIError)?.message ?? error.localizedDescription) }
                    completion?(false)
                }
            }
        }
    }

    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + defaultCurrency
    }
    
    private var referenceCard: some View {
        standingCard(standingText("Reason (optional)", "Motif (facultatif)")) {
            TextField(standingText("Enter a reason", "Saisir un motif"), text: $reference)
                .standingField()
        }
    }

    private var submitButton: some View {
        Button(action: validateAndShowConfirmation) {
            Text(AppStrings.buttonTitle(selectedAccount == nil ? AppStrings.selectionnerUnCompte : AppStrings.soumettre))
                .font(.system(size: 17, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(.white)
                .frame(width: 160, height: 50)
                .background(selectedAccount == nil || isVerifying || isCalculatingTransferFee ? Color(hex: "E0E0E0") : Color(hex: "174EA6"))
                .cornerRadius(9)
        }
        .disabled(isLoading || isVerifying || isCalculatingTransferFee || selectedAccount == nil)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }

    // MARK: - Helper Methods
    private func fetchLinkedAccounts() {
        isLoading = true
        var request = RequestListLinkedAcc()
        request.source = "W"
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        request.requestId = dateFormatter.string(from: Date()) + String(format: "%06d", Int.random(in: 0...999999))

        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.bank = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        request.entityId = userDataManager.getUserCode()

        APIClient.shared.getLinkedAccounts(request: request) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        parseLinkedAccounts(response)
                    } else {
                        hasLoadedAccounts = false
                        showErrorAlert(AppStrings.erreurValue(String(describing: response.message ?? AppStrings.erreurLorsDeLaRecuperationDesComptes)))
                    }
                case .failure(let error):
                    hasLoadedAccounts = false
                    showErrorAlert((error as? APIError)?.message ?? AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                }
            }
        }
    }

    private func parseLinkedAccounts(_ response: JResponseService) {
        linkedAccounts.removeAll()
        selectedAccount = nil
        accountNameVerified = ""
        feeQuoteID = UUID()
        isCalculatingTransferFee = false
        calculatedFee = 0
        totalAmountWithFee = 0

        for accountData in response.result ?? [] {
            guard let dict = accountData as? [String: Any] else { continue }
            var account = Account()
            account.accountNumber = dict["accountNumber"] as? String ?? ""
            account.accountHolder = dict["accountHolder"] as? String ?? ""
            account.bankCode = dict["bankCode"] as? String ?? ""
            account.bankName = dict["bankWording"] as? String ?? ""
            account.accountType = dict["accountType"] as? String ?? ""
            account.currency = dict["currency"] as? String ?? ""
            account.balance = dict["balance"].map { String(describing: $0) } ?? ""
            if !account.accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                linkedAccounts.append(account)
            }
        }

        if linkedAccounts.isEmpty {
            showErrorAlert(AppStrings.noLinkedBankAccountsWereReturnedLinkABankAccount)
        }
    }

    private func selectAccount(_ account: Account) {
        selectedAccount = account
        accountNameVerified = ""
        verifyAccount(account)
        // Recalculate transfer fee when account changes
        calculateTransferFee()
    }
    
    private func verifyAccount(_ account: Account) {
        guard !account.accountNumber.isEmpty else { return }
        
        isVerifying = true
        
        var request = RequestWalletToBankAccountNE()
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.source = "W"
        request.desBank = account.bankCode.isEmpty ? "00100" : account.bankCode
        request.srcBank = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        request.desAccount = account.accountNumber
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.getAccountNameEnquiry(request: request) { result in
            DispatchQueue.main.async {
                guard self.selectedAccount?.accountNumber == account.accountNumber,
                      self.selectedAccount?.bankCode == account.bankCode else { return }
                self.isVerifying = false

                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        if let result = response.result,
                           let nameToCredit = result["accountHolder"] as? String {
                            self.accountNameVerified = nameToCredit.isEmpty ? account.accountHolder : nameToCredit
                            self.selectedAccount?.accountName = self.accountNameVerified
                        } else {
                            self.accountNameVerified = account.accountHolder
                        }
                    } else {
                        self.accountNameVerified = account.accountHolder
                    }
                case .failure:
                    self.accountNameVerified = account.accountHolder
                }
            }
        }
    }
    
    private func validateAndShowConfirmation() {
        guard selectedAccount != nil else {
            showErrorAlert(AppStrings.veuillezSelectionnerUnCompte)
            return
        }
        
        guard !amount.isEmpty else {
            showErrorAlert(AppStrings.leMontantEstRequis)
            return
        }
        
        guard let value = Double(getCleanAmount(amount)), value.isFinite, value > 0 else {
            showErrorAlert(AppStrings.enterAValidAmountGreaterThanZero)
            return
        }
        guard !isCalculatingTransferFee, !isVerifying else { return }
        calculateTransferFee { success in
            if success { self.showConfirmationDialog = true }
        }
    }
    
    private func processTransfer(with pinCode: String) {
        guard !isLoading, let account = selectedAccount, !account.accountNumber.isEmpty,
              let value = Double(getCleanAmount(amount)), value.isFinite, value > 0 else { return }
        isLoading = true

        let cleanAmount = getCleanAmount(amount)
        transactionAmount = cleanAmount
        transactionReference = reference
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        transactionDate = dateFormatter.string(from: Date())
        
        var request = RequestAccountToWallet()
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.source = "W"
        request.srcAccount = account.accountNumber
        request.srcBank = account.bankCode.isEmpty ? "00100" : account.bankCode
        request.accountHolder = accountNameVerified.isEmpty ? account.accountHolder : accountNameVerified
        request.desBank = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        request.amount = cleanAmount
        request.otp = ""
        request.pin = pinCode
        request.reason = reference
        request.currency = numericCurrency
        
        let idDateFormatter = DateFormatter()
        idDateFormatter.dateFormat = "yyMMdd"
        let datePrefix = idDateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        let requestId = String((datePrefix + randomDigits).prefix(12))
        request.requestId = requestId
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.accountToWallet(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        if let reference = response.resultString, !reference.isEmpty {
                            self.transactionId = reference
                        } else if let result = response.result {
                            self.transactionId = result["transactionId"] as? String ??
                                               result["reference"] as? String ??
                                               requestId
                        } else {
                            self.transactionId = response.requestId ?? requestId
                        }
                        
                        self.showSuccessDialog = true
                    } else {
                        self.showErrorAlert(AppStrings.transfertEchoueValue(String(describing: response.message ?? AppStrings.unknownError)))
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
    
    private func getCleanAmount(_ value: String) -> String {
        return value.components(separatedBy: .whitespacesAndNewlines).joined().replacingOccurrences(of: ",", with: ".")
    }
    
    private func showErrorAlert(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Extension for String cleaning
extension String {
    func cleanCurrencyValue() -> String {
        return self.replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

struct AccountToWalletConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let amount: String
    let fee: Double
    let withdrawalFee: Double
    let total: Double
    let currency: String
    let accountNumber: String
    let accountHolder: String
    let paymentDetails: String
    
    @Binding var isPresented: Bool
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    @State private var pin: String = ""
    @State private var showPinError = false
    @State private var pinErrorMessage = ""
    @State private var isVerifyingPin = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(AppStrings.confirmerLeTransfert)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.vertical, 16)
                
                // Transaction Details
                ScrollView {
                    VStack(spacing: 16) {
                        // Amount Section with Fees Breakdown
                        VStack(spacing: 12) {
                            DetailRowView(label: AppStrings.montant3, value: formatAmount(Double(amount.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ".")) ?? 0.0))
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            // Fees Breakdown Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text(AppStrings.fraisApplicables)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                // Withdrawal Fee (if applicable)
                                if withdrawalFee > 0 {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Image(systemName: "banknote")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Text(AppStrings.fraisDeRetrait)
                                                .font(.system(size: 13))
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                        Text(formatAmount(withdrawalFee))
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Transfer Fee
                                if fee > 0 {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Image(systemName: "paperplane.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "174EA6"))
                                            Text(AppStrings.fraisDeTransfert)
                                                .font(.system(size: 13))
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                        Text(formatAmount(fee))
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color(hex: "174EA6"))
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(hex: "174EA6").opacity(0.1))
                                    .cornerRadius(8)
                                } else {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Image(systemName: "paperplane.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.green)
                                            Text(AppStrings.fraisDeTransfert)
                                                .font(.system(size: 13))
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                        Text(AppStrings.gratuit)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.green)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            DetailRowView(
                                label: AppStrings.totalACrediter,
                                value: formatAmount(total),
                                isHighlighted: true
                            )
                        }
                        .padding(16)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        
                        // Account Source Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.compteSource3)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            DetailRowView(label: AppStrings.compte, value: accountNumber)
                            DetailRowView(label: AppStrings.titulaire2, value: accountHolder)
                        }
                        .padding(16)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        
                        // Payment Details
                        if !paymentDetails.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(AppStrings.reference2)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text(paymentDetails)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // PIN Entry
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.pin)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            WalletPINField(AppStrings.entrerLeCodePin, text: $pin)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(showPinError ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .onChange(of: pin) { newValue in
                                    if newValue.count > 4 { pin = String(newValue.prefix(4)) }
                                    showPinError = false
                                }
                            
                            if showPinError {
                                Text(pinErrorMessage)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 400)
                
                Divider()
                    .padding(.vertical, 16)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        onCancel()
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "174EA6"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "174EA6"), lineWidth: 1)
                            )
                    }
                    
                    Button(action: { validateAndConfirm() }) {
                        Group {
                            if isVerifyingPin {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(AppStrings.buttonTitle(AppStrings.confirmer))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "174EA6"))
                        .cornerRadius(8)
                    }
                    .disabled(isVerifyingPin)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 500)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + currency
    }
    
    private func validateAndConfirm() {
        showPinError = false
        
        guard pin.isValidWalletPIN else {
            pinErrorMessage = AppStrings.lePinDoitContenirExactement4Chiffres
            showPinError = true
            return
        }
        
        isVerifyingPin = true
        
        PinVerificationService.verify(pin: pin) { verifiedPin in
            isVerifyingPin = false
            onConfirm(verifiedPin)
        } onFailure: { message in
            isVerifyingPin = false
            pinErrorMessage = message
            showPinError = true
            pin = ""
        }
    }
}

struct AccountToWalletTransferView_Previews: PreviewProvider {
    static var previews: some View {
        AccountToWalletTransferView()
    }
}
