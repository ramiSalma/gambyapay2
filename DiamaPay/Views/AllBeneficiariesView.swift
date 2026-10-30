import SwiftUI

struct AllBeneficiariesView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var beneficiaries: [WalletBeneficiary] = []
    @State private var isLoading = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var beneficiaryToDelete: WalletBeneficiary?
    @State private var showDeleteConfirmation = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""

    private let blue = Color(hex: "174EA6")
    private let cyan = Color(hex: "0788B9")

    private var groupedBeneficiaries: [(title: String, items: [WalletBeneficiary])] {
        let groups = Dictionary(grouping: matching(beneficiaries), by: \.transactionTypeTitle)
        return groups.map { (title: $0.key, items: $0.value) }
            .sorted { left, right in
                let leftOrder = left.items.first?.transactionTypeSortOrder ?? Int.max
                let rightOrder = right.items.first?.transactionTypeSortOrder ?? Int.max
                return leftOrder == rightOrder ? left.title < right.title : leftOrder < rightOrder
            }
    }

    private func matching(_ list: [WalletBeneficiary]) -> [WalletBeneficiary] {
        guard !searchText.isEmpty else { return list }
        return list.filter {
            ($0.name ?? "").localizedCaseInsensitiveContains(searchText)
                || ($0.destination ?? "").localizedCaseInsensitiveContains(searchText)
                || ($0.bankCode ?? "").localizedCaseInsensitiveContains(searchText)
                || ($0.destBankCode ?? "").localizedCaseInsensitiveContains(searchText)
                || $0.transactionTypeTitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if isLoading {
                ProgressView(AppStrings.loadingBeneficiaries)
                    .tint(blue)
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                ContentUnavailableView {
                    Label(AppStrings.couldntLoadBeneficiaries, systemImage: "exclamationmark.circle")
                } description: {
                    Text(AppStrings.option(errorMessage))
                } actions: {
                    Button(AppStrings.buttonTitle(AppStrings.tryAgain)) { loadBeneficiaries() }
                        .buttonStyle(.borderedProminent)
                        .tint(blue)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        searchField

                        if beneficiaries.isEmpty {
                            ContentUnavailableView(
                                AppStrings.noBeneficiariesYet,
                                systemImage: "person.2",
                                description: Text(AppStrings.yourSavedWalletAndBankBeneficiariesWillAppearHere)
                            )
                            .frame(minHeight: 300)
                        } else if groupedBeneficiaries.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                                .frame(minHeight: 300)
                        } else {
                            ForEach(groupedBeneficiaries, id: \.title) { group in
                                beneficiarySection(group.title.uppercased(), items: group.items)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .refreshable { await refreshBeneficiaries() }
            }
        }
        .background(Color(hex: "F4F6FB").ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(
                onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {},
                selectedTab: "Home", onHome: { dismiss() }
            )
        }
        .navigationBarHidden(true)
        .onAppear { loadBeneficiaries() }
        .alert(AppStrings.removeBeneficiary, isPresented: $showDeleteConfirmation) {
            Button(AppStrings.buttonTitle(AppStrings.remove), role: .destructive) { deleteSelectedBeneficiary() }
            Button(AppStrings.buttonTitle(AppStrings.cancel), role: .cancel) { beneficiaryToDelete = nil }
        } message: {
            Text(AppStrings.thisBeneficiaryWillBeRemovedFromYourSavedList)
        }
        .alert(AppStrings.couldntRemoveBeneficiary, isPresented: $showDeleteError) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(deleteErrorMessage.isEmpty ? AppStrings.pleaseTryAgain : deleteErrorMessage)
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Text(AppStrings.beneficiaries)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .background(blue.ignoresSafeArea(edges: .top))
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .medium))
                .foregroundColor(cyan)
            TextField(AppStrings.search, text: $searchText)
                .font(.system(size: 14))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5))
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    private func beneficiarySection(_ title: String, items: [WalletBeneficiary]) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.9)
                .foregroundColor(cyan)
                .padding(.top, 4)
                .padding(.bottom, 2)

            ForEach(Array(items.enumerated()), id: \.offset) { _, beneficiary in
                beneficiaryCard(beneficiary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
    }

    private func beneficiaryCard(_ beneficiary: WalletBeneficiary) -> some View {
        let name = beneficiary.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let destination = beneficiary.destination?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bankCode = beneficiary.destBankCode ?? beneficiary.bankCode ?? ""
        let initials = initialsFor(name.isEmpty ? destination : name)
        let date = formattedAddedDate(beneficiary.actionDate)

        return HStack(spacing: 14) {
            Text(initials)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(cyan)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(name.isEmpty ? beneficiary.transactionTypeTitle : name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "858585"))
                    .lineLimit(1)

                Text(AppStrings.valueValue(String(describing: destination), String(describing: bankCode)))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "505A69"))
                    .lineLimit(1)

                HStack(alignment: .center) {
                    Text(beneficiary.transactionTypeTitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(Capsule().stroke(Color(hex: "505A69"), lineWidth: 1.2))
                    Spacer(minLength: 4)
                    Text(AppStrings.addedValue(String(describing: date)))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "505A69"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            Button {
                beneficiaryToDelete = beneficiary
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color(hex: "505A69"))
                    .frame(width: 30, height: 42)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppStrings.removeBeneficiary2)
            .disabled(isDeleting)
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "E4E7EC"), lineWidth: 1))
        .shadow(color: .black.opacity(0.10), radius: 2, x: 0, y: 2)
    }

    private func initialsFor(_ value: String) -> String {
        let parts = value.split(whereSeparator: \.isWhitespace)
        let letters = parts.prefix(2).compactMap(\.first).map(String.init).joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    private func formattedAddedDate(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "—" }
        let formats = ["dd-MM-yyyy", "dd/MM/yyyy", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"]
        for format in formats {
            let parser = DateFormatter()
            parser.locale = Locale(identifier: "en_US_POSIX")
            parser.dateFormat = format
            if let date = parser.date(from: value) {
                let output = DateFormatter()
                output.locale = Locale(identifier: "en_US_POSIX")
                output.dateFormat = "dd-MM-yyyy"
                return output.string(from: date)
            }
        }
        return value
    }

    private func loadBeneficiaries(completion: @escaping () -> Void = {}) {
        guard !isLoading else { completion(); return }
        let user = UserDataManager.shared
        let phoneNumber = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phoneNumber.isEmpty else {
            errorMessage = AppStrings.pleaseSignInAgainToLoadYourBeneficiaries
            completion()
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
                        errorMessage = response.message ?? AppStrings.unableToLoadBeneficiaries
                        completion()
                        return
                    }
                    beneficiaries = response.result ?? []
                case .failure(let error):
                    errorMessage = (error as? APIError)?.message
                        ?? AppStrings.unableToLoadBeneficiariesPleaseTryAgain
                }
                completion()
            }
        }
    }

    private func deleteSelectedBeneficiary() {
        guard let beneficiary = beneficiaryToDelete,
              let beneficiaryId = beneficiary.beneficiaryId,
              !beneficiaryId.isEmpty else {
            deleteErrorMessage = AppStrings.beneficiaryDetailsAreIncomplete
            showDeleteError = true
            return
        }
        let user = UserDataManager.shared
        let phoneNumber = user.getPhoneNumber().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phoneNumber.isEmpty else {
            deleteErrorMessage = AppStrings.pleaseSignInAgainToManageBeneficiaries
            showDeleteError = true
            return
        }

        isDeleting = true
        let request = WalletBeneficiaryDeleteRequest(
            phoneNumber: phoneNumber,
            beneficiaryId: beneficiaryId,
            requestId: DateFormatter.with(format: "yyMMdd").string(from: Date())
                + String(format: "%06d", Int.random(in: 0...999999)),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: user.getUserCode().isEmpty ? phoneNumber : user.getUserCode()
        )
        APIClient.shared.deleteWalletBeneficiary(request: request) { result in
            DispatchQueue.main.async {
                isDeleting = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    beneficiaries.removeAll { $0.beneficiaryId == beneficiaryId }
                case .success(let response):
                    deleteErrorMessage = response.message ?? AppStrings.unableToRemoveBeneficiary
                    showDeleteError = true
                case .failure(let error):
                    deleteErrorMessage = (error as? APIError)?.message
                        ?? AppStrings.unableToRemoveBeneficiaryPleaseTryAgain
                    showDeleteError = true
                }
                beneficiaryToDelete = nil
            }
        }
    }

    @MainActor
    private func refreshBeneficiaries() async {
        await withCheckedContinuation { continuation in
            loadBeneficiaries { continuation.resume() }
        }
    }
}
