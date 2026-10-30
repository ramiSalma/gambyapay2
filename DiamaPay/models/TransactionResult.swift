//
//  TransactionResult.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//


import Foundation

// MARK: - TransactionResult Model (Missing from your code)
struct TransactionResult: Codable {
    let trxRef: String?
    let authDate: String?
    let currency: String?
    let sign: String?
    let status: String?
    let details: String?
    let openBal: String?
    let closeBal: String?
    let type: String?
    let amount: String?
    
    // Initialize from dictionary (for API response conversion)
    init(from dict: [String: Any]) {
        self.trxRef = dict["trxRef"] as? String
        self.authDate = dict["authDate"] as? String
        self.currency = dict["currency"] as? String
        self.sign = dict["sign"] as? String
        self.status = dict["status"] as? String
        self.details = dict["trxDetails"] as? String
        self.openBal = dict["openBalance"] as? String
        self.closeBal = dict["closeBalance"] as? String
        self.type = dict["type"] as? String
        self.amount = dict["amount"] as? String
    }
}
