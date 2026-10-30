//
//  RequestApproval.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct RequestApproval: Codable {
    var phoneNumber: String? = nil

    var walletNumber: String?
    var source: String?
    var bank: String?
    var action: String?
    var pin: String?
    var transactionRef: String?
    var transactionType: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
}