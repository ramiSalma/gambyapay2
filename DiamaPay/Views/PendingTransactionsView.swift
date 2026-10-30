//
//  PendingTransactionsView.swift
//  DiamaPay
//
//  Created by Assistant on 1/12/2025.
//

import SwiftUI

struct PendingTransactionsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var pendingTransactions: [PendingTransaction] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = AppStrings.error
    @State private var alertMessage = ""
    @State private var showPinDialog = false
    @State private var selectedTransaction: PendingTransaction?
    @State private var selectedAction: String = ""
    
    private let userDataManager = UserDataManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "F6F8FC")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.pendingTransactions, headerColor: Color(hex: "174EA6"))
                
                if isLoading && pendingTransactions.isEmpty {
                    loadingView
                } else if pendingTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsList
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .onAppear(perform: loadPendingTransactions)
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) {
                if alertTitle == AppStrings.succes {
                    loadPendingTransactions()
                }
            }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .overlay {
            if showPinDialog, let transaction = selectedTransaction {
                PinDialogView1(
                    isPresented: $showPinDialog,
                    transaction: transaction,
                    action: selectedAction,
                    onConfirm: { pin in
                        validateTransaction(transaction, action: selectedAction, pin: pin)
                        showPinDialog = false
                    }
                )
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .frame(width: 88, height: 88)
                
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                        .scaleEffect(1.5)
                    
                    Text(AppStrings.loadingTransactions2)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "64748B"))
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Title Card
    private var titleCard: some View {
        Text(AppStrings.waitingForYourApproval)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "174EA6")))
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
    
    // MARK: - Transactions List
    private var transactionsList: some View {
        VStack(spacing: 0) {
            titleCard
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(pendingTransactions) { transaction in
                        PendingTransactionCard(
                            transaction: transaction,
                            onApprove: {
                                selectedTransaction = transaction
                                selectedAction = "A"
                                showPinDialog = true
                            },
                            onReject: {
                                selectedTransaction = transaction
                                selectedAction = "R"
                                showPinDialog = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            .refreshable {
                loadPendingTransactions()
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 54, weight: .light))
                .foregroundColor(Color(hex: "0788B9").opacity(0.65))
            
            VStack(spacing: 8) {
                Text(AppStrings.noPendingTransactions)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Text(AppStrings.youreAllCaughtUp)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "94A3B8"))
            }
            
            Spacer()
        }
        .padding(32)
    }
    
    // MARK: - Helper Methods
    private func loadPendingTransactions() {
        guard !isLoading else { return }
        
        isLoading = true
        
        var request = RequestListPendingTransactions()
        request.source = "W"
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.bank = userDataManager.getBankCode()
        request.pin = userDataManager.getPinForAPI()
        request.entityId = userDataManager.getUserCode()
        request.requestId = generateRequestId()
        request.requestDate = getCurrentTimestamp()
        
        APIClient.shared.getPendingTransactions(request: request) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let response):
                    handleSuccessResponse(response)
                case .failure(let error):
                    handleErrorResponse(error)
                }
            }
        }
    }
    
    private func handleSuccessResponse(_ response: JResponseService) {
        if response.respCode == "000" {
            parseTransactions(from: response)
        } else {
            showErrorAlert(response.message ?? AppStrings.couldNotLoadPendingTransactions)
        }
    }
    
    private func handleErrorResponse(_ error: Error) {
        if let apiError = error as? APIError {
            showErrorAlert(AppStrings.option(apiError.message))
        } else {
            showErrorAlert(AppStrings.networkErrorValue(String(describing: error.localizedDescription)))
        }
    }
    
    private func parseTransactions(from response: JResponseService) {
        pendingTransactions = (response.result as? [[String: Any]])?.compactMap { dict in
            var transaction = PendingTransaction()
            transaction.trxRef = dict["trxRef"] as? String
            transaction.authDate = dict["authDate"] as? String
            transaction.amount = dict["amount"] as? String
            transaction.agent = dict["agent"] as? String
            transaction.currency = dict["currency"] as? String
            transaction.tax = dict["tax"] as? String
            transaction.fees = dict["fees"] as? String
            transaction.type = dict["type"] as? String
            transaction.pCode = dict["pCode"] as? String
            transaction.details = dict["trxDetails"] as? String
            return transaction
        } ?? []
    }
    
    private func validateTransaction(_ transaction: PendingTransaction, action: String, pin: String) {
        guard !pin.isEmpty else {
            showErrorAlert(AppStrings.pinIsRequired)
            return
        }
        
        isLoading = true
        
        var request = RequestApproval()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.walletNumber = userDataManager.getWalletNumber()
        request.source = "W"
        request.bank = userDataManager.getBankCode()
        request.action = action
        request.pin = pin
        request.transactionRef = transaction.trxRef
        request.transactionType = transaction.pCode
        request.requestId = generateRequestId()
        request.requestDate = getCurrentTimestamp()
        request.entityId = userDataManager.getUserCode()
        
        APIClient.shared.validateTransaction(request: request) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        let actionText = action == "A" ? "approved" : "rejected"
                        showSuccessAlert(AppStrings.transactionValueSuccessfully(String(describing: actionText)))
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            loadPendingTransactions()
                        }
                    } else {
                        showErrorAlert(AppStrings.couldNotUpdateTransactionValue(String(describing: response.message ?? AppStrings.pleaseTryAgain)))
                    }
                case .failure(let error):
                    handleErrorResponse(error)
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
    
    private func generateRequestId() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        return datePrefix + randomDigits
    }
    
    private func getCurrentTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}

// MARK: - Preview
struct PendingTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PendingTransactionsView()
        }
    }
}

struct PendingTransactionCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let transaction: PendingTransaction
    let onApprove: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section with gray background
            VStack(spacing: 0) {
                // Header Row
                HStack(alignment: .center, spacing: 12) {
                    Text(transaction.transactionTypeDescription)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "174EA6"))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 10)
                
                // Amount Display
                Text(transaction.formattedAmount)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "0788B9"))
                    .tracking(-0.4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color(hex: "F4F8FD"))
            
            // Details Section
            VStack(spacing: 0) {
                detailRow(icon: "info.circle", label: AppStrings.reference, value: transaction.trxRef ?? "N/A")
                detailDivider
                detailRow(icon: "calendar", label: AppStrings.date, value: transaction.formattedDate)
                if let fees = transaction.fees, !fees.isEmpty, fees != "0", fees != "0.00" {
                    detailDivider
                    detailRow(icon: "plusminus", label: AppStrings.fees, value: fees)
                }
                if let tax = transaction.tax, !tax.isEmpty, tax != "0", tax != "0.00" {
                    detailDivider
                    detailRow(icon: "percent", label: AppStrings.tax, value: tax)
                }
                if let details = transaction.details, !details.isEmpty {
                    detailDivider
                    detailRow(icon: "text.alignleft", label: AppStrings.details, value: details)
                }
                
                if transaction.shouldShowBeneficiary {
                    detailDivider
                    detailRow(icon: "person", label: transaction.beneficiaryLabel, value: transaction.beneficiaryValue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // Action Buttons
            HStack(spacing: 12) {
                actionButton(title: AppStrings.reject, icon: "xmark", color: Color(hex: "DC2626"), isFilled: false, action: onReject)
                
                if transaction.pCode != "43" {
                    actionButton(title: AppStrings.approve, icon: "checkmark", color: Color(hex: "174EA6"), isFilled: true, action: onApprove)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "DCE5F1"), lineWidth: 1))
        .shadow(color: Color(hex: "174EA6").opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "0788B9"))
                .frame(width: 18, height: 18)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
                .lineLimit(1)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "334155"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 7)
    }
    
    private var detailDivider: some View {
        Rectangle()
            .fill(Color(hex: "F3F4F6"))
            .frame(height: 1)
            .padding(.leading, 32)
    }
    
    private func actionButton(title: String, icon: String, color: Color, isFilled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
            .font(.system(size: 16))
                
                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 15, weight: .bold))
                    .tracking(0)
            }
            .foregroundColor(isFilled ? .white : color)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(isFilled ? color : Color.clear)
            .overlay(isFilled ? nil : RoundedRectangle(cornerRadius: 16).stroke(color, lineWidth: 2))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PendingTransactionCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PendingTransactionCard(
                transaction: PendingTransaction(
                    trxRef: "2025012345",
                    authDate: "2025-01-15 14:30:00",
                    amount: "1500.00",
                    agent: "621234567",
                    currency: "GMD",
                    tax: "0",
                    fees: "0",
                    type: "Retrait",
                    pCode: "01",
                    details: nil
                ),
                onApprove: {},
                onReject: {}
            )
            .padding()
        }
        .background(Color.white)
    }
}

struct PinDialogView1: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var isPresented: Bool
    let transaction: PendingTransaction
    let action: String
    let onConfirm: (String) -> Void
    
    @State private var pin: String = ""
    @State private var showError: Bool = false
    @State private var isVerifyingPin: Bool = false
    @State private var errorMessage: String = ""
    @FocusState private var isPinFocused: Bool
    
    private var actionText: String {
        action == "A" ? "approuver" : "rejeter"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 0) {
                headerSection
                transactionDetails
                pinInput
                actionButtons
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPinFocused = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blueH.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "lock.shield")
                    .font(.system(size: 24))
                    .foregroundColor(.blueH)
            }
            
            Text(AppStrings.codePinRequis)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "1F2937"))
            
            Text(AppStrings.entrezVotreCodePinPourValueLaTransaction(String(describing: actionText)))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(.top, 32)
        .padding(.bottom, 24)
    }
    
    private var transactionDetails: some View {
        VStack(spacing: 12) {
            transactionDetailRow(label: AppStrings.type2, value: transaction.transactionTypeDescription, isBold: false)
            Divider().background(Color(hex: "E5E7EB"))
            transactionDetailRow(label: AppStrings.montant2, value: transaction.formattedAmount, isBold: true)
            Divider().background(Color(hex: "E5E7EB"))
            transactionDetailRow(label: AppStrings.reference3, value: transaction.trxRef ?? "N/A", isBold: false)
        }
        .padding(16)
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(12)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    private func transactionDetailRow(label: String, value: String, isBold: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: isBold ? .bold : .semibold))
                .foregroundColor(isBold ? .blueH : Color(hex: "1F2937"))
        }
    }
    
    private var pinInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppStrings.pin)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "374151"))
            
            WalletPINField(AppStrings.entrezVotreCodePin, text: $pin)
                .font(.system(size: 16, weight: .medium))
                .padding(16)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(showError ? Color(hex: "DC2626") : Color(hex: "D1D5DB"), lineWidth: 1.5))
                .cornerRadius(12)
                .keyboardType(.numberPad)
                .focused($isPinFocused)
                .onChange(of: pin) { newValue in
                    if newValue.count > 4 { pin = String(newValue.prefix(4)) }
                    showError = false
                    errorMessage = ""
                }
            
            if showError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage.isEmpty ? AppStrings.leCodePinEstObligatoire : errorMessage)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(hex: "DC2626"))
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
    
    private func verifyPin() {
        errorMessage = ""
        
        guard pin.isValidWalletPIN else {
            errorMessage = AppStrings.lePinDoitContenirExactement4Chiffres
            showError = true
            return
        }
        
        isVerifyingPin = true
        
        PinVerificationService.verify(pin: pin) { verifiedPin in
            isVerifyingPin = false
            onConfirm(verifiedPin)
        } onFailure: { message in
            isVerifyingPin = false
            errorMessage = message
            showError = true
            pin = ""
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { isPresented = false }) {
                Text(AppStrings.buttonTitle(AppStrings.annuler))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(12)
            }
            .disabled(isVerifyingPin)
            
            Button(action: { verifyPin() }) {
                Group {
                    if isVerifyingPin {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(AppStrings.buttonTitle(AppStrings.confirmer))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.blueH)
                .cornerRadius(12)
            }
            .disabled(isVerifyingPin)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

struct PinDialogView_Previews: PreviewProvider {
    static var previews: some View {
        PinDialogView1(
            isPresented: .constant(true),
            transaction: PendingTransaction(
                trxRef: "2025012345",
                authDate: "2025-01-15 14:30:00",
                amount: "1500.00",
                agent: "621234567",
                currency: "GMD",
                tax: "0",
                fees: "0",
                type: "Retrait",
                pCode: "01",
                details: nil
            ),
            action: "A",
            onConfirm: { _ in }
        )
    }
}
