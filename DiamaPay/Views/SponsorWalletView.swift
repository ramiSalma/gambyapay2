//
//  SponsorWalletView.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import SwiftUI
import Contacts
import ContactsUI

struct SponsorWalletView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()
    
    // MARK: - State Variables
    @State private var recipientPhone: String = ""
    @State private var recipientName: String = ""
    @State private var dailyLimit: String = ""
    @State private var monthlyLimit: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var pin: String = ""
    
    @State private var showContactPicker = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var showPinEntry = false
    @State private var isVerifying = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var sponsoredBankCode = ""
    @State private var isRecipientVerified = false
    @State private var recipientLookupID = UUID()
    @State private var recipientLookupError = ""
    
    private let userDataManager = UserDataManager.shared
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.sponsorAWallet, headerColor: Color(hex: "174EA6"))

                if isLoading {
                    loadingView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Title Card
                            
                            // Recipient Details Card
                            recipientDetailsCard
                            
                            // Limits Card
                            limitsCard
                            
                            // Period Card
                            periodCard
                            
                            // Submit Button
                            submitButton
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .tint(Color(hex: "174EA6"))
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .alert(AppStrings.entrerLeCodePin, isPresented: $showPinEntry) {
            WalletPINField(AppStrings.pin, text: $pin)
                .keyboardType(.numberPad)
                .onChange(of: pin) {
                    pin = String(pin.filter { $0.isASCII && $0.isNumber }.prefix(4))
                }
            Button(AppStrings.buttonTitle(AppStrings.annuler), role: .cancel) { pin = "" }
            Button(AppStrings.buttonTitle(AppStrings.confirmer)) {
                let enteredPin = pin
                pin = ""
                guard !isLoading, validateInputs(),
                      enteredPin.isValidWalletPIN,
                      enteredPin.allSatisfy({ $0.isASCII && $0.isNumber }) else { return }
                processSponsorWithPin(enteredPin)
            }
            .disabled(!pin.isValidWalletPIN)
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPickerView(selectedPhone: $recipientPhone, normalizePhone: WalletTransferRecipient.normalize)
        }
        .sheet(isPresented: $showStartDatePicker) {
            DatePickerSheetz(
                selectedDate: $startDate,
                minimumDate: Date(),
                title: AppStrings.startDate2,
                onSave: {
                    showStartDatePicker = false
                    validateDateRange()
                }
            )
        }
        .sheet(isPresented: $showEndDatePicker) {
            DatePickerSheetz(
                selectedDate: $endDate,
                minimumDate: Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date(),
                title: AppStrings.endDate2,
                onSave: {
                    showEndDatePicker = false
                }
            )
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "174EA6")))
                .scaleEffect(1.5)
            
            Text(AppStrings.processing2)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Title Card
    private var titleCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "174EA6"))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text(AppStrings.sponsoriserUnPortefeuille)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 80, height: 3)
            }
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Source Details Card
    private var sourceDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.sourceDesFonds)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "174EA6"))
                    .frame(width: 60, height: 2)
            }
            
            HStack {
                Text(AppStrings.numeroDeTelephone)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(userDataManager.getPhoneNumber())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text(AppStrings.walletNumber2)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(userDataManager.getWalletNumber())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Recipient Details Card (Optimized with Auto-Verify)
    private var recipientDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.recipientDetails)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "174EA6"))
                    .frame(width: 96, height: 3)
            }
            
            HStack(alignment: .top, spacing: 10) {
                HStack(spacing: 8) {
                    TextField(AppStrings.recipientNumber2, text: $recipientPhone.walletPhoneNumber())
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.leading, 12)
                        .onChange(of: recipientPhone) {
                            resetVerificationFields()
                            recipientLookupError = ""
                            showPinEntry = false
                            pin = ""
                        }
                        .task(id: recipientPhone) {
                            guard WalletTransferRecipient.isValid(recipientPhone) else { return }
                            do { try await Task.sleep(nanoseconds: 500_000_000) } catch { return }
                            verifyRecipient()
                        }
                    
                    if isVerifying {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "174EA6")))
                            .scaleEffect(0.8)
                            .padding(.trailing, 12)
                    } else if isRecipientVerified && !recipientName.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "174EA6"))
                            .padding(.trailing, 12)
                    }
                }
                .frame(height: 54)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "4B5563"), lineWidth: 1.5))
                .cornerRadius(12)
                
                Button(action: { showContactPicker = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 25, weight: .medium))
                            .frame(width: 46, height: 44)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "174EA6"), lineWidth: 1.5))
                        Text(AppStrings.buttonTitle(AppStrings.contacts))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "174EA6"))
                }
            }
            
            if isRecipientVerified && !recipientName.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(hex: "174EA6"))
                        .font(.system(size: 14))
                    
                    Text(recipientName)
                        .font(.system(size: 14, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(hex: "174EA6").opacity(0.1))
                .cornerRadius(8)
            }
            if !recipientLookupError.isEmpty {
                Text(recipientLookupError)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .accessibilityLabel(recipientLookupError)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Limits Card
    private var limitsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.limits)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "174EA6"))
                    .frame(width: 96, height: 3)
            }
            
            limitField(placeholder: AppStrings.dailyLimit2, text: $dailyLimit)
            
            limitField(placeholder: AppStrings.monthlyLimit, text: $monthlyLimit)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Period Card
    private var periodCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.period)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "174EA6"))
                    .frame(width: 96, height: 3)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.startDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Button(action: {
                    showStartDatePicker = true
                }) {
                    HStack {
                        Text(formatDate(startDate))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "174EA6"))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "4B5563"), lineWidth: 1.5))
                    .cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.endDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Button(action: {
                    showEndDatePicker = true
                }) {
                    HStack {
                        Text(formatDate(endDate))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "174EA6"))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "4B5563"), lineWidth: 1.5))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            validateAndPrepare()
        }) {
            Text(AppStrings.buttonTitle(AppStrings.send))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 150)
                .frame(height: 52)
                .background(Color(hex: "174EA6"))
                .cornerRadius(8)
        }
        .disabled(isLoading || isVerifying || !isRecipientVerified)
        .opacity(isLoading || isVerifying || !isRecipientVerified ? 0.45 : 1)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private func limitField(placeholder: String, text: Binding<String>) -> some View {
        FormattedTextField(placeholder: placeholder, text: text, sponsorFormStyle: true)
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return formatter.string(from: date)
    }
    
    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    private func resetVerificationFields() {
        recipientLookupID = UUID()
        isVerifying = false
        recipientName = ""
        sponsoredBankCode = ""
        isRecipientVerified = false
    }
    
    private func validateDateRange() {
        if endDate <= startDate {
            let newEndDate = Calendar.current.date(byAdding: .month, value: 3, to: startDate) ?? Date()
            endDate = newEndDate
            showError(AppStrings.dateAdjusted, AppStrings.theEndDateWasMovedAfterTheStartDate)
        }
    }
    
    // MARK: - Verify Recipient
    private func verifyRecipient() {
        let recipient = WalletTransferRecipient.normalize(recipientPhone)
        guard !recipient.isEmpty else { return }
        let lookupID = UUID()
        recipientLookupID = lookupID
        recipientLookupError = ""
        isVerifying = true
        
        var request = RequestNameEnquiry()
        request.source = "P"
        request.phoneNumber = recipient
        request.bank = "00100"
        request.pin = userDataManager.getPinForAPI()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.getWalletInfo(request: request) { result in
            DispatchQueue.main.async {
                guard self.recipientLookupID == lookupID,
                      WalletTransferRecipient.normalize(self.recipientPhone) == recipient else { return }
                self.isVerifying = false

                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.handleVerificationSuccess(response)
                    } else {
                        self.handleVerificationError(response)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.recipientLookupError = apiError.message
                    } else {
                        self.recipientLookupError = error.localizedDescription
                    }
                    self.resetVerificationFields()
                }
            }
        }
    }
    
    private func handleVerificationSuccess(_ response: ResponseServiceJson) {
        if let result = response.result {
            let clientName = result["walletHolder"] as? String ?? ""
            guard !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                recipientLookupError = AppStrings.recipientInformationIsUnavailable
                resetVerificationFields()
                return
            }

            sponsoredBankCode = "00100"
            recipientName = clientName
            isRecipientVerified = true
        } else {
            recipientLookupError = AppStrings.recipientInformationIsUnavailable
            resetVerificationFields()
        }
    }
    
    private func handleVerificationError(_ response: ResponseServiceJson) {
        let errorMessage = response.message ?? {
            switch response.respCode {
            case "001": return AppStrings.walletNotFound
            case "003": return AppStrings.requiredRequestDetailsAreMissing
            case "005": return AppStrings.incorrectPin
            case "006": return AppStrings.pinIsBlocked
            case "021": return AppStrings.userIsNotAuthorized
            default: return AppStrings.verificationFailedCodeValue(String(describing: response.respCode ?? "N/A"))
            }
        }()
        
        recipientLookupError = errorMessage
        resetVerificationFields()
    }
    
    // MARK: - Validate and Prepare
    private func validateAndPrepare() {
        guard validateInputs() else { return }
        
        pin = ""
        showPinEntry = true
    }

    private func validateInputs() -> Bool {
        if WalletTransferRecipient.normalize(recipientPhone).isEmpty {
            showError(AppStrings.error, AppStrings.recipientPhoneNumberIsRequired2)
            return false
        }
        
        if isVerifying || !isRecipientVerified || recipientName.isEmpty {
            showError(AppStrings.error, AppStrings.pleaseVerifyTheRecipientFirst)
            return false
        }
        
        if dailyLimit.isEmpty {
            showError(AppStrings.error, AppStrings.dailyLimitIsRequired)
            return false
        }
        
        if monthlyLimit.isEmpty {
            showError(AppStrings.error, AppStrings.monthlyLimitIsRequired)
            return false
        }
        
        guard let daily = Double(dailyLimit.cleanCurrencyValue()),
              let monthly = Double(monthlyLimit.cleanCurrencyValue()) else {
            showError(AppStrings.error, AppStrings.enterValidLimitAmounts)
            return false
        }
        
        if monthly < daily {
            showError(AppStrings.error, AppStrings.monthlyLimitMustBeAtLeastTheDailyLimit)
            return false
        }
        
        return true
    }
    
    // MARK: - Process Sponsor
    private func processSponsorWithPin(_ enteredPin: String) {
        isLoading = true
        
        var request = SponsoredWalletDto()
        request.source = "P"
        request.phoneNumber = userDataManager.getPhoneNumber()
        request.walletNumber = userDataManager.getWalletNumber()
        request.bankCode = "00100"
        
        request.phoneNumberSponsored = WalletTransferRecipient.normalize(recipientPhone)
        request.walletNumberSponsored = ""
        request.bankCodeSponsored = sponsoredBankCode.isEmpty ? "00100" : sponsoredBankCode
        
        request.dailyLimit = dailyLimit.cleanCurrencyValue()
        request.monthlyLimit = monthlyLimit.cleanCurrencyValue()
        request.dateStart = formatDateForAPI(startDate) + " 00:00:00"
        request.dateEnd = formatDateForAPI(endDate) + " 23:59:59"
        
        request.pin = enteredPin
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = fullDateFormatter.string(from: Date())
        request.entityId = UserDataManager.shared.getUserCode()
        
        APIClient.shared.sponsorWallet(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.showSuccessAndDismiss(AppStrings.walletSponsoredSuccessfully)
                    } else {
                        self.showError(AppStrings.error, response.message ?? AppStrings.couldNotSponsorThisWallet)
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showError(AppStrings.error, apiError.message)
                    } else {
                        self.showError(AppStrings.error, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func showError(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccess(_ message: String) {
        alertTitle = AppStrings.success
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccessAndDismiss(_ message: String) {
        alertTitle = AppStrings.success
        alertMessage = message
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.view.tintColor = UIColor(Color(hex: "174EA6"))
        alert.addAction(UIAlertAction(title: AppStrings.ok, style: .default) { _ in
            self.dismiss()
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheetz: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var selectedDate: Date
    let minimumDate: Date
    let title: String
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: minimumDate...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.buttonTitle(AppStrings.cancel)) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.buttonTitle(AppStrings.save)) {
                        onSave()
                    }
                }
            }
        }
    }
}
