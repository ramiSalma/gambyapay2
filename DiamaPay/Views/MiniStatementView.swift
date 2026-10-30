//
//  MiniStatementView.swift
//  DiamaPay
//
//  Created by Bits on [Date]
//

import SwiftUI

struct MiniStatementView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var dateFrom: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var dateTo: Date = Date()
    @State private var dateFromString: String = ""
    @State private var dateToString: String = ""
    @State private var showDateFromPicker = false
    @State private var showDateToPicker = false
    
    @State private var transactions: [TransactionItem] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.error
    @State private var showEmptyState = false
    
    @State private var verifiedPin: String = ""
    @State private var showPinDialog = false
    
    private let userDataManager = UserDataManager.shared
    
    // Date formatters
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.miniStatement, headerColor: Color(hex: "174EA6"))

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
                            // Title Card
                            
                            // Date Filter Card (Hidden by default like Android)
                            // dateFilterCard
                            
                            // Action Buttons
                            actionButtonsSection
                            
                            // Info Text
                            infoText
                            
                            // Transactions List or Empty State
                            if showEmptyState {
                                emptyStateView
                            } else {
                                transactionsListView
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            // PIN Dialog Overlay
            if showPinDialog {
                PinEntryDialog(
                    isPresented: $showPinDialog,
                    onConfirm: { pin in
                        verifiedPin = pin
                        userDataManager.savePinForAPI(pin)
                        showPinDialog = false
                        fetchTransactions()
                    },
                    onCancel: {
                        showPinDialog = false
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .sheet(isPresented: $showDateFromPicker) {
            DatePickerSheet(
                selectedDate: $dateFrom,
                dateString: $dateFromString,
                title: AppStrings.dateDeDebut
            )
        }
        .sheet(isPresented: $showDateToPicker) {
            DatePickerSheet(
                selectedDate: $dateTo,
                dateString: $dateToString,
                title: AppStrings.dateDeFin
            )
        }
        .onAppear {
            // Initialize date strings
            dateFromString = displayDateFormatter.string(from: dateFrom)
            dateToString = displayDateFormatter.string(from: dateTo)
            
            promptForPin()
        }
    }
    
    // MARK: - Title Card
    private var titleCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blueH)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text(AppStrings.miniReleve)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 80, height: 3)
            }
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Date Filter Card (Hidden by default)
    private var dateFilterCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // Date From
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.de)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showDateFromPicker = true
                    }) {
                        HStack {
                            Text(dateFromString)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "calendar")
                                .foregroundColor(.blueH)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                        .cornerRadius(8)
                    }
                }
                
                // Date To
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.a)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showDateToPicker = true
                    }) {
                        HStack {
                            Text(dateToString)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "calendar")
                                .foregroundColor(.blueH)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Download Statement Button (full width like Android)
            Button(action: {
                validateAndDownloadStatement()
            }) {
                Text(AppStrings.buttonTitle(AppStrings.telechargerLeReleve))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blueH)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blueH, lineWidth: 2)
                    )
                    .cornerRadius(12)
            }
            .disabled(isLoading)
        }
        .padding(.horizontal, 0)
    }
    
    // MARK: - Info Text
    private var infoText: some View {
        Text(AppStrings.laRechercheAfficheLes5DernieresTransactions)
            .font(.system(size: 12, weight: .regular))
            .italic()
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }
    
    // MARK: - Transactions List View
    private var transactionsListView: some View {
        VStack(spacing: 12) {
            ForEach(transactions) { transaction in
                TransactionRowViewA(transaction: transaction)
                    .onTapGesture {
                        // Handle transaction tap if needed
                        //print("Transaction tapped: \(transaction.transactionReference ?? "N/A")")
                    }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 40)
            
            Text(AppStrings.aucuneTransaction)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(AppStrings.ilNYAPasDeTransactionsPourLaPeriode)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Helper Methods
    private func promptForPin() {
        showPinDialog = true
    }
    
    private func validateAndRequestTransactions() {
        if verifiedPin.isEmpty {
            promptForPin()
            return
        }
        fetchTransactions()
    }
    
    private func validateAndDownloadStatement() {
        if verifiedPin.isEmpty {
            promptForPin()
            return
        }
        downloadEStatement()
    }
    
    private func fetchTransactions() {
        isLoading = true
        showEmptyState = false
        
        let request = prepareTransactionRequest()
        
        APIClient.shared.getLast5Transactions(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.processTransactionResponse(response)
                    } else {
                        self.showErrorAlert(response.message ?? AppStrings.echecDeLaRecuperationDesTransactions)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurDeConnexionVerifiezVotreInternet)
                    }
                }
            }
        }
    }
    
    private func downloadEStatement() {
        isLoading = true
        
        let request = prepareEStatementRequest()
        
        APIClient.shared.downloadEStatement(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.showSuccessAlert(AppStrings.releveTelechargeAvecSucces)
                    } else {
                        self.showErrorAlert(response.message ?? AppStrings.echecDuTelechargementDuReleve)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurDeConnexionVerifiezVotreInternet)
                    }
                }
            }
        }
    }
    
    private func prepareTransactionRequest() -> RequestLast5Transactions {
        var request = RequestLast5Transactions()
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.source = "W"
        request.pin = verifiedPin
        request.bank = userDataManager.getBankCode()
        request.dateFrom = apiDateFormatter.string(from: dateFrom)
        request.dateTo = apiDateFormatter.string(from: dateTo)
        
        // Generate requestId
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        let requestId = String((datePrefix + randomDigits).prefix(12))
        request.requestId = requestId
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = userDataManager.getUserCode()
        request.type = "P"
        
        return request
    }
    
    private func prepareEStatementRequest() -> RequestEStatement {
        var request = RequestEStatement()
        request.walletNumber = userDataManager.getWalletNumber()
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.source = "W"
        request.pin = verifiedPin
        request.bank = userDataManager.getBankCode()
        request.dateFrom = apiDateFormatter.string(from: dateFrom)
        request.dateTo = apiDateFormatter.string(from: dateTo)
        
        // Generate requestId
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        let requestId = String((datePrefix + randomDigits).prefix(12))
        request.requestId = requestId
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = userDataManager.getUserCode()
        request.type = "P"
        request.campaignId = ""
        request.groupId = ""
        
        return request
    }
    
    private func processTransactionResponse(_ response: JResponseService) {
        guard let resultList = response.result, !resultList.isEmpty else {
            showEmptyState = true
            transactions = []
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: resultList)
            let decoder = JSONDecoder()
            var processedTransactions = try decoder.decode([TransactionItem].self, from: jsonData)
            
            // Assign unique IDs
            for i in 0..<processedTransactions.count {
                processedTransactions[i].id = UUID().uuidString
            }
            
            if processedTransactions.isEmpty {
                showEmptyState = true
            } else {
                transactions = processedTransactions
                showEmptyState = false
            }
        } catch {
            //print("Error decoding transactions: \(error)")
            showEmptyState = true
            transactions = []
        }
    }
    
    private func showErrorAlert(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
        showEmptyState = true
    }
    
    private func showSuccessAlert(_ message: String) {
        alertTitle = AppStrings.succes
        alertMessage = message
        showAlert = true
    }
}
// MARK: - Transaction Row View
struct TransactionRowViewA: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let transaction: TransactionItem
    
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }()
    
    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.cleanDescription)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formattedAmount)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(amountColor)
            }
            
            // Reference Row
            if let reference = transaction.transactionReference, !reference.isEmpty {
                HStack {
                    Text(AppStrings.ref)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(reference)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Balance Row
            if let balance = transaction.closingBalance, !balance.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Text(AppStrings.solde2)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(formatNumber(balance)) \(transaction.currency ?? "GMD")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var formattedDate: String {
        guard let dateStr = transaction.transactionDate else { return "" }
        
        if let date = apiDateFormatter.date(from: dateStr) {
            return displayDateFormatter.string(from: date)
        }
        
        return dateStr
    }
    
    private var formattedAmount: String {
        guard let amountStr = transaction.amount else { return "0 GMD" }
        let amount = formatNumber(amountStr)
        let currency = transaction.currency ?? "GMD"
        
        if transaction.isDebit {
            return "- \(amount) \(currency)"
        } else {
            return "+ \(amount) \(currency)"
        }
    }
    
    private var amountColor: Color {
        if transaction.isDebit {
            return .red
        } else {
            return .green
        }
    }
    
    private func formatNumber(_ numberStr: String) -> String {
        let cleanedStr = numberStr.replacingOccurrences(of: ",", with: ".")
        guard let number = Double(cleanedStr) else { return numberStr }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: number)) ?? numberStr
    }
}
// MARK: - Preview
struct MiniStatementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MiniStatementView()
        }
    }
}
