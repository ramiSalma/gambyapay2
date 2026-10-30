//
//  PinVerificationService.swift
//  DiamaPay
//
//  Created by Bits on 10/3/2026.
//


//
//  PinVerificationService.swift
//  DiamaPay
//

import Foundation

class PinVerificationService {
    
    static func verify(
        pin: String,
        onSuccess: @escaping (String) -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        guard pin.isValidWalletPIN else {
            onFailure(AppStrings.pinMustContainExactly4Digits)
            return
        }

        let userDataManager = UserDataManager.shared
        
        var request = RequestCheckPin()
        request.walletNumber = userDataManager.getWalletNumber()
        request.pin = pin
        request.source = "W"
        request.entityId = userDataManager.getUserCode()
        request.bank = userDataManager.getBankCode().isEmpty ? "00100" : userDataManager.getBankCode()
        
        let idFormatter = DateFormatter()
        idFormatter.dateFormat = "yyMMdd"
        let datePrefix = idFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        request.requestId = datePrefix + randomDigits
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        request.requestDate = dateFormatter.string(from: Date())
        
        APIClient.shared.checkPin(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        onSuccess(pin)
                    } else {
                        onFailure(response.message ?? "Code PIN incorrect")
                    }
                case .failure(let error):
                    onFailure((error as? APIError)?.message ?? "Erreur de connexion")
                }
            }
        }
    }
}
