//
//  DSDPinValidationDialog.swift
//  DiamaPay
//
//  Created by bits dev team on 24/11/2025.
//


//
//  DSDDialogs.swift
//  DiamaPay
//
//  Dialog components for DSD Payment flow
//

import SwiftUI

// MARK: - PIN Validation Dialog
struct DSDPinValidationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let operation: DSDPendingOperation
    @Binding var isPresented: Bool
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    @State private var pin: String = ""
    @FocusState private var isPinFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(alignment: .leading, spacing: 24) {
                // Title Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.valider)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(AppStrings.entrezVotreCodePin)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // Payment Details Card
                VStack(spacing: 16) {
                    // Chassis Row
                    HStack {
                        Text(AppStrings.chassis)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(operation.chassisNumber)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Amount Row
                    HStack {
                        Text(AppStrings.montantAPayer)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(operation.formattedAmount)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                .padding(20)
                .background(Color.blueH.opacity(0.05))
                .cornerRadius(12)
                
                // PIN Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.pin)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    WalletPINField("", text: $pin)
                        .keyboardType(.numberPad)
                        .font(.system(size: 14, weight: .medium))
                        .padding()
                        .frame(height: 52)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isPinFocused ? Color.green : Color.clear, lineWidth: 2)
                        )
                        .focused($isPinFocused)
                        .onChange(of: pin) { newValue in
                            if newValue.count > 4 {
                                pin = String(newValue.prefix(4))
                            }
                        }
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    
                    Button(action: {
                        if (pin.isValidWalletPIN) {
                            onConfirm(pin)
                        }
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.confirmer))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background((!pin.isValidWalletPIN) ? Color.gray : Color.green)
                            .cornerRadius(12)
                    }
                    .disabled((!pin.isValidWalletPIN))
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20)
            .padding(.horizontal, 24)
        }
        .onAppear {
            isPinFocused = true
        }
    }
}

// MARK: - Validation Confirmation Dialog
struct DSDValidationConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let operation: DSDPendingOperation
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(alignment: .leading, spacing: 24) {
                // Icon and Title
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text(AppStrings.confirmerLaValidation)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(AppStrings.voulezVousVraimentValiderCePaiementDsd)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Payment Details Card
                VStack(spacing: 16) {
                    DetailRow(label: AppStrings.chassis, value: operation.chassisNumber)
                    Divider()
                    DetailRow(label: AppStrings.categorie, value: operation.categoryDisplay)
                    Divider()
                    DetailRow(label: AppStrings.montant3, value: operation.formattedAmount, valueColor: .green)
                    Divider()
                    DetailRow(label: AppStrings.reference2, value: operation.operationId)
                }
                .padding(20)
                .background(Color.blueH.opacity(0.05))
                .cornerRadius(12)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    
                    Button(action: onConfirm) {
                        Text(AppStrings.buttonTitle(AppStrings.continuer))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Rejection Confirmation Dialog
struct DSDRejectionConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let operation: DSDPendingOperation
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(alignment: .leading, spacing: 24) {
                // Icon and Title
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    
                    Text(AppStrings.confirmerLeRejet)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(AppStrings.voulezVousVraimentRejeterCePaiementDsdCetteActionEst)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Payment Details Card
                VStack(spacing: 16) {
                    DetailRow(label: AppStrings.chassis, value: operation.chassisNumber)
                    Divider()
                    DetailRow(label: AppStrings.categorie, value: operation.categoryDisplay)
                    Divider()
                    DetailRow(label: AppStrings.montant3, value: operation.formattedAmount, valueColor: .red)
                    Divider()
                    DetailRow(label: AppStrings.reference2, value: operation.operationId)
                }
                .padding(20)
                .background(Color.red.opacity(0.05))
                .cornerRadius(12)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                    }
                    
                    Button(action: onConfirm) {
                        Text(AppStrings.buttonTitle(AppStrings.rejeter))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20)
            .padding(.horizontal, 24)
        }
    }
}

