//
//  FeeCalculationRequest.swift
//  DiamaPay
//
//  Created by Bits on 28/9/2025.
//




import Foundation

struct FeeCalculationRequest: Codable {
    var processingCode: String = ""
    var bankCode: String = ""
    var actionCode: String = ""
    var currencyCode: String = ""
    var transactionAmount: Double = 0.0
    var walletProductCode: String = ""
    var walletType: String = ""
    var origin: String = ""
    var messageType: String = "ON_US"
}

/// Customer API fee quote (the legacy fee-engine fields are not accepted here).
struct WalletFeeQuoteRequest: Codable {
    let walletNumber: String
    let phoneNumber: String
    let source: String
    let bank: String
    let currency: String
    let amount: String
    let destination: String
    let transactionType: String
    let destinationBank: String
    let requestId: String
    let requestDate: String
    let entityId: String
}


extension WalletFeeQuoteRequest {
    static func current(amount: Double, destination: String, transactionType: String,
                        destinationBank: String = "00100") -> WalletFeeQuoteRequest {
        let user = UserDataManager.shared
        let wallet = user.getWalletNumber()
        let bank = user.getBankCode()
        return WalletFeeQuoteRequest(
            walletNumber: wallet, phoneNumber: user.getPhoneNumber(),
            source: wallet.isEmpty ? "P" : "W", bank: bank.isEmpty ? "00100" : bank,
            currency: "270", amount: String(amount), destination: destination,
            transactionType: transactionType,
            destinationBank: destinationBank.isEmpty ? "00100" : destinationBank,
            requestId: DateFormatter.with(format: "yyMMdd").string(from: Date()) + String(format: "%06d", Int.random(in: 0...999999)),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: user.getUserCode()
        )
    }
}
