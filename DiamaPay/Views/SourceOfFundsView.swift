//
//  SourceOfFunds.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//

import SwiftUI;

// MARK: - Main Component
struct SourceOfFundsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @State private var hasInitialized = false
    @State private var selectedSource: SourceOfFunds = .wallet
    @State private var selectedWallet: SponsoringWallet? = nil
    @State private var sponsors: [SponsoringWallet] = []
    @State private var balance: String = "00.00"
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // User data manager
    private let userDataManager = UserDataManager.shared
    
    // Callbacks for parent views
    var onSourceChanged: ((SourceOfFunds) -> Void)?
    var onWalletChanged: ((SponsoringWallet?) -> Void)?
    var onBalanceChanged: ((String) -> Void)?
    var walletTransferStyle = false
    var blueAccent = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card with exact Android styling
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Source Selection Toggle
                sourceSelectionToggle
                
                // Sponsor Section (conditionally visible)
                if selectedSource == .sponsor {
                    sponsorSection
                }
                
                // Balance Display
                balanceSection
            }
            .padding(walletTransferStyle ? 15 : 24)
            .background(Color.white)
            .cornerRadius(walletTransferStyle ? 16 : 20)
            .overlay {
                if walletTransferStyle {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                }
            }
            .shadow(color: Color.black.opacity(0.1), radius: walletTransferStyle ? 8 : 6, x: 0, y: walletTransferStyle ? 4 : 2)
        }
        .padding(.vertical, walletTransferStyle ? 0 : 20)
        .background(walletTransferStyle ? Color.clear : Color(red: 0.95, green: 0.95, blue: 0.95))
        .onAppear {
            guard !hasInitialized else { return }
            hasInitialized = true
            selectedSource = .wallet
            balance = String(format: "%.2f", userDataManager.getAvailableBalance())
            loadSponsoringWallets()
        }
        .alert(AppStrings.errorHeading, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok)) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .overlay(
            // Loading Overlay
            Group {
                if isLoading {
                    LoadingOverlay(walletTransferStyle: walletTransferStyle)
                }
            }
        )
    }
    
    // MARK: - Header Section (exact match to Android)
    private var headerSection: some View {
        HStack(spacing: 12) {
            if walletTransferStyle {
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 4, height: 32)
                Text(AppStrings.sourceOfFunds)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blueH.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay(Image(systemName: "creditcard.fill").font(.system(size: 13)).foregroundColor(Color.blueH))
                Text(AppStrings.sourceDesFonds)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            }
            
            Spacer()
        }
        .padding(.bottom, walletTransferStyle ? 13 : 20)
    }
    
    // MARK: - Source Selection Toggle (exact Android layout)
    private var sourceSelectionToggle: some View {
        HStack(spacing: 0) {
            // My Wallet Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedSource = .wallet
                    onSourceChanged?(.wallet)
                    update()
                }
            }) {
                Text(AppStrings.buttonTitle(walletTransferStyle ? AppStrings.wallet : AppStrings.monPortefeuille))
                    .font(.system(size: walletTransferStyle ? 14 : 14, weight: .semibold))
                    .foregroundColor(selectedSource == .wallet ? .white : (walletTransferStyle ? Color.gray : Color.blueH))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedSource == .wallet ? (walletTransferStyle && !blueAccent ? Color(hex: "359B46") : Color.blueH) : Color.clear) // primary_green
                    .shadow(color: selectedSource == .wallet ? Color(red: 0.2, green: 0.7, blue: 0.4).opacity(0.3) : Color.clear, radius: 3)
            )
            
            // Sponsor Button
            Button(action: {
                if !sponsors.isEmpty && sponsors.count > 1 { // More than just placeholder
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSource = .sponsor
                        onSourceChanged?(.sponsor)
                        update()
                    }
                }
            }) {
                Text(AppStrings.buttonTitle(AppStrings.sponsor))
                    .font(.system(size: walletTransferStyle ? 14 : 14, weight: .semibold))
                    .foregroundColor(selectedSource == .sponsor ? .white : Color(red: 0.4, green: 0.4, blue: 0.4))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedSource == .sponsor ? (walletTransferStyle && !blueAccent ? Color(hex: "359B46") : Color.blueH) : Color.clear)
                    .shadow(color: selectedSource == .sponsor ? Color(red: 0.2, green: 0.7, blue: 0.4).opacity(0.3) : Color.clear, radius: 3)
            )
            .disabled(sponsors.isEmpty || sponsors.count <= 1)
            .opacity((sponsors.isEmpty || sponsors.count <= 1) ? 0.5 : 1.0)
        }
        .frame(height: walletTransferStyle ? 44 : 56)
        .padding(walletTransferStyle ? 0 : 4)
        .background(walletTransferStyle ? Color.gray.opacity(0.18) : Color(red: 0.98, green: 0.98, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            if !walletTransferStyle {
                RoundedRectangle(cornerRadius: 16).stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
            }
        }
        .padding(.bottom, walletTransferStyle ? 16 : 24)
    }
    
    // MARK: - Sponsor Section (exact Android behavior)
    private var sponsorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Sponsor Label (matches Android)
            Text(walletTransferStyle ? AppStrings.sponsorSection : AppStrings.selectionnerUnSponsor)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38)) // sponsor_label_color
                .padding(.bottom, 8)
            
            // Sponsor Dropdown (exact Android spinner behavior)
            Menu {
                ForEach(sponsors, id: \.id) { sponsor in
                    Button(action: {
                        selectedWallet = sponsor
                        onWalletChanged?(sponsor.walletNumber.isEmpty ? nil : sponsor)
                        if sponsor.userName != AppStrings.selectionnerUnSponsor {
                            getDailyLimit(for: sponsor)
                        } else {
                            balance = "00.00"
                        }
                    }) {
                        Text(AppStrings.buttonTitle(sponsor.walletNumber.isEmpty ? (walletTransferStyle ? AppStrings.selectASponsor : AppStrings.selectionnerUnSponsor) : (sponsor.userName.isEmpty ? (walletTransferStyle ? AppStrings.unnamedSponsor : AppStrings.sponsorSansNom) : sponsor.userName)))
                    }
                }
            } label: {
                HStack {
                    Text(selectedWallet?.walletNumber.isEmpty == false ? (selectedWallet?.userName ?? "") : (walletTransferStyle ? AppStrings.selectASponsor : AppStrings.selectionnerUnSponsor))
                        .font(.system(size: walletTransferStyle ? 14 : 14, weight: .medium))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
                .padding(.horizontal, 12)
                .frame(height: walletTransferStyle ? 46 : 48)
                .background(walletTransferStyle ? Color.white : Color(red: 0.96, green: 0.96, blue: 0.96))
                .overlay {
                    if walletTransferStyle {
                        RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.2)
                    }
                }
                .cornerRadius(walletTransferStyle ? 14 : 8)
            }
            .padding(.bottom, 16)
        }
    }
    
    private var walletTransferBalanceText: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_GM")
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let value = formatter.string(from: NSNumber(value: Double(balance) ?? 0)) ?? "0.00"
        if selectedSource == .wallet { return "\(value) GMD" }
        return selectedWallet?.walletNumber.isEmpty == false ? value : "00.00"
    }

    private var balanceSection: some View {
        VStack(spacing: 0) {
            if walletTransferStyle {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(walletTransferStyle ? (selectedSource == .wallet ? AppStrings.availableBalance2 : AppStrings.dailyLimitGmd) : balanceLabel)
                            .font(.system(size: 13, weight: .medium))
                            .tracking(0.5)
                            .foregroundColor(.secondary)
                        Text(walletTransferBalanceText)
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Spacer(minLength: 12)
                    Image(systemName: "wallet.bifold.fill")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.55))
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
            ZStack {
                // Premium gradient background (exact Android gradient)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blueH,
                        Color.blueH
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Balance Content (exact Android layout)
                VStack(spacing: 6) {
                    Text("GMD \(balance.formatAsCurrency())")  // ← Add .formatAsCurrency()
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(balanceLabel)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Rectangle()
                        .fill(.white.opacity(0.6))
                        .frame(width: 40, height: 2)
                        .padding(.top, 8)
                }
                .padding(24)
            }
            .frame(height: 110)
            .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Computed Properties (exact Android logic)
    private var balanceLabel: String {
        switch selectedSource {
        case .wallet:
            return AppStrings.availableBalance
        case .sponsor:
            return AppStrings.limiteQuotidienneGmd
        }
    }
    
    // MARK: - Methods (matching exact Android behavior)
    private func loadSponsoringWallets() {
        initProgress()
        
        // Create request exactly like Android
        var request = RequestListSponsoringWallets()
        request.source = "P"
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.bank = "00100"
        request.pin = userDataManager.getPinForAPI()
        
        // Generate requestId (exact Android format: yyMMdd + random 6 digits)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        // Generate requestDate (exact Android format: yyyy-MM-dd HH:mm:ss)
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        
        request.entityId = UserDataManager.shared.getUserCode()
        
        // Call API using your actual APIClient
        APIClient.shared.getSponsoringWallets(request: request) { result in
            DispatchQueue.main.async {
                self.dismissProgress()
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.processSponsoringWalletsResponse(response)
                    } else {
                        let errorMsg = response.message ?? (walletTransferStyle ? AppStrings.unableToLoadSponsorWallets : AppStrings.erreurLorsDeLaRecuperationDesPortefeuillesSponsors)
                        self.displayAlert(errorMsg)
                        self.disableSponsorOption()
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.displayAlert(walletTransferStyle ? AppStrings.errorValue(AppStrings.option(apiError.message)) : AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.displayAlert(walletTransferStyle ? AppStrings.networkErrorValue(String(describing: error.localizedDescription)) : AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                    self.disableSponsorOption()
                }
            }
        }
    }
    
    private func processSponsoringWalletsResponse(_ response: JResponseService) {
        sponsors = [SponsoringWallet.placeholder]
        
        if let resultList = response.result {
            for sponsorData in resultList {
                guard let dict = sponsorData as? [String: Any] else { continue }
                
                var wallet = SponsoringWallet()
                wallet.walletNumber = dict["walletNumber"] as? String ?? ""
                wallet.walletNumberSponsored = dict["walletNumberSponsored"] as? String ?? ""
                wallet.userName = dict["userName"] as? String ?? ""
                wallet.userNameSponsored = dict["userNameSponsored"] as? String ?? ""
                wallet.phoneNumber = dict["phoneNumber"] as? String ?? ""
                wallet.phoneNumberSponsored = dict["phoneNumberSponsored"] as? String ?? ""
                
                if let dailyLimitInt = dict["dailyLimit"] as? Int {
                    wallet.dailyLimit = String(format: "%.2f", Double(dailyLimitInt))
                } else if let dailyLimitDouble = dict["dailyLimit"] as? Double {
                    wallet.dailyLimit = String(format: "%.2f", dailyLimitDouble)
                } else if let dailyLimitStr = dict["dailyLimit"] as? String {
                    wallet.dailyLimit = dailyLimitStr
                } else {
                    wallet.dailyLimit = "0.00"
                }

                // Handle monthlyLimit - can be Int, Double, or String
                if let monthlyLimitInt = dict["monthlyLimit"] as? Int {
                    wallet.monthlyLimit = String(format: "%.2f", Double(monthlyLimitInt))
                } else if let monthlyLimitDouble = dict["monthlyLimit"] as? Double {
                    wallet.monthlyLimit = String(format: "%.2f", monthlyLimitDouble)
                } else if let monthlyLimitStr = dict["monthlyLimit"] as? String {
                    wallet.monthlyLimit = monthlyLimitStr
                } else {
                    wallet.monthlyLimit = "0.00"
                }
                wallet.startDate = dict["startDate"] as? String ?? ""
                wallet.endDate = dict["endDate"] as? String ?? ""
                wallet.bankCode = dict["bankCode"] as? String ?? ""
                wallet.bankWording = dict["bankWording"] as? String ?? ""
                wallet.creationTs = dict["creationTs"] as? String ?? ""
                
                // Validation
                if wallet.userName.isEmpty {
                    wallet.userName = AppStrings.sponsorSansNom
                }
                
                if wallet.walletNumber.isEmpty {
                    continue
                }
                
                if wallet.dailyLimit.isEmpty {
                    wallet.dailyLimit = "0.00"
                }
                
                sponsors.append(wallet)
            }
        }
        
        if sponsors.count <= 1 {
            disableSponsorOption()
        }
        
        update()
    }
    
    private func getDailyLimit(for wallet: SponsoringWallet) {
        guard wallet.userName != AppStrings.selectionnerUnSponsor,
              !wallet.walletNumber.isEmpty else {
            balance = "00.00"
            return
        }
        
        updateBalanceDisplay(wallet.dailyLimit.isEmpty ? "0.00" : wallet.dailyLimit)
    }
    
    
    private func updateBalanceDisplay(_ balanceStr: String) {
        // Store the clean value (without formatting)
        if let amount = Double(balanceStr) {
            if amount < 10 {
                balance = String(format: "0%.2f", amount)
            } else {
                balance = String(format: "%.2f", amount)
            }
        } else {
            balance = "00.00"
        }
        // Pass formatted value to callback
        onBalanceChanged?("GMD \(balance.formatAsCurrency())")
    }
    
    private func update() {
        // Exact Android update() method logic
        let sourceOfFunds = selectedSource
        
        if sourceOfFunds == .sponsor {
            if let wallet = selectedWallet, !wallet.walletNumber.isEmpty {
                onWalletChanged?(wallet)
                getDailyLimit(for: wallet)
            } else {
                balance = "00.00"
                onWalletChanged?(nil)
            }
        } else if sourceOfFunds == .wallet {
            // Hide sponsor elements (handled by conditional rendering)
            fetchWalletBalance()
        }
    }
    private func fetchWalletBalance() {
        balance = String(format: "%.2f", userDataManager.getAvailableBalance())
        onBalanceChanged?("GMD \(balance.formatAsCurrency())")
        guard walletTransferStyle else { return }
        APIClient.shared.getBalance { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    userDataManager.saveWalletBalance(availableAmount: response.availableAmount,
                                                      totalAmount: response.totalAmount,
                                                      currency: response.currency)
                    guard selectedSource == .wallet else { return }
                    balance = String(format: "%.2f", response.availableAmount)
                    onBalanceChanged?("GMD \(balance.formatAsCurrency())")
                case .failure:
                    // Keep the last known balance when the refresh is unavailable.
                    break
                }
            }
        }
    }

    private func disableSponsorOption() {
        // In SwiftUI, this is handled by the disabled modifier on the button
        // The button is already disabled when sponsors.count <= 1
    }
    
    private func initProgress() {
        isLoading = true
    }
    
    private func dismissProgress() {
        isLoading = false
    }
    
    private func displayAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func getSelectedWallet() -> SponsoringWallet? {
        if selectedSource == .sponsor,
           let wallet = selectedWallet,
           wallet.userName != AppStrings.selectionnerUnSponsor {
            return wallet
        }
        return nil
    }
    
    func getSelectedSourceOfFunds() -> SourceOfFunds {
        return selectedSource
    }
    
    func getBalance() -> String {
        return "GMD \(balance.formatAsCurrency())"
    }
}

struct LoadingOverlay: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    var walletTransferStyle = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                
                Text(walletTransferStyle ? AppStrings.pleaseWait : AppStrings.veuillezPatienter)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

