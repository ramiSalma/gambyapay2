//
//  BalanceResponse 2.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


// BalanceResponse.swift
struct BalanceResponsea: Codable {
    let code: String
    let message: String?
    let data: BalanceInfo?
    
    struct BalanceInfo: Codable {
        let accountNumber: String
        let availableBalance: String
        let currency: String
        let accountType: String?
    }
}
