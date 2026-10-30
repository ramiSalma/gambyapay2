import SwiftUI
import UIKit

@main
struct DiamaPayApp: App {
    @StateObject private var localization = AppLanguageStore.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
                .environment(\.locale, Locale(identifier: localization.language.rawValue))
                .environment(\.layoutDirection, localization.language.layoutDirection)
                .modifier(AppTranslationModifier())
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // ✅ JAILBREAK DETECTION - Check on app launch
        performJailbreakCheck()
        
        setupAppLifecycleNotifications()
        return true
    }
    
    private func setupAppLifecycleNotifications() {
        // Listen for app going to background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // Listen for app terminating
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        // ✅ Listen for app becoming active (returns from background)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        //print("📱 App entering background - setting logout flag")
        UserDefaults.standard.set(true, forKey: "app_was_closed")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func appWillTerminate() {
        //print("📱 App terminating - setting logout flag")
        UserDefaults.standard.set(true, forKey: "app_was_closed")
        UserDefaults.standard.synchronize()
    }
    
    // ✅ NEW: Check jailbreak when app returns from background
    @objc private func appDidBecomeActive() {
        //print("📱 App became active - checking security")
        performJailbreakCheck()
    }
    
    // MARK: - Jailbreak Detection
    private func performJailbreakCheck() {
        #if !DEBUG
        // Only check in RELEASE builds (not during development)
        if JailbreakDetector.shared.isJailbroken() {
            //print("❌ SECURITY: Jailbroken device detected!")
            
            // Show alert after a short delay to ensure UI is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showJailbreakAlert()
            }
        } else {
            //print("✅ SECURITY: Device is secure (not jailbroken)")
        }
        #else
        //print("⚠️ DEBUG MODE: Jailbreak detection skipped (development build)")
        #endif
    }
    
    private func showJailbreakAlert() {
        // Get the key window's root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            //print("❌ Could not get root view controller, forcing exit")
            exit(0)
            return
        }
        
        // Find the topmost presented view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        // Show jailbreak alert
        JailbreakDetector.shared.showJailbreakAlert(on: topController) {
            // App will exit after user dismisses alert
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
