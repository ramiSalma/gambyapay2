import SwiftUI

struct SettingsView: View {
    var onReturnHome: (() -> Void)? = nil
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var requirePin = UserDefaults.standard.object(forKey: "requirePinForEveryTransaction") as? Bool ?? true

    private let blue = Color(hex: "174EA6")
    private let cyan = Color(hex: "087FB3")

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.securitySettings, headerColor: blue)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        pinRequirementCard
                        securityOptionsCard
                        importantInformationCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(
                onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {},
                selectedTab: "Settings", onHome: { dismiss() }
            )
        }
        .navigationBarHidden(true)

    }

    private var pinRequirementCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(blue)
                    .frame(width: 40)
                Text(AppStrings.requirePin)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                Toggle(AppStrings.requirePin, isOn: $requirePin)
                    .labelsHidden()
                    .tint(blue)
                    .onChange(of: requirePin) { _, value in
                        UserDefaults.standard.set(value, forKey: "requirePinForEveryTransaction")
                    }
            }

            Text(AppStrings.pinBypassHelp)
                .font(.footnote)
                .foregroundColor(Color(hex: "475467"))

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(cyan)
                    Text(AppStrings.transactionsWithoutPin)
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.black)
                    Spacer(minLength: 4)
                    Text("0 / 5")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(cyan)
                }
                Text(requirePin
                     ? AppStrings.pinAlwaysRequired
                     : AppStrings.fiveTransactionsLeft)
                    .font(.footnote)
                    .foregroundColor(Color(hex: "475467"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "E5F3FF"))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(cyan, lineWidth: 1.5))
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(blue, lineWidth: 1.5))
        .shadow(color: blue.opacity(0.10), radius: 5, x: 0, y: 3)
    }

    private var securityOptionsCard: some View {
        VStack(spacing: 0) {
            AppLanguagePicker(settingsRowStyle: true)
                .buttonStyle(.plain)

            divider

            NavigationLink(destination: ChangePinView()) {
                settingsRow(icon: "asterisk", title: AppStrings.changePin)
            }
            .buttonStyle(.plain)

            divider

            NavigationLink(destination: ChangeSecurityQuestionView(onReturnHome: {
                if let onReturnHome { onReturnHome() } else { dismiss() }
            })) {
                settingsRow(icon: "questionmark.circle.fill", title: AppStrings.changeSecurityQuestion)
            }
            .buttonStyle(.plain)

            divider

            NavigationLink(destination: BiometricSettingsView()) {
                HStack(spacing: 16) {
                    Image(systemName: "touchid")
                        .font(.system(size: 25, weight: .regular))
                        .foregroundColor(blue)
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.buttonTitle(AppStrings.biometricAuthentication))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(AppStrings.buttonTitle(AppStrings.biometricHelp))
                            .font(.footnote)
                            .foregroundColor(Color(hex: "475467"))
                    }
                    Spacer()
                    Capsule()
                        .fill(Color.gray.opacity(0.28))
                        .frame(width: 46, height: 26)
                        .overlay(alignment: UserDataManager.shared.isBiometricEnabled() ? .trailing : .leading) {
                            Circle()
                                .fill(blue)
                                .frame(width: 26, height: 26)
                                .shadow(color: blue.opacity(0.2), radius: 2, y: 1)
                        }
                }
                .padding(.vertical, 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(blue, lineWidth: 1.5))
        .shadow(color: blue.opacity(0.10), radius: 5, x: 0, y: 3)
    }

    private var importantInformationCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label(AppStrings.importantInformation, systemImage: "info.circle.fill")
                .font(.subheadline.weight(.bold))
                .foregroundColor(cyan)
            informationBullet(AppStrings.pinResetRule)
            informationBullet(AppStrings.keepPinSecure)
            informationBullet(AppStrings.counterReset)
            informationBullet(AppStrings.disableBypass)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(cyan, lineWidth: 1.5))
        .shadow(color: blue.opacity(0.08), radius: 5, x: 0, y: 3)
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(blue)
                .frame(width: 40)
            Text(AppStrings.buttonTitle(title))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "475467"))
        }
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }

    private var divider: some View {
        Rectangle().fill(Color(hex: "D9D9D9")).frame(height: 1)
    }

    private func informationBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(cyan).frame(width: 8, height: 8).padding(.top, 6)
            Text(text)
                .font(.footnote)
                .foregroundColor(Color(hex: "475467"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
