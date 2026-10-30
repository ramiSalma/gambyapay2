//
//  RequestListPendingTransactions.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct RequestListPendingTransactions: Codable {
    var walletNumber: String?
    var phoneNumber: String?
    var source: String?
    var bank: String?
    var pin: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
}