//
//  DiamaPayHomeView.swift (Optimized)
//  DiamaPay
//

import SwiftUI

struct DiamaPayHomeView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var showDrawer = false
    @State private var isFloatingMenuExpanded = false
    
    var body: some View {
            ZStack {
                mainContent
                overlays
                sideMenu
                floatingActionButton
                adPopup
                navigationLinks
            }
            .navigationBarHidden(true)
        }
       
    private var mainContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                HeaderSection(
                    userName: viewModel.userName,
                    balance: viewModel.balance,
                    currency: viewModel.currency,
                    isBalanceVisible: $viewModel.isBalanceVisible,
                    onTransactionsTap: { viewModel.navigate(to: .transactions) }
                )

                OrderFoodHomeBanner {
                    viewModel.navigateToOrderFood = true
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 26)
                
                VStack(spacing: 26) {
                    TransfersSection(onTransferTap: viewModel.navigate)
                    PromotionsSection(
                        ads: viewModel.ads,
                        onAdTap: viewModel.selectAd
                    )
                }
                .padding(.top, 28)
            }
        }
        .background(Color.white)
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeHeaderBar(onMenuTap: { withAnimation { showDrawer.toggle() } })
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(
                onSponsors: { viewModel.navigateToSponsoring = true },
                onQR: { viewModel.navigate(to: .qr) },
                onLimits: { viewModel.navigate(to: .limits) },
                onSettings: { viewModel.navigateToSettings = true }
            )
        }
        .onAppear(perform: viewModel.onAppear)
        .disabled(showDrawer || isFloatingMenuExpanded || viewModel.showAdPopup)
        .blur(radius: blurRadius)
        .refreshable { await viewModel.refreshBalance() }
    }
    
    private var blurRadius: CGFloat {
        if showDrawer { return 5 }
        if isFloatingMenuExpanded { return 3 }
        if viewModel.showAdPopup { return 5 }
        return 0
    }
    
    // MARK: - Overlays
    private var overlays: some View {
        Group {
            if showDrawer || isFloatingMenuExpanded {
                Color.black.opacity(showDrawer ? 0.3 : 0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showDrawer = false
                            isFloatingMenuExpanded = false
                        }
                    }
            }
        }
    }
    
    // MARK: - Side Menu
    private var sideMenu: some View {
        HStack(spacing: 0) {
            if showDrawer {
                SideMenuView { selected in
                    viewModel.handleMenuSelection(selected, authManager: authManager)
                    withAnimation { showDrawer = false }
                }
                .frame(width: 300)
                .transition(.move(edge: .leading))
            }
            Spacer()
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        EmptyView()
    }
    
    // MARK: - Ad Popup
    private var adPopup: some View {
        Group {
            if viewModel.showAdPopup, let ad = viewModel.selectedAd {
                AdPopupView(ad: ad, isPresented: $viewModel.showAdPopup) {
                    viewModel.markAdAsViewed(ad)
                }
                .zIndex(100)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    }
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            NavigationLink("", destination: MyProfileView(), isActive: $viewModel.navigateToProfile)
            NavigationLink("", destination: AllBeneficiariesView(), isActive: $viewModel.navigateToBeneficiaries)
            NavigationLink("", destination: SettingsView(onReturnHome: { viewModel.navigateToSettings = false }), isActive: $viewModel.navigateToSettings)
            NavigationLink("", destination: WalletTransferView(onOpenSettings: { showDrawer = true }), isActive: $viewModel.navigateToWalletTransfer)
            NavigationLink("", destination: WalletToAccountTransferView(), isActive: $viewModel.navigateToWalletToAccountTransfer)
            NavigationLink("", destination: TransactionHistoryView(), isActive: $viewModel.navigateToTransactions)
            NavigationLink("", destination: AccountToWalletTransferView(), isActive: $viewModel.navigateToAccountToWalletTransfer)
            NavigationLink("", destination: MoneyVoucherView(), isActive: $viewModel.navigateToMoneyVoucher)
            NavigationLink("", destination: MobileMoneyView(), isActive: $viewModel.navigateToMobileMoney)
            NavigationLink("", destination: LinkedAccountsListView(), isActive: $viewModel.navigateToLinkedAccounts)
            NavigationLink("", destination: CrowdfundingView(), isActive: $viewModel.navigateToCrowdfunding)
            NavigationLink("", destination: StandingInstructionListView(), isActive: $viewModel.navigateToSI)
            NavigationLink("", destination: SponsoredWalletsListView(), isActive: $viewModel.navigateToSponsored)
            NavigationLink("", destination: SponsoringWalletListView(), isActive: $viewModel.navigateToSponsoring)
            NavigationLink("", destination: SponsorWalletView(), isActive: $viewModel.navigateToSponsor)
            NavigationLink("", destination: FAQView(), isActive: $viewModel.navigateToFAQ)
            NavigationLink("", destination: ChangePinView(), isActive: $viewModel.navigateToPin)
            NavigationLink("", destination: PendingTransactionsView(), isActive: $viewModel.navigateToPending)
            NavigationLink("", destination: MiniStatementView(), isActive: $viewModel.navigateToStatement)
            NavigationLink("", destination: SendCommentsView(), isActive: $viewModel.navigateToComment)
            NavigationLink("", destination: FileComplaintView(), isActive: $viewModel.navigateToComplaint)
            NavigationLink("", destination: QRPaymentView(), isActive: $viewModel.navigateToQR)
            NavigationLink("", destination: WalletDeactivationView(), isActive: $viewModel.navigateToDeactivate)
            NavigationLink("", destination: BiometricSettingsView(), isActive: $viewModel.navigateToBiometric)
            NavigationLink("", destination: CheckLimitView(onOpenSettings: { showDrawer = true }), isActive: $viewModel.navigateToLimits)
            NavigationLink("", destination: TermsAndConditionsView(), isActive: $viewModel.navigateToTerms)
            NavigationLink("", destination: RechargeServiceView(isData: false), isActive: $viewModel.navigateToPhoneCredit)
            NavigationLink("", destination: RechargeServiceView(isData: true), isActive: $viewModel.navigateToBuyData)
            NavigationLink("", destination: BillPayProvidersView(), isActive: $viewModel.navigateToBills)
            NavigationLink("", destination: OrderFoodView(), isActive: $viewModel.navigateToOrderFood)
            NavigationLink("", destination: OrderFoodView(initiallyShowingHistory: true), isActive: $viewModel.navigateToFoodHistory)
            NavigationLink("", destination: FoodComplaintsView(), isActive: $viewModel.navigateToFoodComplaints)
            NavigationLink("", destination: LoanRequestView(), isActive: $viewModel.navigateToLoanRequest)
            NavigationLink("", destination: LoanRequestsView(), isActive: $viewModel.navigateToLoanRequests)
            NavigationLink("", destination: LoanHelpView(), isActive: $viewModel.navigateToLoanHelp)
            NavigationLink("", destination: SavingsWalletView(), isActive: $viewModel.navigateToSavings)
            NavigationLink("", destination: SavingsWalletStatementView(), isActive: $viewModel.navigateToSavingsStatement)

        }
    }
}

private struct OrderFoodHomeBanner: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [Color(hex: "245DAA"), Color(hex: "9BAFC8")], startPoint: .leading, endPoint: .trailing))

                HStack(spacing: 16) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Color(hex: "174EA6"))
                        .frame(width: 46, height: 46)
                        .background(Color.white.opacity(0.94), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.buttonTitle(AppStrings.orderFood))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Text(AppStrings.buttonTitle(AppStrings.fastDelivery))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
                .padding(.horizontal, 18)

                HStack(spacing: 28) {
                    Image(systemName: "fork.knife")
                    Image(systemName: "birthday.cake")
                    Image(systemName: "cup.and.saucer")
                }
                .font(.system(size: 42, weight: .light))
                .foregroundColor(.white.opacity(0.07))
                .offset(x: 225, y: -29)
                .allowsHitTesting(false)
            }
            .frame(height: 92)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppStrings.orderFoodFastLocalDelivery)
    }
}

// MARK: - View Model
@MainActor
class HomeViewModel: ObservableObject {
    @Published var userName = ""
    @Published var balance = "000.00"
    @Published var currency = "GMD"
    @Published var isBalanceVisible = false
    @Published var ads: [Advertisement] = []
    @Published var showAdPopup = false
    @Published var selectedAd: Advertisement?
    
    // Navigation states
    @Published var navigateToWalletTransfer = false
    @Published var navigateToWalletToAccountTransfer = false
    @Published var navigateToAccountToWalletTransfer = false
    @Published var navigateToTransactions = false
    @Published var navigateToMoneyVoucher = false
    @Published var navigateToMobileMoney = false
    @Published var navigateToLinkedAccounts = false
    @Published var navigateToCrowdfunding = false
    @Published var navigateToSI = false
    @Published var navigateToSponsored = false
    @Published var navigateToSponsoring = false
    @Published var navigateToSponsor = false
    @Published var navigateToFAQ = false
    @Published var navigateToPin = false
    @Published var navigateToPending = false
    @Published var navigateToStatement = false
    @Published var navigateToComment = false
    @Published var navigateToComplaint = false
    @Published var navigateToQR = false
    @Published var navigateToDeactivate = false
    @Published var navigateToBiometric = false
    @Published var navigateToLimits = false
    @Published var navigateToTerms = false
    @Published var navigateToProfile = false
    @Published var navigateToBeneficiaries = false
    @Published var navigateToPhoneCredit = false
    @Published var navigateToBuyData = false
    @Published var navigateToBills = false
    @Published var navigateToSettings = false
    @Published var navigateToOrderFood = false
    @Published var navigateToFoodHistory = false
    @Published var navigateToFoodComplaints = false
    @Published var navigateToLoanRequest = false
    @Published var navigateToLoanRequests = false
    @Published var navigateToLoanHelp = false
    @Published var navigateToSavings = false
    @Published var navigateToSavingsStatement = false

    
    private var hasShownAdThisSession = false
    
    func onAppear() {
        userName = UserDataManager.shared.getUserName()
        ads = UserDataManager.shared.loadAdvertisements()
        Task {
            await fetchWalletBalance()
            showLatestAdIfNew()
        }
    }
    
    func refreshBalance() async {
        await fetchWalletBalance()
    }
    
    func selectAd(_ ad: Advertisement) {
        selectedAd = ad
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showAdPopup = true
        }
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .walletTransfer: navigateToWalletTransfer = true
        case .walletToAccountTransfer: navigateToWalletToAccountTransfer = true
        case .accountToWalletTransfer: navigateToAccountToWalletTransfer = true
        case .bills: navigateToBills = true
        case .transactions: navigateToTransactions = true
        case .qr: navigateToQR = true
        case .moneyVoucher: navigateToMoneyVoucher = true
        case .si: navigateToSI = true
        case .limits: navigateToLimits = true
        }
    }
    
    func handleMenuSelection(_ selected: String, authManager: AuthenticationManager) {
        switch selected {
        case "profile": navigateToProfile = true
        case "beneficiaries": navigateToBeneficiaries = true
        case "transactions": navigateToTransactions = true
        case "walletTransfer": navigateToWalletTransfer = true
        case "limits": navigateToLimits = true
        case "walletToAccountTransfer": navigateToWalletToAccountTransfer = true
        case "accountToWalletTransfer": navigateToAccountToWalletTransfer = true
        case "moneyVoucher": navigateToMoneyVoucher = true
        case "mobileMoney": navigateToMobileMoney = true
        case "sponsored": navigateToSponsored = true
        case "terms": navigateToTerms = true
        case "qr": navigateToQR = true
        case "sponsoring": navigateToSponsoring = true
        case "linked": navigateToLinkedAccounts = true
        case "crowdfunding": navigateToCrowdfunding = true
        case "si": navigateToSI = true
        case "pinChange": navigateToPin = true
        case "pending": navigateToPending = true
        case "statement": navigateToStatement = true
        case "comment": navigateToComment = true
        case "complaint": navigateToComplaint = true
        case "foodComplaints": navigateToFoodComplaints = true
        case "loanRequest": navigateToLoanRequest = true
        case "loanRequests": navigateToLoanRequests = true
        case "loanHelp": navigateToLoanHelp = true
        case "deactivate": navigateToDeactivate = true
        case "biometric": navigateToBiometric = true
        case "FAQ": navigateToFAQ = true
        case "billPayment": navigateToBills = true
        case "phoneCredit": navigateToPhoneCredit = true
        case "buyData": navigateToBuyData = true
        case "settings": navigateToSettings = true
        case "orderFood": navigateToOrderFood = true
        case "orderHistory": navigateToFoodHistory = true
        case "savings": navigateToSavings = true
        case "savingsStatement": navigateToSavingsStatement = true

        case "logout":
            authManager.logout()
        default:
            break
        }
    }
    
    func handleFloatingAction(_ action: String) {
        switch action {
        case "moneyVoucher": navigateToMoneyVoucher = true
        case "sponsoring": navigateToSponsoring = true
        case "sponsor": navigateToSponsor = true
        case "sponsors": navigateToSponsoring = true
        case "crowdfunding": navigateToCrowdfunding = true
        case "si": navigateToSI = true
        case "payment": navigateToTransactions = true
        case "limits": navigateToLimits = true
        default:
            break
        }
    }
    
    func markAdAsViewed(_ ad: Advertisement) {
        guard let index = ads.firstIndex(where: { $0.id == ad.id }) else { return }
        ads[index].viewed = true
        UserDataManager.shared.markAdvertisementAsViewed(adId: ad.id)
    }
    
    private func showLatestAdIfNew() {
        guard !hasShownAdThisSession,
              let latestUnviewedAd = ads.first(where: { $0.viewed != true }) else {
            return
        }
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            selectedAd = latestUnviewedAd
            hasShownAdThisSession = true
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showAdPopup = true
            }
        }
    }
    
    private func fetchWalletBalance() async {
        let walletNumber = UserDataManager.shared.getWalletNumber()
        let pin = UserDataManager.shared.getPinForAPI()
        
        guard !walletNumber.isEmpty else { return }
        
        let datePrefix = DateFormatter.with(format: "yyMMdd").string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0..<1000000))
        let requestId = datePrefix + randomDigits
        let requestDate = DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date())
        
        let request = RequestBalanceEnquiry(
            walletNumber: walletNumber,
            phoneNumber: UserDataManager.shared.getPhoneNumber(),
            source: "W",
            pin: pin,
            bank: UserDataManager.shared.getBankCode(),
            requestId: requestId,
            requestDate: requestDate,
            entityId: UserDataManager.shared.getUserCode()
        )
        
        await withCheckedContinuation { continuation in
            APIClient.shared.getWalletBalance(request: request) { result in
                switch result {
                case .success(let response):
                    guard response.isSuccessful, let resultObj = response.result else {
                        continuation.resume()
                        return
                    }
                    
                    let availableAmount = Double(resultObj["availableBalance"] as? String ?? "0") ?? 0
                    let globalAmount = Double(resultObj["globalBalance"] as? String ?? "0") ?? 0
                    let currency = resultObj["currencyWording"] as? String ?? "GMD"
                    
                    UserDataManager.shared.saveWalletBalance(
                        availableAmount: availableAmount,
                        totalAmount: globalAmount,
                        currency: currency
                    )
                    
                    Task { @MainActor in
                        self.balance = availableAmount.formatAsCurrency()
                        self.currency = currency
                    }
                    
                case .failure(let error):
                    print("❌ Failed to load balance: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }
}

// MARK: - Navigation Destination
enum NavigationDestination {
    case walletTransfer, walletToAccountTransfer, accountToWalletTransfer
    case transactions, qr, moneyVoucher, si, limits, bills
}

// MARK: - Header Section
struct HeaderSection: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let userName: String
    let balance: String
    let currency: String
    @Binding var isBalanceVisible: Bool
    let onTransactionsTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            userGreeting
                .padding(.top, 32)
                .padding(.bottom, 26)
            BalanceCard(balance: balance, currency: currency,
                        isBalanceVisible: $isBalanceVisible,
                        onTransactionsTap: onTransactionsTap)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
        }
        .background(Color.white)
    }

    private var userGreeting: some View {
        HStack {
            HStack(spacing: 5) {
                Text(AppStrings.hello).foregroundColor(Color(hex: "8791A3"))
                Text(userName).foregroundColor(Color(hex: "202633"))
            }
            .font(.system(size: 20, weight: .medium))
            Spacer()
        }
        .padding(.horizontal, 22)
    }
}

private struct HomeHeaderBar: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let onMenuTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.white)
                    .font(.system(size: 25, weight: .medium))
                    .frame(width: 44, height: 48)
            }
            Spacer()
            Text("EWALLET")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 44, height: 48)
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background(Color(hex: "174EA6").ignoresSafeArea(edges: .top))
    }
}

// MARK: - Balance Card
struct BalanceCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let balance: String
    let currency: String
    @Binding var isBalanceVisible: Bool
    let onTransactionsTap: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            Text(AppStrings.availableBalance)
                .font(.system(size: 16, weight: .medium))
                .tracking(1)
                .foregroundColor(Color(hex: "7A8699"))
            HStack(spacing: 10) {
                Text(isBalanceVisible ? "\(balance) \(currency)" : "*********")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(Color(hex: "202633"))
                Button(action: { isBalanceVisible.toggle() }) {
                    Image(systemName: isBalanceVisible ? "eye" : "eye.slash")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(Color(hex: "A4AFBF"))
                }
            }
            .padding(.bottom, 58)
            transactionsButton
        }
        .padding(.top, 4)
    }
    
    private var transactionsButton: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(Color(hex: "5D6CD5"))
                .font(.system(size: 23, weight: .medium))
            Text(AppStrings.transactionHistory)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(hex: "303949"))
            Spacer()
            Button(action: onTransactionsTap) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "A4AFBF"))
                        .font(.system(size: 12))
                }
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 66)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "E0E5EC"), lineWidth: 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTransactionsTap)
    }
}

// MARK: - Transfers Section
struct TransfersSection: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let onTransferTap: (NavigationDestination) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            transferCards
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text(AppStrings.quickAccess)
                .font(.system(size: 16, weight: .semibold))
                .tracking(1)
                .foregroundColor(Color(hex: "7A8699"))
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var transferCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                TransferCard(
                    title: AppStrings.transferToWallet,
                    icon: "wallet.pass",
                    backgroundColor: .clear,
                    iconColor: Color(hex: "5D6CD5")
                ) { onTransferTap(.walletTransfer) }
                
                TransferCard(
                    title: AppStrings.walletToAccount,
                    icon: "creditcard",
                    backgroundColor: .clear,
                    iconColor: Color(hex: "5D6CD5")
                ) { onTransferTap(.walletToAccountTransfer) }
            }
            
            HStack(spacing: 12) {
                TransferCard(
                    title: AppStrings.bills,
                    icon: "doc.text",
                    backgroundColor: .clear,
                    iconColor: Color(hex: "5D6CD5")
                ) { onTransferTap(.bills) }
                
                TransferCard(
                    title: AppStrings.qrPayment,
                    icon: "qrcode",
                    backgroundColor: .clear,
                    iconColor: Color(hex: "5D6CD5")
                ) { onTransferTap(.qr) }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Transfer Card
struct TransferCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    let icon: String
    let backgroundColor: Color
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            ZStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 34, weight: .regular))
                    .frame(height: 46)
            }
            
            Text(AppStrings.buttonTitle(title))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "303949"))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 144, alignment: .leading)
        .padding(.vertical, 18)
        .padding(.horizontal, 22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(hex: "E0E5EC"), lineWidth: 1.5))
        .onTapGesture(perform: action)
    }
}

// MARK: - Promotions Section
struct PromotionsSection: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let ads: [Advertisement]
    let onAdTap: (Advertisement) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeader
            adScrollView
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text(AppStrings.promotions)
                .font(.system(size: 16, weight: .semibold))
                .tracking(1)
                .foregroundColor(Color(hex: "7A8699"))
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var adScrollView: some View {
        Group {
        if ads.isEmpty {
            Text(AppStrings.noPromotions)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "A4AFBF"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
        } else {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ads) { ad in
                    AdCard(ad: ad, onTap: { onAdTap(ad) })
                }
            }
            .padding(.horizontal, 15)
        }
        }
        }
    }
}

struct AppBottomBar: View {
    @Environment(\.navigateBottomTab) private var navigateBottomTab
    @Environment(\.bottomNavigationSelection) private var bottomNavigationSelection

    private var activeTab: String { bottomNavigationSelection?.title ?? selectedTab }

    private func navigate(to tab: BottomNavigationTab, fallback: () -> Void) {
        if let navigateBottomTab {
            navigateBottomTab(tab)
        } else {
            fallback()
        }
    }

    @ObservedObject private var localization = AppLanguageStore.shared
    let onSponsors: () -> Void
    let onQR: () -> Void
    let onLimits: () -> Void
    let onSettings: () -> Void
    var selectedTab = "Home"
    var onHome: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                item("house.fill", AppStrings.home, selected: activeTab == "Home", action: { navigate(to: .home, fallback: onHome) })
                Spacer()
                item("hand.thumbsup", AppStrings.sponsors, selected: activeTab == "Sponsors", action: { navigate(to: .sponsors, fallback: onSponsors) })
                Spacer(minLength: 76)
                item("speedometer", AppStrings.limits, selected: activeTab == "Limits", action: { navigate(to: .limits, fallback: onLimits) })
                Spacer()
                item("gearshape.fill", AppStrings.settings, selected: activeTab == "Settings", action: { navigate(to: .settings, fallback: onSettings) })
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)

            Button(action: { navigate(to: .qr, fallback: onQR) }) {
                Image(systemName: "qrcode")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color(hex: "0788B9"))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 10)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .offset(y: -20)
        }
        .frame(height: 50)
        .background {
            AppBottomBarShape(cornerRadius: 28)
                .fill(Color(hex: "174EA6"))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func item(_ icon: String, _ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 22, weight: .semibold))
                Text(AppStrings.buttonTitle(title)).font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(selected ? .white : Color.white.opacity(0.4))
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct AppBottomBarShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let mid = rect.midX
        let cutoutHalfWidth: CGFloat = 46
        let cutoutDepth: CGFloat = 30
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0), control: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: mid - cutoutHalfWidth, y: 0))
        path.addCurve(
            to: CGPoint(x: mid + cutoutHalfWidth, y: 0),
            control1: CGPoint(x: mid - cutoutHalfWidth * 0.4, y: cutoutDepth),
            control2: CGPoint(x: mid + cutoutHalfWidth * 0.4, y: cutoutDepth)
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: cornerRadius), control: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Ad Card
struct AdCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let ad: Advertisement
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                if let img = ad.decodedImage() {
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(width: 280, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    fallbackCard
                }
                
                if ad.viewed == true {
                    viewedBadge
                }
            }
        }
    }
    
    private var fallbackCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(ad.title ?? AppStrings.promo)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(ad.description ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
            Spacer()
            Image(systemName: "megaphone.fill")
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 40))
        }
        .padding(16)
        .frame(width: 280, height: 140)
        .background(Color(hex: "2E5E3E"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var viewedBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "eye.fill")
                .font(.system(size: 10))
            Text(AppStrings.vu)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.6))
        .clipShape(Capsule())
        .padding(8)
    }
}

// MARK: - Floating Action Menu
struct FloatingActionMenu: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var isExpanded: Bool
    let onAction: (String) -> Void
    
    private var menuItems: [(icon: String, label: String, color: Color, action: String)] { [
        ("clock.fill", AppStrings.transactionHistory, .gray, "payment"),
        ("person", AppStrings.sponsoriserUnPortefeuille, .cyan, "sponsor"),
        ("person.3.fill", AppStrings.sponsoringWallets, .blueH, "sponsors"),
        ("ticket.fill", AppStrings.moneyVoucher, .orange, "moneyVoucher"),
        ("arrow.left.arrow.right", AppStrings.standingInstructions, .purple, "si"),
        ("gauge.with.needle.fill", AppStrings.mesLimites, .green, "limits")
    ] }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            mainButton
            if isExpanded {
                menuItemsList
            }
        }
    }
    
    private var mainButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.blueH)
                    .frame(width: 56, height: 56)
                    .shadow(color: .blueH.opacity(0.3), radius: 8, x: 0, y: 4)
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .font(.title2)
                    .rotationEffect(.degrees(isExpanded ? 45 : 90))
            }
        }
    }
    
    private var menuItemsList: some View {
        VStack(spacing: 12) {
            ForEach(menuItems, id: \.action) { item in
                FloatingMenuItem(
                    icon: item.icon,
                    label: item.label,
                    backgroundColor: item.color
                ) {
                    onAction(item.action)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded = false
                    }
                }
            }
        }
        .offset(y: -80)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
}

// MARK: - Floating Menu Item
struct FloatingMenuItem: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let icon: String
    let label: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            Text(AppStrings.buttonTitle(label))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 48, height: 48)
                        .shadow(color: backgroundColor.opacity(0.3), radius: 6, x: 0, y: 3)
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
        }
    }
}

// MARK: - Ad Popup View
struct AdPopupView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let ad: Advertisement
    @Binding var isPresented: Bool
    var onClose: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { closePopup() }
            
            VStack(spacing: 0) {
                adHeader
                adContent
            }
            .frame(maxWidth: UIScreen.main.bounds.width - 40)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .onAppear {
            if let onClose = onClose {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onClose()
                }
            }
        }
    }
    
    private var adHeader: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [Color(hex: "FF9F5A"), Color(hex: "FFA65C")],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.description ?? AppStrings.promotion)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(ad.title ?? AppStrings.neManquezPasCetteOpportunite)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 50)
            .padding(.vertical, 12)
            
            Button(action: closePopup) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 12)
            .padding(.trailing, 12)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var adContent: some View {
        Group {
            if let image = ad.decodedImage() {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "4CAF50"))
                    Text(AppStrings.aucuneImageDisponible)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color.white)
            }
        }
    }
    
    private func closePopup() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

// MARK: - Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension DateFormatter {
    static func with(format: String) -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = format
        return df
    }
}
