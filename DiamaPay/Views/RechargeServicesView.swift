import SwiftUI

// Shared styling for the Android recharge service forms.
private enum RechargeStyle {
    static let blue = Color(hex: "174EA6")
    static let cyan = Color(hex: "0083B7")
    static let gray = Color(hex: "545D69")
}

private struct RechargeCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(RechargeStyle.blue)
                Rectangle().fill(RechargeStyle.cyan).frame(width: 57, height: 2)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.04)))
        .shadow(color: .black.opacity(0.17), radius: 3, x: 0, y: 3)
    }
}

private struct RechargeField: View {
    let placeholder: String
    @Binding var text: String
    var decimal = false

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(decimal ? .decimalPad : .numberPad)
            .font(.system(size: 13))
            .foregroundColor(.black)
            .padding(.horizontal, 11)
            .frame(height: 46)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(RechargeStyle.gray, lineWidth: 1.1))
    }
}

private struct RechargeSelector: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        } label: {
            HStack {
                Text(selection)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(RechargeStyle.gray)
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black)
            .padding(.horizontal, 19)
            .frame(height: 46)
            .contentShape(Rectangle())
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(RechargeStyle.gray, lineWidth: 1.1))
        }
        .accessibilityLabel(title)
        .accessibilityValue(selection)
    }
}

private struct RechargeAction: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(AppStrings.buttonTitle(title))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 144, height: 46)
                .background(RechargeStyle.blue)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

private struct RechargeSavedButton: View {
    var symbol = "books.vertical.fill"
    var title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.system(size: 23))
                    .frame(width: 46, height: 46)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(RechargeStyle.cyan, lineWidth: 1))
                Text(AppStrings.buttonTitle(title)).font(.system(size: 10))
            }
            .foregroundColor(RechargeStyle.blue)
        }
        .buttonStyle(.plain)
    }
}

struct RechargeServiceView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let isData: Bool
    @State private var phone = ""
    @State private var amount = ""
    @State private var selectedProvider = "MTN"
    @State private var selectedProduct = "MTN DATA 1GB"
    @State private var showContacts = false
    @State private var showSaved = false
    @State private var message = ""
    @State private var showMessage = false
    @AppStorage("recharge_saved_phone_numbers") private var savedNumbers = ""

    private var numbers: [String] { savedNumbers.split(separator: ",").map(String.init) }

    var body: some View {
        VStack(spacing: 0) {
            DiamaPayHeader(title: isData ? AppStrings.buyData : AppStrings.phoneCredit, headerColor: RechargeStyle.blue)
            ScrollView {
                VStack(spacing: 16) {
                    SourceOfFundsView(walletTransferStyle: true)
                        .padding(.bottom, 12)
                    RechargeCard(title: AppStrings.rechargeProviderDetails) {
                        RechargeSelector(
                            title: AppStrings.rechargeProviderDetails,
                            options: ["MTN", "Orange", "Telecel"],
                            selection: $selectedProvider
                        )
                    }
                    RechargeCard(title: isData ? AppStrings.rechargeRecipientDetails : AppStrings.phoneNumber) {
                        HStack(alignment: .top, spacing: 8) {
                            RechargeField(placeholder: AppStrings.rechargeRecipientNumber, text: $phone)
                            RechargeSavedButton(title: AppStrings.rechargeSaved) { showSaved = true }
                            RechargeSavedButton(symbol: "person.crop.rectangle.fill", title: AppStrings.rechargeContacts) { showContacts = true }
                        }
                        if isData {
                            VStack(alignment: .leading, spacing: 9) {
                                Text(AppStrings.rechargeProducts).font(.system(size: 12)).foregroundColor(RechargeStyle.gray)
                                RechargeSelector(
                                    title: AppStrings.rechargeProducts,
                                    options: ["MTN DATA 1GB", "MTN DATA 3GB", "MTN DATA 5GB", "MTN DATA 10GB"],
                                    selection: $selectedProduct
                                )
                            }
                            .padding(.top, 6)
                        }
                    }
                    RechargeCard(title: AppStrings.amount) {
                        RechargeField(placeholder: AppStrings.rechargeEnterAmount, text: $amount, decimal: true)
                    }
                    RechargeAction(title: AppStrings.submit, action: validate)
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                }
                .padding(16)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showContacts) {
            ContactPickerView(selectedPhone: $phone, normalizePhone: { $0 })
        }
        .confirmationDialog(AppStrings.rechargeSaved, isPresented: $showSaved, titleVisibility: .visible) {
            ForEach(numbers, id: \.self) { number in
                Button(AppStrings.buttonTitle(number)) { phone = number }
            }
            if !phone.isEmpty && !numbers.contains(phone) {
                Button(AppStrings.buttonTitle(AppStrings.rechargeSaveNumber)) { savedNumbers = (numbers + [phone]).joined(separator: ",") }
            }
            Button(AppStrings.buttonTitle(AppStrings.annuler), role: .cancel) { }
        } message: {
            Text(numbers.isEmpty ? AppStrings.rechargeNoSaved : AppStrings.rechargeChooseSaved)
        }
        .alert(AppStrings.information, isPresented: $showMessage) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: { Text(message) }
    }

    private func validate() {
        let digits = phone.filter(\.isNumber)
        if digits.count < 7 || digits.count > 15 {
            message = AppStrings.rechargeInvalidPhone
        } else if let value = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")), value > 0 {
            message = AppStrings.rechargeNotConnected
        } else {
            message = AppStrings.rechargeInvalidAmount
        }
        showMessage = true
    }
}

enum NawecService {
    case water, cashPower
    var title: String { self == .water ? "NAWEC Water Bill" : "NAWEC Cash Power" }
}

struct NawecServiceView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let service: NawecService
    @State private var account = ""
    @State private var amount = ""
    @State private var showSaved = false
    @State private var showMessage = false
    @State private var message = ""
    @AppStorage("nawec_saved_water_accounts") private var waterAccounts = ""
    @AppStorage("nawec_saved_power_meters") private var powerMeters = ""

    private var saved: [String] {
        (service == .water ? waterAccounts : powerMeters).split(separator: ",").map(String.init)
    }

    var body: some View {
        VStack(spacing: 0) {
            DiamaPayHeader(title: service == .water ? "EWALLET" : service.title, headerColor: RechargeStyle.blue)
            ScrollView {
                VStack(spacing: 16) {
                    RechargeCard(title: service.title) {
                        HStack(alignment: .top, spacing: 8) {
                            RechargeField(placeholder: service == .water ? AppStrings.rechargeWaterAccount : AppStrings.rechargeMeterNumber, text: $account)
                                .padding(.top, 8)
                            RechargeSavedButton(title: AppStrings.rechargeSaved) { showSaved = true }
                        }
                        if service == .cashPower {
                            RechargeField(placeholder: AppStrings.rechargeEnterAmount, text: $amount, decimal: true)
                                .padding(.bottom, 15)
                        } else {
                            HStack {
                                Spacer()
                                RechargeAction(title: AppStrings.rechargeEnquire, action: validate)
                                Spacer()
                            }
                            .padding(.bottom, 15)
                        }
                    }
                    if service == .cashPower {
                        RechargeAction(title: AppStrings.rechargePay, action: validate)
                    }
                }
                .padding(16)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .confirmationDialog(AppStrings.rechargeSaved, isPresented: $showSaved, titleVisibility: .visible) {
            ForEach(saved, id: \.self) { value in Button(AppStrings.buttonTitle(value)) { account = value } }
            if !account.isEmpty && !saved.contains(account) {
                Button(AppStrings.buttonTitle(AppStrings.rechargeSaveNumber)) {
                    let updated = (saved + [account]).joined(separator: ",")
                    if service == .water { waterAccounts = updated } else { powerMeters = updated }
                }
            }
            Button(AppStrings.buttonTitle(AppStrings.annuler), role: .cancel) { }
        } message: { Text(saved.isEmpty ? AppStrings.rechargeNoSaved : AppStrings.rechargeChooseSaved) }
        .alert(AppStrings.information, isPresented: $showMessage) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: { Text(message) }
    }

    private func validate() {
        if account.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = service == .water ? AppStrings.rechargeAccountRequired : AppStrings.rechargeMeterRequired
        } else if service == .cashPower && (Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0 {
            message = AppStrings.rechargeInvalidAmount
        } else {
            message = AppStrings.rechargeNotConnected
        }
        showMessage = true
    }
}
