import SwiftUI

struct MobileMoneyView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedSource: SourceOfFunds = .wallet
    @State private var selectedWallet: SponsoringWallet?
    @State private var currentBalance = ""
    @State private var providers: [Provider] = []
    @State private var selectedProvider: Provider?
    @State private var isLoadingProviders = false
    @State private var providerError: String?
    @State private var receiverPhone = ""
    @State private var recipientName = ""
    @State private var amount = ""
    @State private var paymentReference = ""
    @State private var showContactPicker = false
    @State private var showSavedRecipients = false
    @State private var isSavingRecipient = false
    @State private var showPinConfirmation = false
    @State private var isSubmitting = false
    @State private var isVerifyingReceiver = false
    @State private var mobileMoneyAuthCode = ""
    @State private var showSuccessDialog = false
    @State private var transactionId = ""
    @State private var transactionDate = ""
    @State private var isRecipientAlreadySaved = false
    @State private var shouldReturnHomeAfterSave = false
    @State private var pendingSavePhone = ""
    @State private var pendingSaveName = ""
    @State private var pendingSaveProviderCode = ""
    @State private var showAlert = false
    @State private var alertTitle = AppStrings.error
    @State private var alertMessage = ""

    private let blue = Color(hex: "174EA6")
    private let cyan = Color(hex: "0788B9")
    private let user = UserDataManager.shared

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.mobileMoney, headerColor: blue)
                ScrollView {
                    VStack(spacing: 18) {
                        SourceOfFundsView(
                            onSourceChanged: { selectedSource = $0 },
                            onWalletChanged: { selectedWallet = $0 },
                            onBalanceChanged: { currentBalance = $0 },
                            walletTransferStyle: true,
                            blueAccent: false
                        )
                        providerCard
                        beneficiaryCard
                        amountCard
                        referenceCard
                        Button { validateAndConfirm() } label: {
                            Text(AppStrings.buttonTitle(isVerifyingReceiver ? AppStrings.verifying : (isSubmitting ? AppStrings.submitting : AppStrings.submit)))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 170, height: 54)
                                .background(blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(isSubmitting || isVerifyingReceiver)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 44)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .alert(alertTitle, isPresented: $showAlert) {
            if alertTitle == AppStrings.saveRecipient {
                Button(AppStrings.buttonTitle(AppStrings.save)) { saveRecipient() }
                Button(AppStrings.buttonTitle(AppStrings.notNow), role: .cancel) { finishAndReturnHome() }
            } else if alertTitle == AppStrings.recipientSaved {
                Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) {
                    if shouldReturnHomeAfterSave { finishAndReturnHome() }
                }
            } else {
                Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) {
                    if shouldReturnHomeAfterSave { finishAndReturnHome() }
                }
            }
        } message: { Text(AppStrings.option(alertMessage)) }
        .sheet(isPresented: $showContactPicker) {
            ContactPickerView(selectedPhone: $receiverPhone)
        }
        .sheet(isPresented: $showSavedRecipients) {
            SavedAccountRecipientsView(includeMobileMoneyRecipients: true) { beneficiary in
                receiverPhone = beneficiary.destination ?? ""
                recipientName = beneficiary.name ?? ""
                let savedProviderCode = beneficiary.destBankCode ?? beneficiary.bankCode
                if let savedProviderCode {
                    selectedProvider = providers.first {
                        $0.code == savedProviderCode || $0.id == savedProviderCode
                    } ?? selectedProvider
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSuccessDialog) {
            TransactionSuccessView(
                transactionId: transactionId,
                transactionDate: transactionDate,
                amount: amount,
                recipientName: recipientName,
                recipientPhone: receiverPhone,
                senderName: user.getUserName(),
                senderPhone: user.getPhoneNumber(),
                withdrawalFee: 0,
                fee: 0,
                total: Double(amount.cleanCurrencyValue()) ?? 0,
                currency: "GMD",
                paymentDetails: paymentReference,
                onClose: {
                    showSuccessDialog = false
                    let alreadySaved = isRecipientAlreadySaved
                    let recipientLabel = recipientName.isEmpty ? receiverPhone : recipientName
                    pendingSavePhone = receiverPhone
                    pendingSaveName = recipientName
                    pendingSaveProviderCode = selectedProvider?.code ?? selectedProvider?.id ?? ""
                    clearForm()
                    guard !alreadySaved else {
                        finishAndReturnHome()
                        return
                    }
                    shouldReturnHomeAfterSave = true
                    alertTitle = AppStrings.saveRecipient
                    alertMessage = AppStrings.wouldYouLikeToSaveValueForFutureMobileMoney(String(describing: recipientLabel))
                    showAlert = true
                }
            )
        }
        .overlay {
            if showPinConfirmation {
                VoucherConfirmationDialog(
                    amount: amount,
                    withdrawalFee: 0,
                    fee: 0,
                    total: Double(amount.cleanCurrencyValue()) ?? 0,
                    currency: "GMD",
                    recipientName: recipientName,
                    recipientPhone: receiverPhone,
                    title: AppStrings.confirmMobileMoney,
                    providerName: selectedProvider?.displayName ?? "",
                    mobileMoneyStyle: true,
                    paymentDetails: paymentReference,
                    sourceType: selectedSource,
                    selectedWallet: selectedWallet,
                    isPresented: $showPinConfirmation,
                    onConfirm: { pin in
                        showPinConfirmation = false
                        submitMobileMoney(pin: pin)
                    },
                    onCancel: { showPinConfirmation = false }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .task { loadProviders() }
    }

    private var providerCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle(AppStrings.providerDetails)
            Menu {
                ForEach(Array(providers.enumerated()), id: \.offset) { _, provider in
                    Button(AppStrings.buttonTitle(provider.displayName)) { selectedProvider = provider }
                }
            } label: {
                HStack {
                    if isLoadingProviders { ProgressView().tint(blue) }
                    Text(selectedProvider?.displayName ?? (isLoadingProviders ? AppStrings.loadingProviders : AppStrings.selectProvider))
                        .font(.system(size: 16))
                        .foregroundColor(selectedProvider.map { _ in Color.primary } ?? Color.secondary)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(blue)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "505A69"), lineWidth: 1.2))
                .contentShape(Rectangle())
            }
            .disabled(providers.isEmpty || isLoadingProviders)
            if let providerError {
                HStack {
                    Text(providerError).font(.caption).foregroundColor(.red)
                    Spacer()
                    Button(AppStrings.buttonTitle(AppStrings.retry), action: loadProviders).font(.caption).foregroundColor(blue)
                }
            }
        }
        .cardStyle()
    }

    private var beneficiaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle(AppStrings.beneficiaryDetails)
            HStack(alignment: .top, spacing: 8) {
                TextField(AppStrings.phoneNumber2, text: $receiverPhone.walletPhoneNumber())
                    .keyboardType(.numberPad)
                    .font(.system(size: 16))
                    .padding(.horizontal, 12)
                    .frame(height: 52)
                    .overlay(fieldBorder)
                    .onChange(of: receiverPhone) {
                        if receiverPhone.count > 10 { receiverPhone = String(receiverPhone.prefix(10)) }
                    }
                recipientAction(AppStrings.contacts, icon: "person.crop.rectangle.fill") { showContactPicker = true }
                recipientAction(AppStrings.saved, icon: "book.closed.fill") { showSavedRecipients = true }
            }
            TextField(AppStrings.beneficiaryName2, text: $recipientName)
                .font(.system(size: 16))
                .padding(.horizontal, 12)
                .frame(height: 52)
                .overlay(fieldBorder)
            Button(action: saveRecipient) {
                Label(AppStrings.buttonTitle(isSavingRecipient ? AppStrings.saving : AppStrings.saveRecipient2), systemImage: "bookmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(blue)
            }
            .disabled(isSavingRecipient || receiverPhone.isEmpty)
        }
        .cardStyle()
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle(AppStrings.amount)
            FormattedTextField(placeholder: AppStrings.enterAmountGmd, text: $amount, maxLength: 50, walletTransferStyle: true)
                .frame(maxWidth: .infinity, minHeight: 52)
                .overlay(fieldBorder)
        }
        .cardStyle()
    }

    private var referenceCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle(AppStrings.paymentReference)
            TextField(AppStrings.enterPaymentReference, text: $paymentReference)
                .font(.system(size: 16))
                .padding(.horizontal, 12)
                .frame(height: 52)
                .overlay(fieldBorder)
                .onChange(of: paymentReference) {
                    if paymentReference.count > 50 { paymentReference = String(paymentReference.prefix(50)) }
                }
        }
        .cardStyle()
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "505A69"), lineWidth: 1.2)
    }

    private func sectionTitle(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 17, weight: .bold)).foregroundColor(blue)
            Rectangle().fill(cyan).frame(width: 64, height: 2)
        }
    }

    private func recipientAction(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 23))
                    .frame(width: 46, height: 52)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(cyan, lineWidth: 1.2))
                Text(AppStrings.buttonTitle(title)).font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(cyan)
        }
    }

    private func loadProviders() {
        guard !isLoadingProviders else { return }
        isLoadingProviders = true
        providerError = nil
        APIClient.shared.getLoanProviders { result in
            DispatchQueue.main.async {
                isLoadingProviders = false
                switch result {
                case .success(let loadedProviders):
                    providers = loadedProviders
                    if selectedProvider.map({ _ in false }) ?? true { selectedProvider = loadedProviders.first }
                    if loadedProviders.isEmpty { providerError = AppStrings.noProvidersAreAvailable }
                case .failure(let error):
                    let cachedProviders = UserDataManager.shared.loadMobileMoneyProviders()
                    providers = cachedProviders
                    if selectedProvider == nil { selectedProvider = cachedProviders.first }
                    if cachedProviders.isEmpty {
                        providerError = (error as? APIError)?.message ?? AppStrings.unableToLoadProviders
                    }
                }
            }
        }
    }

    private func validateAndConfirm() {
        guard let provider = selectedProvider else {
            showError(AppStrings.pleaseSelectAProvider)
            return
        }
        let destinationPhone = receiverPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !destinationPhone.isEmpty else {
            showError(AppStrings.beneficiaryPhoneNumberIsRequired)
            return
        }
        guard let amountValue = Double(amount.cleanCurrencyValue()), amountValue > 0 else {
            showError(AppStrings.enterAValidAmount)
            return
        }
        let senderPhone = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        let walletNumber = user.getWalletNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !senderPhone.isEmpty, !walletNumber.isEmpty else {
            showError(AppStrings.yourWalletDetailsAreUnavailablePleaseSignInAgain)
            return
        }

        isVerifyingReceiver = true
        let request = RequestWalletToMobileMoneyNE(
            walletNumber: walletNumber,
            phoneNumber: senderPhone,
            source: "W",
            bank: user.getBankCode().isEmpty ? "00100" : user.getBankCode(),
            provider: provider.code ?? provider.id ?? "",
            receiverPhone: destinationPhone,
            requestId: newRequestId(),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: user.getUserCode().isEmpty ? senderPhone : user.getUserCode()
        )
        APIClient.shared.enquireMobileMoneyReceiver(request: request) { result in
            DispatchQueue.main.async {
                isVerifyingReceiver = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    guard let authCode = response.authCode, !authCode.isEmpty else {
                        showError(AppStrings.theReceiverWasFoundButVerificationCouldNotBeCompleted)
                        return
                    }
                    mobileMoneyAuthCode = authCode
                    recipientName = response.accountName
                        ?? response.resultString
                        ?? response.result?["accountName"] as? String
                        ?? response.result?["name"] as? String
                        ?? recipientName
                    showPinConfirmation = true
                case .success(let response):
                    mobileMoneyAuthCode = ""
                    showError(response.message ?? AppStrings.receiverPhoneNumberWasNotFoundForTheSelectedProvider)
                case .failure(let error):
                    mobileMoneyAuthCode = ""
                    showError((error as? APIError)?.message ?? AppStrings.unableToVerifyTheReceiverPhoneNumber)
                }
            }
        }
    }

    private func submitMobileMoney(pin: String) {
        guard !isSubmitting, let provider = selectedProvider else { return }
        let senderPhone = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        let walletNumber = user.getWalletNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !senderPhone.isEmpty, !walletNumber.isEmpty else {
            showError(AppStrings.yourWalletDetailsAreUnavailablePleaseSignInAgain)
            return
        }

        isSubmitting = true
        let requestId = DateFormatter.with(format: "yyMMdd").string(from: Date())
            + String(format: "%06d", Int.random(in: 0...999999))
        let request = RequestWalletToMobileMoney(
            walletNumber: walletNumber,
            phoneNumber: senderPhone,
            source: "W",
            amount: amount.cleanCurrencyValue(),
            provider: provider.code ?? provider.id ?? "",
            reason: String(paymentReference.prefix(25)),
            authCode: mobileMoneyAuthCode,
            receiverPhone: receiverPhone.trimmingCharacters(in: .whitespacesAndNewlines),
            pin: pin,
            requestId: requestId,
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: user.getUserCode().isEmpty ? senderPhone : user.getUserCode(),
            sponsorWallet: selectedSource == .sponsor ? selectedWallet?.walletNumber : nil
        )
        APIClient.shared.transferWalletToMobileMoney(request: request) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    transactionId = response.transactionReference.isEmpty ? requestId : response.transactionReference
                    transactionDate = response.transactionDateFormatted
                    checkWhetherRecipientIsSavedAndPresentSuccess()
                case .success(let response):
                    showError(response.message ?? AppStrings.mobileMoneyTransferFailed)
                case .failure(let error):
                    showError((error as? APIError)?.message ?? AppStrings.mobileMoneyTransferCouldNotBeConfirmedCheckTransactionHistory)
                }
            }
        }
    }

    private func newRequestId() -> String {
        DateFormatter.with(format: "yyMMdd").string(from: Date())
            + String(format: "%06d", Int.random(in: 0...999999))
    }

    private func clearForm() {
        selectedSource = .wallet
        selectedWallet = nil
        selectedProvider = nil
        receiverPhone = ""
        recipientName = ""
        amount = ""
        paymentReference = ""
        mobileMoneyAuthCode = ""
        isRecipientAlreadySaved = false
    }

    private func finishAndReturnHome() {
        clearForm()
        shouldReturnHomeAfterSave = false
        pendingSavePhone = ""
        pendingSaveName = ""
        pendingSaveProviderCode = ""
        presentationMode.wrappedValue.dismiss()
    }

    private func checkWhetherRecipientIsSavedAndPresentSuccess() {
        let phoneNumber = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        let request = WalletBeneficiaryListRequest(
            phoneNumber: phoneNumber,
            requestId: newRequestId(),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: user.getUserCode().isEmpty ? phoneNumber : user.getUserCode()
        )
        APIClient.shared.listWalletBeneficiaries(request: request) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result, response.respCode == "000" {
                    let selectedProviderCode = selectedProvider?.code ?? selectedProvider?.id
                    isRecipientAlreadySaved = (response.result ?? []).contains { beneficiary in
                        guard beneficiary.isMobileMoneyRecipient,
                              beneficiary.destination?.trimmingCharacters(in: .whitespacesAndNewlines) == receiverPhone.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
                        let savedProviderCode = beneficiary.destBankCode ?? beneficiary.bankCode
                        return savedProviderCode == nil || savedProviderCode?.isEmpty == true
                            || savedProviderCode == selectedProviderCode
                    }
                } else {
                    isRecipientAlreadySaved = false
                }
                showSuccessDialog = true
            }
        }
    }

    private func showError(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }

    private func saveRecipient() {
        guard !isSavingRecipient else { return }
        let senderPhone = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        let destination = (shouldReturnHomeAfterSave ? pendingSavePhone : receiverPhone)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let beneficiaryName = shouldReturnHomeAfterSave ? pendingSaveName : recipientName
        let providerCode = shouldReturnHomeAfterSave ? pendingSaveProviderCode : (selectedProvider?.code ?? selectedProvider?.id ?? "00100")
        guard !senderPhone.isEmpty, !destination.isEmpty else {
            showError(AppStrings.enterABeneficiaryPhoneNumberBeforeSaving)
            return
        }
        isSavingRecipient = true
        let request = WalletBeneficiaryAddRequest(
            phoneNumber: senderPhone,
            destination: destination,
            institutionCode: providerCode,
            transactionType: "70",
            name: beneficiaryName,
            requestId: DateFormatter.with(format: "yyMMdd").string(from: Date()) + String(format: "%06d", Int.random(in: 0...999999)),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: user.getUserCode().isEmpty ? senderPhone : user.getUserCode()
        )
        APIClient.shared.addWalletBeneficiary(request: request) { result in
            DispatchQueue.main.async {
                isSavingRecipient = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    isRecipientAlreadySaved = true
                    alertTitle = AppStrings.recipientSaved
                    alertMessage = AppStrings.theRecipientHasBeenSaved
                    showAlert = true
                case .success(let response):
                    showError(response.message ?? AppStrings.unableToSaveTheBeneficiary)
                case .failure(let error):
                    showError((error as? APIError)?.message ?? AppStrings.unableToSaveTheBeneficiary)
                }
            }
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
    }
}
