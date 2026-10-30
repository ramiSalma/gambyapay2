//
//  InactivityModifier.swift
//  DiamaPay
//
//  Created by bits dev team on 21/11/2025.
//


import SwiftUI

struct InactivityModifier: ViewModifier {
    @ObservedObject var manager: InactivityManager
    @ObservedObject var authManager: AuthenticationManager
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        manager.resetTimer()
                    }
            )
            .onTapGesture {
                manager.resetTimer()
            }
            .onReceive(NotificationCenter.default.publisher(for: .inactivityLogout)) { _ in
                DispatchQueue.main.async {
                    authManager.logout()
                }
            }
    }
}
