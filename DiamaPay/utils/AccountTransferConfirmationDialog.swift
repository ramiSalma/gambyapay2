//
//  AccountTransferConfirmationDialog.swift
//  DiamaPay
//

import SwiftUI

struct AccountTransferConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let amount: String
    let fee: Double
    let total: Double
    let currency: String
    let accountName: String
    let accountNumber: String
    let bankName: String
    let paymentDetails: String

    @Binding var isPresented: Bool
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @State private var pin = ""
    @State private var showPinError = false
    @State private var pinErrorMessage = ""
    @State private var isVerifyingPin = false
    @FocusState private var pinFieldFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.48)
                    .ignoresSafeArea()
                    .onTapGesture { onCancel() }

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(spacing: 14) {
                            amountCard
                            recipientCard
                            descriptionCard
                            pinEntry
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                    }

                    actionButtons
                }
                .frame(maxWidth: 500)
                .frame(maxHeight: min(geometry.size.height * 0.92, 820))
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.22), radius: 22, x: 0, y: 10)
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 30, weight: .semibold))
                Text(AppStrings.confirmationDuTransfert)
                    .font(.system(size: 25, weight: .bold))
            }
            Text(AppStrings.verifiezLesDetailsEtSaisissezVotreCodePin)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 45)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(Color(hex: "0788B9"))
    }

    private var amountCard: some View {
        VStack(spacing: 12) {
            Text(AppStrings.montant)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(formatAmount(parsedAmount))
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color(hex: "0788B9"))
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

            Divider()
            HStack {
                Text(AppStrings.fraisDEnvoi)
                Spacer()
                Text(fee > 0 ? formatAmount(fee) : AppStrings.gratuit)
            }
            .font(.system(size: 15))
            .foregroundColor(.secondary)

            Divider()
            HStack {
                Text(AppStrings.totalADebiter)
                Spacer()
                Text(formatAmount(total))
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Color(hex: "174EA6"))
        }
        .padding(16)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.14), lineWidth: 1))
    }

    private var recipientCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(AppStrings.informationsDuBeneficiaire)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.secondary)

            detailRow(AppStrings.beneficiary, value: accountName)
            Divider()
            detailRow(AppStrings.numeroDeCompte, value: accountNumber)
            if !bankName.isEmpty {
                Divider()
                detailRow(AppStrings.banque, value: bankName)
            }
        }
        .padding(16)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.14), lineWidth: 1))
    }

    @ViewBuilder
    private var descriptionCard: some View {
        if !paymentDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                Text(AppStrings.description)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.secondary)
                Text(paymentDetails)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.14), lineWidth: 1))
        }
    }

    private var pinEntry: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(AppStrings.authentification)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                if pinFieldFocused {
                    Button(AppStrings.buttonTitle(AppStrings.done)) { pinFieldFocused = false }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "0788B9"))
                }
            }

            WalletPINField(AppStrings.pin, text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($pinFieldFocused)
                .font(.system(size: 20, weight: .medium))
                .padding(.horizontal, 16)
                .frame(height: 62)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(showPinError ? Color.red : Color(hex: "0788B9"), lineWidth: 2))
                .onChange(of: pin) { newValue in
                    let digits = String(newValue.filter(\.isNumber).prefix(4))
                    if digits != newValue { pin = digits }
                    showPinError = false
                }

            if showPinError {
                Text(pinErrorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
        }
        .padding(.top, 4)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: onCancel) {
                Text(AppStrings.buttonTitle(AppStrings.annuler))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "0788B9"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "0788B9"), lineWidth: 1.5))
            }
            .disabled(isVerifyingPin)

            Button {
                validateAndConfirm()
            } label: {
                HStack(spacing: 8) {
                    if isVerifyingPin {
                        ProgressView().tint(.white)
                    }
                    Text(AppStrings.buttonTitle(AppStrings.transferer))
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "0788B9"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isVerifyingPin)
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    private var parsedAmount: Double {
        Double(amount.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func detailRow(_ title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .foregroundColor(.secondary)
            Spacer(minLength: 8)
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .font(.system(size: 15))
    }

    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return "\(formatter.string(from: NSNumber(value: value)) ?? "0.00") \(currency)"
    }

    private func validateAndConfirm() {
        guard !isVerifyingPin, isPresented else { return }
        showPinError = false

        guard pin.isValidWalletPIN else {
            pinErrorMessage = AppStrings.lePinDoitContenirExactement4Chiffres
            showPinError = true
            return
        }

        isVerifyingPin = true
        PinVerificationService.verify(pin: pin) { verifiedPin in
            DispatchQueue.main.async {
                isVerifyingPin = false
                guard isPresented else { return }
                onConfirm(verifiedPin)
            }
        } onFailure: { message in
            DispatchQueue.main.async {
                isVerifyingPin = false
                guard isPresented else { return }
                pinErrorMessage = message
                showPinError = true
                pin = ""
            }
        }
    }
}
