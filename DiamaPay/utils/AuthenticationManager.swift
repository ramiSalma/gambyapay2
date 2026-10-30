import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showSplash = true
    
    init() {
        setupInactivityLogoutListener()
    }
    
    private func setupInactivityLogoutListener() {
        NotificationCenter.default.addObserver(
            forName: .inactivityLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.logout()
        }
    }
    
    func checkAuthenticationStatus() {
        let hasToken = !UserDataManager.shared.getToken().isEmpty
        let tokenValid = !UserDataManager.shared.isTokenExpired()
        let appWasClosed = UserDefaults.standard.bool(forKey: "app_was_closed")
        
    
        
        // Clear the flag
        UserDefaults.standard.set(false, forKey: "app_was_closed")
        
        // If app was closed (backgrounded), always show login
        if appWasClosed {
            isAuthenticated = false
            showSplash = false
            return
        }
        
        // If token expired, clear data and show login
        if hasToken && !tokenValid {
            UserDataManager.shared.clearSession()
            isAuthenticated = false
            showSplash = false
            return
        }
        
        // Otherwise, check if authenticated
        isAuthenticated = false
        showSplash = false
        
    }
    
    func login() {
        isAuthenticated = true
    }
    
    func logout() {
        UserDataManager.shared.clearSession()
        isAuthenticated = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Add this notification extension
extension Notification.Name {
    static let backgroundLogout = Notification.Name("backgroundLogout")
}
