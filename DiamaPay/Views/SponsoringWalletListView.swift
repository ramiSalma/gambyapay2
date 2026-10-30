//
//  SponsoringWalletListView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  SponsoringWalletListView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import SwiftUI

struct SponsoringWalletListView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
     @State private var navigationPath = NavigationPath()
    
    // MARK: - State Variables
    @State private var wallets: [SponsoringWallet] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showEmptyState = false
    @State private var emptyStateMessage = AppStrings.noSponsoringWalletsFound
    
    // Selected wallet for actions
    @State private var selectedWallet: SponsoringWallet?
    @State private var showActionSheet = false
    @State private var showUnlinkConfirmation = false
    
    private let userDataManager = UserDataManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "F6F8FC")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.sponsoringWallets, headerColor: Color(hex: "174EA6"))

                if isLoading {
                    loadingView
                } else if showEmptyState {
                    emptyStateView
                } else {
                    walletListView
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .onAppear {
            loadSponsoringWallets()
        }
       
    }
    

    // MARK: - Title Card
    private var titleCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blueH)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text(AppStrings.walletsSponsoringYou)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 80, height: 3)
            }
            .padding(.vertical, 8)  // Reduce from 16 to 8
        }
        .frame(height: 64)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)

    }
    // MARK: - Wallet List View
    private var walletListView: some View {
        VStack(spacing: 0) {
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(wallets.enumerated()), id: \.element.id) { index, wallet in
                        WalletRowView(wallet: wallet)
                         
                        
                        if index < wallets.count - 1 {
                            Divider()
                                .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(16)
            }
        }
       
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text(AppStrings.loadingWallets)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            
            VStack(spacing: 16) {
                Spacer()
                
                Image(systemName: "tray")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(Color(hex: "0788B9"))
                
                Text(emptyStateMessage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(16)
            
        }
            .padding(.top, 20)
            .padding(.bottom, 30)
    }
    
    // MARK: - API Methods
    private func loadSponsoringWallets() {
        let phoneNumber = userDataManager.getPhoneNumber()
        let walletNumber = userDataManager.getWalletNumber()
        
        if phoneNumber.isEmpty && walletNumber.isEmpty {
            showEmptyState = true
            emptyStateMessage = AppStrings.walletInformationIsUnavailable
            return
        }
        
        isLoading = true
        
        var request = RequestListSponsoringWallets()
        
        if !walletNumber.isEmpty {
            request.source = "W"
            request.walletNumber = walletNumber
        } else {
            request.source = "P"
            request.phoneNumber = phoneNumber
        }
        
        request.bank = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        request.pin = userDataManager.getPinForAPI()
        
        // Generate requestId (yyMMdd + 6 random digits)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        // Generate requestDate
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.getSponsoringWallets(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        print("sponsoring response",response)
                        print("response: \(response)")

                        self.processResponse(response)
                    } else {
                        self.showEmptyState = true
                        self.emptyStateMessage = response.message ?? AppStrings.noSponsoringWalletsFound
                    }
                case .failure(let error):
                    self.showEmptyState = true
                    if let apiError = error as? APIError {
                        self.emptyStateMessage = apiError.message
                    } else {
                        self.emptyStateMessage = AppStrings.checkYourInternetConnection
                    }
                }
            }
        }
    }
    
    private func processResponse(_ response: JResponseService) {
        guard let resultList = response.result, !resultList.isEmpty else {
            showEmptyState = true
            emptyStateMessage = AppStrings.noSponsoringWalletsFound
            return
        }
        
        var parsedWallets: [SponsoringWallet] = []
        
        for sponsorData in resultList {
            guard let dict = sponsorData as? [String: Any] else { continue }
            
            var wallet = SponsoringWallet()
            wallet.walletNumber = dict["walletNumber"] as? String ?? ""
            wallet.walletNumberSponsored = dict["walletNumberSponsored"] as? String ?? ""
            wallet.userName = dict["userName"] as? String ?? dict["walletHolder"] as? String ?? AppStrings.notSpecified
            wallet.userNameSponsored = dict["userNameSponsored"] as? String ?? AppStrings.notSpecified
            wallet.phoneNumber = dict["phoneNumber"] as? String ?? ""
            wallet.phoneNumberSponsored = dict["phoneNumberSponsored"] as? String ?? ""
            
            // Handle dailyLimit
            if let dailyLimitInt = dict["dailyLimit"] as? Int {
                wallet.dailyLimit = String(format: "%.2f", Double(dailyLimitInt))
            } else if let dailyLimitDouble = dict["dailyLimit"] as? Double {
                wallet.dailyLimit = String(format: "%.2f", dailyLimitDouble)
            } else if let dailyLimitStr = dict["dailyLimit"] as? String {
                wallet.dailyLimit = dailyLimitStr
            } else {
                wallet.dailyLimit = "0.00"
            }
            
            // Handle monthlyLimit
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
            
            // Validate and add
            if !wallet.walletNumber.isEmpty {
                parsedWallets.append(wallet)
            }
            print("wallet: \(wallet)")
        }
        
        if parsedWallets.isEmpty {
            showEmptyState = true
            emptyStateMessage = AppStrings.noSponsoringWalletsFound
        } else {
            wallets = parsedWallets
            showEmptyState = false
        }
    }
    
    private func updateWalletLimit(_ wallet: SponsoringWallet) {
        // TODO: Navigate to update limit screen
        alertTitle = AppStrings.info
        alertMessage = AppStrings.miseAJourDeLaLimitePourValue(String(describing: wallet.userName))
        showAlert = true
    }
    
    private func unlinkWallet(_ wallet: SponsoringWallet) {
        // TODO: Implement unlink functionality
        alertTitle = AppStrings.info
        alertMessage = AppStrings.fonctionnaliteDeDissociationAImplementer
        showAlert = true
    }
}

// MARK: - Wallet Row View
struct WalletRowView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let wallet: SponsoringWallet
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.blueH.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text(wallet.userName.prefix(1).uppercased())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "174EA6"))
                }
                
                // Wallet Info (sponsor / parrain)
                VStack(alignment: .leading, spacing: 4) {
                    Text(wallet.userName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(wallet.phoneNumber)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(AppStrings.validUntilValue(String(describing: formattedExpiryDate)))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Limits
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(AppStrings.daily)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(formatAmount(wallet.dailyLimit))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "174EA6"))
                    }
                    
                    HStack(spacing: 4) {
                        Text(AppStrings.monthly)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(formatAmount(wallet.monthlyLimit))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "174EA6"))
                    }
                }
                
       
            }
            .padding(12)
        }
        .background(Color.white)
    }
    
    private var formattedExpiryDate: String {
        let endDate = wallet.endDate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !endDate.isEmpty, endDate.lowercased() != "null" else {
            return "**/**/**"
        }
        return formatDate(endDate)
    }
    
    private func formatDate(_ dateStr: String) -> String {
        let inputFormats = ["yyyyMMdd", "MM-dd-yyyy", "yyyy-MM-dd", "yyyyMMddHHmm"]
        
        for format in inputFormats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = formatter.date(from: dateStr) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "dd/MM/yyyy"
                outputFormatter.locale = Locale(identifier: "fr_FR")
                return outputFormatter.string(from: date)
            }
        }
        
        return "**/**/**"
    }
    
    private func formatAmount(_ amount: String) -> String {
        if let amountDouble = Double(amount) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: localization.language.rawValue)
            formatter.maximumFractionDigits = 0
            return (formatter.string(from: NSNumber(value: amountDouble)) ?? "0") + " GMD"
        }
        return "0 GMD"
    }
}

// MARK: - Preview
struct SponsoringWalletListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SponsoringWalletListView()
        }
    }
}
