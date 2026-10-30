import SwiftUI

struct QRPaymentConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let paymentData: EMVQRPaymentData
    let sendingFee: Double
    let withdrawalFee: Double
    let isDynamic: Bool
    let recipientType: RecipientType
    @Binding var isPresented: Bool
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @State private var pin: String = ""
    @State private var showPinError = false
    @State private var pinErrorMessage = ""
    @State private var isValidatingPin = false

    private let userDataManager = UserDataManager.shared

    // ✅ Correct fee logic
    private var displaySendingFee: Double {
        recipientType == .client ? sendingFee : 0
    }

    private var displayWithdrawalFee: Double {
        switch recipientType {
        case .client:
            return withdrawalFee
        case .agent:
            return withdrawalFee  // Always show for agent (dynamic or static)
        case .merchant, .unknown:
            return 0  // Never show for merchant
        }
    }

    // ✅ Total amount calculation
    private var totalAmount: Double {
        switch recipientType {
        case .client:
            if isDynamic {
                return paymentData.amount + displaySendingFee
            } else {
                return paymentData.amount + displaySendingFee + displayWithdrawalFee
            }
        case .agent:
            // Always include withdrawal fee for agent (dynamic or static)
            return paymentData.amount + displayWithdrawalFee
        case .merchant, .unknown:
            // No fees for merchant
            return paymentData.amount
        }
    }

    // Base amount - always show the full amount from QR/input
    private var displayBaseAmount: Double {
        // ✅ Always return the full payment amount (no deductions)
        return paymentData.amount
    }

    private var showRecipientDetails: Bool {
        recipientType != .unknown
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isValidatingPin { onCancel() }
                }

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(AppStrings.paiementCodeQrEmv)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    if paymentData.isExpired {
                        Text(AppStrings.ceCodeQrAExpire)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)

                Divider()
                    .padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        // Amount & Fees
                        VStack(spacing: 12) {
                            Text(AppStrings.montantAPayer)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)

                            Text(formatAmount(displayBaseAmount))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.greenH)

                            if displaySendingFee > 0 || displayWithdrawalFee > 0 {
                                VStack(spacing: 8) {
                                    Divider().padding(.vertical, 4)

                                    if displaySendingFee > 0 {
                                        HStack {
                                            Text(AppStrings.fraisDEnvoi2)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(formatAmount(displaySendingFee))
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.orange)
                                        }
                                    }

                                    if displayWithdrawalFee > 0 {
                                        HStack {
                                            Text(AppStrings.fraisDeRetrait2)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(formatAmount(displayWithdrawalFee))
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.orange)
                                        }
                                    }

                                    Divider().padding(.vertical, 4)

                                    HStack {
                                        Text(AppStrings.totalADebiter2)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(formatAmount(totalAmount))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.blueH)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(16)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                        // Recipient Details
                        VStack(alignment: .leading, spacing: 12) {
                            if showRecipientDetails {
                                HStack {
                                    Text(AppStrings.destinataire2)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Text(recipientTypeName)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(recipientTypeColor)
                                        .cornerRadius(4)
                                }
                            }

                            DetailRowView(label: AppStrings.nom2, value: paymentData.merchantName)
                            DetailRowView(label: AppStrings.portefeuille2, value: paymentData.merchantWallet)

                            if !paymentData.bankCode.isEmpty {
                                DetailRowView(label: AppStrings.banque, value: AppStrings.diamabankSa)
                            }

                            if paymentData.expiresAt != nil {
                                DetailRowView(label: AppStrings.expireLe, value: paymentData.formattedExpiration)
                            }
                        }
                        .padding(16)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                        // PIN Entry
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.pin)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)

                            WalletPINField(AppStrings.entrerLeCodePin, text: $pin)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(showPinError ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(isValidatingPin)
                                .onChange(of: pin) {
                                    if pin.count > 4 { pin = String(pin.prefix(4)) }
                                    showPinError = false
                                }

                            if showPinError {
                                Text(pinErrorMessage)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 450)

                Divider()
                    .padding(.vertical, 16)

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        if !isValidatingPin { onCancel() }
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blueH)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blueH, lineWidth: 1)
                            )
                    }
                    .disabled(isValidatingPin)

                    Button(action: { validateAndConfirm() }) {
                        if isValidatingPin {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text(AppStrings.buttonTitle(AppStrings.payer))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(paymentData.isExpired || !pin.isValidWalletPIN || isValidatingPin ? Color.gray : Color.greenH)
                    .cornerRadius(8)
                    .disabled(paymentData.isExpired || !pin.isValidWalletPIN || isValidatingPin)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 500)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
        }
    }

    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        formatter.maximumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " GMD"
    }

    private var recipientTypeName: String {
        switch recipientType {
        case .client: return AppStrings.client
        case .merchant: return AppStrings.marchand
        case .agent: return AppStrings.agent2
        case .unknown: return AppStrings.inconnu
        }
    }

    private var recipientTypeColor: Color {
        switch recipientType {
        case .client: return .blue
        case .merchant: return .green
        case .agent: return .orange
        case .unknown: return .gray
        }
    }

    private func validateAndConfirm() {
        guard pin.isValidWalletPIN else {
            showPinError = true
            pinErrorMessage = AppStrings.leCodePinDoitContenir4Chiffres
            return
        }

        guard !paymentData.isExpired else {
            showPinError = true
            pinErrorMessage = AppStrings.ceCodeQrAExpire
            return
        }

        isValidatingPin = true

        var pinRequest = RequestNameEnquiry()
        pinRequest.source = "P"
        pinRequest.phoneNumber = userDataManager.getPhoneNumber()
        pinRequest.bank = "00100"
        pinRequest.pin = pin

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        pinRequest.requestId = datePrefix + randomDigits

        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        pinRequest.requestDate = fullDateFormatter.string(from: Date())
        pinRequest.entityId = UserDataManager.shared.getUserCode()

        APIClient.shared.getWalletInfo(request: pinRequest) { result in
            DispatchQueue.main.async {
                self.isValidatingPin = false

                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.onConfirm(self.pin)
                    } else {
                        self.handlePinValidationError(response)
                    }
                case .failure(let error):
                    self.showPinError = true
                    self.pinErrorMessage = (error as? APIError)?.message ?? AppStrings.erreurReseauValue(String(describing: error.localizedDescription))
                }
            }
        }
    }

    private func handlePinValidationError(_ response: ResponseServiceJson) {
        showPinError = true
        let errorMessage = response.message ?? {
            switch response.respCode {
            case "001": return AppStrings.portefeuilleNonTrouve
            case "003": return AppStrings.donneesManquantesDansLaRequete
            case "005": return AppStrings.codePinIncorrect
            case "006": return AppStrings.codePinBloque
            case "021": return AppStrings.utilisateurNonAutorise
            default: return AppStrings.echecDeLaValidationCodeValue(String(describing: response.respCode ?? "N/A"))
            }
        }()
        pinErrorMessage = errorMessage
    }
}
