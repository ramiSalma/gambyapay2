//
//  SplashView.swift
//  DiamaPay
//
//  Created by Bits on 17/9/2025.
//


import SwiftUI

struct SplashView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @State private var isActive = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack {
                Image("BITSLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 156)

                    .foregroundColor(.black)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            LoginView() 
        }
    }
}
