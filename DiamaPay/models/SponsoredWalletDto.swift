//
//  SponsoredWalletDto.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


struct SponsoredWalletDto: Codable {
    var bankCode: String?
    var bankCodeSponsored: String?
    var phoneNumber: String?
    var phoneNumberSponsored: String?
    var source: String?
    var walletNumber: String?
    var walletNumberSponsored: String?
    var dateStart: String?
    var dateEnd: String?
    var dailyLimit: String?
    var monthlyLimit: String?
    var pin: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
    
    enum CodingKeys: String, CodingKey {
        case bankCode
        case bankCodeSponsored
        case phoneNumber
        case phoneNumberSponsored
        case source
        case walletNumber
        case walletNumberSponsored
        case dateStart
        case dateEnd
        case dailyLimit
        case monthlyLimit
        case pin
        case requestId
        case requestDate
        case entityId
    }
}
