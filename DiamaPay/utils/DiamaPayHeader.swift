//
//  DiamaPayHeader.swift
//  DiamaPay
//
//  Created by Bits on 21/10/2025.
//


import SwiftUI
import SwiftUI

struct DiamaPayHeader: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    var headerColor: Color
    @Environment(\.dismiss) private var dismiss
    var onBackToHome: (() -> Void)?
    
    init(title: String = "GambiaPay", headerColor: Color = .greenH, onBackToHome: (() -> Void)? = nil) {
        self.title = title
        self.headerColor = headerColor
        self.onBackToHome = onBackToHome
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [headerColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            
            HStack {
                Button(action: {
                    if let onBackToHome = onBackToHome {
                        onBackToHome()
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(8)
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
    }
}
