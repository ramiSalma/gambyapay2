//
//  VoucherConfirmationDialog.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import SwiftUI

struct VoucherConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let amount: String
    let withdrawalFee: Double
    let fee: Double
    let total: Double
    let currency: String
    let recipientName: String
    let recipientPhone: String
    var title = AppStrings.confirmerLaMiseADisposition
    var providerName = ""
    var recipientIdNumber = ""
    var mobileMoneyStyle = false
    var moneyVoucherStyle = false
    let paymentDetails: String
    let sourceType: SourceOfFunds
    let selectedWallet: SponsoringWallet?
    
    @Binding var isPresented: Bool
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    @State private var pin: String = ""
    @State private var isPinVisible = false
    @State private var showPinError = false
    @State private var isVerifyingPin = false
    @State private var pinErrorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: moneyVoucherStyle ? .leading : .center, spacing: 8) {
                    if moneyVoucherStyle {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 22, weight: .semibold))
                            Text(title)
                                .font(.system(size: 22, weight: .bold))
                        }
                        Text(AppStrings.verifyYourTransactionDetails)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.leading, 34)
                    } else {
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(mobileMoneyStyle ? Color(hex: "174EA6") : Color.primary)
                            .multilineTextAlignment(.center)
                    }
                }
                .foregroundColor(moneyVoucherStyle ? .white : .primary)
                .padding(.top, moneyVoucherStyle ? 20 : 24)
                .padding(.bottom, moneyVoucherStyle ? 18 : 0)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: moneyVoucherStyle ? .leading : .center)
                .background(moneyVoucherStyle ? Color(hex: "0788B9") : Color.clear)
                
                Divider()
                    .padding(.vertical, 16)
                
                // Transaction Details
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            DetailRowView(
                                label: (mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.amount : AppStrings.montant3,
                                value: formatAmount(Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0)
                            )
                            
                            // Withdrawal Fee (conditional)
                            if withdrawalFee > 0 {
                                DetailRowView(
                                    label: moneyVoucherStyle ? AppStrings.availabilityFee : (mobileMoneyStyle ? AppStrings.withdrawalFee2 : AppStrings.fraisDeRetrait),
                                    value: formatAmount(withdrawalFee)
                                )
                            }
                            
                            // Transaction/Sending Fee
                            DetailRowView(
                                label: moneyVoucherStyle ? AppStrings.voucherFee : (mobileMoneyStyle ? AppStrings.mobileMoneyFee : AppStrings.fraisDeMiseADisposition),
                                value: fee > 0 ? formatAmount(fee) : ((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.free : AppStrings.gratuit)
                            )
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            // Total to Debit
                            DetailRowView(
                                label: (mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.totalToDebit2 : AppStrings.totalADebiter,
                                value: formatAmount(total),
                                isHighlighted: true
                            )
                        }
                        .padding(16)
                        .modifier(ConfirmationCardStyle(voucherStyle: moneyVoucherStyle))
                        .onAppear {
                            //print("🔍 Confirmation Dialog Values:")
                            //print("   Amount: \(amount)")
                            //print("   Withdrawal Fee: \(withdrawalFee)")
                            //print("   Transaction Fee: \(fee)")
                            //print("   Total: \(total)")
                        }
                        
                        // Recipient Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.recipientInformation2 : AppStrings.destinataire2)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            DetailRowView(label: (mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.recipient : AppStrings.nom2, value: recipientName)
                            DetailRowView(label: (mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.phone : AppStrings.telephone2, value: recipientPhone)
                            if moneyVoucherStyle && !recipientIdNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                DetailRowView(label: AppStrings.idNumber, value: recipientIdNumber)
                            }
                            if !providerName.isEmpty {
                                DetailRowView(label: AppStrings.provider, value: providerName)
                            }
                        }
                        .padding(16)
                        .modifier(ConfirmationCardStyle(voucherStyle: moneyVoucherStyle))
                        
                        // Source of Funds
                        VStack(alignment: .leading, spacing: 12) {
                            Text((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.sourceOfFunds : AppStrings.sourceDesFonds2)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            if sourceType == .sponsor, let wallet = selectedWallet {
                                DetailRowView(label: AppStrings.type, value: (mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.sponsorWallet : AppStrings.portefeuilleSponsor)
                                DetailRowView(label: AppStrings.sponsor, value: wallet.userName)
                            } else {
                                DetailRowView(label: AppStrings.type, value: (mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.myWallet : AppStrings.monPortefeuille)
                            }
                        }
                        .padding(16)
                        .modifier(ConfirmationCardStyle(voucherStyle: moneyVoucherStyle))
                        
                        // Payment Details
                        if !paymentDetails.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.reason : AppStrings.commentaire)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text(paymentDetails)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .modifier(ConfirmationCardStyle(voucherStyle: moneyVoucherStyle))
                        }
                        
                        // PIN Entry
                        VStack(alignment: .leading, spacing: 12) {
                            Text((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.authentication2 : AppStrings.pin)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 14) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor((mobileMoneyStyle || moneyVoucherStyle) ? Color(hex: "0788B9") : .blueH)
                                Group {
                                    if isPinVisible {
                                        WalletPINField((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.pinCode : AppStrings.entrerLeCodePin, text: $pin, isSecure: false)
                                    } else {
                                        WalletPINField((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.pinCode : AppStrings.entrerLeCodePin, text: $pin)
                                    }
                                }
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .medium))
                                Button { isPinVisible.toggle() } label: {
                                    Image(systemName: isPinVisible ? "eye" : "eye.slash")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(showPinError ? Color.red : Color.gray.opacity(0.65), lineWidth: 1.2))
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
                        .modifier(ConfirmationCardStyle(voucherStyle: moneyVoucherStyle))
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
                        Text(AppStrings.buttonTitle((mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.cancel : AppStrings.annuler))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(moneyVoucherStyle ? .white : .blueH)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(moneyVoucherStyle ? Color(hex: "0788B9") : Color.white)
                            .cornerRadius(moneyVoucherStyle ? 12 : 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(moneyVoucherStyle ? Color(hex: "0788B9") : (mobileMoneyStyle ? Color(hex: "174EA6") : Color.blueH), lineWidth: 1)
                            )
                    }
                    
                    Button(action: { validateAndConfirm() }) {
                        Group {
                            if isVerifyingPin {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(AppStrings.buttonTitle(moneyVoucherStyle ? AppStrings.transfer : (mobileMoneyStyle ? AppStrings.confirm : AppStrings.confirmer)))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background((mobileMoneyStyle || moneyVoucherStyle) ? Color(hex: "0788B9") : Color.greenH)
                        .cornerRadius(moneyVoucherStyle ? 12 : 8)
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
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " " + currency
    }

    private func validateAndConfirm() {
        showPinError = false
        
        guard pin.isValidWalletPIN else {
            pinErrorMessage = (mobileMoneyStyle || moneyVoucherStyle) ? AppStrings.pinMustContainExactly4Digits : AppStrings.lePinDoitContenirExactement4Chiffres
            showPinError = true
            return
        }
        
        isVerifyingPin = true
        
        PinVerificationService.verify(pin: pin) { verifiedPin in
            isVerifyingPin = false
            onConfirm(verifiedPin)
        } onFailure: { message in
            isVerifyingPin = false
            pinErrorMessage = message
            showPinError = true
            pin = ""
        }
    }
}

private struct ConfirmationCardStyle: ViewModifier {
    let voucherStyle: Bool

    func body(content: Content) -> some View {
        content
            .background(voucherStyle ? Color(hex: "F8F9FB") : Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: voucherStyle ? 14 : 12))
            .overlay(RoundedRectangle(cornerRadius: voucherStyle ? 14 : 12)
                .stroke(voucherStyle ? Color(hex: "E1E5EB") : Color.clear, lineWidth: 1.2))
    }
}

struct DetailRowView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let label: String
    let value: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: isHighlighted ? 16 : 14, weight: isHighlighted ? .semibold : .regular))
                .foregroundColor(isHighlighted ? Color(hex: "263445") : Color(hex: "667085"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: isHighlighted ? 16 : 14, weight: isHighlighted ? .bold : .semibold))
                .foregroundColor(isHighlighted ? Color(hex: "174EA6") : Color(hex: "263445"))
        }
    }
}
