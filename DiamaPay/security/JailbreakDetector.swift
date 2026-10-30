import Foundation
import UIKit

class JailbreakDetector {
    
    static let shared = JailbreakDetector()
    
    private init() {}
    
    // MARK: - Main Detection Method
    func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        // Allow simulator for development
        return false
        #else
        
        return checkSuspiciousFiles() ||
               checkSuspiciousApps() ||
               checkSystemFiles() ||
               checkCanWriteToPrivate() ||
               checkSymlinks() ||
               checkCydiaURL() ||
               checkSuspiciousEnvironment()
        #endif
    }
    
    // MARK: - Detection Methods
    
    // 1. Check for common jailbreak files
    private func checkSuspiciousFiles() -> Bool {
        let suspiciousFiles = [
            "/Applications/Cydia.app",
            "/Applications/blackra1n.app",
            "/Applications/FakeCarrier.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/WinterBoard.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/private/var/lib/apt",
            "/private/var/lib/cydia",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/private/var/stash",
            "/private/var/tmp/cydia.log",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/usr/bin/sshd",
            "/usr/libexec/sftp-server",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/bin/bash",
            "/bin/sh",
            "/usr/libexec/ssh-keysign",
            "/usr/bin/ssh",
            "/var/cache/apt",
            "/var/lib/apt",
            "/var/lib/cydia",
            "/usr/sbin/frida-server",
            "/usr/bin/cycript",
            "/usr/local/bin/cycript",
            "/usr/lib/libcycript.dylib",
            "/.installed_unc0ver",
            "/.bootstrapped_electra",
            "/usr/share/jailbreak/injectme.plist",
            "/etc/apt/sources.list.d/electra.list",
            "/etc/apt/sources.list.d/sileo.sources",
            "/.cydia_no_stash",
            "/private/var/lib/dpkg/info"
        ]
        
        for path in suspiciousFiles {
            if FileManager.default.fileExists(atPath: path) {
                #if DEBUG
                //print("⚠️ Jailbreak: Found suspicious file: \(path)")
                #endif
                return true
            }
            
            // Also check if we can access the file (sometimes exists but hidden)
            if let _ = try? String(contentsOfFile: path, encoding: .utf8) {
                #if DEBUG
                //print("⚠️ Jailbreak: Can access file: \(path)")
                #endif
                return true
            }
        }
        
        return false
    }
    
    // 2. Check if suspicious apps can be opened
    private func checkSuspiciousApps() -> Bool {
        let suspiciousApps = [
            "cydia://package/com.example.package",
            "sileo://",
            "zbra://",
            "filza://",
            "activator://",
            "undecimus://",
            "checkra1n://",
            "taurine://"
        ]
        
        for urlString in suspiciousApps {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    #if DEBUG
                    //print("⚠️ Jailbreak: Can open suspicious URL: \(urlString)")
                    #endif
                    return true
                }
            }
        }
        
        return false
    }
    
    // 3. Check if we can write to system directories
    private func checkSystemFiles() -> Bool {
        let testPath = "/private/jailbreak_test_\(UUID().uuidString).txt"
        let testString = "jailbreak test"
        
        do {
            try testString.write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            #if DEBUG
            //print("⚠️ Jailbreak: Can write to system directories")
            #endif
            return true
        } catch {
            return false
        }
    }
    
    // 4. Alternative write check to /private
    private func checkCanWriteToPrivate() -> Bool {
        let testPaths = [
            "/private/test_jb.txt",
            "/private/var/test_jb.txt"
        ]
        
        for testPath in testPaths {
            do {
                try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
                try? FileManager.default.removeItem(atPath: testPath)
                #if DEBUG
                //print("⚠️ Jailbreak: Can write to \(testPath)")
                #endif
                return true
            } catch {
                // Good - cannot write
            }
        }
        
        return false
    }
    
    // 5. Check for symbolic links (common on jailbroken devices)
    private func checkSymlinks() -> Bool {
        let paths = [
            "/Applications",
            "/Library/Ringtones",
            "/Library/Wallpaper",
            "/usr/arm-apple-darwin9",
            "/usr/include",
            "/usr/libexec",
            "/usr/share"
        ]
        
        for path in paths {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                if let type = attributes[.type] as? FileAttributeType,
                   type == .typeSymbolicLink {
                    #if DEBUG
                    //print("⚠️ Jailbreak: Found symbolic link at \(path)")
                    #endif
                    return true
                }
            } catch {
                // Path doesn't exist or can't be accessed - not jailbroken
            }
        }
        
        return false
    }
    
    // 6. Check Cydia URL scheme
    private func checkCydiaURL() -> Bool {
        if let url = URL(string: "cydia://") {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    // 7. Check suspicious environment variables
    private func checkSuspiciousEnvironment() -> Bool {
        let environment = ProcessInfo.processInfo.environment
        
        // Check for suspicious environment variables
        let suspiciousVars = [
            "DYLD_INSERT_LIBRARIES",
            "_MSSafeMode",
            "_SafeMode"
        ]
        
        for variable in suspiciousVars {
            if environment[variable] != nil {
                #if DEBUG
                //print("⚠️ Jailbreak: Found suspicious environment variable: \(variable)")
                #endif
                return true
            }
        }
        
        return false
    }
    
    // MARK: - User-Friendly Alert
    func showJailbreakAlert(on viewController: UIViewController, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: AppStrings.appareilNonSecurise,
            message: AppStrings.votreAppareilSembleEtreJailbreakePourVotreSecuriteDiamacash,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: AppStrings.quit, style: .destructive) { _ in
            completion?()
            exit(0)
        })
        
        viewController.present(alert, animated: true)
    }
}
