import SwiftUI

struct SavedLinkedAccountsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    let accounts: [Account]
    let onSelect: (Account) -> Void

    @State private var search = ""

    private var filteredAccounts: [Account] {
        guard !search.isEmpty else { return accounts }
        return accounts.filter {
            $0.accountNumber.localizedCaseInsensitiveContains(search)
                || $0.accountHolder.localizedCaseInsensitiveContains(search)
                || $0.accountName.localizedCaseInsensitiveContains(search)
                || $0.bankCode.localizedCaseInsensitiveContains(search)
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
                    Text(AppStrings.selectARecentRecipient)
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

            if accounts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 34))
                        .foregroundColor(Color(hex: "0788B9"))
                    Text(AppStrings.noSavedAccounts)
                        .font(.system(size: 17, weight: .semibold))
                    Text(AppStrings.linkedBankAccountsWillAppearHere)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredAccounts.isEmpty {
                Text(AppStrings.noMatchingAccounts)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredAccounts) { account in
                            Button {
                                onSelect(account)
                                dismiss()
                            } label: {
                                accountRow(account)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.white)
        .presentationCornerRadius(24)
    }

    private func accountRow(_ account: Account) -> some View {
        let name = account.accountHolder.isEmpty ? account.accountName : account.accountHolder
        let initials = name.split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()

        return HStack(spacing: 14) {
            Text(initials.isEmpty ? String(account.accountNumber.prefix(1)) : initials)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color(hex: "0788B9")))

            VStack(alignment: .leading, spacing: 5) {
                Text(name.isEmpty ? account.accountNumber : name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(hex: "505A69"))
                    .lineLimit(1)
                Text(AppStrings.valueValue(String(describing: account.accountNumber), String(describing: account.bankCode)))
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
}
