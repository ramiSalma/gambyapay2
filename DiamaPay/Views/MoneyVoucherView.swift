//
//  MoneyVoucherView.swift - Updated with Recipient Name & ID
//  DiamaPay
//

import Contacts
import ContactsUI
import SwiftUI

struct MoneyVoucherView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var selectedSource: SourceOfFunds = .wallet
    @State private var selectedWallet: SponsoringWallet? = nil
    @State private var currentBalance: String = ""
    
    @State private var receiverPhone: String = ""
    @State private var recipientName: String = ""
    @State private var recipientIdNumber: String = ""
    @State private var amount: String = ""
    @State private var paymentDetails: String = ""
    
    @State private var showContactPicker = false
    @State private var showSavedRecipients = false
    @State private var isSavingRecipient = false
    @State private var isVerifying = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.error
    
    // Voucher management
    @State private var calculatedFee: Double = 0.0
    @State private var totalAmountWithFee: Double = 0.0
    @State private var feeRuleIndex = ""
    
    // Withdrawal Fee (NEW)
    @State private var withdrawalFee: Double = 0.0
    @State private var isWithdrawalFeeEnabled: Bool = false
    @State private var isCalculatingWithdrawalFee = false
    @State private var withdrawalFeeError: String? = nil
    
    
    // Success dialog state
    @State private var showSuccessDialog = false
    @State private var transactionId = ""
    @State private var transactionDate = ""
    @State private var transactionReference = ""
    @State private var voucherCode = ""
    @State private var isRecipientAlreadySaved = false
    @State private var shouldReturnHomeAfterSave = false
    @State private var pendingSavePhone = ""
    @State private var pendingSaveName = ""
    
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
                DiamaPayHeader(title: AppStrings.moneyVoucher, headerColor: Color(hex: "174EA6"))

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
                        VStack(spacing: 18) {
                            // Source of Funds View
                            SourceOfFundsView(
                                onSourceChanged: { source in
                                    selectedSource = source
                                },
                                onWalletChanged: { wallet in
                                    selectedWallet = wallet
                                },
                                onBalanceChanged: { balance in
                                    currentBalance = balance
                                },
                                walletTransferStyle: true,
                                blueAccent: false
                            )

                            recipientDetailsCard
                            amountCard
                            referenceCard
                            submitButton
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 44)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .onDisappear {
            isLoading = false
            isVerifying = false
            showConfirmationDialog = false
        }
        .alert(alertTitle, isPresented: $showAlert) {
            if alertTitle == AppStrings.saveRecipient {
                Button(AppStrings.buttonTitle(AppStrings.save)) { saveRecipient() }
                Button(AppStrings.buttonTitle(AppStrings.notNow), role: .cancel) { finishAndReturnHome() }
            } else {
                Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) {
                    if shouldReturnHomeAfterSave { finishAndReturnHome() }
                }
            }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPickerView(selectedPhone: $receiverPhone)
        }
        .sheet(isPresented: $showSavedRecipients) {
            SavedAccountRecipientsView(includeMoneyVoucherRecipients: true) { beneficiary in
                receiverPhone = beneficiary.destination ?? ""
                recipientName = beneficiary.name ?? ""
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSuccessDialog) {
            VoucherSuccessView(
                transactionId: transactionId,
                transactionDate: transactionDate,
                amount: amount,
                recipientName: recipientName,
                recipientPhone: receiverPhone,
                senderName: userDataManager.getUserName(),
                senderPhone: userDataManager.getPhoneNumber(),
                fee: calculatedFee,
                withdrawalFee: isWithdrawalFeeEnabled ? withdrawalFee : 0.0,
                total: totalAmountWithFee,
                currency: defaultCurrency,
                paymentDetails: paymentDetails,
                voucherCode: voucherCode,
                onClose: {
                    showSuccessDialog = false
                    let alreadySaved = isRecipientAlreadySaved
                    let savedPhone = receiverPhone
                    let savedName = recipientName
                    clearForm()
                    guard !alreadySaved else {
                        finishAndReturnHome()
                        return
                    }
                    pendingSavePhone = savedPhone
                    pendingSaveName = savedName
                    shouldReturnHomeAfterSave = true
                    alertTitle = AppStrings.saveRecipient
                    alertMessage = AppStrings.wouldYouLikeToSaveValueForFutureVoucherTransfers(String(describing: savedName.isEmpty ? savedPhone : savedName))
                    showAlert = true
                }
            )
        }
        .overlay(confirmationDialogOverlay)
    }
    

    
    // MARK: - Title Card
    private var titleCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blueH)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text(AppStrings.miseADisposition)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 80, height: 3)
            }
            .padding(.vertical, 16)
        }
    }
    
    private var recipientDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardSectionTitle(AppStrings.recipientDetails, underlineWidth: 116)
            HStack(alignment: .top, spacing: 10) {
                TextField(AppStrings.phoneNumber2, text: $receiverPhone.walletPhoneNumber())
                    .keyboardType(.numberPad)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
                    .onChange(of: receiverPhone) {
                        if receiverPhone.count > 10 {
                            receiverPhone = String(receiverPhone.prefix(10))
                        }
                    }
                recipientAction(AppStrings.saved, icon: "book.closed.fill") { showSavedRecipients = true }
                recipientAction(AppStrings.contacts, icon: "person.crop.rectangle.fill") { showContactPicker = true }
            }
            TextField(AppStrings.recipientName2, text: $recipientName)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
            TextField(AppStrings.idNumber, text: $recipientIdNumber)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
        }
        .padding(13)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Amount Card
    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardSectionTitle(AppStrings.amount, underlineWidth: 72)
            FormattedTextField(placeholder: AppStrings.amount2, text: $amount, walletTransferStyle: true)
        }
        .padding(13)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Withdrawal Fee Card (NEW)
    private var withdrawalFeeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.ajouterLesFraisDeRetrait)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if isCalculatingWithdrawalFee {
                        HStack(spacing: 4) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                                .scaleEffect(0.7)
                            Text(AppStrings.calcul)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    } else if let error = withdrawalFeeError {
                        Text(error)
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    } else if withdrawalFee > 0 {
                    Text(AppStrings.feeValue(String(describing: formatAmount(withdrawalFee))))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    } else if !amount.isEmpty {
                        Text(AppStrings.aucunFraisApplicable)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    } else {
                        Text(AppStrings.enterAnAmountToSeeTheFee)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $isWithdrawalFeeEnabled)
                    .labelsHidden()
                    .disabled(withdrawalFee == 0.0 || amount.isEmpty)
            }
        }
        .padding(16)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + defaultCurrency
    }

    private func recipientAction(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .semibold))
                    .frame(width: 48, height: 48)
                    .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "0788B9"), lineWidth: 1.5))
                Text(AppStrings.buttonTitle(title)).font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(Color(hex: "0788B9"))
        }
    }
    
    private func calculateWithdrawalFeeDebounced() {
        calculateWithdrawalFee()
    }
   
    
    private var referenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardSectionTitle(AppStrings.reasonOptional, underlineWidth: 132)
            TextField(AppStrings.enterAReason, text: $paymentDetails)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
                .onChange(of: paymentDetails) {
                    if paymentDetails.count > 50 {
                        paymentDetails = String(paymentDetails.prefix(50))
                    }
                }
        }
        .padding(13)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }

    private func cardSectionTitle(_ title: String, underlineWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "174EA6"))
            Rectangle()
                .fill(Color(hex: "0788B9"))
                .frame(width: underlineWidth, height: 2)
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                validateAndShowConfirmation()
            }) {
                Text(AppStrings.buttonTitle(AppStrings.submit))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 190, height: 56)
                    .background(Color(hex: "174EA6"))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 3)
            }
            .disabled(isLoading)
        }
        .padding(16)
    }
    
    // MARK: - Validation (UPDATED)
    private func validateAndShowConfirmation() {
        guard validateInputs() else { return }
        calculateTransactionFee()
    }
    
    private func validateInputs() -> Bool {
        // Source validation
        if selectedSource == .sponsor && selectedWallet == nil {
            showErrorAlert(AppStrings.veuillezSelectionnerUnPortefeuilleSponsor)
            return false
        }
        
        // Sponsor limit validation
        if selectedSource == .sponsor, let wallet = selectedWallet {
            if let requestedAmount = Double(amount.replacingOccurrences(of: ",", with: ".")),
               !wallet.dailyLimit.isEmpty,
               let dailyLimit = Double(wallet.dailyLimit),
               requestedAmount > dailyLimit {
            showErrorAlert(AppStrings.amountExceedsTheSponsorSDailyLimit)
                return false
            }
        }
        
        // Phone number validation
        if receiverPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showErrorAlert(AppStrings.recipientPhoneNumberIsRequired)
            return false
        }

        // NEW: Recipient name validation (REQUIRED)
        // Amount validation
        guard let amountValue = Double(amount.cleanCurrencyValue()), amountValue > 0 else {
            showErrorAlert(AppStrings.enterAValidAmount2)
            return false
        }
        
        return true
    }

  
 
    private func handleVoucherSuccess(_ response: ResponseService, requestId: String) {
        if let result = response.result {
            switch result {
            case .string(let value):
                let trimmed = value.trimmingCharacters(in: .whitespaces)
                transactionId = trimmed.isEmpty ? requestId : trimmed
                
            case .dictionary(let dict):
                if let txId = dict["transactionId"]?.value as? String {
                    transactionId = txId
                } else if let reference = dict["reference"]?.value as? String {
                    transactionId = reference
                } else {
                    transactionId = requestId
                }
                
            case .array(_):
                transactionId = requestId
            }
        } else if let reqId = response.requestId?.trimmingCharacters(in: .whitespaces), !reqId.isEmpty {
            transactionId = reqId
        } else {
            transactionId = requestId
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        transactionDate = dateFormatter.string(from: Date())
        
        if case .string(let code)? = response.result {
            voucherCode = code
        } else {
            voucherCode = transactionId
        }
        transactionReference = paymentDetails
        checkWhetherRecipientIsSavedAndPresentSuccess()
    }
    
    private func showErrorAlert(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }
    
    // MARK: - Fee Calculation (NO DISPATCH QUEUE VERSION)
    private func calculateTransactionFee() {
        isLoading = true
        
        let feeRequest = WalletFeeQuoteRequest.current(
            amount: Double(amount.cleanCurrencyValue().replacingOccurrences(of: ",", with: ".")) ?? 0.0, destination: receiverPhone,
            transactionType: selectedSource == .sponsor ? "10" : "43", destinationBank: "00100"
        )
        
        //print("🔵 Starting fee calculation for amount: \(feeRequest.transactionAmount)")
        
        APIClient.shared.calculateTransactionFee(request: feeRequest) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
            case .success(let response):
                //print("🔵 API Response Code: \(response.respCode)")
                //print("🔵 Response feeAmount: \(String(describing: response.feeAmount))")
                
                if response.respCode == "000" {
                    // Get fee from the nested result object
                    let extractedFee = response.result?.totalFees ?? 0.0
                    /*
                    //print("✅ Fee Amount: \(extractedFee)")
                    //print("✅ Total Amount: \(response.result?.totalAmount ?? 0.0)")
                    */
                    self.calculatedFee = extractedFee
                    self.feeRuleIndex = response.result?.ruleIndex ?? ""
                    
                    // Calculate total with all fees
                    let baseAmount = Double(self.amount.cleanCurrencyValue().replacingOccurrences(of: ",", with: ".")) ?? 0.0
                    let withdrawalFeeValue = self.isWithdrawalFeeEnabled ? self.withdrawalFee : 0.0
                    self.totalAmountWithFee = baseAmount + withdrawalFeeValue + self.calculatedFee
                    
                    //print("📊 Fee Calculation Complete:")
                    //print("   Base Amount: \(baseAmount)")
                    //print("   Withdrawal Fee: \(withdrawalFeeValue)")
                    //print("   Transaction Fee: \(self.calculatedFee)")
                    //print("   Total: \(self.totalAmountWithFee)")
                    
                    // Show dialog
                    //print("🎯 Showing dialog with fee: \(self.calculatedFee), total: \(self.totalAmountWithFee)")
                    self.showConfirmationDialog = true
                    
                } else {
                    // Fee calculation failed
                    self.showErrorAlert(AppStrings.impossibleDeCalculerLesFraisValue(String(describing: response.message ?? AppStrings.unknownError)))
                }
                
            case .failure(let error):
                // Network error
                if let apiError = error as? APIError {
                    self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                } else {
                    self.showErrorAlert(AppStrings.erreurReseauLorsDuCalculDesFrais)
                }
                }
            }
        }
    }

    // MARK: - Withdrawal Fee Calculation (NO DISPATCH QUEUE VERSION)
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
            amount: amountValue, destination: receiverPhone,
            transactionType: "43", destinationBank: "00100"
        )
        
        APIClient.shared.calculateWithdrawalFee(request: request) { result in
            self.isCalculatingWithdrawalFee = false
            
            switch result {
            case .success(let response):
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

    // MARK: - Process Voucher (NO DISPATCH QUEUE VERSION)
    private func processMoneyVoucher(with pinCode: String) {
        isLoading = true
        
        var request = RequestMoneyVoucher()
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.source = "W"
        request.bank = "00100"
        request.currency = numericCurrency
        let baseAmount = Double(amount.cleanCurrencyValue()) ?? 0.0
        request.amount = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), baseAmount)
        request.receiverPhone = receiverPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        request.reason = String(paymentDetails.trimmingCharacters(in: .whitespacesAndNewlines).prefix(100))
        request.pin = pinCode
        
        if selectedSource == .sponsor, let wallet = selectedWallet {
            request.sponsorWallet = wallet.walletNumber
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        let requestId = String((datePrefix + randomDigits).prefix(12))
        request.requestId = requestId
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode().isEmpty
            ? request.phoneNumber
            : UserDataManager.shared.getUserCode()
        
        APIClient.shared.moneyVoucher(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.isSuccessful {
                        self.handleVoucherSuccess(response, requestId: requestId)
                    } else {
                        self.showErrorAlert(AppStrings.voucherTransferFailedValue(String(describing: response.message ?? AppStrings.unknownError2)))
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.option(apiError.message))
                    } else {
                        self.showErrorAlert(AppStrings.networkErrorValue(String(describing: error.localizedDescription)))
                    }
                }
            }
        }
    }

    private func checkWhetherRecipientIsSavedAndPresentSuccess() {
        let phoneNumber = userDataManager.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        let request = WalletBeneficiaryListRequest(
            phoneNumber: phoneNumber,
            requestId: newVoucherRequestId(),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: userDataManager.getUserCode().isEmpty ? phoneNumber : userDataManager.getUserCode()
        )
        APIClient.shared.listWalletBeneficiaries(request: request) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result, response.respCode == "000" {
                    isRecipientAlreadySaved = (response.result ?? []).contains { beneficiary in
                        beneficiary.isMoneyVoucherRecipient
                            && beneficiary.destination?.trimmingCharacters(in: .whitespacesAndNewlines)
                                == receiverPhone.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                } else {
                    isRecipientAlreadySaved = false
                }
                showSuccessDialog = true
            }
        }
    }

    private func saveRecipient() {
        guard !isSavingRecipient else { return }
        let phoneNumber = userDataManager.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        let destination = (shouldReturnHomeAfterSave ? pendingSavePhone : receiverPhone)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let name = shouldReturnHomeAfterSave ? pendingSaveName : recipientName
        guard !phoneNumber.isEmpty, !destination.isEmpty else {
            showErrorAlert(AppStrings.recipientDetailsAreUnavailableSoTheVoucherRecipientCouldNot)
            return
        }

        isSavingRecipient = true
        let request = WalletBeneficiaryAddRequest(
            phoneNumber: phoneNumber,
            destination: destination,
            institutionCode: "00100",
            transactionType: "43",
            name: name,
            requestId: newVoucherRequestId(),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: userDataManager.getUserCode().isEmpty ? phoneNumber : userDataManager.getUserCode()
        )
        APIClient.shared.addWalletBeneficiary(request: request) { result in
            DispatchQueue.main.async {
                isSavingRecipient = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    isRecipientAlreadySaved = true
                    alertTitle = AppStrings.recipientSaved
                    alertMessage = AppStrings.theVoucherRecipientHasBeenSaved
                    showAlert = true
                case .success(let response):
                    showErrorAlert(response.message ?? AppStrings.unableToSaveTheVoucherRecipient)
                case .failure(let error):
                    showErrorAlert((error as? APIError)?.message ?? AppStrings.unableToSaveTheVoucherRecipient)
                }
            }
        }
    }

    private func newVoucherRequestId() -> String {
        DateFormatter.with(format: "yyMMdd").string(from: Date())
            + String(format: "%06d", Int.random(in: 0...999999))
    }

    private func clearForm() {
        selectedSource = .wallet
        selectedWallet = nil
        receiverPhone = ""
        recipientName = ""
        recipientIdNumber = ""
        amount = ""
        paymentDetails = ""
        calculatedFee = 0
        totalAmountWithFee = 0
        feeRuleIndex = ""
        withdrawalFee = 0
        isWithdrawalFeeEnabled = false
        isRecipientAlreadySaved = false
    }

    private func finishAndReturnHome() {
        clearForm()
        shouldReturnHomeAfterSave = false
        pendingSavePhone = ""
        pendingSaveName = ""
        presentationMode.wrappedValue.dismiss()
    }

    // MARK: - Confirmation Dialog Overlay
    private var confirmationDialogOverlay: some View {
        Group {
            if showConfirmationDialog {
                VoucherConfirmationDialog(
                    amount: amount,
                    withdrawalFee: isWithdrawalFeeEnabled ? withdrawalFee : 0.0,
                    fee: calculatedFee,
                    total: totalAmountWithFee,
                    currency: defaultCurrency,
                    recipientName: recipientName.isEmpty ? AppStrings.destinataire2 : recipientName,
                    recipientPhone: receiverPhone,
                    title: AppStrings.transferConfirmation,
                    recipientIdNumber: recipientIdNumber,
                    moneyVoucherStyle: true,
                    paymentDetails: paymentDetails,
                    sourceType: selectedSource,
                    selectedWallet: selectedWallet,
                    isPresented: $showConfirmationDialog,
                    onConfirm: { pinCode in
                        showConfirmationDialog = false
                        processMoneyVoucher(with: pinCode)
                    },
                    onCancel: {
                        showConfirmationDialog = false
                    }
                )
                .onAppear {
                    //print("🔍 Dialog appeared with:")
                    //print("   Fee: \(self.calculatedFee)")
                    //print("   Total: \(self.totalAmountWithFee)")
                }
            }
        }
    }
}
