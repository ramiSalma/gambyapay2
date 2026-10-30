import Foundation
import Security

class UserDataManager {
    
    static let shared = UserDataManager()
       private init() {}
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainHelper()
    /// Mark an advertisement as viewed
       func markAdvertisementAsViewed(adId: String) {
           var ads = loadAdvertisements()
           
           guard let index = ads.firstIndex(where: { $0.id == adId }) else {
               return
           }
           
           // Update the viewed status
           var updatedAd = ads[index]
           updatedAd.viewed = true
           ads[index] = updatedAd
           
           // Save back to storage
           saveAdvertisements(ads)
           
       }
       

    func clearSession() {
        
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "token_timestamp")
        UserDefaults.standard.removeObject(forKey: "pin_for_api")
       
        
    }
    
       /// Save advertisements array to UserDefaults
       private func saveAdvertisements(_ ads: [Advertisement]) {
           if let encoded = try? JSONEncoder().encode(ads) {
               UserDefaults.standard.set(encoded, forKey: "savedAdvertisements")
           } else {
           }
       }
       
       /// Check if an advertisement has been viewed
       func isAdvertisementViewed(adId: String) -> Bool {
           let ads = loadAdvertisements()
           return ads.first(where: { $0.id == adId })?.viewed == true
       }
       
       /// Get count of unviewed advertisements
       func getUnviewedAdsCount() -> Int {
           let ads = loadAdvertisements()
           return ads.filter { $0.viewed != true }.count
       }
       
       /// Mark all advertisements as viewed
       func markAllAdvertisementsAsViewed() {
           var ads = loadAdvertisements()
           
           for index in ads.indices {
               ads[index].viewed = true
           }
           
           saveAdvertisements(ads)
       }
       
       /// Reset all advertisements viewed status (for testing)
       func resetAllAdvertisementsViewedStatus() {
           var ads = loadAdvertisements()
           
           for index in ads.indices {
               ads[index].viewed = false
           }
           
           saveAdvertisements(ads)
       }
    func isBiometricEnabled() -> Bool {
            let phoneNumber = getPhoneNumber()
            guard !phoneNumber.isEmpty else { return false }
            return UserDefaults.standard.bool(forKey: "biometric_enabled_\(phoneNumber)")
        }
        
        func setUseBiometric(_ enabled: Bool) {
            let phoneNumber = getPhoneNumber()
            guard !phoneNumber.isEmpty else { return }
            UserDefaults.standard.set(enabled, forKey: "biometric_enabled_\(phoneNumber)")
            
            if !enabled {
                // Clear stored credentials if disabling
                deleteBiometricCredentials()
            }
        }
        
        func isBiometricLoginAvailable() -> Bool {
            let phoneNumber = getPhoneNumber()
            guard !phoneNumber.isEmpty else { return false }
            
            // Check if biometric is enabled and credentials are stored
            return isBiometricEnabled() &&
                   KeychainManager.shared.retrieve(for: "biometric_\(phoneNumber)") != nil
        }
        
        func saveBiometricCredentials(pin: String) -> Bool {
            let phoneNumber = getPhoneNumber()
            guard !phoneNumber.isEmpty else { return false }
            
            return KeychainManager.shared.save(pin, for: "biometric_\(phoneNumber)")
        }
        
        func validateBiometricCredentials() -> Bool {
            // Check if user is logged in and token is valid
            guard isLoggedIn() && !isTokenExpired() else {
                return false
            }
            
            // Check if biometric credentials exist
            let phoneNumber = getPhoneNumber()
            guard !phoneNumber.isEmpty else { return false }
            
            return KeychainManager.shared.retrieve(for: "biometric_\(phoneNumber)") != nil
        }
        
        func deleteBiometricCredentials() {
            let phoneNumber = getPhoneNumber()
            guard !phoneNumber.isEmpty else { return }
            
            _ = KeychainManager.shared.delete(for: "biometric_\(phoneNumber)")
        }
    // MARK: - Keychain Access
    func updateToken(_ newToken: String, durationMs: Int? = nil) {
        keychain.save(newToken, forKey: Keys.token)
        
        if let duration = durationMs, duration > 0 {
            let currentTime = Date().timeIntervalSince1970 * 1000
            let expiryTime = currentTime + Double(duration)
            userDefaults.set(expiryTime, forKey: Keys.tokenTimeout)
        }
    }
    func getBankWording() -> String {
        return userDefaults.string(forKey: Keys.bankWording) ?? ""
    }

    
    // MARK: - Keys
    private struct Keys {
        static let userCode = "user_code"
        static let name = "name"
        static let phoneNumber = "phone_number"
        static let email = "email"
        static let bankCode = "bank_code"
        static let bankWording = "bank_wording"
        static let branchCode = "branch_code"
        static let walletNumber = "wallet_number"
        static let userType = "user_type"
        static let type = "type"
        static let respCode = "resp_code"
        static let deviceIdentifier = "device_identifier"
        static let requiresPinChange = "requires_pin_change"
        static let tokenTimeout = "token_timeout"
        static let useBiometric = "use_biometric"
        static let availableBalance = "available_balance"
        static let totalBalance = "total_balance"
        static let currency = "currency"
        static let formattedBalance = "formatted_balance"
        
        // Keychain keys (for sensitive data)
        static let token = "auth_token"
        static let pinForAPI = "pin_for_api"
    }
    
    // MARK: - Save User Data
    func saveUserData(from authResponse: AuthResponse) {
        
        // Save token to keychain (secure storage)
        if let token = authResponse.token?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty {
            keychain.save(token, forKey: Keys.token)
            
            // Calculate token expiry
            let tokenDurationMs = authResponse.tokenTimeout ?? 0
            let currentTime = Date().timeIntervalSince1970 * 1000
            let expiryTime: Double
            
            if tokenDurationMs > 0 {
                expiryTime = currentTime + Double(tokenDurationMs)
            } else {
                // Default to 24 hours
                expiryTime = currentTime + (24 * 60 * 60 * 1000)
            }
            
            userDefaults.set(expiryTime, forKey: Keys.tokenTimeout)
        } else {
        }
        
        // Save basic user information to UserDefaults
        saveIfNotNil(authResponse.userCode, forKey: Keys.userCode)
        saveIfNotNil(authResponse.name, forKey: Keys.name)
        saveIfNotNil(authResponse.phoneNumber, forKey: Keys.phoneNumber)
        saveIfNotNil(authResponse.email, forKey: Keys.email)
        saveIfNotNil(authResponse.bankCode, forKey: Keys.bankCode)
        saveIfNotNil(authResponse.bankWording, forKey: Keys.bankWording)
        saveIfNotNil(authResponse.branchCode, forKey: Keys.branchCode)
        saveIfNotNil(authResponse.walletnumber, forKey: Keys.walletNumber)
        saveIfNotNil(authResponse.userType, forKey: Keys.userType)
        saveIfNotNil(authResponse.type, forKey: Keys.type)
        saveIfNotNil(authResponse.respCode, forKey: Keys.respCode)

        // Provider data is included in the authenticated login response. Keep a
        // local copy so screens can still populate when the provider endpoint
        // is restricted for the signed-in user.
        if let providerList = authResponse.providerList,
           let data = try? JSONEncoder().encode(providerList) {
            userDefaults.set(data, forKey: "mobile_money_providers")
        }
        
        if let serverDeviceId = authResponse.deviceIdentifier, !serverDeviceId.isEmpty {
            userDefaults.set(serverDeviceId, forKey: Keys.deviceIdentifier)
        } else {
            let fallbackId = APIClient.getDeviceId()
            userDefaults.set(fallbackId, forKey: Keys.deviceIdentifier)
        }
        
        if let ads = authResponse.ads, !ads.isEmpty {
            do {
                let data = try JSONEncoder().encode(ads)
                userDefaults.set(data, forKey: "advertisements")
            } catch {
            }
        }

        
        userDefaults.set(authResponse.requiresPinChange ?? false, forKey: Keys.requiresPinChange)
        
        userDefaults.synchronize()
        
        // Verify save
        let savedToken = getToken()
        if savedToken.isEmpty {
        } else {
        }
    }

    func loadMobileMoneyProviders() -> [Provider] {
        guard let data = userDefaults.data(forKey: "mobile_money_providers"),
              let items = try? JSONDecoder().decode([AnyCodable].self, from: data) else { return [] }
        return items.compactMap { item in
            guard let values = item.value as? [String: Any] else { return nil }
            func string(_ keys: String...) -> String? {
                for key in keys {
                    if let value = values[key], !(value is NSNull) { return String(describing: value) }
                }
                return nil
            }
            return Provider(
                id: string("id", "providerId"),
                name: string("label", "name", "providerName"),
                code: string("code", "providerCode", "id"),
                type: string("type", "providerType")
            )
        }
    }
    
    func loadAdvertisements() -> [Advertisement] {
        if let data = userDefaults.data(forKey: "advertisements") {
            do {
                let ads = try JSONDecoder().decode([Advertisement].self, from: data)
                return ads
            } catch {
            }
        }
        return []
    }

    private func saveIfNotNil(_ value: String?, forKey key: String) {
        if let value = value {
            userDefaults.set(value, forKey: key)
        }
    }
    
    // MARK: - Save PIN for API calls
    func savePinForAPI(_ pin: String) {
        keychain.save(pin, forKey: Keys.pinForAPI)
    }
    
    // MARK: - Getters
    func getToken() -> String {
        return keychain.load(forKey: Keys.token) ?? ""
    }
    
    func getUserCode() -> String {
        return userDefaults.string(forKey: Keys.userCode) ?? ""
    }
    
    func getUserName() -> String {
        return userDefaults.string(forKey: Keys.name) ?? "User"
    }
    
    func getPhoneNumber() -> String {
        return userDefaults.string(forKey: Keys.phoneNumber) ?? ""
    }
    
    func getEmail() -> String {
        return userDefaults.string(forKey: Keys.email) ?? ""
    }
    
    func getBankCode() -> String {
        return userDefaults.string(forKey: Keys.bankCode) ?? ""
    }
    
    func getWalletNumber() -> String {
        return userDefaults.string(forKey: Keys.walletNumber) ?? ""
    }
    
    func getDeviceIdentifier() -> String {
        return userDefaults.string(forKey: Keys.deviceIdentifier) ?? ""
    }
    
    func getPinForAPI() -> String {
        return keychain.load(forKey: Keys.pinForAPI) ?? ""
    }
    
    func getTokenTimeout() -> Double {
        return userDefaults.double(forKey: Keys.tokenTimeout)
    }
    
    func requiresPinChange() -> Bool {
        return userDefaults.bool(forKey: Keys.requiresPinChange)
    }
    
    // MARK: - Authentication Status
    func isLoggedIn() -> Bool {
        let token = getToken()
        let hasToken = !token.isEmpty
        let tokenNotExpired = !isTokenExpired()
        let hasUserData = !getUserCode().isEmpty
        
        let loggedIn = hasToken && tokenNotExpired && hasUserData
  
        
        return loggedIn
    }
    
    func isTokenExpired() -> Bool {
        let tokenTimeout = getTokenTimeout()
        let currentTime = Date().timeIntervalSince1970 * 1000
        
   
        if tokenTimeout == 0 {
            return false
        }
        
        let expired = currentTime > tokenTimeout
        
        if expired {
            let timeOverdue = currentTime - tokenTimeout
        } else {
            let timeRemaining = tokenTimeout - currentTime
        }
        
        return expired
    }
    
   
    func saveWalletBalance(availableAmount: Double, totalAmount: Double, currency: String) {
        let displayCurrency = mapCurrencyCode(currency)
        
        userDefaults.set(availableAmount, forKey: Keys.availableBalance)
        userDefaults.set(totalAmount, forKey: Keys.totalBalance)
        userDefaults.set(displayCurrency, forKey: Keys.currency)
        
        let formattedBalance = String(format: "%.2f %@", availableAmount, displayCurrency)
        userDefaults.set(formattedBalance, forKey: Keys.formattedBalance)
        
        userDefaults.synchronize()
    }
    
    private func mapCurrencyCode(_ currencyCode: String) -> String {
        switch currencyCode {
        case "270":
            return "GMD"
        case "324":
            return "GNF" // Guinea Franc
        case "952":
            return "XOF" // West African CFA Franc
        case "953":
            return "XPF" // CFP Franc
        case "840":
            return "USD" // US Dollar
        case "978":
            return "EUR" // Euro
        default:
            // If it's already alphabetic (like "GNF"), return as-is
            if currencyCode.range(of: "^[A-Z]{3}$", options: .regularExpression) != nil {
                return currencyCode
            }
            return "GNF"
        }
    }
    
    func getAvailableBalance() -> Double {
        return userDefaults.double(forKey: Keys.availableBalance)
    }
    
    func getTotalBalance() -> Double {
        return userDefaults.double(forKey: Keys.totalBalance)
    }
    
    func getCurrency() -> String {
        return "270"
    }
    
    func getFormattedBalance() -> String {
        return userDefaults.string(forKey: Keys.formattedBalance) ?? "0.00 GMD"
    }
    
    // MARK: - Clear Data
    func clearAllUserData() {
        
        let keys = [Keys.userCode, Keys.name, Keys.phoneNumber, Keys.email, Keys.bankCode,
                   Keys.bankWording, Keys.branchCode, Keys.walletNumber, Keys.userType,
                   Keys.type, Keys.respCode, Keys.deviceIdentifier, Keys.requiresPinChange,
                   Keys.tokenTimeout, Keys.useBiometric, Keys.availableBalance,
                   Keys.totalBalance, Keys.currency, Keys.formattedBalance]
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
        
        // Clear Keychain
        keychain.delete(forKey: Keys.token)
        keychain.delete(forKey: Keys.pinForAPI)
        
        userDefaults.synchronize()
    
        let remainingToken = getToken()
        if remainingToken.isEmpty {
        } else {
        }
    }
    
    func logout() {
        
        // Save biometric state BEFORE clearing
        let phoneNumber = getPhoneNumber()
        let biometricWasEnabled = isBiometricEnabled()
        
        clearAllUserData()
        
        // Restore phone number and biometric setting
        if !phoneNumber.isEmpty && biometricWasEnabled {
            userDefaults.set(phoneNumber, forKey: Keys.phoneNumber)
            userDefaults.set(true, forKey: "biometric_enabled_\(phoneNumber)")
        }
        
    }
    
    func clearSessionOnly() {
      
        keychain.delete(forKey: Keys.token)
        userDefaults.removeObject(forKey: Keys.tokenTimeout)
        userDefaults.removeObject(forKey: Keys.availableBalance)
        userDefaults.removeObject(forKey: Keys.totalBalance)
        userDefaults.removeObject(forKey: Keys.formattedBalance)
        
        userDefaults.synchronize()
    }
    

}

// MARK: - KeychainHelper
class KeychainHelper {
    func save(_ data: String, forKey key: String) {
        let data = Data(data.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
