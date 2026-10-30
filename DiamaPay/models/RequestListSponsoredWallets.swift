//
//  RequestListSponsoredWallets.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


struct RequestListSponsoredWallets: Codable {
    var walletNumber: String?
    var phoneNumber: String?
    var source: String?
    var bank: String?
    var pin: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
    
    enum CodingKeys: String, CodingKey {
        case walletNumber
        case phoneNumber
        case source
        case bank
        case pin
        case requestId
        case requestDate
        case entityId
    }
}