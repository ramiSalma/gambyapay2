import SwiftUI

struct MyProfileView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @State private var profile: WalletProfile?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            DiamaPayHeader(title: AppStrings.myProfile, headerColor: Color(hex: "174EA6"))
            if isLoading {
                VStack(spacing: 14) {
                    ProgressView().tint(Color(hex: "0788B9"))
                    Text(AppStrings.loadingProfile)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "F5F7FA"))
            } else if let errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 42))
                        .foregroundColor(Color(hex: "0788B9"))
                    Text(AppStrings.profileUnavailable)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "174EA6"))
                    Text(AppStrings.option(errorMessage))
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button(action: loadProfile) {
                        Label(AppStrings.buttonTitle(AppStrings.tryAgain), systemImage: "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .frame(height: 46)
                            .background(Color(hex: "174EA6"), in: Capsule())
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "F5F7FA"))
            } else if let profile {
                ScrollView {
                    VStack(spacing: 16) {
                        profileHero(profile)
                        profileSection(AppStrings.personalInformation, icon: "person.text.rectangle", fields: [
                            (AppStrings.customerName, profile.customerName),
                            (AppStrings.firstName, profile.firstName),
                            (AppStrings.familyName, profile.familyName),
                            (AppStrings.phoneNumber2, profile.phoneNumber),
                            (AppStrings.email, profile.email),
                            (AppStrings.address, profile.address)
                        ])
                        profileSection(AppStrings.walletInformation2, icon: "wallet.pass", fields: [
                            (AppStrings.walletNumber2, profile.walletNumber),
                            (AppStrings.walletType, AppStrings.profileTypeValue(profile.walletType)),
                            (AppStrings.walletStatus, AppStrings.profileStatusValue(profile.walletStatus)),
                            (AppStrings.kycLevel, profile.kycLevel),
                            (AppStrings.registrationDate, profile.registrationDate),
                            (AppStrings.bank, profileBankName(profile))
                        ])
                        profileSection(AppStrings.identification, icon: "person.text.rectangle.fill", fields: [
                            (AppStrings.nationalId, profile.nationalId)
                        ])
                        profileSection(AppStrings.nextOfKin, icon: "person.2", fields: [
                            (AppStrings.name, profile.nextOfKinName),
                            (AppStrings.phoneNumber2, profile.nextOfKinPhone)
                        ])
                        Button(action: loadProfile) {
                            Label(AppStrings.buttonTitle(AppStrings.refreshProfile), systemImage: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "174EA6"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "DCE4EF"), lineWidth: 1))
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
                .background(Color(hex: "F5F7FA"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if profile == nil { loadProfile() }
        }
    }

    private func profileHero(_ profile: WalletProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Text(profileInitials(profile))
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                    .frame(width: 62, height: 62)
                    .background(.white.opacity(0.96), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileDisplayName(profile))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(displayValue(profile.phoneNumber))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.84))
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text(displayValue(profile.walletNumber))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .textSelection(.enabled)
                Spacer(minLength: 4)
                Text(displayValue(AppStrings.profileStatusValue(profile.walletStatus)))
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.18), in: Capsule())
            }
            .foregroundColor(.white)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(hex: "174EA6"), Color(hex: "0788B9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .shadow(color: Color(hex: "174EA6").opacity(0.18), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
    }

    private func profileSection(_ title: String, icon: String, fields: [(String, String?)]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0788B9"))
                    .frame(width: 28, height: 28)
                    .background(Color(hex: "EAF5FA"), in: RoundedRectangle(cornerRadius: 8))
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
            }
            .padding(.bottom, 8)

            ForEach(fields.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 12) {
                    Text(fields[index].0)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "697586"))
                    Spacer(minLength: 8)
                    Text(displayValue(fields[index].1))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(fields[index].1?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                                         ? Color(hex: "303949") : Color(hex: "98A2B3"))
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)
                .accessibilityElement(children: .combine)

                if index < fields.count - 1 {
                    Divider().overlay(Color(hex: "EDF0F4"))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: "E5EAF0"), lineWidth: 1))
        .shadow(color: .black.opacity(0.035), radius: 7, x: 0, y: 3)
    }

    private func profileDisplayName(_ profile: WalletProfile) -> String {
        let customerName = profile.customerName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !customerName.isEmpty { return customerName }
        let name = [profile.firstName, profile.familyName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return name.isEmpty ? AppStrings.myProfile : name
    }

    private func profileInitials(_ profile: WalletProfile) -> String {
        let initials = profileDisplayName(profile)
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
        return initials.isEmpty ? "?" : initials.uppercased()
    }

    private func profileBankName(_ profile: WalletProfile) -> String? {
        [profile.bankName, profile.bankWording, UserDataManager.shared.getBankWording()]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    private func displayValue(_ value: String?) -> String {
        let value = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? AppStrings.notProvided : value
    }

    private func loadProfile() {
        guard !isLoading else { return }
        let user = UserDataManager.shared
        let wallet = user.getWalletNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !wallet.isEmpty || !phone.isEmpty else {
            errorMessage = AppStrings.yourWalletDetailsAreMissingPleaseSignInAgain
            return
        }
        errorMessage = nil
        isLoading = true
        let bank = user.getBankCode().trimmingCharacters(in: .whitespacesAndNewlines)
        let request = WalletProfileRequest(
            walletNumber: wallet.isEmpty ? nil : wallet,
            phoneNumber: phone.isEmpty ? nil : phone,
            source: wallet.isEmpty ? "P" : "W",
            bank: bank.isEmpty ? "00100" : bank
        )
        APIClient.shared.getWalletProfile(request: request) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if response.respCode == "000", let details = response.result {
                        profile = details
                    } else {
                        errorMessage = response.message ?? AppStrings.unableToLoadYourProfilePleaseTryAgain
                    }
                case .failure(let error):
                    errorMessage = (error as? APIError)?.message ?? AppStrings.unableToLoadYourProfilePleaseCheckYourConnectionAnd
                }
            }
        }
    }
}
