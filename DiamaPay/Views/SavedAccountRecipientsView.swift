import SwiftUI

struct SavedAccountRecipientsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    var includeMobileMoneyRecipients = false
    var includeMoneyVoucherRecipients = false
    let onSelect: (WalletBeneficiary) -> Void

    @State private var recipients: [WalletBeneficiary] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var search = ""

    private var filteredRecipients: [WalletBeneficiary] {
        guard !search.isEmpty else { return recipients }
        return recipients.filter {
            ($0.name ?? "").localizedCaseInsensitiveContains(search)
                || ($0.destination ?? "").localizedCaseInsensitiveContains(search)
                || (($0.destBankCode ?? $0.bankCode ?? "").localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.28))
                .frame(width: 44, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 18)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(AppStrings.savedRecipients)
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(Color(hex: "174EA6"))
                    Text(listSubtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "505A69"))
                }
                Spacer()
                Button(AppStrings.buttonTitle(AppStrings.close)) { dismiss() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0788B9"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(Color(hex: "0788B9"))
                TextField(AppStrings.search, text: $search)
                    .font(.system(size: 17))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "505A69"), lineWidth: 1.5))
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            Group {
                if isLoading {
                    ProgressView(AppStrings.loadingSavedRecipients)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 14) {
                        Text(AppStrings.option(errorMessage)).multilineTextAlignment(.center)
                        Button(AppStrings.buttonTitle(AppStrings.tryAgain), action: loadRecipients)
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
                } else if recipients.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.rectangle.stack")
                            .font(.system(size: 34))
                            .foregroundColor(Color(hex: "0788B9"))
                        Text(AppStrings.noSavedRecipients)
                            .font(.system(size: 17, weight: .semibold))
                        Text(emptyMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredRecipients.isEmpty {
                    Text(AppStrings.noMatchingRecipients)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(filteredRecipients.enumerated()), id: \.offset) { _, recipient in
                                Button {
                                    onSelect(recipient)
                                    dismiss()
                                } label: {
                                    recipientRow(recipient)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .background(Color.white)
        .presentationCornerRadius(24)
        .onAppear(perform: loadRecipients)
    }

    private func recipientRow(_ recipient: WalletBeneficiary) -> some View {
        let name = recipient.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let initials = (name?.isEmpty == false ? name! : recipient.destination ?? "?")
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
        let bankCode = recipient.destBankCode ?? recipient.bankCode ?? ""

        return HStack(spacing: 14) {
            Text(initials.isEmpty ? "?" : initials)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color(hex: "0788B9")))

            VStack(alignment: .leading, spacing: 5) {
                Text(name?.isEmpty == false ? name! : AppStrings.savedRecipient)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(hex: "505A69"))
                    .lineLimit(1)
                Text(AppStrings.valueValue(String(describing: recipient.destination ?? ""), String(describing: bankCode)))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "505A69"))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }

    private func loadRecipients() {
        guard !isLoading else { return }
        let user = UserDataManager.shared
        let phoneNumber = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phoneNumber.isEmpty else {
            errorMessage = AppStrings.pleaseSignInAgainToLoadSavedRecipients
            return
        }

        isLoading = true
        errorMessage = nil
        let request = WalletBeneficiaryListRequest(
            phoneNumber: phoneNumber,
            requestId: DateFormatter.with(format: "yyMMdd").string(from: Date())
                + String(format: "%06d", Int.random(in: 0...999999)),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: user.getUserCode().isEmpty ? phoneNumber : user.getUserCode()
        )

        APIClient.shared.listWalletBeneficiaries(request: request) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    guard response.respCode == "000" else {
                        errorMessage = response.message ?? AppStrings.unableToLoadSavedRecipients
                        return
                    }
                    recipients = (response.result ?? []).filter { recipient in
                        if includeMoneyVoucherRecipients { return recipient.isMoneyVoucherRecipient }
                        if includeMobileMoneyRecipients { return recipient.isMobileMoneyRecipient }
                        return recipient.isBankAccountRecipient
                    }
                case .failure(let error):
                    errorMessage = (error as? APIError)?.message
                        ?? AppStrings.unableToLoadSavedRecipientsPleaseTryAgain
                }
            }
        }
    }

    private var listSubtitle: String {
        if includeMoneyVoucherRecipients { return AppStrings.selectASavedVoucherRecipient }
        if includeMobileMoneyRecipients { return AppStrings.selectASavedMobileMoneyRecipient }
        return AppStrings.selectARecentRecipient
    }

    private var emptyMessage: String {
        if includeMoneyVoucherRecipients { return AppStrings.savedVoucherRecipientsWillAppearHere }
        if includeMobileMoneyRecipients { return AppStrings.savedMobileMoneyRecipientsWillAppearHere }
        return AppStrings.savedBankAccountsWillAppearHere
    }
}
