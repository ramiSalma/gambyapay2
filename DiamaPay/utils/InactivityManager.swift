//
//  InactivityManager.swift
//  DiamaPay
//
//  Created by bits dev team on 21/11/2025.
//


import SwiftUI

class InactivityManager: ObservableObject {
    private var timer: Timer?
    private let timeout: TimeInterval = 300 // 5 minutes (300 seconds)
    
    init() {
        startTimer()
    }
    
    func resetTimer() {
        timer?.invalidate()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.triggerLogout()
        }
    }
    
    private func triggerLogout() {
        NotificationCenter.default.post(name: .inactivityLogout, object: nil)
    }
    
    deinit {
        timer?.invalidate()
    }
}

// Notification name
extension Notification.Name {
    static let inactivityLogout = Notification.Name("inactivityLogout")
}
