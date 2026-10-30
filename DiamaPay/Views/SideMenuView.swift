import SwiftUI

struct SideMenuView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header

                sectionHeader(AppStrings.profileSection)
                item("person.crop.circle", AppStrings.myProfile, "profile")
                item("person.2", AppStrings.beneficiaries, "beneficiaries")
                sectionDivider

                sectionHeader(AppStrings.loansSection)
                item("wallet.bifold", AppStrings.requestLoan, "loanRequest")
                item("clock.arrow.circlepath", AppStrings.myLoans, "loanRequests")
                item("questionmark.bubble", AppStrings.loanHelp, "loanHelp")
                sectionDivider

                sectionHeader(AppStrings.transfersSection)
                item("arrow.left.arrow.right", AppStrings.transferToWallet, "walletTransfer")
                item("wallet.bifold.fill", AppStrings.walletToAccount, "walletToAccountTransfer")
                item("bankToWallet", AppStrings.accountToWallet, "accountToWalletTransfer")
                item("voucher", AppStrings.moneyVoucher, "moneyVoucher")
                item("iphone", AppStrings.mobileMoney, "mobileMoney")
                item("qrcode", AppStrings.qrTransfer, "qr")
                item("wallet.pass", AppStrings.crowdFunding, "crowdfunding")
                item("repeat", AppStrings.standingInstructions, "si")
                sectionDivider

                sectionHeader(AppStrings.foodSection)
                item("fork.knife", AppStrings.orderFood, "orderFood")
                item("clock.arrow.circlepath", AppStrings.foodHistory, "orderHistory")
                item("exclamationmark.triangle", AppStrings.complaints, "foodComplaints")
                sectionDivider

                sectionHeader(AppStrings.rechargesSection)
                item("phone", AppStrings.phoneCredit, "phoneCredit")
                item("antenna.radiowaves.left.and.right", AppStrings.buyData, "buyData")
                item("creditcard", AppStrings.billPayment, "billPayment")
                sectionDivider

                sectionHeader(AppStrings.sponsorSection)
                item("person.2", AppStrings.sponsoredWallets, "sponsored")
                item("person.3", AppStrings.sponsoringWallets, "sponsoring")
                sectionDivider

                sectionHeader(AppStrings.savingsSection)
                item("banknote", AppStrings.savingsWallet, "savings")
                item("waveform.path", AppStrings.savingsStatement, "savingsStatement")
                sectionDivider

                sectionHeader(AppStrings.transactionsSection)
                item("list.bullet.rectangle", AppStrings.transactionHistory, "transactions")
                sectionDivider

                sectionHeader(AppStrings.walletManagement)
                item("gauge.with.needle", AppStrings.limits, "limits")
                item("deactivate", AppStrings.deactivateWallet, "deactivate")
                item("pending", AppStrings.pendingTransactions, "pending")
                sectionDivider

                sectionHeader(AppStrings.helpSection)
                item("gearshape", AppStrings.settings, "settings")
                item("bubble.left", AppStrings.sendFeedback, "comment")
                item("exclamationmark.bubble", AppStrings.fileComplaint, "complaint")
                DrawerItem(icon: "phone", title: AppStrings.contactUs) {
                    makePhoneCall(phoneNumber: "+224612008699")
                }
                item("terms", AppStrings.terms, "terms")
                item("faq", AppStrings.faq, "FAQ")
                item("rectangle.portrait.and.arrow.right", AppStrings.logout, "logout")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EWALLET")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(AppStrings.walletTagline)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.96))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 70)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .background(Color(hex: "174EA6").ignoresSafeArea(edges: .top))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .medium))
            .tracking(1.5)
            .foregroundColor(Color(hex: "174EA6"))
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }

    private func item(_ icon: String, _ title: String, _ selection: String) -> some View {
        DrawerItem(icon: icon, title: title) {
            onSelect(selection)
        }
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color(hex: "E1E4E8"))
            .frame(height: 1)
            .padding(.top, 8)
    }

    private func makePhoneCall(phoneNumber: String) {
        let cleanedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        guard let url = URL(string: "tel://\(cleanedNumber)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:])
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView { _ in }
            .frame(width: 300)
            .previewLayout(.sizeThatFits)
    }
}
