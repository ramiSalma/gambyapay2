import SwiftUI

struct CheckLimitView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    var onOpenSettings: () -> Void = {}
    @State private var showSponsors = false
    @State private var showQR = false
    @State private var isLoading = false
    @State private var hasLoaded = false
    @State private var errorMessage: String?
    @State private var limitSummary: LimitSummary?
    @State private var limitDetails: [LimitDetail] = []
    @State private var expandedCards: Set<Int> = []

    private let accent = Color(hex: "174EA6")

    var body: some View {
        VStack(spacing: 0) {
            DiamaPayHeader(title: AppStrings.limits, headerColor: accent)
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        globalDailyLimitCard
                        sectionTitle
                        if isLoading {
                            ProgressView(AppStrings.loadingLimits)
                                .tint(accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else if let errorMessage {
                            VStack(spacing: 12) {
                                Text(AppStrings.option(errorMessage))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Button(AppStrings.buttonTitle(AppStrings.tryAgain), action: loadWalletLimits)
                                    .tint(accent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        } else if hasLoaded && limitDetails.isEmpty {
                            Text(AppStrings.noLimitsConfigured)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 2)
                        } else {
                            ForEach(Array(limitDetails.enumerated()), id: \.offset) { index, limit in
                                limitCard(limit, index: index)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 112)
                }
                Button(action: loadWalletLimits) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 58, height: 58)
                        .background(Color(hex: "0089BC"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 3)
                }
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
                .accessibilityLabel(AppStrings.refreshWalletLimits)
                .padding(.trailing, 16)
                .padding(.bottom, 42)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "F5F5F5").ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(
                onSponsors: { showSponsors = true },
                onQR: { showQR = true },
                onLimits: loadWalletLimits,
                onSettings: {
                    dismiss()
                    onOpenSettings()
                },
                selectedTab: "Limits",
                onHome: { dismiss() }
            )
        }
        .background {
            NavigationLink("", destination: SponsoringWalletListView(), isActive: $showSponsors)
                .hidden()
            NavigationLink("", destination: QRPaymentView(), isActive: $showQR)
                .hidden()
        }
        .navigationBarHidden(true)
        .onAppear {
            if !hasLoaded && errorMessage == nil { loadWalletLimits() }
        }
    }

    private var sectionTitle: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color(hex: "0089BC"))
                .frame(width: 4, height: 26)
            Text(AppStrings.limitsByTransaction)
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(accent)
        }
        .padding(.top, 4)
    }

    private var globalDailyLimitCard: some View {
        VStack(spacing: 0) {
            Text(AppStrings.globalDailyLimit)
                .font(.system(size: 23, weight: .bold))
                .multilineTextAlignment(.center)
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 62, height: 2)
                .padding(.top, 10)
            Text(AppStrings.allYourTransactionsShareThisCommonDailyLimit)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)
                .padding(.bottom, 18)
            VStack(spacing: 10) {
                Text(AppStrings.globalDailyLimit)
                    .font(.system(size: 12, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(.white.opacity(0.8))
                Text(globalLimitAmount)
                    .font(.system(size: 30, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                if !isLoading && limitSummary?.soldeDisponible == nil {
                    Text(AppStrings.notAvailable)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(spacing: 4) {
                Text(AppStrings.period)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                Text(periodText)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "1B63BA"))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 3)
    }

    private var globalLimitAmount: String {
        guard let amount = limitSummary?.soldeDisponible, amount.isFinite else { return "—" }
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_GM")
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "—"
    }

    private var periodText: String {
        guard let start = nonempty(limitSummary?.debutPeriode),
              let end = nonempty(limitSummary?.finPeriode) else { return "—" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        func parse(_ value: String) -> Date? {
            for format in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd", "dd/MM/yyyy"] {
                formatter.dateFormat = format
                if let date = formatter.date(from: value) { return date }
            }
            let iso = ISO8601DateFormatter()
            if let date = iso.date(from: value) { return date }
            iso.formatOptions.insert(.withFractionalSeconds)
            return iso.date(from: value)
        }
        guard let startDate = parse(start), let endDate = parse(end) else { return "\(start) - \(end)" }
        formatter.dateFormat = "yyyy"
        let sameYear = formatter.string(from: startDate) == formatter.string(from: endDate)
        formatter.dateFormat = sameYear ? "dd/MM" : "dd/MM/yyyy"
        let startLabel = formatter.string(from: startDate)
        formatter.dateFormat = "dd/MM/yyyy"
        return "\(startLabel) - \(formatter.string(from: endDate))"
    }

    private func limitCard(_ limit: LimitDetail, index: Int) -> some View {
        let expanded = expandedCards.contains(index)
        let currency = nonempty(limit.currencyCode) ?? nonempty(limitSummary?.devise)
        return VStack(alignment: .leading, spacing: 14) {
            Text(nonempty(limit.operationName) ?? AppStrings.transactionValue(String(describing: nonempty(limit.processingCode) ?? "—")))
                .font(.headline)
                .foregroundColor(accent)
            detail(AppStrings.processingCode, limit.processingCode)
            Divider()
            if let percentage = limit.pourcentageUtilisationJour, percentage.isFinite {
                detail(AppStrings.dailyUsage, String(format: "%.1f%%", percentage))
                // The label retains the reported percentage, including values over 100%.
                // Only the visual bar is constrained to its valid range.
                ProgressView(value: min(max(percentage, 0), 100), total: 100)
                    .tint(accent)
                    .accessibilityLabel(AppStrings.dailyLimitUsage)
                    .accessibilityValue(String(format: "%.1f percent", percentage))
            } else {
                detail(AppStrings.dailyUsage, nil)
            }
            detail(AppStrings.dailyLimit, money(limit.limiteJournaliere, currency: currency))
            detail(AppStrings.usedToday, money(limit.consommeAujourdhui, currency: currency))
            detail(AppStrings.remainingToday, money(limit.restantAujourdhui, currency: currency))
            detail(AppStrings.transactionsToday, limit.nombreTransactionsJour.map { String($0) })
            // These are strings in the backend DTO. Display the bank's values without
            // guessing their code meanings or deriving eligibility from usage alone.
            detail(AppStrings.canTransact, limit.peutTransacter)
            detail(AppStrings.alertLevel, limit.niveauAlerte)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expanded {
                        expandedCards.remove(index)
                    } else {
                        expandedCards.insert(index)
                    }
                }
            } label: {
                HStack {
                    Text(AppStrings.buttonTitle(expanded ? AppStrings.hideDetails : AppStrings.viewDetails))
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                }
            }
            .tint(accent)
            .accessibilityValue(expanded ? "Expanded" : "Collapsed")
            if expanded {
                Divider()
                detail(AppStrings.minimumPerTransaction, money(limit.montantMinimum, currency: currency))
                detail(AppStrings.maximumPerTransaction, money(limit.montantMaximum, currency: currency))
                detail(AppStrings.periodType, limit.typePeriode)
                detail(AppStrings.periodLimit, money(limit.limitePeriode, currency: currency))
                detail(AppStrings.usedThisPeriod, money(limit.consommePeriode, currency: currency))
                detail(AppStrings.remainingThisPeriod, money(limit.restantPeriode, currency: currency))
                detail(AppStrings.periodStarts, limit.debutPeriode)
                detail(AppStrings.periodEnds, limit.finPeriode)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "E0E5EC"), lineWidth: 1))
    }

    private func detail(_ title: String, _ value: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(nonempty(value) ?? AppStrings.notProvided)
                .font(.subheadline)
                .foregroundColor(Color(hex: "303949"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func nonempty(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        return value
    }

    private func money(_ amount: Double?, currency: String?) -> String? {
        guard let amount, amount.isFinite else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        guard let number = formatter.string(from: NSNumber(value: amount)) else { return nil }
        guard let code = nonempty(currency) else { return number }
        return "\(number) \(code == "270" ? "GMD" : code)"
    }

    private func loadWalletLimits() {
        guard !isLoading else { return }
        let user = UserDataManager.shared
        let wallet = nonempty(user.getWalletNumber())
        let phone = nonempty(user.getPhoneNumber())
        guard wallet != nil || phone != nil else {
            errorMessage = AppStrings.yourWalletDetailsAreMissingPleaseSignInAgain
            return
        }
        isLoading = true
        errorMessage = nil
        limitSummary = nil
        limitDetails = []
        expandedCards.removeAll()

        var request = RequestGetWalletLimits()
        request.walletNumber = wallet
        request.phoneNumber = phone
        request.bank = nonempty(user.getBankCode()) ?? "00100"
        APIClient.shared.getWalletLimits(request: request) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    guard response.isSuccessful else {
                        errorMessage = nonempty(response.message) ?? AppStrings.unableToLoadWalletLimitsPleaseTryAgain
                        return
                    }
                    limitSummary = response.summary
                    limitDetails = response.limits ?? []
                    hasLoaded = true
                case .failure(let error):
                    errorMessage = (error as? APIError)?.message ?? AppStrings.unableToLoadWalletLimitsPleaseCheckYourConnectionAnd
                }
            }
        }
    }
}
