//
//  TransferConfirmationDialog.swift
//  DiamaPay
//
//  Created by Bits on 28/9/2025.
//  Updated to show withdrawal fees and transfer fees with clear visual distinction
//

import SwiftUI

struct TransferConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let amount: String
    let withdrawalFee: Double
    let transferFee: Double
    let total: Double
    let currency: String
    let recipientName: String
    let recipientPhone: String
    let paymentDetails: String
    let sourceType: SourceOfFunds
    let selectedWallet: SponsoringWallet?
    
    @Binding var isPresented: Bool
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    @State private var pin: String = ""
    @State private var showPinError = false
    @State private var pinErrorMessage = ""
    @State private var isVerifyingPin = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "174EA6"))
                        .frame(width: 42, height: 42)
                        .background(Color(hex: "EAF1FB"))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 5) {
                        Text(AppStrings.confirmTransfer)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "172B4D"))
                        Text(AppStrings.reviewTheDetailsAndEnterYourPin)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "5F6B7A"))
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 22)
                .padding(.horizontal, 22)
                
                Divider()
                    .padding(.vertical, 16)
                
                // Transaction Details
                ScrollView {
                    VStack(spacing: 16) {
                        // Amount Section with Fees Breakdown
                        VStack(spacing: 12) {
                            DetailRowView(label: AppStrings.transferAmount, value: formatAmount(Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0))
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            // Fees Breakdown Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text(AppStrings.applicableFees)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "667085"))
                                
                                // Withdrawal Fee (if applicable)
                                if withdrawalFee > 0 {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Image(systemName: "banknote")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Text(AppStrings.withdrawalFee2)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color(hex: "263445"))
                                        }
                                        Spacer()
                                        Text(formatAmount(withdrawalFee))
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Transfer/Sending Fee
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(transferFee > 0 ? .blueH : .green)
                                        Text(AppStrings.transferFee2)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(hex: "263445"))
                                    }
                                    Spacer()
                                    Text(transferFee > 0 ? formatAmount(transferFee) : AppStrings.free)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(transferFee > 0 ? .blueH : .green)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background((transferFee > 0 ? Color.blueH : Color.green).opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            DetailRowView(
                                label: AppStrings.totalToDebit,
                                value: formatAmount(total),
                                isHighlighted: true
                            )
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "E5E9EF"), lineWidth: 1))
                        
                        // Recipient Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.recipient)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "667085"))
                            
                            DetailRowView(label: AppStrings.name, value: recipientName)
                            DetailRowView(label: AppStrings.recipientNumber, value: recipientPhone)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "E5E9EF"), lineWidth: 1))
                        
                        // Source of Funds
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.sourceOfFunds2)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "667085"))
                            
                            if sourceType == .sponsor, let wallet = selectedWallet {
                                DetailRowView(label: AppStrings.type, value: AppStrings.sponsorWallet)
                                DetailRowView(label: AppStrings.sponsor, value: wallet.userName)
                            } else {
                                DetailRowView(label: AppStrings.type, value: AppStrings.myWallet)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "E5E9EF"), lineWidth: 1))
                        
                        // Payment Details
                        if !paymentDetails.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(AppStrings.reason)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "667085"))
                                
                                Text(paymentDetails)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "263445"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "E5E9EF"), lineWidth: 1))
                        }
                        
                        // PIN Entry
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.pin)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "667085"))
                            
                            WalletPINField(AppStrings.enterPin, text: $pin)
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
                                .onChange(of: pin) { newValue in
                                    if newValue.count > 4 { pin = String(newValue.prefix(4)) }
                                    showPinError = false
                                }
                            
                            if showPinError {
                                Text(pinErrorMessage)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "E5E9EF"), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 400)
                
                Divider()
                    .padding(.vertical, 16)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        onCancel()
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.cancel))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blueH)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "0788B9"), lineWidth: 1)
                            )
                    }
                    
                    Button(action: { validateAndConfirm() }) {
                        Group {
                            if isVerifyingPin {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(AppStrings.buttonTitle(AppStrings.confirm))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "174EA6"))
                        .cornerRadius(10)
                    }
                    .disabled(isVerifyingPin)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(1)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + currency
    }
    
    private func validateAndConfirm() {
        guard !isVerifyingPin, isPresented else { return }
        showPinError = false
        
        guard pin.isValidWalletPIN else {
            pinErrorMessage = AppStrings.pinMustContainExactly4Digits
            showPinError = true
            return
        }
        
        isVerifyingPin = true
        
        PinVerificationService.verify(pin: pin) { verifiedPin in
            isVerifyingPin = false
            guard isPresented else { return }
            onConfirm(verifiedPin)
        } onFailure: { message in
            isVerifyingPin = false
            guard isPresented else { return }
            pinErrorMessage = message
            showPinError = true
            pin = ""
        }
    }
}
