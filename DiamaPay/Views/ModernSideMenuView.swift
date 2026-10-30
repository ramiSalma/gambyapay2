//
//  ModernSideMenuView.swift
//  DiamaPay
//
//  Created by Bits on 31/10/2025.
//


import SwiftUI

struct ModernSideMenuView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    var onSelect: (String) -> Void
    @State private var selectedItem: String? = nil
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Modern gradient header
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blueH, Color.blueH.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "wallet.pass.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        Text("GambiaPay")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(AppStrings.votrePortefeuilleDigitalSecurise)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .padding(.top, 50)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 160)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Menu sections
                VStack(spacing: 0) {
                    // TRANSFERT Section
                    MenuSection(title: AppStrings.transfert) {
                        ModernDrawerItem(
                            icon: "arrow.left.arrow.right",
                            title: AppStrings.transfererDeLArgent,
                            iconColor: .blue,
                            isSelected: selectedItem == "walletTransfer"
                        ) {
                            selectedItem = "walletTransfer"
                            onSelect("walletTransfer")
                        }
                        
                        ModernDrawerItem(
                            icon: "wallet.bifold.fill",
                            title: AppStrings.walletVersMaBanque,
                            iconColor: .purple,
                            isSelected: selectedItem == "walletToAccountTransfer"
                        ) {
                            selectedItem = "walletToAccountTransfer"
                            onSelect("walletToAccountTransfer")
                        }
                        
                        ModernDrawerItem(
                            icon: "building.columns.fill",
                            title: AppStrings.banqueVersMonWallet,
                            iconColor: .orange,
                            isSelected: selectedItem == "accountToWalletTransfer"
                        ) {
                            selectedItem = "accountToWalletTransfer"
                            onSelect("accountToWalletTransfer")
                        }
                        
                        ModernDrawerItem(
                            icon: "ticket.fill",
                            title: AppStrings.moneyVoucher,
                            iconColor: .green,
                            isSelected: selectedItem == "moneyVoucher"
                        ) {
                            selectedItem = "moneyVoucher"
                            onSelect("moneyVoucher")
                        }
                        
                        ModernDrawerItem(
                            icon: "qrcode",
                            title: AppStrings.qrPayment,
                            iconColor: .indigo,
                            isSelected: selectedItem == "qr"
                        ) {
                            selectedItem = "qr"
                            onSelect("qr")
                        }
                        
                        ModernDrawerItem(
                            icon: "person.3.fill",
                            title: AppStrings.crowdFunding,
                            iconColor: Color(hex: "174EA6"),
                            isSelected: selectedItem == "crowdfunding"
                        ) {
                            selectedItem = "crowdfunding"
                            onSelect("crowdfunding")
                        }

                        ModernDrawerItem(
                            icon: "repeat",
                            title: AppStrings.standingInstructions,
                            iconColor: .teal,
                            isSelected: selectedItem == "si"
                        ) {
                            selectedItem = "si"
                            onSelect("si")
                        }
                    }
                    
                    // PARRAINAGE Section
                    MenuSection(title: AppStrings.sponsorSection) {
                        ModernDrawerItem(
                            icon: "person.2.fill",
                            title: AppStrings.sponsoredWallets,
                            iconColor: .pink,
                            isSelected: selectedItem == "sponsored"
                        ) {
                            selectedItem = "sponsored"
                            onSelect("sponsored")
                        }
                        
                        ModernDrawerItem(
                            icon: "person.3.fill",
                            title: AppStrings.afficherMesParrains,
                            iconColor: .cyan,
                            isSelected: selectedItem == "sponsoring"
                        ) {
                            selectedItem = "sponsoring"
                            onSelect("sponsoring")
                        }
                    }
                    
                    // GESTION DU PORTEFEUILLE Section
                    MenuSection(title: AppStrings.walletManagement) {
                        ModernDrawerItem(
                            icon: "gauge.with.needle.fill",
                            title: AppStrings.mesLimites,
                            iconColor: .yellow,
                            isSelected: selectedItem == "limits"
                        ) {
                            selectedItem = "limits"
                            onSelect("limits")
                        }
                        
                        ModernDrawerItem(
                            icon: "doc.text.fill",
                            title: AppStrings.demandeDeMiniReleve,
                            iconColor: .blue,
                            isSelected: selectedItem == "statement"
                        ) {
                            selectedItem = "statement"
                            onSelect("statement")
                        }
                        
                        ModernDrawerItem(
                            icon: "xmark.circle.fill",
                            title: AppStrings.desactiverMonCompte,
                            iconColor: .red,
                            isSelected: selectedItem == "deactivate"
                        ) {
                            selectedItem = "deactivate"
                            onSelect("deactivate")
                        }
                        
                        ModernDrawerItem(
                            icon: "hourglass",
                            title: AppStrings.transactionAValider,
                            iconColor: .orange,
                            isSelected: selectedItem == "pending"
                        ) {
                            selectedItem = "pending"
                            onSelect("pending")
                        }
                        
                        ModernDrawerItem(
                            icon: "link.circle.fill",
                            title: AppStrings.comptesBancaires,
                            iconColor: .purple,
                            isSelected: selectedItem == "linked"
                        ) {
                            selectedItem = "linked"
                            onSelect("linked")
                        }
                    }
                    
                    // PARAMETRE Section
                    MenuSection(title: AppStrings.parametre) {
                        ModernDrawerItem(
                            icon: "lock.rotation.open",
                            title: AppStrings.changerLeCodePin,
                            iconColor: .indigo,
                            isSelected: selectedItem == "pinChange"
                        ) {
                            selectedItem = "pinChange"
                            onSelect("pinChange")
                        }
                        
                        HStack {
                            ModernDrawerItem(
                                icon: "faceid",
                                title: AppStrings.connexionBiometrique,
                                iconColor: .green,
                                isSelected: selectedItem == "biometric"
                            ) {
                                selectedItem = "biometric"
                                onSelect("biometric")
                            }
                            
                            if UserDataManager.shared.isBiometricEnabled() {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(.trailing, 24)
                            }
                        }
                    }
                    
                    // ASSISTANCE Section
                    MenuSection(title: AppStrings.helpSection) {
                        ModernDrawerItem(
                            icon: "text.bubble.fill",
                            title: AppStrings.ecrireUnCommentaire,
                            iconColor: .blue,
                            isSelected: selectedItem == "comment"
                        ) {
                            selectedItem = "comment"
                            onSelect("comment")
                        }
                        
                        ModernDrawerItem(
                            icon: "exclamationmark.triangle.fill",
                            title: AppStrings.declarerUnIncident,
                            iconColor: .orange,
                            isSelected: selectedItem == "complaint"
                        ) {
                            selectedItem = "complaint"
                            onSelect("complaint")
                        }
                        
                        ModernDrawerItem(
                            icon: "phone.fill",
                            title: "Contactez-nous",
                            iconColor: .green,
                            isSelected: selectedItem == "contact"
                        ) {
                            selectedItem = "contact"
                            makePhoneCall(phoneNumber: "+224612008699")
                        }
                        
                        ModernDrawerItem(
                            icon: "doc.plaintext.fill",
                            title: AppStrings.terms,
                            iconColor: .gray,
                            isSelected: selectedItem == "terms"
                        ) {
                            selectedItem = "terms"
                            onSelect("complaint")
                        }
                        
                        ModernDrawerItem(
                            icon: "questionmark.circle.fill",
                            title: AppStrings.faq,
                            iconColor: .cyan,
                            isSelected: selectedItem == "FAQ"
                        ) {
                            selectedItem = "FAQ"
                            onSelect("FAQ")
                        }
                    }
                    
                    // Logout - Special styling
                    Divider()
                        .padding(.vertical, 8)
                    
                    Button(action: {
                        selectedItem = "logout"
                        onSelect("logout")
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                            
                            Text(AppStrings.buttonTitle(AppStrings.logout))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            selectedItem == "logout" ?
                            Color.red.opacity(0.08) : Color.clear
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func makePhoneCall(phoneNumber: String) {
        let cleanedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        
        guard let url = URL(string: "tel://\(cleanedNumber)") else {
            //print("Invalid phone number")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    //print("Phone call initiated successfully")
                } else {
                    //print("Failed to initiate phone call")
                }
            }
        } else {
            //print("This device cannot make phone calls")
        }
    }
}

// MARK: - Modern Section Header
struct MenuSection<Content: View>: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            content
            
            Divider()
                .padding(.vertical, 8)
        }
    }
}

// MARK: - Modern Drawer Item
struct ModernDrawerItem: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let icon: String
    let title: String
    let iconColor: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blueH.opacity(0.08) : Color.clear)
                    .padding(.horizontal, 16)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Preview
struct ModernSideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ModernSideMenuView { selection in
            //print("Selected: \(selection)")
        }
        .frame(width: 340)
    }
}
