//
//  EMVQRPaymentData.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  EMVQRPaymentData.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//

import Foundation

struct EMVQRPaymentData {
    var tokenId: String = ""
    var originalQrCode: String = ""
    var merchantWallet: String = ""
    var merchantNumber: String = ""
    var merchantName: String = ""
    var bankCode: String = ""
    var amount: Double = 0.0
    var currency: String = "GNF"
    var expiresAt: Date?
    
    
    var formattedExpiration: String {
        guard let expiresAt = expiresAt else { return AppStrings.nA }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: expiresAt)
    }

    
    var isValid: Bool {
        return !tokenId.isEmpty &&
               !originalQrCode.isEmpty &&
               !merchantWallet.isEmpty &&
               !merchantName.isEmpty &&
               amount > 0
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: amount)) ?? "0") \(currency)"
    }
}

