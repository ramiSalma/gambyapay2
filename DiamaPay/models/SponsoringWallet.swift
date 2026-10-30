//
//  SponsoringWallet.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//
import Foundation;

// MARK: - Models (matching exact Android structure)
struct SponsoringWallet: Identifiable, Hashable, Codable {
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
    var creationTs: String = ""
    
    static let placeholder = SponsoringWallet(userName: "Sélectionner un Sponsor")
}
