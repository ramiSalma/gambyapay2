//
//  SponsoredWalletsListView.swift
//  DiamaPay
//
//

import SwiftUI

struct SponsoredWalletsListView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var sponsoredWallets: [SponsoredWallet] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showUpdateDialog = false
    @State private var selectedWallet: SponsoredWallet?
    @State private var showPinDialog = false
    @State private var showUnlinkAlert = false
    @State private var showSponsorForm = false
    @State private var pinDialogAction: PinDialogAction = .unlink
    
    private let userDataManager = UserDataManager.shared
    
    enum PinDialogAction {
        case unlink
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F6F8FC")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.sponsoredWallets, headerColor: Color(hex: "174EA6"))

                if isLoading {
                    loadingView
                } else {
                    contentView
                }
            }
            NavigationLink("", destination: SponsorWalletView(), isActive: $showSponsorForm)
                .hidden()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .onAppear {
            loadSponsoredWallets()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .alert(AppStrings.unlinkWallet, isPresented: $showUnlinkAlert) {
            Button(AppStrings.buttonTitle(AppStrings.cancel), role: .cancel) { }
            Button(AppStrings.buttonTitle(AppStrings.unlink), role: .destructive) {
                pinDialogAction = .unlink
                showPinDialog = true
            }
        } message: {
            if let wallet = selectedWallet {
                Text(AppStrings.areYouSureYouWantToUnlinkTheWalletFor(String(describing: wallet.userNameSponsored)))
            }
        }
        .sheet(isPresented: $showUpdateDialog) {
            if let wallet = selectedWallet {
                UpdateSponsoredWalletView(
                    wallet: wallet,
                    onSuccess: {
                        showUpdateDialog = false
                        loadSponsoredWallets()
                    }
                )
            }
        }
        .overlay(pinDialogOverlay)
        .overlay(alignment: .bottomTrailing) {
            Button { showSponsorForm = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 62, height: 62)
                    .background(Color(hex: "0788B9"), in: Circle())
                    .shadow(color: .black.opacity(0.18), radius: 7, x: 0, y: 4)
            }
            .accessibilityLabel(AppStrings.sponsorAWallet2)
            .padding(.trailing, 24)
            .padding(.bottom, 92)
        }
    }
    
    // MARK: - PIN Dialog Overlay
    private var pinDialogOverlay: some View {
        Group {
            if showPinDialog, let wallet = selectedWallet {
                PinDialogView(
                    isPresented: $showPinDialog,
                    title: pinDialogAction == .unlink ? AppStrings.unlinkWallet : "",
                    message: pinDialogAction == .unlink ? AppStrings.enterYourPinToConfirm : "",
                    onConfirm: { pin in
                        showPinDialog = false
                        if pinDialogAction == .unlink {
                            performUnlink(wallet: wallet, pin: pin)
                        }
                    }
                )
            }
        }
    }

    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "174EA6")))
            
            Text(AppStrings.loadingWallets)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 14) {
                if sponsoredWallets.isEmpty {
                    emptyStateView
                } else {
                    // Wallets List
                    VStack(spacing: 12) {
                        ForEach(sponsoredWallets, id: \.id) { wallet in
                            SponsoredWalletCard(
                                wallet: wallet,
                                onUpdate: {
                                    selectedWallet = wallet
                                    showUpdateDialog = true
                                },
                                onUnlink: {
                                    selectedWallet = wallet
                                    showUnlinkConfirmation(for: wallet)
                                }
                            )
                        }
                    }
                }
                
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 88)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 42))
                .foregroundColor(Color(hex: "174EA6").opacity(0.75))
                .padding(.top, 24)
            
            Text(AppStrings.noSponsoredWallets)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(AppStrings.youHaveNotSponsoredAnyWalletsYet)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
        .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Load Sponsored Wallets
    private func loadSponsoredWallets() {
        isLoading = true
        
        var request = RequestListSponsoredWallets()
        request.source = "P"
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.bank = "00100"
        request.pin = userDataManager.getPinForAPI()
        
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
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.getSponsoredWallets(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.processSponsoredWallets(response)
                    } else {
                        self.showError(AppStrings.error, response.message ?? AppStrings.unableToLoadWallets)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showError(AppStrings.error, apiError.message)
                    } else {
                        self.showError(AppStrings.error, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func processSponsoredWallets(_ response: JResponseService) {
        sponsoredWallets.removeAll()
        
        guard let resultList = response.result else { return }
        
        for sponsorData in resultList {
            guard let dict = sponsorData as? [String: Any] else { continue }
            
            var wallet = SponsoredWallet()
            wallet.walletNumber = dict["walletNumber"] as? String ?? ""
            wallet.walletNumberSponsored = dict["walletNumberSponsored"] as? String ?? ""
            wallet.userName = dict["userName"] as? String ?? ""
            wallet.userNameSponsored = dict["userNameSponsored"] as? String ?? AppStrings.notSpecified
            wallet.phoneNumber = dict["phoneNumber"] as? String ?? ""
            wallet.phoneNumberSponsored = dict["phoneNumberSponsored"] as? String ?? ""
            
            // Handle dailyLimit
            if let dailyLimitInt = dict["dailyLimit"] as? Int {
                wallet.dailyLimit = String(format: "%.0f", Double(dailyLimitInt))
            } else if let dailyLimitDouble = dict["dailyLimit"] as? Double {
                wallet.dailyLimit = String(format: "%.0f", dailyLimitDouble)
            } else if let dailyLimitStr = dict["dailyLimit"] as? String {
                wallet.dailyLimit = dailyLimitStr
            } else {
                wallet.dailyLimit = "0"
            }
            
            // Handle monthlyLimit
            if let monthlyLimitInt = dict["monthlyLimit"] as? Int {
                wallet.monthlyLimit = String(format: "%.0f", Double(monthlyLimitInt))
            } else if let monthlyLimitDouble = dict["monthlyLimit"] as? Double {
                wallet.monthlyLimit = String(format: "%.0f", monthlyLimitDouble)
            } else if let monthlyLimitStr = dict["monthlyLimit"] as? String {
                wallet.monthlyLimit = monthlyLimitStr
            } else {
                wallet.monthlyLimit = "0" 
            }
            
            wallet.startDate = dict["startDate"] as? String ?? ""
            wallet.endDate = dict["endDate"] as? String ?? ""
            wallet.bankCode = dict["bankCode"] as? String ?? ""
            wallet.bankWording = dict["bankWording"] as? String ?? ""
            wallet.creationTs = dict["creationTs"] as? String ?? ""
            
            if !wallet.walletNumberSponsored.isEmpty {
                sponsoredWallets.append(wallet)
            }
        }
    }
    
    // MARK: - Unlink Confirmation
    private func showUnlinkConfirmation(for wallet: SponsoredWallet) {
        showUnlinkAlert = true
    }
    
    private func performUnlink(wallet: SponsoredWallet, pin: String) {
        isLoading = true
        
        var request = SponsoredWalletDto()
        
        // User information
        let walletNumber = userDataManager.getWalletNumber()
        let phoneNumber = userDataManager.getPhoneNumber()
        let bankCode = userDataManager.getBankCode()
        
        // Set source
        if !walletNumber.isEmpty {
            request.source = "W"
            request.walletNumber = walletNumber
            request.phoneNumber = phoneNumber
        } else {
            request.source = "P"
            request.phoneNumber = phoneNumber
        }
        
        request.pin = pin
        request.bankCode = bankCode
        request.walletNumberSponsored = wallet.walletNumberSponsored
        request.phoneNumberSponsored = wallet.phoneNumberSponsored
        request.bankCodeSponsored = wallet.bankCode.isEmpty ? bankCode : wallet.bankCode
        request.dateStart = wallet.startDate
        request.dateEnd = wallet.endDate
        request.dailyLimit = wallet.dailyLimit.isEmpty ? "10" : wallet.dailyLimit
        request.monthlyLimit = wallet.monthlyLimit.isEmpty ? "120" : wallet.monthlyLimit
        
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
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.unlinkSponsoredWallet(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.showSuccess(AppStrings.walletUnlinkedSuccessfully)
                        self.loadSponsoredWallets()
                    } else {
                        self.showError(AppStrings.error, response.message ?? AppStrings.failedToUnlinkWallet)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showError(AppStrings.error, apiError.message)
                    } else {
                        self.showError(AppStrings.error, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func showError(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccess(_ message: String) {
        alertTitle = AppStrings.success
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Sponsored Wallet Card
struct SponsoredWalletCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let wallet: SponsoredWallet
    let onUpdate: () -> Void
    let onUnlink: () -> Void
    
    @State private var showMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(initials(for: wallet.userNameSponsored))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                    .frame(width: 42, height: 42)
                    .background(Color(hex: "E8F1FA"), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(wallet.userNameSponsored.isEmpty ? AppStrings.sponsoredWallet : wallet.userNameSponsored)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "17212F"))
                        .lineLimit(1)
                    Text(wallet.phoneNumberSponsored)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "586273"))
                }
                Spacer(minLength: 4)
                Button { showMenu = true } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "174EA6"))
                        .frame(width: 30, height: 34)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(AppStrings.walletOptions)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider().overlay(Color(hex: "E8EDF3"))

            HStack(alignment: .top, spacing: 0) {
                statColumn(title: AppStrings.dailyLimit, value: formatCurrency(wallet.dailyLimit))
                statDivider
                statColumn(title: AppStrings.monthlyLimit2, value: formatCurrency(wallet.monthlyLimit))
                statDivider
                statColumn(title: AppStrings.validity, value: compactDateRange(start: wallet.startDate, end: wallet.endDate))
            }
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(hex: "E2E7ED"), lineWidth: 1))
        .shadow(color: Color(hex: "13253A").opacity(0.06), radius: 5, x: 0, y: 2)
        .actionSheet(isPresented: $showMenu) {
            ActionSheet(
                title: Text(AppStrings.options),
                buttons: [
                    .default(Text(AppStrings.update)) {
                        onUpdate()
                    },
                    .destructive(Text(AppStrings.unlink)) {
                        onUnlink()
                    },
                    .cancel(Text(AppStrings.buttonTitle(AppStrings.cancel)))
                ]
            )
        }
    }
    
    private func formatCurrency(_ amount: String) -> String {
        guard let value = Double(amount), value > 0 else {
            return AppStrings.noLimit
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        formatter.maximumFractionDigits = 0
        
        return (formatter.string(from: NSNumber(value: value)) ?? amount) + " GMD"
    }

    private var statDivider: some View {
        Rectangle().fill(Color(hex: "EEF1F5")).frame(width: 1, height: 44)
    }

    private func statColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 11, weight: .medium)).foregroundColor(Color(hex: "586273"))
                .lineLimit(1).minimumScaleFactor(0.8)
            Text(value).font(.system(size: 12, weight: .semibold)).foregroundColor(Color(hex: "17212F"))
                .lineLimit(2).minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(whereSeparator: \.isWhitespace)
        let letters = parts.prefix(2).compactMap(\.first)
        return letters.isEmpty ? "SW" : String(letters).uppercased()
    }

    private func compactDateRange(start: String, end: String) -> String {
        let from = start.isEmpty || start == "null" ? "—" : formatDate(start)
        let to = end.isEmpty || end == "null" ? "—" : formatDate(end)
        return AppStrings.valueToValue(String(describing: from), String(describing: to))
    }
    
    private func formatDateRange(start: String, end: String) -> String {
        var result = ""
        
        if !start.isEmpty && start != "null" {
            result += AppStrings.fromValue(String(describing: formatDate(start)))
        } else {
            result += AppStrings.startDateNotSpecified
        }
        
        if !end.isEmpty && end != "null" {
            result += AppStrings.toValue(String(describing: formatDate(end)))
        } else if !start.isEmpty && start != "null" {
            result += AppStrings.noEndDate
        }
        
        return result
    }
    
    private func formatDate(_ dateStr: String) -> String {
        let inputFormats = ["yyyyMMdd", "MM-dd-yyyy", "yyyy-MM-dd", "dd/MM/yyyy", "dd-MM-yyyy", "yyyyMMddHHmm", "yyyy-MM-dd HH:mm:ss"]
        
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
        
        return dateStr
    }
}

// MARK: - PIN Dialog View
struct PinDialogView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let onConfirm: (String) -> Void
    
    @State private var pin: String = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
            Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                WalletPINField(AppStrings.pin, text: $pin)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                
                if showError {
                    Text(AppStrings.pleaseEnterYourPin)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.cancel))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        if (!pin.isValidWalletPIN) {
                            showError = true
                        } else {
                            showError = false
                            onConfirm(pin)
                        }
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.confirm))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blueH)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}

struct SponsoredWalletsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SponsoredWalletsListView()
        }
    }
}
