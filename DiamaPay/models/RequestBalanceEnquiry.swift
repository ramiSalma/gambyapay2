//
//  RequestBalanceEnquiry.swift
//  DiamaPay
//
//  Created by Bits on 18/9/2025.
//


struct RequestBalanceEnquiry: Codable {
    let walletNumber: String
    let phoneNumber: String?
    let source: String
    let pin: String
    let bank: String?
    let requestId: String
    let requestDate: String
    let entityId: String
}