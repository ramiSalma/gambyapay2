//
//  RequestWalletToAccount.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  RequestWalletToAccount.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import Foundation

struct RequestWalletToAccount: Codable {
    var walletNumber: String?
    var phoneNumber: String?
    var source: String?
    var srcBank: String?
    var desAccount: String?
    var desBank: String?
    var amount: String?
    var currency: String?
    var reason: String?
    var pin: String?
    var authCode: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
    var sponsorWallet: String?
}