//
//  BiometricHelper 2.swift
//  DiamaPay
//
//  Created by Bits on 2/10/2025.
//

import LocalAuthentication
import Foundation

class BiometricHelper {
    
    // MARK: - Biometric Type
    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID
        
        var displayName: String {
            switch self {
            case .none: return AppStrings.biometric
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            case .opticID: return "Optic ID"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "lock.fill"
            case .touchID: return "touchid"
            case .faceID: return "faceid"
            case .opticID: return "opticid"
            }
        }
    }
    
    // MARK: - Biometric Error
    enum BiometricError: LocalizedError {
        case notAvailable
        case notEnrolled
        case authenticationFailed
        case userCancel
        case userFallback
        case systemCancel
        case passcodeNotSet
        case biometryLockout
        case unknown(String)
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return AppStrings.biometricAuthenticationIsNotAvailableOnThisDevice
            case .notEnrolled:
                return AppStrings.noBiometricDataEnrolledPleaseSetUpFaceIdTouch
            case .authenticationFailed:
                return AppStrings.authenticationFailedPleaseTryAgain
            case .userCancel:
                return AppStrings.authenticationCancelled
            case .userFallback:
                return AppStrings.userChoseToUsePin
            case .systemCancel:
                return AppStrings.authenticationCancelledBySystem
            case .passcodeNotSet:
                return AppStrings.devicePasscodeNotSetPleaseSetUpAPasscodeFirst
            case .biometryLockout:
                return AppStrings.biometricAuthenticationIsLockedDueToTooManyFailedAttempts
            case .unknown(let message):
                return message
            }
        }
    }
    
    // MARK: - Biometric Status
    struct BiometricStatus {
        let isAvailable: Bool
        let type: BiometricType
        let message: String
    }
    
    // MARK: - Check Biometric Type
    static func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    static func getBiometricTypeString() -> String {
        return getBiometricType().displayName
    }
    
    // MARK: - Check Availability
    static func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    static func getBiometricStatus() -> BiometricStatus {
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canEvaluate {
            return BiometricStatus(
                isAvailable: true,
                type: getBiometricType(),
                message: AppStrings.valueIsAvailable(String(describing: getBiometricTypeString()))
            )
        } else if let error = error {
            let message = mapErrorToMessage(error)
            return BiometricStatus(
                isAvailable: false,
                type: .none,
                message: message
            )
        } else {
            return BiometricStatus(
                isAvailable: false,
                type: .none,
                message: AppStrings.biometricAuthenticationIsNotAvailable
            )
        }
    }
    
    // MARK: - Authentication
    static func authenticateWithCustomPrompt(
        reason: String = AppStrings.authenticateToAccessYourWallet,
        completion: @escaping (Result<Void, BiometricError>) -> Void
    ) {
        let context = LAContext()
        context.localizedCancelTitle = AppStrings.usePin
        context.localizedFallbackTitle = AppStrings.enterPin
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(.failure(mapError(error)))
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, authError in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    let error = mapError(authError as NSError?)
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Error Mapping
    private static func mapError(_ error: NSError?) -> BiometricError {
        guard let error = error else { return .unknown(AppStrings.unknownError2) }
        
        switch error.code {
        case LAError.authenticationFailed.rawValue:
            return .authenticationFailed
        case LAError.userCancel.rawValue:
            return .userCancel
        case LAError.userFallback.rawValue:
            return .userFallback
        case LAError.systemCancel.rawValue:
            return .systemCancel
        case LAError.passcodeNotSet.rawValue:
            return .passcodeNotSet
        case LAError.biometryNotAvailable.rawValue:
            return .notAvailable
        case LAError.biometryNotEnrolled.rawValue:
            return .notEnrolled
        case LAError.biometryLockout.rawValue:
            return .biometryLockout
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    private static func mapErrorToMessage(_ error: NSError) -> String {
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return AppStrings.biometricAuthenticationIsNotAvailableOnThisDevice
        case LAError.biometryNotEnrolled.rawValue:
            return AppStrings.noBiometricDataEnrolledPleaseSetUpFaceIdTouch
        case LAError.passcodeNotSet.rawValue:
            return AppStrings.devicePasscodeNotSetPleaseSetUpAPasscodeFirst
        default:
            return error.localizedDescription
        }
    }
    
    // MARK: - Setup Helper
    static func shouldPromptForBiometricSetup() -> Bool {
        // Only prompt if:
        // 1. Biometric is available
        // 2. User hasn't enabled it yet
        // 3. User hasn't been prompted before (or declined)
        
        guard isBiometricAvailable() else { return false }
        
        let userDataManager = UserDataManager.shared
        
        // Don't prompt if already enabled
        if userDataManager.isBiometricEnabled() {
            return false
        }
        
        // Check if user has been prompted before
        let hasBeenPrompted = UserDefaults.standard.bool(forKey: "biometric_setup_prompted")
        return !hasBeenPrompted
    }
    
    static func markBiometricSetupPrompted() {
        UserDefaults.standard.set(true, forKey: "biometric_setup_prompted")
    }
}
