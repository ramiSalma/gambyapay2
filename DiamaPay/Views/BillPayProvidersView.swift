//
//  BillPayProvidersView.swift
//  DiamaPay
//
//  Bill Payment Providers Selection
//

import SwiftUI

struct BillPayProvidersView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.rechargeBillProviders, headerColor: Color(hex: "174EA6"))
                
                ScrollView {
                    VStack(spacing: 34) {
                        NavigationLink(destination: NawecServiceView(service: .water)) {
                            nawecRow("NAWEC Water")
                        }
                        NavigationLink(destination: NawecServiceView(service: .cashPower)) {
                            nawecRow("NAWEC Cash Power")
                        }
                        NavigationLink(destination: DSDBillTypesView()) {
                            nawecRow("DSD")
                        }
                        Text(AppStrings.rechargeMoreBillers)
                            .font(.system(size: 14, weight: .medium))
                            .italic()
                            .foregroundColor(Color(hex: "545D69"))
                            .padding(.top, 24)
                    }
                    .padding(.horizontal, 23)
                    .padding(.top, 21)
                    .padding(.bottom, 24)
                }
                .background(Color(hex: "F5F5F5"))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)

    }
    private func nawecRow(_ title: String) -> some View {
        HStack(spacing: 20) {
            Text("BITS")
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(Color(hex: "174EA6"))
                .frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
                Text(AppStrings.rechargePayBills)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "545D69"))
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "545D69"))
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, minHeight: 84)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.16), radius: 3, x: 0, y: 2)
    }

}

// MARK: - Provider Card Component
struct ProviderCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    let subtitle: String
    let icon: String  // Can be SF Symbol name, image URL, or asset name
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon - No background circle for assets
                if let _ = UIImage(named: icon) {
                    // Local asset image
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                } else if icon.hasPrefix("http://") || icon.hasPrefix("https://") {
                    // Remote image
                    AsyncImage(url: URL(string: icon)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 56, height: 56)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 56, height: 56)
                        case .failure:
                            // Fallback to colored circle with icon
                            ZStack {
                                Circle()
                                    .fill(color.opacity(0.1))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "photo")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(color)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // SF Symbol with colored background
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(color)
                    }
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
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
struct BillPayProvidersView_Previews: PreviewProvider {
    static var previews: some View {
        BillPayProvidersView()
    }
}
