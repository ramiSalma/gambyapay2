//
//  RequestDeactivateWallet.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


import Foundation

// MARK: - RequestDeactivateWallet
struct RequestDeactivateWallet: Codable {
    var bank: String? = "00100"

    var source: String?
    var phoneNumber: String?
    var walletNumber: String?
    var reason: String?
    var requestDate: String?
    var requestId: String?
    var entityId: String?
    var pin: String?
    var paymentMethod: String?
    var institution: String?
    var receiver: String?
    var beneficiaryName: String?
}
