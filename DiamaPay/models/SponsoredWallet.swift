//
//  SponsoredWallet.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


import Foundation

// MARK: - SponsoredWallet
struct SponsoredWallet: Codable, Identifiable {
    var id = UUID()
    var walletNumber: String = ""
    var walletNumberSponsored: String = ""
    var userName: String = ""
    var userNameSponsored: String = ""
    var phoneNumber: String = ""
    var phoneNumberSponsored: String = ""
    var dailyLimit: String = ""
    var monthlyLimit: String = ""
    var startDate: String = ""
    var endDate: String = ""
    var bankCode: String = ""
    var bankWording: String = ""
    var bankCodeSponsored: String = ""
    var creationTs: String = ""
    
    enum CodingKeys: String, CodingKey {
        case walletNumber
        case walletNumberSponsored
        case userName
        case userNameSponsored
        case phoneNumber
        case phoneNumberSponsored
        case dailyLimit
        case monthlyLimit
        case startDate
        case endDate
        case bankCode
        case bankWording
        case bankCodeSponsored
        case creationTs
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        walletNumber = try container.decodeIfPresent(String.self, forKey: .walletNumber) ?? ""
        walletNumberSponsored = try container.decodeIfPresent(String.self, forKey: .walletNumberSponsored) ?? ""
        userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        userNameSponsored = try container.decodeIfPresent(String.self, forKey: .userNameSponsored) ?? ""
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        phoneNumberSponsored = try container.decodeIfPresent(String.self, forKey: .phoneNumberSponsored) ?? ""
        dailyLimit = try container.decodeIfPresent(String.self, forKey: .dailyLimit) ?? ""
        monthlyLimit = try container.decodeIfPresent(String.self, forKey: .monthlyLimit) ?? ""
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate) ?? ""
        endDate = try container.decodeIfPresent(String.self, forKey: .endDate) ?? ""
        bankCode = try container.decodeIfPresent(String.self, forKey: .bankCode) ?? ""
        bankWording = try container.decodeIfPresent(String.self, forKey: .bankWording) ?? ""
        bankCodeSponsored = try container.decodeIfPresent(String.self, forKey: .bankCodeSponsored) ?? ""
        creationTs = try container.decodeIfPresent(String.self, forKey: .creationTs) ?? ""
    }
}
