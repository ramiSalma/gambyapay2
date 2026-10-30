//
//  DSDBillTypesView.swift
//  DiamaPay
//
//  Created by bits dev team on 24/11/2025.
//


//
//  DSDBillTypesView.swift
//  DiamaPay
//
//  DSD Bill Types Selection
//

import SwiftUI

struct DSDBillTypesView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToPrimoArrivant = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.dsdBills, headerColor: Color(hex: "174EA6"))
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Primo Arrivant Card
                        BillTypeCard(
                            title: AppStrings.primoArrivant,
                            subtitle: AppStrings.paiementPourPrimoArrivant,
                            icon: "car.fill",
                            color: .green
                        ) {
                            navigateToPrimoArrivant = true
                        }
                        
                        // Add more bill types here as they become available
                        // BillTypeCard(title: "Type 2", ...)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: DSDPaymentView(),
                isActive: $navigateToPrimoArrivant
            ) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.blueH.opacity(0.3))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(AppStrings.facturesDsd)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.blueH)
    }
}

// MARK: - Bill Type Card Component
struct BillTypeCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with colored background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.buttonTitle(title))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct DSDBillTypesView_Previews: PreviewProvider {
    static var previews: some View {
        DSDBillTypesView()
    }
}
