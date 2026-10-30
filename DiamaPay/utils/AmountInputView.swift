//
//  AmountInputView.swift
//  DiamaPay
//
//  Created by Bits on 12/11/2025.
//
import SwiftUI

// MARK: - Amount Input View
struct AmountInputView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    let merchantData: MerchantQRData
    let onConfirm: (Double, Bool, Double, String) -> Void // amount, feeEnabled, withdrawalFee, ruleIndex
    
    @State private var amountText = ""
    @State private var rawAmount: Double = 0.0  // ✅ Raw value for API calls
    @State private var currentWithdrawalFee: Double = 0.0
    @State private var withdrawalFeeRuleIndex: String = ""
    @State private var isFeeEnabled = false
    @State private var isCalculatingFee = false
    @State private var feeMessage = AppStrings.entrezUnMontantPourVoirLesFrais
    @State private var isDestinationAgent = false
    @State private var isDestinationMerchant = false
    @State private var isDestinationCustomer = false

    @FocusState private var isAmountFocused: Bool
    
    @State private var feeCalculationTimer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text(AppStrings.paiementQrCode)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.blueH)
                        
                        Text(AppStrings.paiementA)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        
                        Text(merchantData.merchantName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        
                        Rectangle()
                            .fill(Color.blueH)
                            .frame(width: 60, height: 2)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(AppStrings.montantAPayer)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .padding(.horizontal, 20)
                        
                        TextField("0", text: $amountText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 16, weight: .medium))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .focused($isAmountFocused)
                            .onChange(of: amountText) { newValue in
                                formatAmountInput(newValue)
                            }
                    }
                  
                    // Agent fee section (read-only display)
                    if shouldShowAgentFeeInfo {
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(AppStrings.fraisDeRetrait)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                    
                                    if isCalculatingFee {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                                .scaleEffect(0.7)
                                            Text(AppStrings.calculEnCours)
                                                .font(.system(size: 11))
                                                .foregroundColor(Color.gray)
                                        }
                                    } else {
                                        Text(feeMessage)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color.gray)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                    }

                    // P2P fee section (with toggle switch)
                    if shouldShowFeeSection {
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(AppStrings.fraisDePaiementQr)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                    
                                    if isCalculatingFee {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                                .scaleEffect(0.7)
                                            Text(AppStrings.calculEnCours)
                                                .font(.system(size: 11))
                                                .foregroundColor(Color.gray)
                                        }
                                    } else {
                                        Text(feeMessage)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isFeeEnabled)
                                    .labelsHidden()
                                    .disabled(currentWithdrawalFee <= 0)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    HStack(spacing: 16) {
                        Button(AppStrings.buttonTitle(AppStrings.annuler)) {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        
                        Button(AppStrings.buttonTitle(AppStrings.confirmer)) {
                            if rawAmount > 0 {
                                onConfirm(rawAmount, isFeeEnabled, currentWithdrawalFee, withdrawalFeeRuleIndex)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(isValidAmount ? Color.greenH : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(!isValidAmount)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle(AppStrings.entrerLeMontant)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isAmountFocused = true
                checkDestinationType()
            }
        }
    }
    
    private var shouldShowFeeSection: Bool {
        // Show fee section for P2P (not Agent, not Merchant)
        return isDestinationCustomer
    }

    private var shouldShowAgentFeeInfo: Bool {
        // Show read-only fee info for Agent
        return !isDestinationCustomer && !isDestinationMerchant
    }
    
    private var isValidAmount: Bool {
        return rawAmount > 0
    }
    
    private func checkDestinationType() {
        isDestinationAgent = merchantData.entityType == "AGENT"
        isDestinationMerchant = merchantData.entityType == "MERCHANT"
        isDestinationCustomer = merchantData.entityType == "CUSTOMER"
        
       
    }
    
    private func formatAmountInput(_ input: String) {
        // Remove all non-digit characters
        let digitsOnly = input.filter { $0.isNumber }
        
        // If empty, reset
        guard !digitsOnly.isEmpty else {
            amountText = ""
            rawAmount = 0.0
            handleAmountChange()
            return
        }
        
        // Convert to number
        guard let number = Double(digitsOnly) else {
            return
        }
        
        // Store raw amount for API
        rawAmount = number
        
        // Format with thousands separator (space)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        
        if let formatted = formatter.string(from: NSNumber(value: number)) {
            amountText = formatted
        }
        
        // Trigger fee calculation
        handleAmountChange()
    }
    
    private func handleAmountChange() {
        feeCalculationTimer?.invalidate()
        
        guard rawAmount > 0 else {
            feeMessage = AppStrings.entrezUnMontantPourVoirLesFrais
            currentWithdrawalFee = 0.0
            isFeeEnabled = false
            return
        }
        
        feeCalculationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            // Calculate fee for both Agent (display only) and P2P (with switch)
            if shouldShowAgentFeeInfo || shouldShowFeeSection {
                calculateWithdrawalFee()
            }
        }
    }
    
    private func calculateWithdrawalFee() {
        guard rawAmount > 0 else { return }
        
        isCalculatingFee = true
        
        let processingCode = isDestinationAgent ? "01" : "22" // AGENT CASHOUT vs P2P CASHOUT
        let origin = isDestinationAgent ? "V" : "W"
        
        let request = WalletFeeQuoteRequest.current(
            amount: rawAmount, destination: merchantData.merchantWallet,
            transactionType: processingCode, destinationBank: merchantData.bankCode
        )
        
   
        
        APIClient.shared.calculateWithdrawalFee(request: request) { result in
            DispatchQueue.main.async {
                isCalculatingFee = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        if let feeAmount = response.feeAmount {
                            currentWithdrawalFee = feeAmount
                            withdrawalFeeRuleIndex = response.ruleIndex ?? ""
                            
                            if feeAmount > 0 {
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .decimal
                                formatter.groupingSeparator = " "
                                formatter.maximumFractionDigits = 0
                                
                                if let formattedFee = formatter.string(from: NSNumber(value: feeAmount)) {
                                    feeMessage = AppStrings.fraisValueGmd(String(describing: formattedFee))
                                }
                            } else if response.respCode == "001" {
                                feeMessage = AppStrings.aucunFraisApplicable
                                isFeeEnabled = false
                            }
                            
                      
                        } else {
                            handleFeeError(AppStrings.montantDesFraisManquant)
                        }
                    } else {
                        handleFeeError(response.message ?? AppStrings.erreurDeCalcul)
                    }
                    
                case .failure(let error):
                    handleFeeError(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleFeeError(_ message: String) {
        feeMessage = AppStrings.impossibleDeCalculerLesFrais
        currentWithdrawalFee = 0.0
        isFeeEnabled = false
    }
}

// MARK: - QR Option Card
struct QROptionCardView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 60, height: 60)
                
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Text(description)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Image Picker
struct ImagePickerA: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerA
        
        init(_ parent: ImagePickerA) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
