//
//  RequestWalletToWallet.swift
//  DiamaPay
//
//  Created by Bits on 28/9/2025.
//


struct RequestWalletToWallet: Codable {
    var srcWalletNumber: String = ""
    var srcPhoneNumber: String = ""
    var source: String = ""
    var srcBank: String = ""
    var amount: String = ""
    var currency: String = ""
    var desWalletNumber: String = ""
    var desPhoneNumber: String = ""
    var desBank: String = ""
    var reason: String = ""
    var pin: String = ""
    var requestId: String = ""
    var requestDate: String = ""
    var entityId: String = ""
    var sponsorWallet: String? = nil
}