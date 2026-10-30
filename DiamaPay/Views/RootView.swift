import SwiftUI

enum BottomNavigationTab: Hashable {
    case home, sponsors, qr, limits, settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .sponsors: return "Sponsors"
        case .qr: return "QR"
        case .limits: return "Limits"
        case .settings: return "Settings"
        }
    }
}

private struct BottomNavigationActionKey: EnvironmentKey {
    static let defaultValue: ((BottomNavigationTab) -> Void)? = nil
}

private struct BottomNavigationSelectionKey: EnvironmentKey {
    static let defaultValue: BottomNavigationTab? = nil
}

extension EnvironmentValues {
    var navigateBottomTab: ((BottomNavigationTab) -> Void)? {
        get { self[BottomNavigationActionKey.self] }
        set { self[BottomNavigationActionKey.self] = newValue }
    }

    var bottomNavigationSelection: BottomNavigationTab? {
        get { self[BottomNavigationSelectionKey.self] }
        set { self[BottomNavigationSelectionKey.self] = newValue }
    }
}

struct RootView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var inactivityManager = InactivityManager()
    @State private var navigationPath = NavigationPath()
    @State private var navigationRevision = UUID()
    @State private var bottomTab: BottomNavigationTab?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if authManager.showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                authManager.checkAuthenticationStatus()
                            }
                        }
                } else if authManager.isAuthenticated {
                    DiamaPayHomeView()
                        .environmentObject(authManager)
                        .modifier(InactivityModifier(manager: inactivityManager, authManager: authManager))
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: BottomNavigationTab.self) { tab in
                Group {
                    switch tab {
                    case .home: DiamaPayHomeView()
                    case .sponsors: SponsoringWalletListView()
                    case .qr: QRPaymentView()
                    case .limits: CheckLimitView()
                    case .settings: SettingsView(onReturnHome: { selectBottomTab(.home) })
                    }
                }
                .environmentObject(authManager)
                .modifier(InactivityModifier(manager: inactivityManager, authManager: authManager))
            }
        }
        .id(navigationRevision)
        .environment(\.navigateBottomTab, selectBottomTab)
        .environment(\.bottomNavigationSelection, navigationPath.isEmpty ? nil : bottomTab)
        .onChange(of: authManager.isAuthenticated) { newValue in
            if !newValue {
                //print("🔄 Redirecting to login - clearing navigation stack")
                // Clear navigation path to go back to root
                navigationPath = NavigationPath()
                bottomTab = nil
            }
        }
        .id(authManager.isAuthenticated) // Force view refresh when auth state changes
    }

    private func selectBottomTab(_ tab: BottomNavigationTab) {
        bottomTab = tab
        navigationPath = tab == .home ? NavigationPath() : NavigationPath([tab])
        // Recreate the stack to clear legacy isActive links and nested stacks too.
        navigationRevision = UUID()
    }

}
