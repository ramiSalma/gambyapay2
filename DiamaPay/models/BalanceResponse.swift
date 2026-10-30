//
//  BalanceResponse.swift
//  DiamaPay
//
//  Created by Bits on 18/9/2025.
//


struct BalanceResponse: Codable {
    let availableAmount: Double
    let totalAmount: Double
    let currency: String
}
