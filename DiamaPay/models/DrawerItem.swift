//
//  DrawerItem.swift
//  DiamaPay
//
//  Created by Bits on 18/9/2025.
//

import SwiftUI

struct DrawerItem: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    var icon: String
    var title: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Handle biometric icon dynamically based on device
                if icon == "biometric" {
                    Image(systemName: BiometricHelper.getBiometricType().icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                        .foregroundColor(Color(hex: "174EA6"))
                }
                // Try to load system icon first, otherwise fallback to asset
                else if UIImage(systemName: icon) != nil {
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .regular))
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(hex: "174EA6"))
                } else {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(hex: "174EA6"))
                }
                
                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "394353"))
                    .padding(.leading, 12)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                
                Spacer()
                
            }
            .frame(minHeight: 46)
            .padding(.vertical, 1)
            .padding(.horizontal, 22)
        }
        .buttonStyle(.plain)
    }
}
